param(
    [string]$Module = "all",

    [string]$Format = "text",

    [string]$OutputFile
)

$ErrorActionPreference = "Continue"
$validModules = @("all", "system", "disk", "network", "service", "process", "package", "security", "container", "log")
$validFormats = @("text", "markdown", "json")

if ($validModules -notcontains $Module) {
    Write-Error "Invalid module '$Module'. Valid values: $($validModules -join ', ')"
    exit 2
}

if ($validFormats -notcontains $Format) {
    Write-Error "Invalid format '$Format'. Valid values: $($validFormats -join ', ')"
    exit 2
}

$lines = New-Object System.Collections.Generic.List[string]
$script:WarningsCount = 0
$script:ErrorsCount = 0
$script:ReportModules = [ordered]@{}
$script:TopLevelErrors = New-Object System.Collections.Generic.List[object]

function Add-Line {
    param([string]$Text = "")
    $script:lines.Add($Text)
}

function Should-Run {
    param([string]$Name)
    return $Module -eq "all" -or $Module -eq $Name
}

function Invoke-HealthCommand {
    param(
        [string]$Name,
        [scriptblock]$Command
    )

    try {
        $previousErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Stop"
        $output = & $Command 2>&1 | Out-String
        [pscustomobject]@{
            name = $Name
            command = $Command.ToString().Trim()
            exit_code = 0
            output = $output.TrimEnd()
        }
    }
    catch {
        [pscustomobject]@{
            name = $Name
            command = $Command.ToString().Trim()
            exit_code = 1
            output = $_.Exception.Message
        }
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
}

function New-ModuleResult {
    param(
        [string]$Name,
        [object[]]$Commands = @(),
        [object[]]$Warnings = @(),
        [object[]]$Errors = @(),
        [string]$Status
    )

    $derivedWarnings = @()
    foreach ($command in $Commands) {
        if ($command.exit_code -ne 0) {
            $derivedWarnings += [pscustomobject]@{
                name = $command.name
                message = "Command returned exit code $($command.exit_code)"
            }
        }
    }
    $allWarnings = @($Warnings) + @($derivedWarnings)

    if (-not $Status) {
        if ($Errors.Count -gt 0) {
            $Status = "error"
        }
        elseif ($allWarnings.Count -gt 0) {
            $Status = "warning"
        }
        else {
            $Status = "ok"
        }
    }

    $script:WarningsCount += $allWarnings.Count
    $script:ErrorsCount += $Errors.Count

    [pscustomobject]@{
        status = $Status
        commands = @($Commands)
        warnings = @($allWarnings)
        errors = @($Errors)
    }
}

function New-SkippedModule {
    [pscustomobject]@{
        status = "skipped"
        commands = @()
        warnings = @()
        errors = @()
    }
}

function New-ModuleWarning {
    param(
        [string]$Name,
        [string]$Message
    )

    [pscustomobject]@{
        name = $Name
        message = $Message
    }
}

function Add-TextSection {
    param(
        [string]$Title,
        [object[]]$Commands
    )

    Add-Line
    if ($Format -eq "markdown") {
        Add-Line "## $Title"
        Add-Line
        Add-Line '```text'
    }
    else {
        Add-Line "== $Title =="
    }

    foreach ($command in $Commands) {
        if ($command.output) {
            Add-Line $command.output
        }
    }

    if ($Format -eq "markdown") {
        Add-Line '```'
    }
}

function Get-SystemModule {
    $commands = @(
        Invoke-HealthCommand "computer_info" { Get-ComputerInfo | Select-Object CsName, WindowsProductName, WindowsVersion, OsArchitecture }
    )
    New-ModuleResult -Name "system" -Commands $commands
}

function Get-DiskModule {
    $commands = @(
        Invoke-HealthCommand "drives" { Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free }
    )
    New-ModuleResult -Name "disk" -Commands $commands
}

function Get-ProcessModule {
    $commands = @(
        Invoke-HealthCommand "top_cpu_processes" { Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, Id, CPU, WorkingSet }
    )
    New-ModuleResult -Name "process" -Commands $commands
}

function Get-ServiceModule {
    $commands = @(
        Invoke-HealthCommand "services_not_running" { Get-Service | Where-Object Status -ne "Running" | Select-Object -First 20 Name, Status, StartType }
    )
    New-ModuleResult -Name "service" -Commands $commands
}

function Get-NetworkModule {
    $commands = @(
        Invoke-HealthCommand "listening_tcp_ports" { Get-NetTCPConnection -State Listen | Select-Object LocalAddress, LocalPort, OwningProcess }
    )
    New-ModuleResult -Name "network" -Commands $commands
}

function Get-PackageModule {
    $commands = @()
    $commands += Invoke-HealthCommand -Name "installed_packages" -Command { Get-Package | Select-Object -First 30 | Format-Table -AutoSize }
    $commands += Invoke-HealthCommand -Name "powershell_repositories" -Command { Get-PSRepository | Format-Table -AutoSize }

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $commands += Invoke-HealthCommand -Name "winget_version" -Command { winget --version }
    }
    else {
        $warnings = @(New-ModuleWarning "winget" "Command not available: winget")
        return New-ModuleResult -Name "package" -Commands $commands -Warnings $warnings
    }

    New-ModuleResult -Name "package" -Commands $commands
}

function Get-SecurityModule {
    $commands = @()
    $commands += Invoke-HealthCommand -Name "firewall_profiles" -Command { Get-NetFirewallProfile | Format-Table -AutoSize }

    if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) {
        $commands += Invoke-HealthCommand -Name "defender_status" -Command { Get-MpComputerStatus | Format-List AMServiceEnabled, AntivirusEnabled, RealTimeProtectionEnabled }
    }
    else {
        $warnings = @(New-ModuleWarning "Get-MpComputerStatus" "Command not available: Get-MpComputerStatus")
        return New-ModuleResult -Name "security" -Commands $commands -Warnings $warnings
    }

    New-ModuleResult -Name "security" -Commands $commands
}

function Get-ContainerModule {
    $commands = @()
    $warnings = @()

    if (Get-Command docker -ErrorAction SilentlyContinue) {
        $commands += Invoke-HealthCommand -Name "docker_version" -Command { docker version }
        $commands += Invoke-HealthCommand -Name "docker_ps" -Command { docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" }
    }
    else {
        $warnings += New-ModuleWarning "docker" "Command not available: docker"
    }

    if (Get-Command kubectl -ErrorAction SilentlyContinue) {
        $commands += Invoke-HealthCommand -Name "kubectl_client" -Command { kubectl version --client=true }
    }
    else {
        $warnings += New-ModuleWarning "kubectl" "Command not available: kubectl"
    }

    New-ModuleResult -Name "container" -Commands $commands -Warnings $warnings
}

function Get-LogModule {
    $commands = @()
    $commands += Invoke-HealthCommand -Name "system_errors" -Command { Get-WinEvent -FilterHashtable @{ LogName = "System"; Level = 2 } -MaxEvents 20 | Format-Table -AutoSize }
    $commands += Invoke-HealthCommand -Name "application_errors" -Command { Get-WinEvent -FilterHashtable @{ LogName = "Application"; Level = 2 } -MaxEvents 20 | Format-Table -AutoSize }
    New-ModuleResult -Name "log" -Commands $commands
}

$moduleOrder = @("system", "disk", "network", "service", "process", "package", "security", "container", "log")
foreach ($moduleName in $moduleOrder) {
    if (-not (Should-Run $moduleName)) {
        $script:ReportModules[$moduleName] = New-SkippedModule
        continue
    }

    switch ($moduleName) {
        "system" { $script:ReportModules[$moduleName] = Get-SystemModule }
        "disk" { $script:ReportModules[$moduleName] = Get-DiskModule }
        "network" { $script:ReportModules[$moduleName] = Get-NetworkModule }
        "service" { $script:ReportModules[$moduleName] = Get-ServiceModule }
        "process" { $script:ReportModules[$moduleName] = Get-ProcessModule }
        "package" { $script:ReportModules[$moduleName] = Get-PackageModule }
        "security" { $script:ReportModules[$moduleName] = Get-SecurityModule }
        "container" { $script:ReportModules[$moduleName] = Get-ContainerModule }
        "log" { $script:ReportModules[$moduleName] = Get-LogModule }
    }
}

$summaryStatus = "ok"
if ($script:ErrorsCount -gt 0) {
    $summaryStatus = "error"
}
elseif ($script:WarningsCount -gt 0) {
    $summaryStatus = "warning"
}

$hostnameValue = $env:COMPUTERNAME
if (-not $hostnameValue) {
    $hostnameValue = [System.Net.Dns]::GetHostName()
}

$metadata = New-Object PSObject
$metadata | Add-Member -MemberType NoteProperty -Name "os" -Value "Windows"
$metadata | Add-Member -MemberType NoteProperty -Name "hostname" -Value $hostnameValue
$metadata | Add-Member -MemberType NoteProperty -Name "timestamp" -Value (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$metadata | Add-Member -MemberType NoteProperty -Name "module" -Value $Module
$metadata | Add-Member -MemberType NoteProperty -Name "format" -Value $Format
$metadata | Add-Member -MemberType NoteProperty -Name "script" -Value "windows-health-check.ps1"

$modulesObject = New-Object PSObject
foreach ($moduleName in $moduleOrder) {
    $modulesObject | Add-Member -MemberType NoteProperty -Name $moduleName -Value $script:ReportModules[$moduleName]
}

$summary = New-Object PSObject
$summary | Add-Member -MemberType NoteProperty -Name "status" -Value $summaryStatus
$summary | Add-Member -MemberType NoteProperty -Name "warnings_count" -Value $script:WarningsCount
$summary | Add-Member -MemberType NoteProperty -Name "errors_count" -Value $script:ErrorsCount

$report = New-Object PSObject
$report | Add-Member -MemberType NoteProperty -Name "metadata" -Value $metadata
$report | Add-Member -MemberType NoteProperty -Name "modules" -Value $modulesObject
$report | Add-Member -MemberType NoteProperty -Name "summary" -Value $summary
$topLevelErrors = @()
foreach ($errorItem in $script:TopLevelErrors) {
    $topLevelErrors += $errorItem
}
$report | Add-Member -MemberType NoteProperty -Name "errors" -Value ([object[]]$topLevelErrors)

if ($Format -eq "json") {
    $rendered = $report | ConvertTo-Json -Depth 8
}
else {
    if ($Format -eq "markdown") {
        Add-Line "# Windows Health Check"
        Add-Line
        Add-Line "- Time: $(Get-Date)"
        Add-Line "- Module: $Module"
    }
    else {
        Add-Line "== Windows Health Check =="
        Add-Line "Time: $(Get-Date)"
        Add-Line "Module: $Module"
    }

    foreach ($moduleName in $moduleOrder) {
        $moduleResult = $script:ReportModules[$moduleName]
        if ($moduleResult.status -ne "skipped") {
            Add-TextSection -Title $moduleName -Commands $moduleResult.commands
        }
    }

    Add-Line
    if ($Format -eq "markdown") {
        Add-Line "## Done"
    }
    else {
        Add-Line "== Done =="
    }
    $rendered = ($lines -join [Environment]::NewLine)
}

if ($OutputFile) {
    $parent = Split-Path -Parent $OutputFile
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $rendered | Set-Content -Path $OutputFile -Encoding UTF8
}

Write-Output $rendered

if ($script:ErrorsCount -gt 0) {
    exit 3
}
elseif ($script:WarningsCount -gt 0) {
    exit 1
}
exit 0

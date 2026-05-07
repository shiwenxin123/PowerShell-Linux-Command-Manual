param(
    [string]$Root = (Resolve-Path ".").Path
)

$ErrorActionPreference = "Stop"
$failures = New-Object System.Collections.Generic.List[string]

$markdownFiles = Get-ChildItem -Path $Root -Recurse -File -Filter *.md

foreach ($file in $markdownFiles) {
    $fenceCount = (Select-String -Path $file.FullName -Pattern '```' -Encoding UTF8).Count
    if ($fenceCount % 2 -ne 0) {
        $failures.Add("Unbalanced code fence: $($file.FullName)")
    }
}

$conflictPattern = '^(<<<<<<<|>>>>>>>|=======$)'
$scanFiles = Get-ChildItem -Path $Root -Recurse -File -Include *.md,*.yml,*.yaml,*.ps1,*.sh,requirements.txt
foreach ($file in $scanFiles) {
    if ($file.Name -eq "check-docs.ps1") {
        continue
    }

    $matches = Select-String -Path $file.FullName -Pattern $conflictPattern -Encoding UTF8 -ErrorAction SilentlyContinue
    foreach ($match in $matches) {
        $failures.Add("Suspicious marker: $($file.FullName):$($match.LineNumber)")
    }
}

$linkRegex = [regex]'\[[^\]]+\]\(([^)]+)\)'
foreach ($file in $markdownFiles) {
    $text = Get-Content -Raw -Encoding UTF8 -Path $file.FullName
    foreach ($match in $linkRegex.Matches($text)) {
        $link = $match.Groups[1].Value
        if ($link -match '^(https?:|mailto:|#)' -or [string]::IsNullOrWhiteSpace($link)) {
            continue
        }

        $path = $link.Split('#')[0]
        if ([string]::IsNullOrWhiteSpace($path)) {
            continue
        }

        $decoded = [uri]::UnescapeDataString($path)
        $target = Join-Path $file.DirectoryName $decoded
        if (-not (Test-Path $target)) {
            $relativeFile = Resolve-Path -Path $file.FullName -Relative
            $failures.Add("Broken relative link: $relativeFile -> $link")
        }
    }
}

$secretPatterns = @(
    '-----BEGIN (RSA |DSA |EC |OPENSSH |)PRIVATE KEY-----',
    'AKIA[0-9A-Z]{16}',
    '(?i)(password|passwd|token|secret|api[_-]?key)\s*[:=]\s*["''][^"'']{8,}["'']'
)

$secretScanFiles = Get-ChildItem -Path $Root -Recurse -File -Include *.md,*.yml,*.yaml,*.ps1,*.sh,*.json,*.env
foreach ($file in $secretScanFiles) {
    if ($file.FullName -match '\\.git\\') {
        continue
    }

    foreach ($pattern in $secretPatterns) {
        $matches = Select-String -Path $file.FullName -Pattern $pattern -Encoding UTF8 -ErrorAction SilentlyContinue
        foreach ($match in $matches) {
            $relativeFile = Resolve-Path -Path $file.FullName -Relative
            $failures.Add("Possible secret: ${relativeFile}:$($match.LineNumber)")
        }
    }
}

$mkdocs = Join-Path $Root "mkdocs.yml"
if (Test-Path $mkdocs) {
    $docsRoot = Join-Path $Root "docs"
    $navPaths = Select-String -Path $mkdocs -Pattern '([A-Za-z0-9_./-]+\.md)' -Encoding UTF8 | ForEach-Object { $_.Matches.Value }
    foreach ($navPath in $navPaths) {
        $target = Join-Path $docsRoot $navPath
        if (-not (Test-Path $target)) {
            $failures.Add("Missing MkDocs nav target: $navPath")
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "Documentation checks OK"

#!/usr/bin/env bash
set -u

MODULE="all"
FORMAT="text"
OUTPUT_FILE=""
WARNINGS_COUNT=0
ERRORS_COUNT=0

usage() {
  cat <<'EOF'
Usage: bash scripts/linux-health-check.sh [--module all|system|disk|network|service|process] [--format text|markdown|json] [--output reports/linux.md]

Examples:
  bash scripts/linux-health-check.sh
  bash scripts/linux-health-check.sh --module disk
  bash scripts/linux-health-check.sh --format markdown --output reports/linux-health-check.md
  bash scripts/linux-health-check.sh --format json --output reports/linux-health-check.json
EOF
}

fail_param() {
  echo "$1" >&2
  usage >&2
  exit 2
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --module)
      [ "$#" -ge 2 ] || fail_param "Missing value for --module"
      MODULE="$2"
      shift 2
      ;;
    --format)
      [ "$#" -ge 2 ] || fail_param "Missing value for --format"
      FORMAT="$2"
      shift 2
      ;;
    --output)
      [ "$#" -ge 2 ] || fail_param "Missing value for --output"
      OUTPUT_FILE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      fail_param "Unknown option: $1"
      ;;
    *)
      # Backward compatibility: first positional argument is treated as output path.
      OUTPUT_FILE="$1"
      shift
      ;;
  esac
done

case "$MODULE" in
  all|system|disk|network|service|process) ;;
  *) fail_param "Unsupported module: $MODULE" ;;
esac

case "$FORMAT" in
  text|markdown|json) ;;
  *) fail_param "Unsupported format: $FORMAT" ;;
esac

if [ -n "$OUTPUT_FILE" ]; then
  if ! mkdir -p "$(dirname "$OUTPUT_FILE")"; then
    echo "Failed to create output directory for: $OUTPUT_FILE" >&2
    exit 3
  fi
fi

json_escape() {
  local value=${1-}
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

json_string() {
  printf '"%s"' "$(json_escape "${1-}")"
}

section() {
  if [ "$FORMAT" = "markdown" ]; then
    echo
    echo "## $1"
    echo
  else
    echo
    echo "== $1 =="
  fi
}

run_block() {
  "$@" 2>&1 || true
}

should_run() {
  [ "$MODULE" = "all" ] || [ "$MODULE" = "$1" ]
}

module_status() {
  local warnings=$1
  local errors=$2
  if [ "$errors" -gt 0 ]; then
    echo "error"
  elif [ "$warnings" -gt 0 ]; then
    echo "warning"
  else
    echo "ok"
  fi
}

run_json_command() {
  local label=$1
  shift
  local output
  local rc
  local label_escaped command_escaped output_escaped
  output=$("$@" 2>&1)
  rc=$?
  if [ "$rc" -ne 0 ]; then
    MODULE_WARNINGS=$((MODULE_WARNINGS + 1))
  fi

  label_escaped=$(json_escape "$label")
  command_escaped=$(json_escape "$*")
  output_escaped=$(json_escape "$output")
  COMMAND_JSON="{\"name\":\"$label_escaped\",\"command\":\"$command_escaped\",\"exit_code\":$rc,\"output\":\"$output_escaped\"}"
}

missing_command_json() {
  local command_name=$1
  local command_escaped message_escaped
  MODULE_WARNINGS=$((MODULE_WARNINGS + 1))
  command_escaped=$(json_escape "$command_name")
  message_escaped=$(json_escape "Command not available: $command_name")
  WARNING_JSON="{\"name\":\"$command_escaped\",\"message\":\"$message_escaped\"}"
}

set_module_json() {
  local name=$1
  local commands=$2
  local warnings=$3
  local errors=$4
  local warning_count=$5
  local error_count=$6
  local status
  status=$(module_status "$warning_count" "$error_count")
  WARNINGS_COUNT=$((WARNINGS_COUNT + warning_count))
  ERRORS_COUNT=$((ERRORS_COUNT + error_count))

  MODULE_JSON="\"$name\":{\"status\":\"$status\",\"commands\":[$commands],\"warnings\":[$warnings],\"errors\":[$errors]}"
}

skipped_json_module() {
  local name=$1
  MODULE_JSON="\"$name\":{\"status\":\"skipped\",\"commands\":[],\"warnings\":[],\"errors\":[]}"
}

collect_system_json() {
  MODULE_WARNINGS=0
  MODULE_ERRORS=0
  local commands=""
  local warnings=""
  run_json_command uname uname -a
  commands="$COMMAND_JSON"
  if [ -f /etc/os-release ]; then
    run_json_command os-release cat /etc/os-release
    commands="$commands,$COMMAND_JSON"
  else
    MODULE_WARNINGS=$((MODULE_WARNINGS + 1))
    missing_command_json /etc/os-release
    warnings="$WARNING_JSON"
  fi
  run_json_command uptime uptime
  commands="$commands,$COMMAND_JSON"
  run_json_command memory free -h
  commands="$commands,$COMMAND_JSON"
  set_module_json system "$commands" "$warnings" "" "$MODULE_WARNINGS" "$MODULE_ERRORS"
}

collect_disk_json() {
  MODULE_WARNINGS=0
  MODULE_ERRORS=0
  local commands=""
  run_json_command disk df -h
  commands="$COMMAND_JSON"
  run_json_command inodes df -i
  commands="$commands,$COMMAND_JSON"
  set_module_json disk "$commands" "" "" "$MODULE_WARNINGS" "$MODULE_ERRORS"
}

collect_process_json() {
  MODULE_WARNINGS=0
  MODULE_ERRORS=0
  local commands=""
  run_json_command top_cpu sh -c "ps aux --sort=-%cpu | head -n 10"
  commands="$COMMAND_JSON"
  run_json_command top_memory sh -c "ps aux --sort=-%mem | head -n 10"
  commands="$commands,$COMMAND_JSON"
  set_module_json process "$commands" "" "" "$MODULE_WARNINGS" "$MODULE_ERRORS"
}

collect_network_json() {
  MODULE_WARNINGS=0
  MODULE_ERRORS=0
  local commands=""
  local warnings=""
  if command -v ss >/dev/null 2>&1; then
    run_json_command listening_ports ss -tulnp
    commands="$COMMAND_JSON"
  elif command -v netstat >/dev/null 2>&1; then
    run_json_command listening_ports netstat -tulnp
    commands="$COMMAND_JSON"
  else
    missing_command_json ss
    warnings="$WARNING_JSON"
  fi

  if command -v ip >/dev/null 2>&1; then
    if [ -n "$commands" ]; then
      run_json_command routes ip route
      commands="$commands,$COMMAND_JSON"
    else
      run_json_command routes ip route
      commands="$COMMAND_JSON"
    fi
  else
    if [ -n "$warnings" ]; then
      missing_command_json ip
      warnings="$warnings,$WARNING_JSON"
    else
      missing_command_json ip
      warnings="$WARNING_JSON"
    fi
  fi
  set_module_json network "$commands" "$warnings" "" "$MODULE_WARNINGS" "$MODULE_ERRORS"
}

collect_service_json() {
  MODULE_WARNINGS=0
  MODULE_ERRORS=0
  local commands=""
  local warnings=""
  if command -v systemctl >/dev/null 2>&1; then
    run_json_command failed_services systemctl --failed --no-pager
    commands="$COMMAND_JSON"
  else
    missing_command_json systemctl
    warnings="$WARNING_JSON"
  fi
  set_module_json service "$commands" "$warnings" "" "$MODULE_WARNINGS" "$MODULE_ERRORS"
}

json_report() {
  local timestamp
  local hostname_value
  local os_value
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  hostname_value=$(hostname 2>/dev/null || echo "unknown")
  os_value=$(uname -s 2>/dev/null || echo "Linux")

  local system_json disk_json network_json service_json process_json
  if should_run system; then collect_system_json; else skipped_json_module system; fi
  system_json="$MODULE_JSON"
  if should_run disk; then collect_disk_json; else skipped_json_module disk; fi
  disk_json="$MODULE_JSON"
  if should_run network; then collect_network_json; else skipped_json_module network; fi
  network_json="$MODULE_JSON"
  if should_run service; then collect_service_json; else skipped_json_module service; fi
  service_json="$MODULE_JSON"
  if should_run process; then collect_process_json; else skipped_json_module process; fi
  process_json="$MODULE_JSON"

  local status="ok"
  if [ "$ERRORS_COUNT" -gt 0 ]; then
    status="error"
  elif [ "$WARNINGS_COUNT" -gt 0 ]; then
    status="warning"
  fi

  local os_escaped hostname_escaped timestamp_escaped module_escaped status_escaped
  os_escaped=$(json_escape "$os_value")
  hostname_escaped=$(json_escape "$hostname_value")
  timestamp_escaped=$(json_escape "$timestamp")
  module_escaped=$(json_escape "$MODULE")
  status_escaped=$(json_escape "$status")
  REPORT=$(printf '{"metadata":{"os":"%s","hostname":"%s","timestamp":"%s","module":"%s","format":"json","script":"linux-health-check.sh"},"modules":{%s,%s,%s,%s,%s},"summary":{"status":"%s","warnings_count":%s,"errors_count":%s},"errors":[]}\n' \
    "$os_escaped" "$hostname_escaped" "$timestamp_escaped" "$module_escaped" \
    "$system_json" "$disk_json" "$network_json" "$service_json" "$process_json" \
    "$status_escaped" "$WARNINGS_COUNT" "$ERRORS_COUNT")
}

text_or_markdown_report() {
  if [ "$FORMAT" = "markdown" ]; then
    echo "# Linux Health Check"
    echo
    echo "- Time: $(date)"
    echo "- Module: $MODULE"
  else
    echo "== Linux Health Check =="
    echo "Time: $(date)"
    echo "Module: $MODULE"
  fi

  if should_run system; then
    section "System"
    if [ "$FORMAT" = "markdown" ]; then echo '```text'; fi
    run_block uname -a
    if [ -f /etc/os-release ]; then run_block cat /etc/os-release; fi
    if [ "$FORMAT" = "markdown" ]; then echo '```'; fi
    section "Uptime"
    if [ "$FORMAT" = "markdown" ]; then echo '```text'; fi
    run_block uptime
    if [ "$FORMAT" = "markdown" ]; then echo '```'; fi
    section "Memory"
    if [ "$FORMAT" = "markdown" ]; then echo '```text'; fi
    run_block free -h
    if [ "$FORMAT" = "markdown" ]; then echo '```'; fi
  fi

  if should_run disk; then
    section "Disk"
    if [ "$FORMAT" = "markdown" ]; then echo '```text'; fi
    run_block df -h
    run_block df -i
    if [ "$FORMAT" = "markdown" ]; then echo '```'; fi
  fi

  if should_run process; then
    section "Top Processes"
    if [ "$FORMAT" = "markdown" ]; then echo '```text'; fi
    run_block sh -c "ps aux --sort=-%cpu | head -n 10"
    run_block sh -c "ps aux --sort=-%mem | head -n 10"
    if [ "$FORMAT" = "markdown" ]; then echo '```'; fi
  fi

  if should_run network; then
    section "Network"
    if [ "$FORMAT" = "markdown" ]; then echo '```text'; fi
    if command -v ss >/dev/null 2>&1; then
      run_block ss -tulnp
    else
      run_block sh -c "netstat -tulnp 2>/dev/null"
    fi
    run_block ip route
    if [ "$FORMAT" = "markdown" ]; then echo '```'; fi
  fi

  if should_run service; then
    section "Failed Services"
    if [ "$FORMAT" = "markdown" ]; then echo '```text'; fi
    if command -v systemctl >/dev/null 2>&1; then
      run_block systemctl --failed --no-pager
    else
      echo "systemctl not available"
    fi
    if [ "$FORMAT" = "markdown" ]; then echo '```'; fi
  fi

  section "Done"
  if [ -n "$OUTPUT_FILE" ]; then echo "Report saved to: $OUTPUT_FILE"; fi
}

if [ "$FORMAT" = "json" ]; then
  json_report || exit 3
else
  REPORT=$(text_or_markdown_report) || exit 3
fi

if [ -n "$OUTPUT_FILE" ]; then
  if ! printf '%s\n' "$REPORT" | tee "$OUTPUT_FILE"; then
    echo "Failed to write output file: $OUTPUT_FILE" >&2
    exit 3
  fi
else
  printf '%s\n' "$REPORT"
fi

if [ "$ERRORS_COUNT" -gt 0 ]; then
  exit 3
elif [ "$WARNINGS_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0

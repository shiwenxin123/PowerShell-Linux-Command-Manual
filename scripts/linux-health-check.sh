#!/usr/bin/env bash
set -u

MODULE="all"
FORMAT="text"
OUTPUT_FILE=""
WARNINGS_COUNT=0
ERRORS_COUNT=0
CERT_WARN_DAYS=30
CERT_MAX_FILES=200
CERT_MAX_BYTES=131072
CERT_MAX_DEPTH=6
CERT_EXTRA_PATHS=()

usage() {
  cat <<'EOF'
Usage: bash scripts/linux-health-check.sh [--module all|system|disk|network|service|process|package|security|container|log] [--format text|markdown|json] [--output reports/linux.md] [--cert-warn-days DAYS] [--cert-path PATH]

Options:
  --module NAME          Check one module, or all. Default: all
  --format FORMAT        text, markdown, or json. Default: text
  --output FILE          Also write the report to FILE
  --cert-warn-days DAYS  Flag certificates expiring within DAYS. Default: 30
  --cert-path PATH       Extra certificate file or directory. May be repeated
  -h, --help             Show this help

The security module includes a read-only TLS certificate expiry probe.
It scans /etc/nginx, /etc/httpd, /etc/pki/tls/certs, /etc/ssl/certs,
and /etc/letsencrypt/live, plus any --cert-path values. Private keys are
skipped. If openssl is missing, the probe records not-found and does not fail.

Examples:
  bash scripts/linux-health-check.sh
  bash scripts/linux-health-check.sh --module disk
  bash scripts/linux-health-check.sh --module security --cert-warn-days 14 --cert-path /path/to/certs
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
    --cert-warn-days)
      [ "$#" -ge 2 ] || fail_param "Missing value for --cert-warn-days"
      case "$2" in
        ''|*[!0-9]*) fail_param "Invalid --cert-warn-days: $2" ;;
      esac
      if [ "${#2}" -gt 5 ]; then
        fail_param "Invalid --cert-warn-days: $2"
      fi
      CERT_WARN_DAYS=$((10#$2))
      if [ "$CERT_WARN_DAYS" -gt 36500 ]; then
        fail_param "Invalid --cert-warn-days: $2"
      fi
      shift 2
      ;;
    --cert-path)
      [ "$#" -ge 2 ] || fail_param "Missing value for --cert-path"
      case "$2" in
        ''|-) fail_param "Invalid --cert-path" ;;
        -*) fail_param "Certificate path must not start with '-'" ;;
        /) fail_param "Certificate path must not be /" ;;
        *$'\n'*|*$'\r'*) fail_param "Certificate path must not contain newlines" ;;
      esac
      CERT_EXTRA_PATHS+=("$2")
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
  all|system|disk|network|service|process|package|security|container|log) ;;
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

collect_package_json() {
  MODULE_WARNINGS=0
  MODULE_ERRORS=0
  local commands=""
  local warnings=""

  run_json_command package_managers sh -c "for c in apt apt-get dnf yum zypper pacman rpm dpkg; do if command -v \"\$c\" >/dev/null 2>&1; then printf '== %s ==\n' \"\$c\"; \"\$c\" --version 2>&1 | head -n 3; fi; done"
  commands="$COMMAND_JSON"

  if command -v apt-cache >/dev/null 2>&1; then
    run_json_command apt_policy apt-cache policy
    commands="$commands,$COMMAND_JSON"
  elif command -v dnf >/dev/null 2>&1; then
    run_json_command dnf_repolist dnf repolist
    commands="$commands,$COMMAND_JSON"
  elif command -v yum >/dev/null 2>&1; then
    run_json_command yum_repolist yum repolist
    commands="$commands,$COMMAND_JSON"
  elif command -v zypper >/dev/null 2>&1; then
    run_json_command zypper_repos zypper repos
    commands="$commands,$COMMAND_JSON"
  else
    missing_command_json package-manager
    warnings="$WARNING_JSON"
  fi

  set_module_json package "$commands" "$warnings" "" "$MODULE_WARNINGS" "$MODULE_ERRORS"
}

# Read-only inventory of Kylin/UOS security-center tooling.
# Missing packages, units, commands, and paths are reported in the output and do not fail the probe.
# Only a status subcommand is executed. enable, disable, set, allow, start, and kysec_set are never run.
domestic_report_package() {
  local name=$1
  local status
  if command -v dpkg-query >/dev/null 2>&1; then
    if status=$(dpkg-query -W -f '${Status}' "$name" 2>/dev/null); then
      printf '%s: dpkg %s\n' "$name" "$status"
      return 0
    fi
  fi
  if command -v rpm >/dev/null 2>&1; then
    if status=$(rpm -q "$name" 2>/dev/null); then
      printf '%s: rpm %s\n' "$name" "$status"
      return 0
    fi
  fi
  if ! command -v dpkg-query >/dev/null 2>&1 && ! command -v rpm >/dev/null 2>&1; then
    printf '%s: package-manager-unavailable\n' "$name"
    return 0
  fi
  printf '%s: not-installed\n' "$name"
}

domestic_report_unit() {
  local unit=$1
  local load active file
  if ! command -v systemctl >/dev/null 2>&1 || [ ! -d /run/systemd/system ]; then
    printf '%s: systemctl-unavailable\n' "$unit"
    return 0
  fi
  if command -v timeout >/dev/null 2>&1; then
    load=$(timeout 5 systemctl show -p LoadState --value "$unit" 2>/dev/null || true)
    active=$(timeout 5 systemctl show -p ActiveState --value "$unit" 2>/dev/null || true)
    file=$(timeout 5 systemctl show -p UnitFileState --value "$unit" 2>/dev/null || true)
  else
    load=$(systemctl show -p LoadState --value "$unit" 2>/dev/null || true)
    active=$(systemctl show -p ActiveState --value "$unit" 2>/dev/null || true)
    file=$(systemctl show -p UnitFileState --value "$unit" 2>/dev/null || true)
  fi
  printf '%s: load=%s active=%s unit_file=%s\n' "$unit" "${load:-unknown}" "${active:-unknown}" "${file:-unknown}"
}

domestic_report_path() {
  local path=$1
  if [ -e "$path" ]; then
    if [ -r "$path" ]; then
      printf '%s: present\n' "$path"
    else
      printf '%s: present-unreadable\n' "$path"
    fi
  else
    printf '%s: absent\n' "$path"
  fi
}

domestic_report_command_presence() {
  local bin=$1
  if command -v "$bin" >/dev/null 2>&1; then
    printf '%s: present (not executed)\n' "$bin"
  else
    printf '%s: not-found\n' "$bin"
  fi
}

domestic_run_status_if_present() {
  local bin=$1
  shift
  local arg output rc
  for arg in "$@"; do
    case "$arg" in
      enable|disable|set|allow|start|scan|add|stop|restart|delete|remove)
        printf '%s: refused non-read-only argument\n' "$bin"
        DOMESTIC_SECURITY_PROBE_RC=1
        return 0
        ;;
    esac
  done
  if ! command -v "$bin" >/dev/null 2>&1; then
    printf '%s: not-found\n' "$bin"
    return 0
  fi
  printf '%s: present\n' "$bin"
  printf '== %s ==\n' "$*"
  rc=0
  if command -v timeout >/dev/null 2>&1; then
    output=$(timeout 5 "$@" 2>&1) || rc=$?
  else
    output=$("$@" 2>&1) || rc=$?
  fi
  printf '%s\n' "$output" | tr -d '\000-\010\013\014\016-\037' | head -n 40
  printf 'exit_code=%s\n' "$rc"
  if [ "$rc" -ne 0 ]; then
    DOMESTIC_SECURITY_PROBE_RC=1
  fi
}

domestic_security_center_probe() {
  DOMESTIC_SECURITY_PROBE_RC=0
  printf '%s\n' 'domestic_security_center: read-only probe'
  printf '%s\n' 'note: not-found, not-installed, and absent are expected when the tool is not on this host'
  printf '%s\n' 'note: enable, disable, set, allow, start, and kysec_set are never executed'

  printf '\n%s\n' '== packages =='
  domestic_report_package ksc-defender
  domestic_report_package kylin-security-center
  domestic_report_package kylin-security-tool
  domestic_report_package uos-security-center
  domestic_report_package deepin-defender

  printf '\n%s\n' '== units =='
  domestic_report_unit ksc-defender.service
  domestic_report_unit ksc-defender-daemon.service
  domestic_report_unit kylin-security-center.service
  domestic_report_unit deepin-defender.service

  printf '\n%s\n' '== commands =='
  domestic_run_status_if_present kylin-security-cli kylin-security-cli status
  domestic_run_status_if_present uos-firewall uos-firewall status
  domestic_run_status_if_present deepin-defender deepin-defender status
  domestic_report_command_presence kylin-security-level
  domestic_report_command_presence uos-security-level
  domestic_report_command_presence kysec_set
  domestic_report_command_presence kysec_stat

  printf '\n%s\n' '== paths =='
  domestic_report_path /etc/kylin-security-center.conf
  domestic_report_path /var/log/kylin-security.log
  domestic_report_path /var/log/uos/security.log

  return "$DOMESTIC_SECURITY_PROBE_RC"
}

# Read-only local TLS certificate expiry probe.
# Scans common certificate directories and optional --cert-path values.
# Private key files are skipped and their contents are never printed.
# Nothing is modified. Missing openssl is recorded as not-found and is not a failure.
tls_cert_sanitize() {
  local value=$1
  value=${value//$'\n'/}
  value=${value//$'\r'/}
  value=${value//$'\t'/ }
  printf '%s' "$value" | tr -d '\000-\010\013\014\016-\037'
}

tls_cert_lower_base() {
  basename -- "$1" | tr '[:upper:]' '[:lower:]'
}

tls_cert_name_is_private() {
  local base
  base=$(tls_cert_lower_base "$1")
  case "$base" in
    *.key|*.key.*|*privkey*|*privatekey*|*private-key*|*id_rsa*|*id_ecdsa*|*id_ed25519*|*.p12|*.pfx)
      return 0
      ;;
  esac
  return 1
}

tls_cert_name_is_bundle() {
  local base
  base=$(tls_cert_lower_base "$1")
  case "$base" in
    ca-certificates.crt|ca-certificates.pem|ca-bundle.crt|ca-bundle.pem|ca-bundle.trust.crt|ca-bundle.trust.pem|tls-ca-bundle.pem)
      return 0
      ;;
  esac
  return 1
}

tls_cert_path_in_ssl_certs() {
  case "$1" in
    /etc/ssl/certs|/etc/ssl/certs/*) return 0 ;;
  esac
  return 1
}

# Distro trust anchors in /etc/ssl/certs are symlinks into the CA bundle.
# Skip them before openssl so a large trust store stays cheap.
tls_cert_is_distro_ca_link() {
  local file=$1
  local target
  tls_cert_path_in_ssl_certs "$file" || return 1
  [ -L "$file" ] || return 1
  target=$(readlink -f -- "$file" 2>/dev/null || true)
  case "$target" in
    /usr/share/ca-certificates|/usr/share/ca-certificates/*) return 0 ;;
  esac
  return 1
}

# Classify a PEM header without reading past the first line.
# Key material lives on the following lines and is never stored or printed.
tls_cert_pem_kind() {
  local file=$1
  local hdr
  hdr=""
  IFS= read -r -n 64 hdr < "$file" || true
  hdr=${hdr%$'\r'}
  case "$hdr" in
    "-----BEGIN CERTIFICATE-----"|"-----BEGIN TRUSTED CERTIFICATE-----"|"-----BEGIN X509 CERTIFICATE-----")
      printf '%s\n' cert
      ;;
    -----BEGIN*PRIVATE\ KEY-----)
      printf '%s\n' key
      ;;
    -----BEGIN*)
      printf '%s\n' other
      ;;
    *)
      printf '%s\n' maybe-der
      ;;
  esac
}

tls_cert_meta_value() {
  local meta=$1
  local key=$2
  local line prefix
  prefix="$key="
  while IFS= read -r line; do
    case "$line" in
      "$prefix"*)
        printf '%s' "${line#"$prefix"}"
        return 0
        ;;
    esac
  done <<< "$meta"
  return 1
}

tls_cert_extract_cn() {
  local dn=$1
  local part cn
  local -a parts=()
  IFS=',' read -r -a parts <<< "$dn"
  for part in "${parts[@]}"; do
    part=${part#" "}
    case "$part" in
      CN=*)
        cn=${part#CN=}
        cn=$(tls_cert_sanitize "$cn")
        if [ -n "$cn" ]; then
          printf '%s' "$cn"
          return 0
        fi
        ;;
    esac
  done
  printf '%s' "-"
}

tls_cert_note_examined() {
  TLS_CERT_EXAMINED=$((TLS_CERT_EXAMINED + 1))
}

tls_cert_report_file() {
  local file=$1
  local inform=$2
  local meta bc subject_dn issuer_dn not_after_raw fp
  local end_epoch now_epoch days status iso subject_cn path_out overdue
  meta=$(LC_ALL=C openssl x509 -inform "$inform" -nameopt RFC2253 -noout \
    -subject -issuer -enddate -fingerprint -sha256 -in "$file" 2>/dev/null) || return 1

  bc=$(LC_ALL=C openssl x509 -inform "$inform" -noout -ext basicConstraints -in "$file" 2>/dev/null || true)
  if tls_cert_path_in_ssl_certs "$file"; then
    case "$bc" in
      *CA:TRUE*)
        TLS_CERT_SKIPPED_CA=$((TLS_CERT_SKIPPED_CA + 1))
        return 0
        ;;
    esac
  fi

  subject_dn=$(tls_cert_meta_value "$meta" subject) || return 1
  issuer_dn=$(tls_cert_meta_value "$meta" issuer) || return 1
  not_after_raw=$(tls_cert_meta_value "$meta" notAfter) || return 1
  fp=$(tls_cert_meta_value "$meta" "sha256 Fingerprint" || true)
  if [ -n "$fp" ] && [ -n "${TLS_CERT_SEEN_FP[$fp]+x}" ]; then
    TLS_CERT_DEDUPED=$((TLS_CERT_DEDUPED + 1))
    return 0
  fi
  if [ -n "$fp" ]; then
    TLS_CERT_SEEN_FP[$fp]=1
  fi

  end_epoch=$(LC_ALL=C date -u -d "$not_after_raw" +%s 2>/dev/null) || return 1
  now_epoch=$(date -u +%s)
  iso=$(LC_ALL=C date -u -d "@$end_epoch" +%Y-%m-%dT%H:%M:%SZ)
  if [ "$end_epoch" -le "$now_epoch" ]; then
    overdue=$(( (now_epoch - end_epoch + 86399) / 86400 ))
    days=$((0 - overdue))
    status=expired
    TLS_CERT_EXPIRED=$((TLS_CERT_EXPIRED + 1))
  else
    days=$(( (end_epoch - now_epoch) / 86400 ))
    if [ "$days" -le "$CERT_WARN_DAYS" ]; then
      status=expiring
      TLS_CERT_EXPIRING=$((TLS_CERT_EXPIRING + 1))
    else
      status=ok
      TLS_CERT_OK=$((TLS_CERT_OK + 1))
    fi
  fi

  subject_cn=$(tls_cert_extract_cn "$subject_dn")
  subject_cn=$(tls_cert_sanitize "$subject_cn")
  issuer_dn=$(tls_cert_sanitize "$issuer_dn")
  path_out=$(tls_cert_sanitize "$file")
  printf 'tls_cert path=%s subject_cn=%s issuer=%s not_after=%s days_remaining=%s status=%s\n' \
    "$path_out" "$subject_cn" "$issuer_dn" "$iso" "$days" "$status"
  TLS_CERT_REPORTED=$((TLS_CERT_REPORTED + 1))
  return 0
}

tls_cert_consider_file() {
  local file=$1
  local real kind size
  if [ "$TLS_CERT_EXAMINED" -ge "$CERT_MAX_FILES" ]; then
    TLS_CERT_LIMIT_HIT=1
    return 0
  fi

  case "$file" in
    *$'\n'*|*$'\r'*)
      tls_cert_note_examined
      TLS_CERT_SKIPPED_UNSUPPORTED=$((TLS_CERT_SKIPPED_UNSUPPORTED + 1))
      return 0
      ;;
  esac

  if tls_cert_name_is_private "$file"; then
    tls_cert_note_examined
    TLS_CERT_SKIPPED_KEY=$((TLS_CERT_SKIPPED_KEY + 1))
    printf 'tls_cert_skip kind=private-key path=%s\n' "$file"
    return 0
  fi

  if tls_cert_name_is_bundle "$file"; then
    tls_cert_note_examined
    TLS_CERT_SKIPPED_BUNDLE=$((TLS_CERT_SKIPPED_BUNDLE + 1))
    return 0
  fi

  if tls_cert_is_distro_ca_link "$file"; then
    TLS_CERT_SKIPPED_CA=$((TLS_CERT_SKIPPED_CA + 1))
    return 0
  fi

  real=$(readlink -f -- "$file" 2>/dev/null || true)
  if [ -z "$real" ]; then
    real=$file
  fi
  if [ -n "${TLS_CERT_SEEN_PATH[$real]+x}" ]; then
    TLS_CERT_DEDUPED=$((TLS_CERT_DEDUPED + 1))
    return 0
  fi
  TLS_CERT_SEEN_PATH[$real]=1

  if [ ! -r "$file" ]; then
    tls_cert_note_examined
    TLS_CERT_SKIPPED_UNREADABLE=$((TLS_CERT_SKIPPED_UNREADABLE + 1))
    return 0
  fi

  size=$(stat -L -c '%s' "$file" 2>/dev/null || true)
  if [ -z "$size" ]; then
    tls_cert_note_examined
    TLS_CERT_SKIPPED_UNREADABLE=$((TLS_CERT_SKIPPED_UNREADABLE + 1))
    return 0
  fi
  if [ "$size" -gt "$CERT_MAX_BYTES" ]; then
    tls_cert_note_examined
    TLS_CERT_SKIPPED_LARGE=$((TLS_CERT_SKIPPED_LARGE + 1))
    return 0
  fi

  kind=$(tls_cert_pem_kind "$file")
  tls_cert_note_examined
  case "$kind" in
    key)
      TLS_CERT_SKIPPED_KEY=$((TLS_CERT_SKIPPED_KEY + 1))
      printf 'tls_cert_skip kind=private-key path=%s\n' "$file"
      ;;
    other)
      TLS_CERT_SKIPPED_UNSUPPORTED=$((TLS_CERT_SKIPPED_UNSUPPORTED + 1))
      ;;
    cert)
      tls_cert_report_file "$file" PEM || TLS_CERT_SKIPPED_UNSUPPORTED=$((TLS_CERT_SKIPPED_UNSUPPORTED + 1))
      ;;
    maybe-der)
      if ! tls_cert_report_file "$file" PEM; then
        tls_cert_report_file "$file" DER || TLS_CERT_SKIPPED_UNSUPPORTED=$((TLS_CERT_SKIPPED_UNSUPPORTED + 1))
      fi
      ;;
    *)
      TLS_CERT_SKIPPED_UNSUPPORTED=$((TLS_CERT_SKIPPED_UNSUPPORTED + 1))
      ;;
  esac
}

tls_cert_scan_root() {
  local root=$1
  local path
  if [ "$TLS_CERT_LIMIT_HIT" -eq 1 ]; then
    printf 'tls_cert_root path=%s state=skipped-limit\n' "$root"
    return 0
  fi
  if [ -L "$root" ] && [ ! -e "$root" ]; then
    printf 'tls_cert_root path=%s state=present-unreadable\n' "$root"
    return 0
  fi
  if [ ! -e "$root" ]; then
    printf 'tls_cert_root path=%s state=absent\n' "$root"
    return 0
  fi
  if [ -d "$root" ]; then
    if [ ! -r "$root" ] || [ ! -x "$root" ]; then
      printf 'tls_cert_root path=%s state=present-unreadable\n' "$root"
      return 0
    fi
    printf 'tls_cert_root path=%s state=present\n' "$root"
    while IFS= read -r -d '' path; do
      tls_cert_consider_file "$path"
      if [ "$TLS_CERT_LIMIT_HIT" -eq 1 ]; then
        break
      fi
    # Only certificate suffixes are visited. *.key, *.p12, and *.pfx are never opened.
    done < <(find "$root" -maxdepth "$CERT_MAX_DEPTH" \( -type f -o -type l \) \
      \( -iname '*.crt' -o -iname '*.cer' -o -iname '*.pem' -o -iname '*.cert' \) \
      -print0 2>/dev/null)
    return 0
  fi
  if [ -f "$root" ]; then
    printf 'tls_cert_root path=%s state=file\n' "$root"
    tls_cert_consider_file "$root"
    return 0
  fi
  printf 'tls_cert_root path=%s state=skipped\n' "$root"
}

tls_cert_expiry_probe() {
  local -a roots=()
  local extra root
  TLS_CERT_EXAMINED=0
  TLS_CERT_REPORTED=0
  TLS_CERT_EXPIRED=0
  TLS_CERT_EXPIRING=0
  TLS_CERT_OK=0
  TLS_CERT_SKIPPED_KEY=0
  TLS_CERT_SKIPPED_LARGE=0
  TLS_CERT_SKIPPED_CA=0
  TLS_CERT_SKIPPED_BUNDLE=0
  TLS_CERT_SKIPPED_UNREADABLE=0
  TLS_CERT_SKIPPED_UNSUPPORTED=0
  TLS_CERT_DEDUPED=0
  TLS_CERT_LIMIT_HIT=0
  unset TLS_CERT_SEEN_PATH
  unset TLS_CERT_SEEN_FP
  declare -gA TLS_CERT_SEEN_PATH
  declare -gA TLS_CERT_SEEN_FP

  printf '%s\n' 'tls_cert_expiry: read-only probe'
  printf 'warn_days=%s\n' "$CERT_WARN_DAYS"
  printf 'max_files=%s\n' "$CERT_MAX_FILES"
  printf 'max_bytes=%s\n' "$CERT_MAX_BYTES"
  printf 'max_depth=%s\n' "$CERT_MAX_DEPTH"
  printf '%s\n' 'note: private keys are skipped and never printed; certificate files are not modified'

  if ! command -v openssl >/dev/null 2>&1; then
    printf '%s\n' 'openssl: not-found'
    printf '%s\n' 'note: openssl is not installed; certificate expiry was not evaluated'
    printf '%s\n' 'tls_cert_summary scanned=0 reported=0 expired=0 expiring=0 ok=0 skipped_key=0 skipped_large=0 skipped_ca=0 skipped_bundle=0 skipped_unreadable=0 skipped_unsupported=0 deduped=0'
    return 0
  fi
  printf '%s\n' 'openssl: present'

  if [ "${#CERT_EXTRA_PATHS[@]}" -gt 0 ]; then
    for extra in "${CERT_EXTRA_PATHS[@]}"; do
      roots+=("$extra")
    done
  fi
  roots+=(
    /etc/nginx
    /etc/httpd
    /etc/pki/tls/certs
    /etc/ssl/certs
    /etc/letsencrypt/live
  )

  for root in "${roots[@]}"; do
    tls_cert_scan_root "$root"
  done

  if [ "$TLS_CERT_LIMIT_HIT" -eq 1 ]; then
    printf 'tls_cert_limit max_files=%s\n' "$CERT_MAX_FILES"
  fi
  printf 'tls_cert_summary scanned=%s reported=%s expired=%s expiring=%s ok=%s skipped_key=%s skipped_large=%s skipped_ca=%s skipped_bundle=%s skipped_unreadable=%s skipped_unsupported=%s deduped=%s\n' \
    "$TLS_CERT_EXAMINED" "$TLS_CERT_REPORTED" "$TLS_CERT_EXPIRED" "$TLS_CERT_EXPIRING" "$TLS_CERT_OK" \
    "$TLS_CERT_SKIPPED_KEY" "$TLS_CERT_SKIPPED_LARGE" "$TLS_CERT_SKIPPED_CA" "$TLS_CERT_SKIPPED_BUNDLE" \
    "$TLS_CERT_SKIPPED_UNREADABLE" "$TLS_CERT_SKIPPED_UNSUPPORTED" "$TLS_CERT_DEDUPED"

  if [ "$TLS_CERT_EXPIRED" -gt 0 ] || [ "$TLS_CERT_EXPIRING" -gt 0 ] || [ "$TLS_CERT_LIMIT_HIT" -eq 1 ]; then
    return 1
  fi
  return 0
}

collect_security_json() {
  MODULE_WARNINGS=0
  MODULE_ERRORS=0
  local commands=""
  local warnings=""

  if [ -r /etc/ssh/sshd_config ]; then
    run_json_command sshd_config sh -c "grep -E '^(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|Port)\\b' /etc/ssh/sshd_config || true"
    commands="$COMMAND_JSON"
  else
    missing_command_json /etc/ssh/sshd_config
    warnings="$WARNING_JSON"
  fi

  if command -v sudo >/dev/null 2>&1; then
    run_json_command sudo_version sudo -V
    if [ -n "$commands" ]; then commands="$commands,$COMMAND_JSON"; else commands="$COMMAND_JSON"; fi
  fi

  if command -v firewall-cmd >/dev/null 2>&1; then
    run_json_command firewall_state firewall-cmd --state
    if [ -n "$commands" ]; then commands="$commands,$COMMAND_JSON"; else commands="$COMMAND_JSON"; fi
  elif command -v ufw >/dev/null 2>&1; then
    run_json_command firewall_state ufw status
    if [ -n "$commands" ]; then commands="$commands,$COMMAND_JSON"; else commands="$COMMAND_JSON"; fi
  else
    missing_command_json firewall-cmd
    if [ -n "$warnings" ]; then warnings="$warnings,$WARNING_JSON"; else warnings="$WARNING_JSON"; fi
  fi

  if command -v getenforce >/dev/null 2>&1; then
    run_json_command selinux getenforce
    if [ -n "$commands" ]; then commands="$commands,$COMMAND_JSON"; else commands="$COMMAND_JSON"; fi
  elif command -v aa-status >/dev/null 2>&1; then
    run_json_command apparmor aa-status
    if [ -n "$commands" ]; then commands="$commands,$COMMAND_JSON"; else commands="$COMMAND_JSON"; fi
  fi

  run_json_command domestic_security_center domestic_security_center_probe
  if [ -n "$commands" ]; then commands="$commands,$COMMAND_JSON"; else commands="$COMMAND_JSON"; fi

  run_json_command tls_cert_expiry tls_cert_expiry_probe
  if [ -n "$commands" ]; then commands="$commands,$COMMAND_JSON"; else commands="$COMMAND_JSON"; fi

  set_module_json security "$commands" "$warnings" "" "$MODULE_WARNINGS" "$MODULE_ERRORS"
}

collect_container_json() {
  MODULE_WARNINGS=0
  MODULE_ERRORS=0
  local commands=""
  local warnings=""

  if command -v docker >/dev/null 2>&1; then
    run_json_command docker_version docker version
    commands="$COMMAND_JSON"
    run_json_command docker_ps docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
    commands="$commands,$COMMAND_JSON"
  else
    missing_command_json docker
    warnings="$WARNING_JSON"
  fi

  if command -v ctr >/dev/null 2>&1; then
    run_json_command containerd_version ctr version
    if [ -n "$commands" ]; then commands="$commands,$COMMAND_JSON"; else commands="$COMMAND_JSON"; fi
  fi

  if command -v kubectl >/dev/null 2>&1; then
    run_json_command kubectl_nodes kubectl get nodes -o wide
    if [ -n "$commands" ]; then commands="$commands,$COMMAND_JSON"; else commands="$COMMAND_JSON"; fi
  else
    missing_command_json kubectl
    if [ -n "$warnings" ]; then warnings="$warnings,$WARNING_JSON"; else warnings="$WARNING_JSON"; fi
  fi

  set_module_json container "$commands" "$warnings" "" "$MODULE_WARNINGS" "$MODULE_ERRORS"
}

collect_log_json() {
  MODULE_WARNINGS=0
  MODULE_ERRORS=0
  local commands=""
  local warnings=""

  if command -v journalctl >/dev/null 2>&1; then
    run_json_command journal_errors journalctl -p 3 -n 50 --no-pager
    commands="$COMMAND_JSON"
    run_json_command journal_disk_usage journalctl --disk-usage
    commands="$commands,$COMMAND_JSON"
  else
    missing_command_json journalctl
    warnings="$WARNING_JSON"
  fi

  if command -v dmesg >/dev/null 2>&1; then
    run_json_command kernel_warnings dmesg -T --level=err,warn
    if [ -n "$commands" ]; then commands="$commands,$COMMAND_JSON"; else commands="$COMMAND_JSON"; fi
  fi

  if [ -d /var/log ]; then
    run_json_command var_log_usage sh -c "du -sh /var/log 2>/dev/null || true"
    if [ -n "$commands" ]; then commands="$commands,$COMMAND_JSON"; else commands="$COMMAND_JSON"; fi
  fi

  set_module_json log "$commands" "$warnings" "" "$MODULE_WARNINGS" "$MODULE_ERRORS"
}

json_report() {
  local timestamp
  local hostname_value
  local os_value
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  hostname_value=$(hostname 2>/dev/null || echo "unknown")
  os_value=$(uname -s 2>/dev/null || echo "Linux")

  local system_json disk_json network_json service_json process_json package_json security_json container_json log_json
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
  if should_run package; then collect_package_json; else skipped_json_module package; fi
  package_json="$MODULE_JSON"
  if should_run security; then collect_security_json; else skipped_json_module security; fi
  security_json="$MODULE_JSON"
  if should_run container; then collect_container_json; else skipped_json_module container; fi
  container_json="$MODULE_JSON"
  if should_run log; then collect_log_json; else skipped_json_module log; fi
  log_json="$MODULE_JSON"

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
  REPORT=$(printf '{"metadata":{"os":"%s","hostname":"%s","timestamp":"%s","module":"%s","format":"json","script":"linux-health-check.sh"},"modules":{%s,%s,%s,%s,%s,%s,%s,%s,%s},"summary":{"status":"%s","warnings_count":%s,"errors_count":%s},"errors":[]}\n' \
    "$os_escaped" "$hostname_escaped" "$timestamp_escaped" "$module_escaped" \
    "$system_json" "$disk_json" "$network_json" "$service_json" "$process_json" "$package_json" "$security_json" "$container_json" "$log_json" \
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

  if should_run package; then
    section "Package"
    if [ "$FORMAT" = "markdown" ]; then echo '```text'; fi
    run_block sh -c "for c in apt apt-get dnf yum zypper pacman rpm dpkg; do if command -v \"\$c\" >/dev/null 2>&1; then printf '== %s ==\n' \"\$c\"; \"\$c\" --version 2>&1 | head -n 3; fi; done"
    if command -v apt-cache >/dev/null 2>&1; then
      run_block apt-cache policy
    elif command -v dnf >/dev/null 2>&1; then
      run_block dnf repolist
    elif command -v yum >/dev/null 2>&1; then
      run_block yum repolist
    elif command -v zypper >/dev/null 2>&1; then
      run_block zypper repos
    else
      echo "package manager not detected"
    fi
    if [ "$FORMAT" = "markdown" ]; then echo '```'; fi
  fi

  if should_run security; then
    section "Security"
    if [ "$FORMAT" = "markdown" ]; then echo '```text'; fi
    if [ -r /etc/ssh/sshd_config ]; then run_block sh -c "grep -E '^(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|Port)\\b' /etc/ssh/sshd_config || true"; fi
    if command -v sudo >/dev/null 2>&1; then run_block sudo -V; fi
    if command -v firewall-cmd >/dev/null 2>&1; then run_block firewall-cmd --state; elif command -v ufw >/dev/null 2>&1; then run_block ufw status; fi
    if command -v getenforce >/dev/null 2>&1; then run_block getenforce; elif command -v aa-status >/dev/null 2>&1; then run_block aa-status; fi
    echo "-- domestic security center --"
    domestic_security_center_probe 2>&1 || true
    echo "-- tls certificate expiry --"
    tls_cert_expiry_probe 2>&1 || true
    if [ "$FORMAT" = "markdown" ]; then echo '```'; fi
  fi

  if should_run container; then
    section "Container"
    if [ "$FORMAT" = "markdown" ]; then echo '```text'; fi
    if command -v docker >/dev/null 2>&1; then
      run_block docker version
      run_block docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
    else
      echo "docker not available"
    fi
    if command -v ctr >/dev/null 2>&1; then run_block ctr version; fi
    if command -v kubectl >/dev/null 2>&1; then run_block kubectl get nodes -o wide; else echo "kubectl not available"; fi
    if [ "$FORMAT" = "markdown" ]; then echo '```'; fi
  fi

  if should_run log; then
    section "Log"
    if [ "$FORMAT" = "markdown" ]; then echo '```text'; fi
    if command -v journalctl >/dev/null 2>&1; then
      run_block journalctl -p 3 -n 50 --no-pager
      run_block journalctl --disk-usage
    else
      echo "journalctl not available"
    fi
    if command -v dmesg >/dev/null 2>&1; then run_block dmesg -T --level=err,warn; fi
    if [ -d /var/log ]; then run_block sh -c "du -sh /var/log 2>/dev/null || true"; fi
    if [ "$FORMAT" = "markdown" ]; then echo '```'; fi
  fi

  section "Done"
  if [ -n "$OUTPUT_FILE" ]; then echo "Report saved to: $OUTPUT_FILE"; fi
}

if [ "$FORMAT" = "json" ]; then
  json_report || exit 3
else
  REPORT=$(text_or_markdown_report) || exit 3
  if printf '%s\n' "$REPORT" | grep -Eq '^tls_cert path=.* status=(expired|expiring)$|^tls_cert_limit '; then
    WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
  fi
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

#!/usr/bin/env bash
# Throwaway self-signed certificates are created in a temp directory and deleted on exit.
# This test never writes certificate or key material into the repository.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SCRIPT="$ROOT/scripts/linux-health-check.sh"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_ge() {
  local got=$1
  local min=$2
  local message=$3
  if [ "$got" -lt "$min" ]; then
    fail "$message (got $got, want >= $min)"
  fi
}

assert_eq() {
  local got=$1
  local want=$2
  local message=$3
  if [ "$got" != "$want" ]; then
    fail "$message (got $got, want $want)"
  fi
}

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

bash -n "$SCRIPT"

assert_exit() {
  local expected=$1
  local dest=$2
  shift 2
  local code=0
  set +e
  "$@" >"$dest" 2>"$dest.err"
  code=$?
  set -e
  if [ "$code" -ne "$expected" ]; then
    if grep -q 'PRIVATE KEY' "$dest" 2>/dev/null; then
      fail "exit $code, expected $expected, and private key material was present"
    fi
    printf 'stdout:\n' >&2
    cat "$dest" >&2 || true
    printf 'stderr:\n' >&2
    cat "$dest.err" >&2 || true
    fail "exit $code, expected $expected for: $*"
  fi
}

summary_field() {
  local file=$1
  local key=$2
  local summary token
  local -a tokens=()
  summary=$(grep '^tls_cert_summary ' "$file")
  read -r -a tokens <<< "$summary"
  for token in "${tokens[@]}"; do
    case "$token" in
      "$key"=*)
        printf '%s' "${token#"$key"=}"
        return 0
        ;;
    esac
  done
  return 1
}

line_field() {
  local line=$1
  local key=$2
  local token
  local -a tokens=()
  read -r -a tokens <<< "$line"
  for token in "${tokens[@]}"; do
    case "$token" in
      "$key"=*)
        printf '%s' "${token#"$key"=}"
        return 0
        ;;
    esac
  done
  return 1
}

expected_not_after() {
  local file=$1
  local raw epoch
  raw=$(LC_ALL=C openssl x509 -in "$file" -noout -enddate)
  raw=${raw#notAfter=}
  epoch=$(LC_ALL=C date -u -d "$raw" +%s)
  LC_ALL=C date -u -d "@$epoch" +%Y-%m-%dT%H:%M:%SZ
}

expected_days_status() {
  local file=$1
  local warn=$2
  local raw epoch now overdue days status
  raw=$(LC_ALL=C openssl x509 -in "$file" -noout -enddate)
  raw=${raw#notAfter=}
  epoch=$(LC_ALL=C date -u -d "$raw" +%s)
  now=$(date -u +%s)
  if [ "$epoch" -le "$now" ]; then
    overdue=$(( (now - epoch + 86399) / 86400 ))
    days=$((0 - overdue))
    status=expired
  else
    days=$(( (epoch - now) / 86400 ))
    if [ "$days" -le "$warn" ]; then
      status=expiring
    else
      status=ok
    fi
  fi
  printf '%s %s\n' "$days" "$status"
}

assert_cert_line() {
  local file=$1
  local out=$2
  local cn=$3
  local issuer=$4
  local warn=$5
  local line days status got_days got_status got_after got_issuer expect_after
  line=$(grep -F "subject_cn=$cn" "$out")
  [ -n "$line" ] || fail "missing certificate line for $cn"
  [ "$(printf '%s\n' "$line" | wc -l)" -eq 1 ] || fail "duplicate certificate line for $cn"
  read -r days status <<< "$(expected_days_status "$file" "$warn")"
  got_days=$(line_field "$line" days_remaining)
  got_status=$(line_field "$line" status)
  got_after=$(line_field "$line" not_after)
  got_issuer=$(line_field "$line" issuer)
  expect_after=$(expected_not_after "$file")
  # The scan timestamp is a moment earlier than this assertion. A certificate
  # created with -days N sits on a day boundary for about a second.
  delta=$((got_days - days))
  if [ "$delta" -lt 0 ]; then
    delta=$((0 - delta))
  fi
  [ "$delta" -le 1 ] || fail "$cn days_remaining $got_days != $days"
  [ "$got_status" = "$status" ] || fail "$cn status $got_status != $status"
  [ "$got_after" = "$expect_after" ] || fail "$cn not_after $got_after != $expect_after"
  [ "$got_issuer" = "$issuer" ] || fail "$cn issuer $got_issuer != $issuer"
  case "$line" in
    "tls_cert path="*) ;;
    *) fail "$cn line does not start with tls_cert path=" ;;
  esac
}

assert_bad_args() {
  local code=0
  set +e
  bash "$SCRIPT" "$@" >/dev/null 2>"$WORKDIR/bad.err"
  code=$?
  set -e
  [ "$code" -eq 2 ] || fail "expected exit 2 for: $*"
}

command -v openssl >/dev/null 2>&1 || fail "openssl is required to generate throwaway certificates"

CA_DIR="$WORKDIR/ca"
CERTS="$WORKDIR/certs"
ONLY_OK="$WORKDIR/only-ok"
LIMIT_DIR="$WORKDIR/limit"
PATH_A="$WORKDIR/path-a"
PATH_B="$WORKDIR/path-b"
mkdir -p "$CA_DIR/demoCA/newcerts" "$CERTS" "$ONLY_OK" "$LIMIT_DIR" "$PATH_A" "$PATH_B"
printf '01\n' > "$CA_DIR/demoCA/serial"
: > "$CA_DIR/demoCA/index.txt"

cat > "$CA_DIR/ca.cnf" << EOF
[ ca ]
default_ca = CA_default
[ CA_default ]
dir = $CA_DIR/demoCA
database = $CA_DIR/demoCA/index.txt
serial = $CA_DIR/demoCA/serial
new_certs_dir = $CA_DIR/demoCA/newcerts
certificate = $CA_DIR/ca.crt
private_key = $CA_DIR/ca.key
default_md = sha256
policy = policy_any
default_days = 1
x509_extensions = usr_cert
[ policy_any ]
commonName = supplied
countryName = optional
organizationName = optional
[ usr_cert ]
basicConstraints = CA:FALSE
EOF

openssl req -x509 -newkey rsa:2048 -keyout "$CA_DIR/ca.key" -out "$CA_DIR/ca.crt" \
  -days 3650 -noenc -subj "/CN=healthcheck-ca.example" -addext basicConstraints=CA:TRUE \
  >"$WORKDIR/openssl.log" 2>&1

openssl req -x509 -newkey rsa:2048 -keyout "$CERTS/ok.key" -out "$CERTS/ok.crt" \
  -days 400 -noenc -subj "/CN=healthcheck-ok.example" -addext basicConstraints=CA:FALSE \
  >>"$WORKDIR/openssl.log" 2>&1
cp "$CERTS/ok.crt" "$CERTS/ok-copy.crt"
cp "$CERTS/ok.crt" "$ONLY_OK/ok.crt"
cp "$CERTS/ok.key" "$ONLY_OK/ok.key"

openssl req -x509 -newkey rsa:2048 -keyout "$CERTS/soon.key" -out "$CERTS/soon.crt" \
  -days 2 -noenc -subj "/CN=healthcheck-soon.example" \
  >>"$WORKDIR/openssl.log" 2>&1
cp "$CERTS/soon.crt" "$PATH_A/soon.crt"

openssl req -new -newkey rsa:2048 -keyout "$CERTS/expired.key" -out "$CA_DIR/expired.csr" \
  -noenc -subj "/CN=healthcheck-expired.example" >>"$WORKDIR/openssl.log" 2>&1
openssl ca -batch -notext -config "$CA_DIR/ca.cnf" -in "$CA_DIR/expired.csr" \
  -out "$CERTS/expired.crt" -startdate 200101000000Z -enddate 200102000000Z \
  >>"$WORKDIR/openssl.log" 2>&1
cp "$CERTS/expired.crt" "$PATH_B/expired.crt"

openssl req -x509 -newkey rsa:2048 -keyout "$CERTS/server.key" -out "$WORKDIR/unused.crt" \
  -days 1 -noenc -subj "/CN=healthcheck-unused.example" >>"$WORKDIR/openssl.log" 2>&1
cp "$CERTS/server.key" "$CERTS/privkey.pem"
cp "$CERTS/server.key" "$CERTS/looks-like-cert.pem"
rm -f "$WORKDIR/unused.crt"

dd if=/dev/zero of="$CERTS/big.crt" bs=1024 count=129 status=none
# Move off the notAfter day boundary created by openssl -days.
sleep 2

index=0
while [ "$index" -lt 201 ]; do
  printf '%s\n' '-----BEGIN PKCS7-----' > "$LIMIT_DIR/f${index}.crt"
  index=$((index + 1))
done

(
  cd "$CERTS"
  sha256sum -- *.crt *.key *.pem > "$WORKDIR/before.sum"
)

assert_bad_args --cert-warn-days
assert_bad_args --cert-warn-days abc
assert_bad_args --cert-warn-days 36501
assert_bad_args --cert-warn-days 999999
assert_bad_args --cert-path
assert_bad_args --cert-path /
assert_bad_args --cert-path -secret
help_out="$WORKDIR/help.txt"
assert_exit 0 "$help_out" bash "$SCRIPT" --help
grep -q -- '--cert-warn-days' "$help_out"
grep -q -- '--cert-path' "$help_out"

main_out="$WORKDIR/main.txt"
assert_exit 1 "$main_out" bash "$SCRIPT" --module security --cert-path "$CERTS"
grep -q 'tls_cert_expiry: read-only probe' "$main_out"
grep -q '^warn_days=30$' "$main_out"
grep -q '^openssl: present$' "$main_out"
grep -q "tls_cert_root path=$CERTS state=present" "$main_out"
grep -q 'note: private keys are skipped and never printed' "$main_out"
assert_cert_line "$CERTS/ok.crt" "$main_out" healthcheck-ok.example CN=healthcheck-ok.example 30
assert_cert_line "$CERTS/soon.crt" "$main_out" healthcheck-soon.example CN=healthcheck-soon.example 30
assert_cert_line "$CERTS/expired.crt" "$main_out" healthcheck-expired.example CN=healthcheck-ca.example 30
assert_ge "$(summary_field "$main_out" expired)" 1 "expired count"
assert_ge "$(summary_field "$main_out" expiring)" 1 "expiring count"
assert_ge "$(summary_field "$main_out" ok)" 1 "ok count"
assert_ge "$(summary_field "$main_out" deduped)" 1 "deduped count"
assert_ge "$(summary_field "$main_out" skipped_large)" 1 "skipped_large count"
assert_ge "$(summary_field "$main_out" skipped_key)" 2 "skipped_key count"
# *.key is outside the certificate suffix set, so the file is never opened.
if grep -F "$CERTS/server.key" "$main_out"; then
  fail "a .key path was included in the report"
fi
grep -q "tls_cert_skip kind=private-key path=$CERTS/privkey.pem" "$main_out"
grep -q "tls_cert_skip kind=private-key path=$CERTS/looks-like-cert.pem" "$main_out"
if grep -F "path=$CERTS/big.crt" "$main_out"; then
  fail "large file was reported"
fi
if grep -q 'PRIVATE KEY' "$main_out"; then
  fail "private key header appeared in the report"
fi
awk 'NR==2 { print; exit }' "$CERTS/looks-like-cert.pem" > "$WORKDIR/secret-line.txt"
if grep -F -q -f "$WORKDIR/secret-line.txt" "$main_out"; then
  fail "private key material appeared in the report"
fi

if [ -d /etc/ssl/certs ]; then
  while IFS= read -r line; do
    path=$(line_field "$line" path)
    case "$path" in
      /etc/ssl/certs/*)
        case "$path" in
          */ca-certificates.crt|*/ca-bundle.crt|*/ca-bundle.trust.crt|*/tls-ca-bundle.pem)
            fail "reported CA bundle $path"
            ;;
        esac
        if [ -f "$path" ]; then
          bc=$(LC_ALL=C openssl x509 -in "$path" -noout -ext basicConstraints 2>/dev/null || true)
          case "$bc" in
            *CA:TRUE*) fail "reported CA certificate from /etc/ssl/certs: $path" ;;
          esac
        fi
        ;;
    esac
  done < <(grep '^tls_cert path=' "$main_out" || true)
fi
if [ -e /etc/ssl/certs/ca-certificates.crt ]; then
  if grep -F 'path=/etc/ssl/certs/ca-certificates.crt' "$main_out"; then
    fail "CA bundle path was reported"
  fi
fi
if [ -e /etc/ssl/certs/ACCVRAIZ1.pem ]; then
  if grep -F 'path=/etc/ssl/certs/ACCVRAIZ1.pem' "$main_out"; then
    fail "distro CA certificate was reported"
  fi
  [ "$(summary_field "$main_out" skipped_ca)" -ge 1 ]
fi

soon_bc=$(LC_ALL=C openssl x509 -in "$CERTS/soon.crt" -noout -ext basicConstraints 2>/dev/null || true)
case "$soon_bc" in
  *CA:TRUE*) ;;
  *) fail "fixture soon.crt was expected to be CA:TRUE so the trust-store filter stays location-specific" ;;
esac
grep -q 'subject_cn=healthcheck-soon.example' "$main_out"

zero_out="$WORKDIR/zero.txt"
assert_exit 1 "$zero_out" bash "$SCRIPT" --module security --cert-warn-days 0 --cert-path "$CERTS"
grep -q '^warn_days=0$' "$zero_out"
assert_cert_line "$CERTS/soon.crt" "$zero_out" healthcheck-soon.example CN=healthcheck-soon.example 0
assert_cert_line "$CERTS/expired.crt" "$zero_out" healthcheck-expired.example CN=healthcheck-ca.example 0
assert_cert_line "$CERTS/ok.crt" "$zero_out" healthcheck-ok.example CN=healthcheck-ok.example 0
[ "$(line_field "$(grep -F 'subject_cn=healthcheck-soon.example' "$main_out")" status)" = "expiring" ]
[ "$(line_field "$(grep -F 'subject_cn=healthcheck-soon.example' "$zero_out")" status)" = "ok" ]

ok_out="$WORKDIR/ok.txt"
assert_exit 0 "$ok_out" bash "$SCRIPT" --module security --cert-path "$ONLY_OK"
assert_cert_line "$ONLY_OK/ok.crt" "$ok_out" healthcheck-ok.example CN=healthcheck-ok.example 30
if grep -Eq '^tls_cert path=.* status=(expired|expiring)$' "$ok_out"; then
  fail "healthy fixture was flagged"
fi

file_out="$WORKDIR/file.txt"
assert_exit 1 "$file_out" bash "$SCRIPT" --module security --cert-path "$CERTS/expired.crt"
grep -q "tls_cert_root path=$CERTS/expired.crt state=file" "$file_out"
grep -q 'subject_cn=healthcheck-expired.example' "$file_out"
if grep -q 'subject_cn=healthcheck-soon.example' "$file_out"; then
  fail "single-file scan reported a certificate that was not requested"
fi

two_out="$WORKDIR/two.txt"
assert_exit 1 "$two_out" bash "$SCRIPT" --module security --cert-path "$PATH_A" --cert-path "$PATH_B"
grep -q "tls_cert_root path=$PATH_A state=present" "$two_out"
grep -q "tls_cert_root path=$PATH_B state=present" "$two_out"
grep -q 'subject_cn=healthcheck-soon.example' "$two_out"
grep -q 'subject_cn=healthcheck-expired.example' "$two_out"

md_out="$WORKDIR/md.txt"
assert_exit 1 "$md_out" bash "$SCRIPT" --module security --format markdown --cert-path "$CERTS/expired.crt"
grep -q 'subject_cn=healthcheck-expired.example' "$md_out"

json_out="$WORKDIR/security.json"
assert_exit 1 "$json_out" bash "$SCRIPT" --module security --format json --cert-path "$CERTS"
python3 -m json.tool "$json_out" >/dev/null
python3 - "$json_out" << 'PY'
import json
import sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
if data["metadata"]["script"] != "linux-health-check.sh":
    raise SystemExit("unexpected script metadata")
if data["metadata"]["module"] != "security":
    raise SystemExit("unexpected module metadata")
commands = data["modules"]["security"]["commands"]
tls = [item for item in commands if item["name"] == "tls_cert_expiry"]
if len(tls) != 1:
    raise SystemExit("tls_cert_expiry command missing")
output = tls[0]["output"]
if tls[0]["exit_code"] != 1:
    raise SystemExit("expected tls command exit 1 when a certificate is expired")
for needle in (
    "subject_cn=healthcheck-expired.example",
    "issuer=CN=healthcheck-ca.example",
    "status=expired",
    "subject_cn=healthcheck-soon.example",
    "status=expiring",
    "subject_cn=healthcheck-ok.example",
    "openssl: present",
):
    if needle not in output:
        raise SystemExit("missing %s" % needle)
if "PRIVATE KEY" in output:
    raise SystemExit("private key header leaked into JSON")
if data["summary"]["errors_count"] != 0:
    raise SystemExit("certificate expiry must be a warning, not an error")
if data["summary"]["status"] != "warning":
    raise SystemExit("expected warning summary")
print("json ok")
PY

disk_out="$WORKDIR/disk.json"
assert_exit 0 "$disk_out" bash "$SCRIPT" --module disk --format json --cert-path "$CERTS"
python3 -m json.tool "$disk_out" >/dev/null
python3 - "$disk_out" << 'PY'
import json
import sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
if data["modules"]["security"]["status"] != "skipped":
    raise SystemExit("security module should be skipped for --module disk")
blob = json.dumps(data["modules"]["disk"])
if "tls_cert_expiry" in blob or "healthcheck-expired.example" in blob:
    raise SystemExit("disk module included the certificate probe")
print("disk ok")
PY

limit_out="$WORKDIR/limit.txt"
assert_exit 1 "$limit_out" bash "$SCRIPT" --module security --cert-path "$LIMIT_DIR"
assert_eq "$(summary_field "$limit_out" scanned)" 200 "limit scan count"
assert_eq "$(summary_field "$limit_out" skipped_unsupported)" 200 "limit unsupported count"
grep -q '^tls_cert_limit max_files=200$' "$limit_out"
grep -q 'tls_cert_root path=/etc/ssl/certs state=skipped-limit' "$limit_out"

bindir="$WORKDIR/bin"
mkdir -p "$bindir"
for cmd in date hostname uname grep sed awk stat find readlink dirname mkdir sh; do
  src=$(command -v "$cmd" || true)
  if [ -n "$src" ]; then
    ln -s "$src" "$bindir/$cmd"
  fi
done
missing_out="$WORKDIR/missing.json"
missing_code=0
bash_bin=$(command -v bash)
set +e
env PATH="$bindir" "$bash_bin" "$SCRIPT" --module security --format json --cert-path "$CERTS" >"$missing_out" 2>"$missing_out.err"
missing_code=$?
set -e
if [ "$missing_code" -ne 0 ] && [ "$missing_code" -ne 1 ]; then
  cat "$missing_out.err" >&2 || true
  fail "openssl not-found path exited $missing_code"
fi
python3 -m json.tool "$missing_out" >/dev/null
python3 - "$missing_out" << 'PY'
import json
import sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
tls = [item for item in data["modules"]["security"]["commands"] if item["name"] == "tls_cert_expiry"]
if len(tls) != 1:
    raise SystemExit("tls command missing when openssl is absent")
if tls[0]["exit_code"] != 0:
    raise SystemExit("missing openssl must not fail the probe")
output = tls[0]["output"]
if "openssl: not-found" not in output:
    raise SystemExit("missing not-found marker")
if "healthcheck-expired.example" in output or "status=expired" in output:
    raise SystemExit("probe scanned certificates without openssl")
print("openssl-missing ok")
PY

(
  cd "$CERTS"
  sha256sum -c "$WORKDIR/before.sum" >/dev/null
) || fail "certificate or key files were modified"

printf 'tls certificate expiry checks passed\n'

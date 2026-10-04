#!/usr/bin/env bash
set -euo pipefail

# NUMERA production preflight
# Validates configuration shape only. It never starts services and never prints secrets.

failures=0

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

pass() {
  printf 'PASS: %s\n' "$1"
}

require_env() {
  local name="$1"
  local value="${!name-}"
  if [[ -z "$value" ]]; then
    fail "$name is not set"
  else
    pass "$name is set"
  fi
}

check_password() {
  local name="$1"
  local value="${!name-}"
  if [[ -z "$value" ]]; then
    return
  fi
  if (( ${#value} < 16 )); then
    fail "$name must be at least 16 characters"
  else
    pass "$name meets the minimum length"
  fi
}

require_env OJAZ_IMAGE
require_env MARIADB_ROOT_PASSWORD
require_env SITE_ADMIN_PASSWORD

check_password MARIADB_ROOT_PASSWORD
check_password SITE_ADMIN_PASSWORD

if [[ -n "${OJAZ_IMAGE-}" ]]; then
  if [[ "$OJAZ_IMAGE" =~ ^ghcr\.io/[^/]+/[^@]+@sha256:[a-f0-9]{64}$ ]]; then
    pass 'OJAZ_IMAGE is pinned to an immutable GHCR digest'
  else
    fail 'OJAZ_IMAGE must use ghcr.io/<owner>/<image>@sha256:<64 lowercase hex characters>'
  fi
fi

compose_file="${OJAZ_COMPOSE_FILE:-deployment/compose.ojaz-reference.yaml}"
if [[ -f "$compose_file" ]]; then
  pass "Compose file exists: $compose_file"
else
  fail "Compose file does not exist: $compose_file"
fi

if command -v docker >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    if docker compose -f "$compose_file" config --quiet >/dev/null 2>&1; then
      pass 'Docker Compose syntax is valid'
    else
      fail 'Docker Compose syntax validation failed'
    fi
  else
    fail 'Docker Compose is not available'
  fi
else
  printf 'WARN: Docker is unavailable; skipped Compose syntax validation\n'
fi

if (( failures > 0 )); then
  printf 'Preflight failed with %d issue(s). No services were started.\n' "$failures" >&2
  exit 1
fi

printf 'Preflight passed. No services were started and no secret values were printed.\n'

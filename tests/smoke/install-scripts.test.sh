#!/bin/bash

# Smoke test for install.sh / uninstall.sh
#
# Verifies that the scripts create and remove the expected files
# in the correct locations. Uses a REAL Chrome NativeMessagingHosts
# directory (the standard location) because Chrome requires the
# manifest to live there.
#
# This test is safe to run — it cleans up after itself.

# NOTE: Intentionally no `set -e` here — we track pass/fail ourselves and
# need to keep running even if a subcommand fails.

RED='\033[0;31m'; GREEN='\033[0;32m'; BOLD='\033[1m'; RESET='\033[0m'
PASS=0; FAIL=0

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
NATIVE_MESSAGING_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
HOST_BINARY_DEST="$NATIVE_MESSAGING_DIR/open-in-default-browser-host"
MANIFEST_PATH="$NATIVE_MESSAGING_DIR/com.openindefaultbrowser.host.json"

# A dummy 32-character extension ID for testing
TEST_EXT_ID="aaaabbbbccccddddeeeeffffgggghhhh"

assert_file_exists() {
  if [ -f "$1" ]; then
    echo -e "  ${GREEN}✓ PASS${RESET}: $2"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗ FAIL${RESET}: $2 — file not found: $1"
    FAIL=$((FAIL + 1))
  fi
}

assert_file_missing() {
  if [ ! -f "$1" ]; then
    echo -e "  ${GREEN}✓ PASS${RESET}: $2"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗ FAIL${RESET}: $2 — file still exists: $1"
    FAIL=$((FAIL + 1))
  fi
}

assert_file_executable() {
  if [ -x "$1" ]; then
    echo -e "  ${GREEN}✓ PASS${RESET}: $2"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗ FAIL${RESET}: $2 — file not executable: $1"
    FAIL=$((FAIL + 1))
  fi
}

assert_file_contains() {
  if grep -q "$2" "$1" 2>/dev/null; then
    echo -e "  ${GREEN}✓ PASS${RESET}: $3"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗ FAIL${RESET}: $3 — pattern '$2' not found in $1"
    FAIL=$((FAIL + 1))
  fi
}

assert_valid_json() {
  if /usr/bin/python3 -c "import json; json.load(open('$1'))" 2>/dev/null; then
    echo -e "  ${GREEN}✓ PASS${RESET}: $2"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗ FAIL${RESET}: $2 — not valid JSON: $1"
    FAIL=$((FAIL + 1))
  fi
}

# ── Cleanup any previous test artifacts ──────────────────────────────────────
cleanup() {
  rm -f "$HOST_BINARY_DEST" "$MANIFEST_PATH" 2>/dev/null || true
}
trap 'cleanup; cleanup_staging' EXIT

echo ""
echo -e "${BOLD}Install Script Smoke Tests${RESET}"
echo "════════════════════════════"
echo ""

# ── Pre-flight: make sure host-binary exists ─────────────────────────────────
if [ ! -f "$SCRIPT_DIR/native-host/host-binary" ]; then
  echo -e "${RED}✗ host-binary not found. Build it first:${RESET}"
  echo "  cd native-host && bun build --compile --minify --sourcemap ./host.js --outfile host-binary"
  exit 1
fi

# ── Create staging directory that mimics release ZIP layout ──────────────────
# install.sh expects host-binary in the same directory (as in the ZIP).
STAGING_DIR="$(mktemp -d)"
ln -sf "$SCRIPT_DIR/native-host/host-binary" "$STAGING_DIR/host-binary"
ln -sf "$SCRIPT_DIR/install.sh"              "$STAGING_DIR/install.sh"
ln -sf "$SCRIPT_DIR/uninstall.sh"            "$STAGING_DIR/uninstall.sh"

cleanup_staging() {
  rm -rf "$STAGING_DIR" 2>/dev/null || true
}

# ── Ensure clean starting state ──────────────────────────────────────────────
cleanup

# ══════════════════════════════════════════════════════════════════════════════
echo -e "${BOLD}Test 1: install.sh creates files correctly${RESET}"
echo ""

"$STAGING_DIR/install.sh" "$TEST_EXT_ID" > /dev/null 2>&1

assert_file_exists  "$HOST_BINARY_DEST" "host binary installed"
assert_file_executable "$HOST_BINARY_DEST" "host binary is executable"
assert_file_exists  "$MANIFEST_PATH" "manifest created"
assert_valid_json   "$MANIFEST_PATH" "manifest is valid JSON"
assert_file_contains "$MANIFEST_PATH" "$TEST_EXT_ID" "manifest contains test extension ID"
assert_file_contains "$MANIFEST_PATH" "com.openindefaultbrowser.host" "manifest contains host name"
assert_file_contains "$MANIFEST_PATH" "stdio" "manifest specifies stdio type"

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo -e "${BOLD}Test 2: uninstall.sh removes files${RESET}"
echo ""

"$STAGING_DIR/uninstall.sh" > /dev/null 2>&1

assert_file_missing "$HOST_BINARY_DEST" "host binary removed"
assert_file_missing "$MANIFEST_PATH" "manifest removed"

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo -e "${BOLD}Test 3: uninstall.sh is idempotent (runs again without error)${RESET}"
echo ""

if "$STAGING_DIR/uninstall.sh" > /dev/null 2>&1; then
  echo -e "  ${GREEN}✓ PASS${RESET}: uninstall.sh exits 0 when nothing to remove"
  PASS=$((PASS + 1))
else
  echo -e "  ${RED}✗ FAIL${RESET}: uninstall.sh exited non-zero on second run"
  FAIL=$((FAIL + 1))
fi

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo -e "${BOLD}Test 4: install.sh rejects invalid extension ID${RESET}"
echo ""

if "$STAGING_DIR/install.sh" "too-short" > /dev/null 2>&1; then
  echo -e "  ${RED}✗ FAIL${RESET}: install.sh should reject short extension ID"
  FAIL=$((FAIL + 1))
else
  echo -e "  ${GREEN}✓ PASS${RESET}: install.sh rejects short extension ID"
  PASS=$((PASS + 1))
fi

echo ""

# ── Summary ──────────────────────────────────────────────────────────────────
echo "════════════════════════════"
TOTAL=$((PASS + FAIL))
echo -e "${BOLD}Results: $PASS/$TOTAL passed${RESET}"

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}$FAIL test(s) failed${RESET}"
  exit 1
else
  echo -e "${GREEN}All tests passed ✓${RESET}"
  exit 0
fi

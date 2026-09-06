#!/bin/bash

# Open in Default Browser — Native Host Uninstaller
# Removes the native messaging host files installed by install.sh

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; BOLD='\033[1m'; CYAN='\033[0;36m'; RESET='\033[0m'

HOST_NAME="com.openindefaultbrowser.host"
NATIVE_MESSAGING_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
HOST_BINARY_DEST="$NATIVE_MESSAGING_DIR/open-in-default-browser-host"
MANIFEST_PATH="$NATIVE_MESSAGING_DIR/$HOST_NAME.json"

echo ""
echo -e "${BOLD}${CYAN}Open in Default Browser — Uninstaller${RESET}"
echo -e "${CYAN}══════════════════════════════════════${RESET}"
echo ""

ERRORS=0

if [ -f "$HOST_BINARY_DEST" ]; then
  rm "$HOST_BINARY_DEST"
  echo -e "${GREEN}✓ Removed host binary${RESET}"
else
  echo "  (host binary not found — already removed?)"
fi

if [ -f "$MANIFEST_PATH" ]; then
  rm "$MANIFEST_PATH"
  echo -e "${GREEN}✓ Removed manifest${RESET}"
else
  echo "  (manifest not found — already removed?)"
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo -e "${BOLD}${GREEN}Uninstalled successfully.${RESET}"
else
  echo -e "${RED}Uninstall completed with errors (see above).${RESET}"
fi
echo ""
echo "  You can also remove the Chrome extension at chrome://extensions/"
echo ""

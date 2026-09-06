#!/bin/bash

# Open in Default Browser — Native Host Installer
# Installs the native messaging host so the Chrome extension can open links
# in your system's default browser.
#
# Usage: ./install.sh [EXTENSION_ID]
#   EXTENSION_ID  (optional) your 32-character Chrome extension ID.
#                 If omitted, the script tries to auto-detect it.

set -e

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; RESET='\033[0m'

# ── Constants ─────────────────────────────────────────────────────────────────
HOST_NAME="com.openindefaultbrowser.host"
NATIVE_MESSAGING_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
HOST_BINARY_DEST="$NATIVE_MESSAGING_DIR/open-in-default-browser-host"
MANIFEST_PATH="$NATIVE_MESSAGING_DIR/$HOST_NAME.json"
CHROME_DIR="$HOME/Library/Application Support/Google/Chrome"

echo ""
echo -e "${BOLD}${CYAN}Open in Default Browser — Installer${RESET}"
echo -e "${CYAN}════════════════════════════════════${RESET}"
echo ""

# ── 1. Locate host-binary ─────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOST_BINARY_SOURCE="$SCRIPT_DIR/host-binary"

if [ ! -f "$HOST_BINARY_SOURCE" ]; then
  echo -e "${RED}✗ Error: host-binary not found in the same folder as this script.${RESET}"
  echo "  Expected: $HOST_BINARY_SOURCE"
  echo ""
  echo "  Make sure you extracted the full ZIP archive and run this script"
  echo "  from inside the extracted folder."
  exit 1
fi
echo -e "${GREEN}✓ Found host binary${RESET}"

# ── 2. Detect Extension ID ────────────────────────────────────────────────────
EXTENSION_ID=""

# Allow passing extension ID as argument (useful for developers / testing)
if [ -n "$1" ]; then
  EXTENSION_ID="$1"
  echo -e "${GREEN}✓ Using provided extension ID: ${BOLD}$EXTENSION_ID${RESET}"
fi

# Auto-detect via Python 3 (/usr/bin/python3 is a system binary present on every macOS 10.15+)
# Use absolute path so it works even if PATH is modified or python3 is shadowed.
if [ -z "$EXTENSION_ID" ] && [ -x "/usr/bin/python3" ]; then
  EXTENSION_ID=$(/usr/bin/python3 - <<'PYEOF'
import os, json, sys

chrome = os.path.expanduser("~/Library/Application Support/Google/Chrome")
if not os.path.isdir(chrome):
    sys.exit(0)

TARGET_NAME = "Open in Default Browser"
KEYWORDS = ["open-in-default-browser", "open", "browser"]

def matches_name(name):
    if not name:
        return False
    low = name.lower()
    return (TARGET_NAME.lower() in low or
            "default browser" in low or
            ("open" in low and "browser" in low))

def matches_path(path):
    if not path:
        return False
    low = path.lower()
    return "open-in-default-browser" in low

def search_pref_file(pref_path):
    try:
        with open(pref_path, "r", encoding="utf-8", errors="ignore") as f:
            data = json.load(f)
        settings = data.get("extensions", {}).get("settings", {})
        for ext_id, info in settings.items():
            if not isinstance(info, dict):
                continue
            path_str = info.get("path", "")
            manifest = info.get("manifest", {})
            name = manifest.get("name", "") if isinstance(manifest, dict) else ""

            # For unpacked extensions, load manifest.json from disk path
            if (not name) and path_str and os.path.isdir(path_str):
                mp = os.path.join(path_str, "manifest.json")
                if os.path.isfile(mp):
                    try:
                        with open(mp) as mf:
                            m = json.load(mf)
                        name = m.get("name", "")
                    except Exception:
                        pass

            if matches_name(name) or matches_path(path_str):
                print(ext_id)
                return True
        return False
    except Exception:
        return False

# Discover profiles
try:
    entries = os.listdir(chrome)
except Exception:
    sys.exit(0)

profiles = [e for e in entries if e == "Default" or e.startswith("Profile ")]
if not profiles:
    profiles = ["Default"]

for profile in profiles:
    for pref in ["Secure Preferences", "Preferences"]:
        pref_path = os.path.join(chrome, profile, pref)
        if os.path.isfile(pref_path):
            if search_pref_file(pref_path):
                sys.exit(0)

# Fallback: search Extensions directories
for profile in profiles:
    ext_dir = os.path.join(chrome, profile, "Extensions")
    if not os.path.isdir(ext_dir):
        continue
    for ext_id in os.listdir(ext_dir):
        for version in os.listdir(os.path.join(ext_dir, ext_id)):
            mp = os.path.join(ext_dir, ext_id, version, "manifest.json")
            if os.path.isfile(mp):
                try:
                    with open(mp) as f:
                        m = json.load(f)
                    if matches_name(m.get("name", "")):
                        print(ext_id)
                        sys.exit(0)
                except Exception:
                    pass
PYEOF
  )
  if [ -n "$EXTENSION_ID" ]; then
    echo -e "${GREEN}✓ Auto-detected extension ID: ${BOLD}$EXTENSION_ID${RESET}"
  fi
fi


# Manual entry if still not found
if [ -z "$EXTENSION_ID" ]; then
  echo ""
  echo -e "${YELLOW}⚠ Could not auto-detect the Chrome extension.${RESET}"
  echo ""
  echo "  This usually means the extension is not yet installed in Chrome."
  echo ""
  echo -e "  ${BOLD}To get your Extension ID:${RESET}"
  echo "    1. Open Chrome and go to:  chrome://extensions/"
  echo "    2. Enable Developer mode (toggle in the top-right corner)"
  echo "    3. Find 'Open in Default Browser'"
  echo "    4. Copy the ID shown below the extension name (32 characters)"
  echo ""
  printf "  Enter Extension ID (or press Enter to skip and install without one): "
  read -r EXTENSION_ID

  # Strip whitespace
  EXTENSION_ID="${EXTENSION_ID// /}"

  if [ -z "$EXTENSION_ID" ]; then
    echo ""
    echo -e "${YELLOW}⚠ Skipping extension ID — installing host binary only.${RESET}"
    echo "  Run this script again after installing the Chrome extension to"
    echo "  create the full manifest."
    echo ""
    SKIP_MANIFEST=true
  elif [ "${#EXTENSION_ID}" -ne 32 ]; then
    echo -e "${RED}✗ Invalid extension ID — must be exactly 32 characters (got ${#EXTENSION_ID}).${RESET}"
    echo "  Please re-run the script with the correct ID."
    exit 1
  fi
fi

# Validate length if we have an ID
if [ -n "$EXTENSION_ID" ] && [ "${#EXTENSION_ID}" -ne 32 ]; then
  echo -e "${RED}✗ Invalid extension ID — must be exactly 32 characters (got ${#EXTENSION_ID}).${RESET}"
  exit 1
fi

# ── 3. Create NativeMessagingHosts directory ───────────────────────────────────
mkdir -p "$NATIVE_MESSAGING_DIR"
echo -e "${GREEN}✓ Native messaging directory ready${RESET}"

# ── 4. Copy host binary ────────────────────────────────────────────────────────
cp "$HOST_BINARY_SOURCE" "$HOST_BINARY_DEST"
chmod +x "$HOST_BINARY_DEST"
# Strip any quarantine attribute that may have survived the download
xattr -cr "$HOST_BINARY_DEST" 2>/dev/null || true
echo -e "${GREEN}✓ Host binary installed${RESET}"

# ── 5. Write native messaging manifest ────────────────────────────────────────
if [ "${SKIP_MANIFEST:-false}" = "false" ]; then
  cat > "$MANIFEST_PATH" <<EOF
{
  "name": "$HOST_NAME",
  "description": "Native messaging host to open URLs in default browser",
  "path": "$HOST_BINARY_DEST",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$EXTENSION_ID/"
  ]
}
EOF
  echo -e "${GREEN}✓ Manifest written${RESET}"
fi

# ── 6. Done ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}Installation complete!${RESET}"
echo ""
echo "  Next step: right-click any link in Chrome and choose"
echo -e "  ${BOLD}'Open in default browser'${RESET} to test."
echo ""
echo "  To uninstall, run:  ./uninstall.sh"
echo ""

#!/usr/bin/env bash
# Genshin Impact wish URL extractor for Linux (Proton / Wine / Lutris / Heroic).
# Usage: ./getlink.sh [/path/to/output_log.txt]
# Open Wish History > History in game first so the URL is cached.
set -euo pipefail

LOG="${1:-}"

# 1. Locate output_log.txt (newest one under $HOME if not given)
if [[ -z "$LOG" ]]; then
  LOG=$(find "$HOME" \( -path '*/proc' -prune \) -o \
        -path '*/miHoYo/Genshin Impact/output_log.txt' -printf '%T@ %p\n' 2>/dev/null \
        | sort -nr | head -n1 | cut -d' ' -f2- || true)
fi
[[ -f "$LOG" ]] || { echo "output_log.txt not found. Pass its path as an argument."; exit 1; }

# 2. Wine prefix root (everything before /drive_c)
PFX="${LOG%/drive_c/*}"

# 3. Game path from the log (Windows style, e.g. D:/Games/.../GenshinImpact_Data)
WINPATH=$(grep -aoP '(?<![A-Za-z])[A-Za-z]:/.*?(GenshinImpact_Data|YuanShen_Data)' "$LOG" | head -n1 || true)
[[ -n "$WINPATH" ]] || { echo "Game path not found in log. Launch the game once, then retry."; exit 1; }

# 4. Convert drive letter to a real path via the prefix's dosdevices
DRIVE="${WINPATH:0:1}"
BASE=$(readlink -f "$PFX/dosdevices/${DRIVE,,}:")
GAME="$BASE/${WINPATH:3}"
[[ -d "$GAME" ]] || { echo "Resolved game dir does not exist: $GAME"; exit 1; }

# 5. Newest webCaches data_2
CACHE=$(find "$GAME/webCaches" -type f -name data_2 -path '*Cache_Data*' -printf '%T@ %p\n' 2>/dev/null \
        | sort -nr | head -n1 | cut -d' ' -f2- || true)
[[ -f "$CACHE" ]] || { echo "Cache not found. Open the Wish History page in game first."; exit 1; }

# 6. Extract last wish URL from the binary cache
TMP=$(mktemp); trap 'rm -f "$TMP"' EXIT
cp "$CACHE" "$TMP"
URL=$(tr -c '[:print:]' '\n' < "$TMP" | grep -oE 'https://[[:print:]]*getGachaLog[[:print:]]*' | tail -n1 || true)
[[ -n "$URL" ]] || { echo "No wish URL in cache. Open Wish History in game, then retry."; exit 1; }

# 7. Validate
RES=$(curl -s "$URL" || true)
if [[ "$RES" == *'"retcode":0'* ]]; then
  echo "Link valid."
else
  echo "Link expired or invalid. Reopen Wish History in game and rerun."
  exit 1
fi

# 8. Copy to clipboard
if   command -v wl-copy >/dev/null; then printf '%s' "$URL" | wl-copy && echo "Copied to clipboard (wl-copy)."
elif command -v xclip   >/dev/null; then printf '%s' "$URL" | xclip -selection clipboard && echo "Copied to clipboard (xclip)."
elif command -v xsel    >/dev/null; then printf '%s' "$URL" | xsel -ib && echo "Copied to clipboard (xsel)."
else echo "No clipboard tool found. URL:"; echo "$URL"
fi

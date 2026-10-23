#!/bin/bash
# Turns the local CyberPatriot folder into files.sql, which mirrors it into
# the cyberpatriot_files table. Paste the output into the Supabase SQL editor.
#   ./sync-files.sh [source-dir]   (default: ~/PWPD Projects/CyberPatriot)
set -euo pipefail
SRC="${1:-$HOME/PWPD Projects/CyberPatriot}"
OUT="$(cd "$(dirname "$0")" && pwd)/files.sql"
cd "$SRC"

{
  echo "begin;"
  echo "delete from public.cyberpatriot_files;"
  find . -type f ! -name '.DS_Store' ! -name '._*' | sed 's|^\./||' | sort | while IFS= read -r f; do
    path=${f//\'/\'\'}
    size=$(stat -f %z "$f")
    printf "insert into public.cyberpatriot_files (path, content_b64, size) values ('%s', '%s', %s);\n" \
      "$path" "$(base64 -i "$f" | tr -d '\n')" "$size"
  done
  echo "commit;"
} > "$OUT"

echo "Wrote $OUT ($(grep -c '^insert' "$OUT") files). Paste it into the Supabase SQL editor."

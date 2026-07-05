#!/usr/bin/env bash
#
# Automated Kaggle dataset downloader.
# Reads dataset slugs from datasets.txt (or slugs passed as arguments)
# and downloads + unzips each into $DOWNLOAD_DIR (default ./data).
#
# Usage:
#   ./download.sh                      # download everything in datasets.txt
#   ./download.sh owner/dataset-name   # download specific dataset(s)
#
# Configuration via .env (see .env.example):
#   KAGGLE_USERNAME, KAGGLE_KEY         — legacy API credentials
#   KAGGLE_API_TOKEN                    — token-based credential (KGAT_...)
#   DOWNLOAD_DIR                        — destination directory
#
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KAGGLE="$DIR/.venv/bin/kaggle"
LIST="$DIR/datasets.txt"

# Load .env if present so KAGGLE_USERNAME/KEY/TOKEN and DOWNLOAD_DIR are exported.
if [[ -f "$DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$DIR/.env"
  set +a
fi

# Resolve DOWNLOAD_DIR: relative paths are anchored at the project root.
DEST="${DOWNLOAD_DIR:-$DIR/data}"
if [[ "$DEST" != /* ]]; then
  DEST="$DIR/$DEST"
fi

if [[ ! -x "$KAGGLE" ]]; then
  echo "ERROR: kaggle CLI not found at $KAGGLE" >&2
  echo "       Run: python3 -m venv .venv && .venv/bin/pip install kaggle" >&2
  exit 1
fi

if [[ ! -f "$HOME/.kaggle/kaggle.json" \
   && ! -f "$HOME/.kaggle/access_token" \
   && -z "${KAGGLE_USERNAME:-}" \
   && -z "${KAGGLE_API_TOKEN:-}" ]]; then
  echo "ERROR: no Kaggle credentials. Provide one of:" >&2
  echo "  - .env with KAGGLE_USERNAME + KAGGLE_KEY (or KAGGLE_API_TOKEN)" >&2
  echo "  - ~/.kaggle/access_token   (KGAT_... token, chmod 600)" >&2
  echo "  - ~/.kaggle/kaggle.json    (username+key, chmod 600)" >&2
  echo "  - KAGGLE_API_TOKEN env var" >&2
  exit 1
fi

# Collect slugs: from args if given, otherwise from the list file.
slugs=()
if [[ $# -gt 0 ]]; then
  slugs=("$@")
elif [[ -f "$LIST" ]]; then
  while IFS= read -r line; do
    line="${line%%#*}"                       # strip inline comments
    line="$(echo "$line" | xargs)"           # trim whitespace
    [[ -n "$line" ]] && slugs+=("$line")
  done < "$LIST"
fi

if [[ ${#slugs[@]} -eq 0 ]]; then
  echo "Nothing to download. Add dataset slugs to $LIST or pass them as arguments." >&2
  exit 0
fi

mkdir -p "$DEST"
for slug in "${slugs[@]}"; do
  name="${slug##*/}"
  out="$DEST/$name"
  echo ">>> Downloading $slug -> $out"
  mkdir -p "$out"
  "$KAGGLE" datasets download -d "$slug" -p "$out" --unzip
done

echo "Done. Files are in $DEST/"

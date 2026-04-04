#!/bin/bash
# Find broken wikilinks in the wiki
set -euo pipefail

if [ ! -d wiki/ ]; then
  echo "No wiki/ directory found."
  exit 0
fi

echo "=== Broken Wikilinks ==="
broken=0

# Collect all article titles from frontmatter and filenames
titles_file=$(mktemp)
for f in wiki/*.md wiki/**/*.md 2>/dev/null; do
  [ -f "$f" ] || continue
  # Extract title from frontmatter
  grep '^title:' "$f" 2>/dev/null | head -1 | sed 's/^title: *"*//;s/"*$//' >> "$titles_file"
  # Also add filename without extension as fallback
  basename "$f" .md >> "$titles_file"
done

# Extract all wikilink targets and check against known titles
grep -roh '\[\[[^]|]*' wiki/ 2>/dev/null | sed 's/\[\[//;s/#.*//' | sort -u | while read -r target; do
  [ -z "$target" ] && continue
  if ! grep -qi "^${target}$" "$titles_file" 2>/dev/null; then
    echo "BROKEN: [[${target}]]"
    broken=$((broken + 1))
  fi
done

rm -f "$titles_file"
echo "---"
echo "Scan complete."

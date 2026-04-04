#!/bin/bash
# Find wiki articles not linked from any other article
set -euo pipefail

if [ ! -d wiki/ ]; then
  echo "No wiki/ directory found."
  exit 0
fi

echo "=== Orphan Articles ==="
orphan_count=0

for article in wiki/*.md wiki/**/*.md 2>/dev/null; do
  [ -f "$article" ] || continue
  base=$(basename "$article" .md)

  # Skip index/meta files
  [[ "$base" == _* ]] && continue

  # Get the article title from frontmatter
  title=$(grep '^title:' "$article" 2>/dev/null | head -1 | sed 's/^title: *"*//;s/"*$//')
  [ -z "$title" ] && title="$base"

  # Check if any OTHER wiki file links to this article (by title or filename)
  linked=false
  if grep -rl "\[\[${title}" wiki/ 2>/dev/null | grep -v "$article" | grep -q .; then
    linked=true
  fi
  if [ "$linked" = false ] && grep -rl "\[\[${base}" wiki/ 2>/dev/null | grep -v "$article" | grep -q .; then
    linked=true
  fi

  if [ "$linked" = false ]; then
    echo "ORPHAN: $article ($title)"
    orphan_count=$((orphan_count + 1))
  fi
done

echo "---"
echo "Total orphans: $orphan_count"

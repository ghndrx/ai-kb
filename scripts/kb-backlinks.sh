#!/bin/bash
# Generate backlinks report — auto-generated link graph
# Shows which articles link to which, enabling link graph visualization
set -euo pipefail

if [ ! -d wiki/ ]; then
  echo "No wiki/ directory found."
  exit 0
fi

echo "=== Backlink Graph ==="
echo ""

# Build adjacency list: source -> targets
for article in wiki/*.md wiki/**/*.md 2>/dev/null; do
  [ -f "$article" ] || continue
  base=$(basename "$article" .md)
  [[ "$base" == _* ]] && continue

  title=$(grep '^title:' "$article" 2>/dev/null | head -1 | sed 's/^title: *"*//;s/"*$//')
  [ -z "$title" ] && title="$base"

  targets=$(grep -oh '\[\[[^]|]*' "$article" 2>/dev/null | sed 's/\[\[//;s/#.*//' | sort -u)
  if [ -n "$targets" ]; then
    echo "## $title"
    echo "$targets" | while read -r t; do
      [ -n "$t" ] && echo "  -> $t"
    done
    echo ""
  fi
done

echo "=== Incoming Links (Backlinks) ==="
echo ""

# For each article, find who links TO it
for article in wiki/*.md wiki/**/*.md 2>/dev/null; do
  [ -f "$article" ] || continue
  base=$(basename "$article" .md)
  [[ "$base" == _* ]] && continue

  title=$(grep '^title:' "$article" 2>/dev/null | head -1 | sed 's/^title: *"*//;s/"*$//')
  [ -z "$title" ] && title="$base"

  # Find all files that link to this article
  linkers=$(grep -rl "\[\[${title}" wiki/ 2>/dev/null | grep -v "$article" || true)
  if [ -n "$linkers" ]; then
    echo "## $title"
    echo "$linkers" | while read -r src; do
      src_title=$(grep '^title:' "$src" 2>/dev/null | head -1 | sed 's/^title: *"*//;s/"*$//')
      echo "  <- $src_title"
    done
    echo ""
  fi
done

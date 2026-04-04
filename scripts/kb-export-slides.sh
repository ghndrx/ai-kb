#!/bin/bash
# Export wiki articles as Marp slide decks
# Usage: bash scripts/kb-export-slides.sh [article-slug]
# Requires: marp-cli (npm install -g @marp-team/marp-cli)
set -euo pipefail

SLIDES_DIR="output/slides"
mkdir -p "$SLIDES_DIR"

if ! command -v marp &> /dev/null; then
  echo "marp-cli not found. Install with: npm install -g @marp-team/marp-cli"
  exit 1
fi

if [ $# -eq 0 ]; then
  # Export all wiki articles
  files=$(find wiki/ -name '*.md' ! -name '_*' 2>/dev/null)
else
  files="wiki/$1.md"
  if [ ! -f "$files" ]; then
    echo "Article not found: $files"
    exit 1
  fi
fi

for article in $files; do
  slug=$(basename "$article" .md)
  title=$(grep '^title:' "$article" 2>/dev/null | head -1 | sed 's/^title: *"*//;s/"*$//')

  # Generate Marp-compatible markdown
  slide_file="$SLIDES_DIR/${slug}-slides.md"

  cat > "$slide_file" << HEADER
---
marp: true
theme: default
paginate: true
header: "$title"
footer: "Pluto Health Knowledge Base"
---

# $title

---

HEADER

  # Convert H2 sections into slide breaks
  sed -n '/^## /,/^---$/p' "$article" | sed 's/^## /---\n\n## /' >> "$slide_file"

  echo "Generated: $slide_file"
done

echo ""
echo "To convert to HTML: marp $SLIDES_DIR/*.md"
echo "To convert to PDF:  marp --pdf $SLIDES_DIR/*.md"

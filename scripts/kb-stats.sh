#!/bin/bash
# Knowledge Base Statistics
set -euo pipefail

echo "=== KB Stats ==="

raw_count=$(find raw/ -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
wiki_count=$(find wiki/ -name '*.md' ! -name '_*' 2>/dev/null | wc -l | tr -d ' ')
index_count=$(find wiki/ -name '_*.md' 2>/dev/null | wc -l | tr -d ' ')
output_count=$(find output/ -name '*.md' 2>/dev/null | wc -l | tr -d ' ')

wiki_words=0
if [ -d wiki/ ]; then
  wiki_words=$(find wiki/ -name '*.md' -exec cat {} + 2>/dev/null | wc -w | tr -d ' ')
fi

wiki_links=0
if [ -d wiki/ ]; then
  wiki_links=$(grep -roh '\[\[[^]]*\]\]' wiki/ 2>/dev/null | wc -l | tr -d ' ')
fi

echo "Raw files:      $raw_count"
echo "Wiki articles:  $wiki_count"
echo "Index pages:    $index_count"
echo "Output files:   $output_count"
echo "Wiki words:     $wiki_words"
echo "Wiki links:     $wiki_links"

if [ "$wiki_count" -gt 0 ] 2>/dev/null; then
  avg_links=$((wiki_links / wiki_count))
  echo "Avg links/article: $avg_links"
fi

if [ -f .kb-last-compile ]; then
  echo "Last compiled:  $(stat -f '%Sm' -t '%Y-%m-%d %H:%M' .kb-last-compile 2>/dev/null || stat -c '%y' .kb-last-compile 2>/dev/null | cut -d. -f1)"
fi

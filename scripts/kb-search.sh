#!/bin/bash
# Search Engine — CLI search across the knowledge base
# Usage: bash scripts/kb-search.sh <query>
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: bash scripts/kb-search.sh <query>"
  echo "Search across wiki articles, raw materials, and outputs."
  exit 1
fi

query="$*"

echo "=== KB Search: '$query' ==="
echo ""

# Search wiki articles (highest priority)
echo "--- Wiki Articles ---"
wiki_results=$(grep -ril "$query" wiki/ 2>/dev/null | head -20 || true)
if [ -n "$wiki_results" ]; then
  echo "$wiki_results" | while read -r f; do
    title=$(grep '^title:' "$f" 2>/dev/null | head -1 | sed 's/^title: *"*//;s/"*$//')
    summary=$(grep '^summary:' "$f" 2>/dev/null | head -1 | sed 's/^summary: *"*//;s/"*$//')
    echo "  [$title] $f"
    [ -n "$summary" ] && echo "    $summary"
  done
else
  echo "  (no matches)"
fi
echo ""

# Search raw materials
echo "--- Raw Materials ---"
raw_results=$(grep -ril "$query" raw/ 2>/dev/null | head -20 || true)
if [ -n "$raw_results" ]; then
  echo "$raw_results" | while read -r f; do
    echo "  $f"
  done
else
  echo "  (no matches)"
fi
echo ""

# Search outputs
echo "--- Outputs ---"
output_results=$(grep -ril "$query" output/ 2>/dev/null | head -10 || true)
if [ -n "$output_results" ]; then
  echo "$output_results" | while read -r f; do
    echo "  $f"
  done
else
  echo "  (no matches)"
fi
echo ""

# Show context for top match
if [ -n "$wiki_results" ]; then
  top=$(echo "$wiki_results" | head -1)
  echo "--- Top Match Context ($top) ---"
  grep -n -i "$query" "$top" 2>/dev/null | head -5
fi

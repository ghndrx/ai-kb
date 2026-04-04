#!/bin/bash
# List raw files changed since the last compile
set -euo pipefail

if [ ! -d raw/ ]; then
  echo "No raw/ directory found."
  exit 0
fi

echo "=== Raw Files Changed Since Last Compile ==="

if [ -f .kb-last-compile ]; then
  changed=$(find raw/ -name '*.md' -newer .kb-last-compile 2>/dev/null)
  count=$(echo "$changed" | grep -c . 2>/dev/null || echo "0")
  if [ "$count" -gt 0 ]; then
    echo "$changed"
  fi
  echo "---"
  echo "Changed: $count files"
else
  echo "No previous compile found. All raw files are new:"
  find raw/ -name '*.md' 2>/dev/null
  count=$(find raw/ -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  echo "---"
  echo "Total: $count files"
fi

#!/usr/bin/env bash
set -euo pipefail

# Ralph Wiggum Method - Continuous AI-assisted development loop
# Reference: https://ghuntley.com/ralph/

PROMPT_FILE="${1:-PROMPT.md}"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Error: Prompt file '$PROMPT_FILE' not found"
  echo ""
  echo "Usage: ralph [PROMPT_FILE]"
  echo "  Default: ralph (uses PROMPT.md)"
  echo "  Custom:  ralph my-prompt.md"
  echo ""
  echo "A default PROMPT.md is available in your home directory as a starting point."
  exit 1
fi

echo "=========================================="
echo "Ralph Wiggum Method - Starting..."
echo "=========================================="
echo "Prompt file: $PROMPT_FILE"
echo "Press Ctrl+C to stop"
echo ""
echo "Tip: When Ralph makes mistakes, refine your prompt and let it continue."
echo "=========================================="
echo ""

# The Ralph loop
while :; do
  cat "$PROMPT_FILE" | claude --print
done

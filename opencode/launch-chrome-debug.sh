#!/bin/bash
# Launch Windows Chrome from WSL with remote debugging for playwright-repl MCP
# Usage: ./launch-chrome-debug.sh
# Close all Chrome windows on Windows before running this.

CHROME_PATH="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
USER_DATA_DIR="/mnt/c/Users/VictorManuelVarelaRo/AppData/Local/Google/Chrome/User Data"

if [ ! -f "$CHROME_PATH" ]; then
  echo "Chrome not found at: $CHROME_PATH"
  exit 1
fi

echo "Launching Chrome with remote debugging on port 9222..."
"$CHROME_PATH" --remote-debugging-port=9222 --user-data-dir="$USER_DATA_DIR" \
  --no-first-run --no-default-browser-check &
echo "Chrome started. Verify at http://localhost:9222/json/version"

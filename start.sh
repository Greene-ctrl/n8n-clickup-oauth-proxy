#!/bin/bash
# Start localtunnel, capture URL, update config, commit, and push to GitHub

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
N8N_ENV="$HOME/.n8n/.env"
ENV_FILE="$REPO_DIR/.env"

# Load GitHub PAT from .env (not committed — see .gitignore)
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
fi

if [ -z "$GITHUB_PAT" ]; then
  echo "ERROR: GITHUB_PAT not set. Add it to $ENV_FILE"
  exit 1
fi

REMOTE="https://${GITHUB_PAT}@github.com/Greene-ctrl/n8n-clickup-oauth-proxy.git"

cd "$REPO_DIR"

# Start localtunnel in background, capture output
echo "Starting localtunnel..."
TMP_LOG=$(mktemp)
npx localtunnel --port 5678 > "$TMP_LOG" 2>&1 &
LT_PID=$!

# Wait for the URL to appear
URL=""
for i in $(seq 1 15); do
  URL=$(grep -oP 'your url is: \Khttps://[^ ]+' "$TMP_LOG" 2>/dev/null || true)
  if [ -n "$URL" ]; then
    break
  fi
  sleep 1
done

if [ -z "$URL" ]; then
  echo "ERROR: Could not get localtunnel URL"
  kill $LT_PID 2>/dev/null
  exit 1
fi

echo "Tunnel URL: $URL"
URL="${URL%/}"

# Update index.html
sed -i "s|const N8N_TARGET = 'https://[^']*'|const N8N_TARGET = '$URL'|g" "$REPO_DIR/index.html"

# Update providers.js
sed -i "s|callbackUrl: 'https://[^']*loca\.lt|callbackUrl: '$URL|g" "$REPO_DIR/providers.js"

# Update .n8n/.env
mkdir -p "$(dirname "$N8N_ENV")"
if [ -f "$N8N_ENV" ] && grep -q '^WEBHOOK_URL=' "$N8N_ENV"; then
  sed -i "s|^WEBHOOK_URL=.*|WEBHOOK_URL=$URL|" "$N8N_ENV"
else
  echo "WEBHOOK_URL=$URL" >> "$N8N_ENV"
fi

echo "Updated config files with URL: $URL"

# Commit and push to GitHub
git add -A
git commit -m "update tunnel URL to $URL"
git remote set-url origin "$REMOTE"
git push origin master 2>/dev/null || git push origin main 2>/dev/null || echo "Push failed — check branch name"
git remote set-url origin "https://github.com/Greene-ctrl/n8n-clickup-oauth-proxy.git"

echo ""
echo "=== Done ==="
echo "local tunnel running (PID: $LT_PID) at $URL"
echo "n8n env updated. Restart n8n if it was already running."
echo "Proxy redeployed via git push."
echo ""
echo "Press Ctrl+C to stop the tunnel."
wait $LT_PID

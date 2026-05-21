#!/bin/bash
# Start localtunnel with auto-restart, capture URL, update config, commit, and push to GitHub

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

REMOTE="https://git:${GITHUB_PAT}@github.com/Greene-ctrl/n8n-clickup-oauth-proxy.git"

cd "$REPO_DIR"

echo "=== n8n Localtunnel Auto-Restart Script ==="
echo "This will keep the tunnel alive and auto-restart if it dies."
echo "Press Ctrl+C to stop."
echo ""

# Loop to keep restarting localtunnel
while true; do
  echo "[$(date)] Starting localtunnel..."
  
  # Start localtunnel in background, capture output
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
    echo "[$(date)] ERROR: Could not get localtunnel URL, retrying..."
    kill $LT_PID 2>/dev/null || true
    sleep 5
    continue
  fi
  
  echo "[$(date)] Tunnel URL: $URL"
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
  
  echo "[$(date)] Updated config files with URL: $URL"
  
  # Commit and push to GitHub
  git add -A
  if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "update tunnel URL to $URL"
    git remote set-url origin "$REMOTE"
    git push origin main 2>&1 || echo "Push failed"
  else
    echo "[$(date)] No changes to commit"
  fi
  
  echo ""
  echo "[$(date)] Tunnel running at $URL (PID: $LT_PID)"
  echo "[$(date)] Press Ctrl+C to stop, or let it auto-restart if it dies"
  echo ""
  
  # Wait for localtunnel to exit (or be killed)
  wait $LT_PID 2>/dev/null
  
  # Tunnel died, wait a moment and restart
  echo "[$(date)] Tunnel died. Restarting in 5 seconds..."
  sleep 5
done

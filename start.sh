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

REMOTE="https://github.com/Greene-ctrl/n8n-clickup-oauth-proxy.git"

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

# Commit and push to GitHub using PAT
git add -A
git commit -m "update tunnel URL to $URL"

# Use GIT_ASKPASS to supply credentials non-interactively
ASKPASS_SCRIPT=$(mktemp)
cat > "$ASKPASS_SCRIPT" << ASKEOF
#!/bin/sh
# Git calls this script for both username and password prompts
# The first call is for username, second is for password
case "\$1" in
  "Username for 'https://github.com'")
    echo "git"
    ;;
  "Password for 'https://git@github.com'")
    echo "$GITHUB_PAT"
    ;;
  *)
    # Fallback: if asked for anything else, return empty
    echo ""
    ;;
esac
ASKEOF
chmod +x "$ASKPASS_SCRIPT"

# Debug: show what we're using (first 10 chars of PAT for security)
echo "DEBUG: GITHUB_PAT starts with: \${GITHUB_PAT:0:10}..."
echo "DEBUG: ASKPASS_SCRIPT at: $ASKPASS_SCRIPT"
echo "DEBUG: ASKPASS content:"
cat "$ASKPASS_SCRIPT"
echo "DEBUG: Pushing to: origin main"

# Test the PAT first with a dry-run fetch
echo "DEBUG: Testing PAT with fetch..."
GIT_ASKPASS="$ASKPASS_SCRIPT" git fetch origin 2>&1 || echo "DEBUG: Fetch failed!"

# Actual push
GIT_ASKPASS="$ASKPASS_SCRIPT" git push origin main 2>&1
rm -f "$ASKPASS_SCRIPT"

echo ""
echo "=== Done ==="
echo "local tunnel running (PID: $LT_PID) at $URL"
echo "n8n env updated. Restart n8n if it was already running."
echo "Proxy redeployed via git push."
echo ""
echo "Press Ctrl+C to stop the tunnel."
wait $LT_PID

# Start n8n Locally with Tunnel

## Prerequisites

- n8n installed globally (`npm install -g n8n`)
- Proxy deployed to Vercel at `https://n8n-clickup-oauth-proxy.vercel.app`

## Steps

### 1. Start n8n (Terminal 1)

```bash
n8n start
```

### 2. Run the full setup script (Terminal 2 — Git Bash)

This starts localtunnel, captures the URL, updates all config files, commits, and pushes to GitHub:

```bash
bash /c/Users/LeonGründling/n8n-clickup-oauth-proxy/start.sh
```

### 3. Restart n8n

Stop n8n (Ctrl+C) and start it again so it picks up the new `WEBHOOK_URL`:

```bash
n8n start
```

## OAuth Flow

1. User clicks "Connect" in n8n
2. n8n redirects to ClickUp OAuth with `redirect_uri` = proxy URL
3. User authorizes → ClickUp redirects to proxy URL
4. Proxy forwards to localtunnel URL
5. localtunnel forwards to `localhost:5678`
6. n8n processes the callback

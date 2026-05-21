#!/bin/bash
# Start localtunnel to expose n8n on localhost:5678
# Run this in a separate Git Bash terminal

echo "Starting localtunnel to localhost:5678..."
echo "Update the N8N_TARGET in index.html with the URL shown below"
echo "Then redeploy the proxy to Vercel"
echo "---"

npx localtunnel --port 5678

# n8n ClickUp OAuth Proxy

This repository provides a Vercel deployment to proxy OAuth callbacks for n8n on Hugging Face Spaces.

## Problem
ClickUp's OAuth system trims the full callback path (`/rest/oauth2-credential/callback`), causing authentication failures.

## Solution
Deploy this Vercel project to create a custom domain that preserves URL paths when forwarding to your Hugging Face Space.

## Setup

### 1. Deploy to Vercel
1. Push this repo to GitHub
2. Import it into [Vercel](https://vercel.com/new)
3. Deploy - you'll get a URL like `yourproject.vercel.app`

### 2. Configure ClickUp
In ClickUp's Developer Console, register your Vercel URL as the OAuth redirect:
```
https://yourproject.vercel.app/
```

### 3. How it works
- ClickUp redirects to `https://yourproject.vercel.app/`
- Vercel rewrites this to `https://leon4gr45-n8n.hf.space/`
- n8n's OAuth server handles the callback at the full path internally

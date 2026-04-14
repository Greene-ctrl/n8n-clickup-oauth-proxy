# n8n OAuth Proxy - Multi-Provider

A generalized OAuth callback proxy that supports multiple providers (ClickUp, Power BI, Azure, Google, GitHub, Microsoft) through a single Vercel deployment.

## 🚀 Features

- **Multi-Provider Support**: Handle OAuth callbacks from multiple services
- **Single Deployment**: One Vercel project for all providers
- **Easy Configuration**: Add new providers by editing one file
- **Zero Server-Side Code**: Pure static HTML with JavaScript redirects
- **Free Tier**: Hosted on Vercel's free tier

## 📋 Supported Providers

| Provider | Callback Path | Description |
|----------|---------------|-------------|
| ClickUp | `/clickup/callback` | Task management integration |
| Power BI | `/powerbi/callback` | Microsoft Power BI analytics |
| Azure AD | `/azure/callback` | Microsoft Azure Active Directory |
| Google | `/google/callback` | Google Workspace integration |
| GitHub | `/github/callback` | GitHub repository integration |
| Microsoft | `/microsoft/callback` | Microsoft 365 integration |

## 🔧 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/Greene-ctrl/n8n-clickup-oauth-proxy.git
cd n8n-clickup-oauth-proxy
```

### 2. Configure Providers

Edit `index.html` to add or modify provider callback URLs:

```javascript
const PROVIDERS = {
  clickup: 'https://your-n8n-instance.hf.space/rest/oauth2-credential/callback',
  powerbi: 'https://your-n8n-instance.hf.space/rest/oauth2-credential/callback',
  azure: 'https://your-n8n-instance.hf.space/rest/oauth2-credential/callback',
  // Add more providers here
};
```

### 3. Deploy to Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel
```

### 4. Register Callback URLs with Providers

For each provider, register the callback URL:

```
https://your-vercel-domain.vercel.app/{provider}/callback
```

**Examples:**
- ClickUp: `https://your-vercel-domain.vercel.app/clickup/callback`
- Power BI: `https://your-vercel-domain.vercel.app/powerbi/callback`
- Azure: `https://your-vercel-domain.vercel.app/azure/callback`

## 📖 Usage

### OAuth Flow

1. **Configure Provider**: Set up OAuth app in provider's console
2. **Set Callback URL**: Use `https://your-vercel-domain.vercel.app/{provider}/callback`
3. **Initiate OAuth**: User clicks "Connect" in n8n
4. **Redirect**: Provider redirects to proxy with OAuth params
5. **Forward**: Proxy forwards to n8n callback with params preserved
6. **Complete**: n8n processes OAuth response

### Example URLs

```
# ClickUp OAuth
https://proxy.vercel.app/clickup/callback?code=abc123&state=xyz

# Power BI OAuth
https://proxy.vercel.app/powerbi/callback?code=def456&state=uvw

# Azure OAuth
https://proxy.vercel.app/azure/callback?code=ghi789&state=rst
```

## 🛠️ Adding New Providers

1. Open `index.html`
2. Add provider to `PROVIDERS` object:

```javascript
const PROVIDERS = {
  // ... existing providers
  newprovider: 'https://your-n8n-instance.hf.space/rest/oauth2-credential/callback'
};
```

3. Commit and push to Vercel (auto-deploys)
4. Register callback URL with new provider

## 🔒 Security Considerations

- **HTTPS Only**: All redirects use HTTPS
- **No Credential Storage**: Stateless proxy, no data stored
- **Parameter Validation**: Query parameters passed through unchanged
- **Error Handling**: Graceful fallback if provider not configured

## 📁 Project Structure

```
n8n-clickup-oauth-proxy/
├── index.html          # Main proxy logic (multi-provider)
├── providers.js        # Provider configuration (reference)
├── vercel.json         # Vercel routing configuration
└── README.md           # This file
```

## 🔄 How It Works

```
Provider OAuth → Vercel Proxy → index.html → n8n Callback
     ↓                ↓             ↓            ↓
?code=xxx      Rewrites to    JS captures   Receives OAuth
&state=yyy     /index.html    params        credentials
```

1. User initiates OAuth in n8n
2. Provider redirects to proxy with OAuth parameters
3. Vercel rewrites all routes to `index.html`
4. JavaScript extracts provider from URL path
5. Query parameters preserved and forwarded to n8n
6. n8n processes OAuth response

## 📝 Configuration Reference

### vercel.json

```json
{
  "rewrites": [
    { "source": "/:provider/callback", "destination": "/index.html" },
    { "source": "/:provider", "destination": "/index.html" },
    { "source": "/callback", "destination": "/index.html" },
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

### index.html - Provider Configuration

```javascript
const PROVIDERS = {
  'provider-name': 'https://n8n-instance/callback-url',
  // Add more providers
};
```

## 🐛 Troubleshooting

### "Unknown Provider" Error
- Check provider name in URL matches key in `PROVIDERS` object
- Ensure provider is added to `index.html`
- Clear browser cache and retry

### OAuth Parameters Not Forwarded
- Check browser console for JavaScript errors
- Verify Vercel rewrites are configured correctly
- Ensure n8n callback URL is accessible

### Deployment Issues
- Check Vercel build logs
- Verify all files committed to repository
- Ensure `vercel.json` is valid JSON

## 📞 Support

For issues or questions:
1. Check this README
2. Review Vercel deployment logs
3. Test with browser developer tools
4. Contact repository maintainer

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Credits

Original ClickUp OAuth proxy by Leon4gr45
Generalized for multi-provider support by Greene-ctrl

// OAuth Provider Configuration
// Add or modify providers here to support additional OAuth integrations

export const PROVIDERS = {
  clickup: {
    name: 'ClickUp',
    callbackUrl: 'https://leon4gr45-n8n.hf.space/rest/oauth2-credential/callback',
    description: 'ClickUp task management integration',
    path: '/clickup/callback'
  },
  powerbi: {
    name: 'Power BI',
    callbackUrl: 'https://leon4gr45-n8n.hf.space/rest/oauth2-credential/callback',
    description: 'Microsoft Power BI analytics integration',
    path: '/powerbi/callback'
  },
  azure: {
    name: 'Azure AD',
    callbackUrl: 'https://leon4gr45-n8n.hf.space/rest/oauth2-credential/callback',
    description: 'Microsoft Azure Active Directory',
    path: '/azure/callback'
  },
  google: {
    name: 'Google',
    callbackUrl: 'https://leon4gr45-n8n.hf.space/rest/oauth2-credential/callback',
    description: 'Google Workspace integration',
    path: '/google/callback'
  },
  github: {
    name: 'GitHub',
    callbackUrl: 'https://leon4gr45-n8n.hf.space/rest/oauth2-credential/callback',
    description: 'GitHub repository integration',
    path: '/github/callback'
  },
  microsoft: {
    name: 'Microsoft',
    callbackUrl: 'https://leon4gr45-n8n.hf.space/rest/oauth2-credential/callback',
    description: 'Microsoft 365 integration',
    path: '/microsoft/callback'
  }
};

// Helper function to get provider by name
export function getProvider(name) {
  return PROVIDERS[name.toLowerCase()] || null;
}

// Helper function to list all available providers
export function listProviders() {
  return Object.keys(PROVIDERS).map(key => ({
    name: key,
    displayName: PROVIDERS[key].name,
    path: PROVIDERS[key].path
  }));
}

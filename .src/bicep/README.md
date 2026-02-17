# Azure AI Foundry Bicep Deployment

This Bicep template creates an Azure AI Foundry project with secure subscription key storage in Key Vault.

## Resources Created

- **Key Vault**: Stores the APIM subscription key securely (for backup/reference)
- **AI Services Account**: Foundry AI services resource
- **AI Foundry Hub**: The hub workspace for organizing AI projects
- **AI Foundry Project**: A project workspace linked to the hub
- **API Connection**: Connects to APIM using direct API key authentication (supports cross-tenant APIM)

## Prerequisites

- Azure CLI installed and authenticated
- An existing resource group
- An existing Azure API Management (APIM) instance
- APIM subscription key

## Deployment

### Option 1: Using Azure CLI with parameters file

1. Update the `foundry.bicepparam` file with your values:
   - `apimName`: Your APIM instance name
   - `subscriptionKey`: Your APIM subscription key (or provide securely during deployment)

2. Deploy the template:

```bash
# Create resource group if it doesn't exist
az group create --name rg-foundry-sbx --location uksouth

# Deploy the template
az deployment group create \
  --resource-group rg-foundry-sbx \
  --template-file foundry.bicep \
  --parameters foundry.bicepparam \
  --parameters subscriptionKey='your-subscription-key-here'
```

### Option 2: Using Azure CLI with inline parameters

```bash
az deployment group create \
  --resource-group rg-foundry-sbx \
  --template-file foundry.bicep \
  --parameters location='uksouth' \
               foundryName='fdry-sbx-ai' \
               hubName='fdry-sbx-hub' \
               projectName='sbx-project-01' \
               apimName='your-apim-name' \
               subscriptionKey='your-subscription-key-here'
```

### Option 3: Secure deployment without exposing subscription key

```bash
# Store subscription key in a secure file (excluded from git)
echo 'your-subscription-key-here' > .apim-key.txt

# Deploy with secure parameter
az deployment group create \
  --resource-group rg-foundry-sbx \
  --template-file foundry.bicep \
  --parameters foundry.bicepparam \
  --parameters subscriptionKey=$(cat .apim-key.txt)

# Clean up the key file
rm .apim-key.txt
```

## Key Features

### Cross-Tenant APIM Support
- Direct API key authentication for APIM in different Azure AD tenants
- No managed identity required for APIM authentication
- Subscription key passed securely as a parameter during deployment

### Secure Key Storage
- The APIM subscription key is stored in Azure Key Vault for backup/reference
- Key Vault provides audit logging and secret rotation capabilities
- Secrets are protected with RBAC authorization

### API Connection
- The connection uses direct API key authentication
- Supports APIM instances in different Azure AD tenants
- The connection can be used within the Foundry project to access your APIM backend
- Note: The API key is stored in the connection configuration (encrypted at rest by Azure)

## Outputs

After deployment, the template outputs:
- `keyVaultName`: Name of the Key Vault
- `keyVaultId`: Resource ID of the Key Vault
- `foundryName`: Name of the AI Services account
- `hubName`: Name of the Foundry Hub
- `projectName`: Name of the Foundry Project
- `projectEndpoint`: Discovery endpoint URL for the project

## Security Best Practices

1. **Never commit subscription keys to source control**
   - Add `.apim-key.txt` to `.gitignore`
   - Use Azure Key Vault or Azure DevOps Secure Files for CI/CD
   - Pass keys as secure parameters during deployment

2. **Use secure parameter passing**
   - Always use `@secure()` decorator for sensitive parameters
   - Avoid passing keys in command history (use files or prompts)
   - Consider Azure DevOps variable groups or GitHub Secrets for automation

3. **Key Vault for storage**
   - Keys are stored in Key Vault for audit and rotation
   - Enable Key Vault logging to track access
   - Use Key Vault RBAC for granular access control

4. **Review network access**
   - By default, resources have public network access enabled
   - Consider adding private endpoints for production deployments
   - Restrict APIM subscription key scope to minimum required APIs

## Troubleshooting

### Cross-Tenant APIM Access
If the connection fails to access APIM in another tenant:
1. Verify the APIM subscription key is valid and not expired
2. Check the APIM instance allows the API you're trying to access
3. Confirm the subscription key has the correct scope (product/API)
4. Test the APIM endpoint directly with curl or Postman

### Key Vault Access Issues
If you can't store the key in Key Vault:
1. Verify you have the "Key Vault Secrets Officer" or "Contributor" role
2. Check that Key Vault RBAC authorization is enabled
3. Ensure there are no network restrictions blocking access

### Connection Issues
If the API connection doesn't work:
1. Verify the APIM name is correct
2. Check that the subscription key is valid
3. Confirm the secret was stored correctly in Key Vault

## Customization

### Change Key Vault SKU
Edit the `keyVault` resource to use 'premium' for HSM-backed keys:
```bicep
sku: {
  family: 'A'
  name: 'premium'
}
```

### Add Network Restrictions
Configure Key Vault network rules:
```bicep
networkAcls: {
  defaultAction: 'Deny'
  bypass: 'AzureServices'
  ipRules: []
  virtualNetworkRules: []
}
```

### Use Different Azure Regions
Update the `location` parameter to deploy in different regions:
```bash
--parameters location='eastus'
```

## Clean Up

To delete all resources:
```bash
az group delete --name rg-foundry-sbx --yes --no-wait
```

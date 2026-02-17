# Azure AI Foundry Bicep Deployment

This Bicep template creates an Azure AI Foundry project with secure subscription key storage in Key Vault.

## Resources Created

- **Key Vault**: Stores the APIM subscription key securely
- **AI Services Account**: Foundry AI services resource
- **AI Foundry Hub**: The hub workspace for organizing AI projects
- **AI Foundry Project**: A project workspace linked to the hub
- **API Connection**: Connects to APIM using the subscription key from Key Vault
- **RBAC Role Assignment**: Grants the project's managed identity access to Key Vault secrets

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

### Secure Key Storage
- The APIM subscription key is stored in Azure Key Vault
- The AI Foundry project uses a system-assigned managed identity
- RBAC role assignment grants the project "Key Vault Secrets User" access

### API Connection
- The connection resource references the Key Vault secret URI
- No hard-coded credentials in the configuration
- The connection can be used within the Foundry project to access your APIM backend

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

2. **Use managed identities**
   - All resources use system-assigned managed identities
   - No connection strings or keys stored in application code

3. **Enable RBAC for Key Vault**
   - The template uses RBAC authorization (not access policies)
   - Follows principle of least privilege

4. **Review network access**
   - By default, resources have public network access enabled
   - Consider adding private endpoints for production deployments

## Troubleshooting

### Key Vault Access Issues
If the connection fails to access the Key Vault secret:
1. Verify the role assignment was created successfully
2. Check that the project's managed identity has the "Key Vault Secrets User" role
3. Ensure Key Vault RBAC authorization is enabled

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

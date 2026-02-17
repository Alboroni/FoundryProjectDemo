// Project module - deploys project-specific resources (Project, Key Vault, Connections)
param location string
param projectName string
param hubResourceId string
param keyVaultName string
param apimName string
@secure()
param subscriptionKey string
param secretName string

// Key Vault to store the subscription key (project-specific)
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    publicNetworkAccess: 'Enabled'
  }
}

// Store the subscription key in Key Vault
resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: secretName
  properties: {
    value: subscriptionKey
  }
}

// AI Foundry Project (references central hub)
resource project 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: projectName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'Sandbox Project'
    description: 'Project workspace linked to central hub'
    hubResourceId: hubResourceId
    publicNetworkAccess: 'Enabled'
  }
}

// API connection using direct API key (for cross-tenant APIM access)
resource connection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = {
  parent: project
  name: 'custom-api-conn'
  properties: {
    category: 'ApiKey'
    target: 'https://${apimName}.azure-api.net/custom'
    authType: 'ApiKey'
    credentials: {
      key: subscriptionKey
    }
    metadata: {
      description: 'Custom API via APIM (cross-tenant) using subscription key'
      apiType: 'Azure'
    }
  }
}

output projectName string = project.name
output projectId string = project.id
output projectEndpoint string = project.properties.discoveryUrl
output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id

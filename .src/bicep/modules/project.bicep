// Project module - deploys project-specific resources (Project, Key Vault, Connections)
param location string
param projectName string
param foundryAccountName string
param hubResourceGroupName string
param keyVaultName string
param apimName string
@secure()
param subscriptionKey string
param secretName string

// Key Vault to store the subscription key (project-specific, not for workspace)
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

// Get reference to the hub AI Services account
resource hubAIServices 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: foundryAccountName
}

// AI Foundry Project (child of AI Services account)
resource project 'Microsoft.CognitiveServices/accounts/projects@2024-10-01' = {
  parent: hubAIServices
  name: projectName
  location: location
  properties: {
    friendlyName: 'Sandbox Project'
    description: 'AI Foundry Project'
  }
}

// API Connection for cross-tenant APIM access
resource connection 'Microsoft.CognitiveServices/accounts/projects/connections@2024-10-01' = {
  parent: project
  name: 'apim-connection'
  properties: {
    category: 'CustomKeys'
    target: 'https://${apimName}.azure-api.net'
    authType: 'ApiKey'
    credentials: {
      key: subscriptionKey
    }
    metadata: {
      description: 'Cross-tenant APIM connection using subscription key'
      apiType: 'REST'
    }
  }
}

output projectName string = project.name
output projectId string = project.id
output connectionName string = connection.name
output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id

// Project module - deploys project-specific resources (Project, Key Vault, Connections)
param location string
param projectName string
param keyVaultName string
param apimName string
@secure()
param subscriptionKey string
param secretName string

// Generate unique Key Vault name (max 24 chars, alphanumeric and hyphens only)
var uniqueSuffix = substring(uniqueString(resourceGroup().id, projectName), 0, 6)
var kvBaseName = length(keyVaultName) > 17 ? substring(keyVaultName, 0, 17) : keyVaultName
var uniqueKeyVaultName = '${kvBaseName}-${uniqueSuffix}'

// Key Vault to store the subscription key (project-specific, not for workspace)
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: uniqueKeyVaultName
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

// AI Foundry Project (standalone)
resource project 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: projectName
  location: location
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: projectName
    publicNetworkAccess: 'Enabled'
  }
}

output projectName string = project.name
output projectId string = project.id
output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id

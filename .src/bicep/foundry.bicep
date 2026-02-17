param location string = 'uksouth'
param foundryName string = 'fdry-sbx-ai'
param hubName string = 'fdry-sbx-hub'
param projectName string = 'sbx-project-01'
param keyVaultName string = 'kv-foundry-${uniqueString(resourceGroup().id)}'
param apimName string
@secure()
param subscriptionKey string
param secretName string = 'apim-subscription-key'

// Key Vault to store the subscription key
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

// AI Services resource
resource foundry 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: foundryName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: foundryName
    publicNetworkAccess: 'Enabled'
  }
}

// AI Foundry Hub
resource hub 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: hubName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'Sandbox Hub'
    description: 'Foundry sandbox hub'
    publicNetworkAccess: 'Enabled'
  }
}

// AI Foundry Project
resource project 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: projectName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'Sandbox Project'
    description: 'Developer sandbox project'
    hubResourceId: hub.id
    publicNetworkAccess: 'Enabled'
  }
}

// Grant project managed identity access to Key Vault secrets
resource projectKeyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, project.id, 'Key Vault Secrets User')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: project.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// API connection using Key Vault reference
resource connection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = {
  parent: project
  name: 'custom-api-conn'
  properties: {
    category: 'ApiKey'
    target: 'https://${apimName}.azure-api.net/custom'
    authType: 'ApiKey'
    credentials: {
      key: secret.properties.secretUri
    }
    metadata: {
      description: 'Custom API via APIM using subscription key from Key Vault'
      apiType: 'Azure'
    }
  }
  dependsOn: [
    projectKeyVaultRoleAssignment
  ]
}

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
output foundryName string = foundry.name
output hubName string = hub.name
output projectName string = project.name
output projectEndpoint string = project.properties.discoveryUrl



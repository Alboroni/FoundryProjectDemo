// Hub module - deploys central AI Foundry Hub and AI Services
// This module contains shared resources used by all projects
param location string
param foundryName string
param hubName string

// Storage Account (required for hub)
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: replace('${hubName}storage', '-', '')
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
  }
}

// Key Vault (required for hub)
resource hubKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: replace('${hubName}-kv', '-', '')
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

// Application Insights (required for hub)
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${hubName}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// AI Services resource (central)
resource foundry 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: foundryName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  properties: {
    customSubDomainName: foundryName
    publicNetworkAccess: 'Enabled'
  }
}

// AI Foundry Hub (central)
resource hub 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: hubName
  location: location
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'Foundry Hub'
    description: 'Central AI Foundry Hub for all projects'
    storageAccount: storage.id
    keyVault: hubKeyVault.id
    applicationInsights: appInsights.id
    publicNetworkAccess: 'Enabled'
  }
}

output foundryName string = foundry.name
output foundryId string = foundry.id
output hubName string = hub.name
output hubId string = hub.id

targetScope = 'resourceGroup'

param location string

@minLength(2)
@maxLength(64)
param foundryName string

param projectName string

@minLength(3)
@maxLength(24)
param storageAccountName string

param appInsightsName string
param keyVaultName string

@secure()
param subscriptionKey string
param secretName string

resource aiFoundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: foundryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  properties: {
    allowProjectManagement: true
    customSubDomainName: foundryName
    disableLocalAuth: false
  }
}

resource aiProject 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  name: projectName
  parent: aiFoundry
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    IngestionMode: 'ApplicationInsights'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    publicNetworkAccess: 'Enabled'
  }
}

resource kvSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: secretName
  parent: keyVault
  properties: {
    value: subscriptionKey
  }
}

output foundryName string = aiFoundry.name
output foundryId string = aiFoundry.id
output projectName string = aiProject.name
output projectId string = aiProject.id
output storageAccountName string = storageAccount.name
output appInsightsName string = appInsights.name
output keyVaultName string = keyVault.name
output keyVaultSecretUri string = kvSecret.properties.secretUri

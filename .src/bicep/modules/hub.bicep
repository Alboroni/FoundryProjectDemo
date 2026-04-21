// Hub module - deploys central AI Foundry Hub and AI Services
// This module contains shared resources used by all projects
param location string
param foundryName string

// AI Services resource (central) - configured for AI Foundry
resource foundry 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
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

// Managed Identity for deployment script
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${foundryName}-script-identity'
  location: location
}

// Storage account for deployment script
resource scriptStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: take('st${replace(foundryName, '-', '')}scr', 24)
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowSharedKeyAccess: false
    supportsHttpsTrafficOnly: true
  }
}

// Grant the managed identity Storage Blob Data Contributor role on the storage account
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: scriptStorage
  name: guid(scriptStorage.id, managedIdentity.id, 'StorageBlobDataContributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Role assignment to allow the script identity to modify the AI Services account
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: foundry
  name: guid(foundry.id, managedIdentity.id, 'Contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Deployment script to enable project management on the AI Services account
resource enableProjectManagement 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: '${foundryName}-enable-projects'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.50.0'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'OnSuccess'
    scriptContent: '''
      az rest --method patch \
        --url "${environment().resourceManager}${ACCOUNT_ID}?api-version=2025-04-01-preview" \
        --body '{"properties": {"allowProjectManagement": true}}'
    '''
    environmentVariables: [
      {
        name: 'ACCOUNT_ID'
        value: foundry.id
      }
    ]
  }
  dependsOn: [
    roleAssignment
    storageRoleAssignment
  ]
}

output foundryName string = foundry.name
output foundryId string = foundry.id

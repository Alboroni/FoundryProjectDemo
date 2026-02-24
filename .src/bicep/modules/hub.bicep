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
  properties: {
    customSubDomainName: foundryName
    publicNetworkAccess: 'Enabled'
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
    scriptContent: '''
      az rest --method patch \
        --url "https://management.azure.com${ACCOUNT_ID}?api-version=2025-04-01-preview" \
        --body '{"properties": {"allowProjectManagement": true}}'
    '''
    environmentVariables: [
      {
        name: 'ACCOUNT_ID'
        value: foundry.id
      }
    ]
  }
}

// Managed Identity for deployment script
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${foundryName}-script-identity'
  location: location
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

output foundryName string = foundry.name
output foundryId string = foundry.id

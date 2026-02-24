
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



output foundryName string = foundry.name
output foundryId string = foundry.id


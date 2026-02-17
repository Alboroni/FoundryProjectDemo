// Hub module - deploys central AI Foundry Hub and AI Services
// This module contains shared resources used by all projects
param location string
param foundryName string
param hubName string

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
  properties: {
    friendlyName: 'Foundry Hub'
    description: 'Central AI Foundry Hub for all projects'
    publicNetworkAccess: 'Enabled'
  }
}

output foundryName string = foundry.name
output foundryId string = foundry.id
output hubName string = hub.name
output hubId string = hub.id

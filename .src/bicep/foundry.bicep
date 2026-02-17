targetScope = 'subscription'

param location string = 'uksouth'
param hubResourceGroupName string = 'rg-foundry-hub'
param projectResourceGroupName string = 'rg-foundry-project-sbx'
param foundryName string = 'fdry-sbx-ai'
param hubName string = 'fdry-sbx-hub'
param projectName string = 'sbx-project-01'
param keyVaultName string = 'kv-foundry-sbx'
param apimName string
@secure()
param subscriptionKey string
param secretName string = 'apim-subscription-key'

// Central hub resource group
resource hubRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: hubResourceGroupName
  location: location
}

// Project-specific resource group
resource projectRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: projectResourceGroupName
  location: location
}

// Deploy hub resources to central resource group
module hubResources 'modules/hub.bicep' = {
  scope: hubRg
  name: 'hub-deployment'
  params: {
    location: location
    foundryName: foundryName
    hubName: hubName
  }
}

// Deploy project resources to project-specific resource group
module projectResources 'modules/project.bicep' = {
  scope: projectRg
  name: 'project-deployment'
  params: {
    location: location
    projectName: projectName
    hubResourceId: hubResources.outputs.hubId
    keyVaultName: keyVaultName
    apimName: apimName
    subscriptionKey: subscriptionKey
    secretName: secretName
  }
}

output hubResourceGroupName string = hubRg.name
output projectResourceGroupName string = projectRg.name
output foundryName string = hubResources.outputs.foundryName
output hubName string = hubResources.outputs.hubName
output hubId string = hubResources.outputs.hubId
output projectName string = projectResources.outputs.projectName
output projectEndpoint string = projectResources.outputs.projectEndpoint
output keyVaultName string = projectResources.outputs.keyVaultName



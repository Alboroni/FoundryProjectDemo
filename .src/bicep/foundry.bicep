targetScope = 'subscription'

param location string = 'uksouth'
param hubResourceGroupName string = 'rg-foundry-hub'
param foundryName string = 'fdry-sbx-ai'
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

// Deploy hub resources to central resource group
module hubResources 'modules/hub.bicep' = {
  scope: hubRg
  name: 'hub-deployment'
  params: {
    location: location
    foundryName: foundryName  }
}

// Deploy project resources to hub resource group (projects must be in same RG as AI Services)
module projectResources 'modules/project.bicep' = {
  scope: hubRg
  name: 'project-deployment'
  params: {
    location: location
    projectName: projectName
    foundryAccountName: foundryName
      keyVaultName: keyVaultName
    apimName: apimName
    subscriptionKey: subscriptionKey
    secretName: secretName
  }
  dependsOn: [
    hubResources
  ]
}


output foundryName string = hubResources.outputs.foundryName
output projectName string = projectResources.outputs.projectName
output projectId string = projectResources.outputs.projectId
output keyVaultName string = projectResources.outputs.keyVaultName



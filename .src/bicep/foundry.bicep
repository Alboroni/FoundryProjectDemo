targetScope = 'subscription'

param location string = 'swedencentral'
param hubResourceGroupName string = 'rg-foundry-hub'
@minLength(2)
@maxLength(64)
param foundryName string = 'fdrysbxai'
param projectName string = 'sbx-project-01'
@minLength(3)
@maxLength(24)
param storageAccountName string = 'stfdrysbxai001'
param appInsightsName string = 'appi-foundry-sbx'
param keyVaultName string = 'kv-foundry-sbx'
@secure()
param subscriptionKey string
param secretName string = 'apim-subscription-key'

// Model Gateway connection parameters (optional)
param modelGatewayTargetUrl string = ''
param modelGatewayName string = 'GatewayApi'
@allowed(['ApiKey', 'OAuth2'])
param modelGatewayAuthType string = 'ApiKey'
@secure()
param modelGatewayApiKey string = ''
param clientId string = ''
@secure()
param clientSecret string = ''
param tokenUrl string = ''
param scopes array = []
param inferenceAPIVersion string = '2024-02-01'
@allowed(['true', 'false'])
param deploymentInPath string = 'true'

// Central hub resource group
resource hubRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: hubResourceGroupName
  location: location
}

module foundryStack 'modules/foundry-stack.bicep' = {
  name: 'foundry-stack-deployment'
  scope: hubRg
  params: {
    location: location
    foundryName: foundryName
    projectName: projectName
    storageAccountName: storageAccountName
    appInsightsName: appInsightsName
    keyVaultName: keyVaultName
    subscriptionKey: subscriptionKey
    secretName: secretName
    modelGatewayTargetUrl: modelGatewayTargetUrl
    modelGatewayName: modelGatewayName
    modelGatewayAuthType: modelGatewayAuthType
    modelGatewayApiKey: modelGatewayApiKey
    clientId: clientId
    clientSecret: clientSecret
    tokenUrl: tokenUrl
    scopes: scopes
    inferenceAPIVersion: inferenceAPIVersion
    deploymentInPath: deploymentInPath
  }
}

output resourceGroupName string = hubRg.name
output foundryName string = foundryStack.outputs.foundryName
output foundryId string = foundryStack.outputs.foundryId
output projectName string = foundryStack.outputs.projectName
output projectId string = foundryStack.outputs.projectId
output storageAccountName string = foundryStack.outputs.storageAccountName
output appInsightsName string = foundryStack.outputs.appInsightsName
output keyVaultName string = foundryStack.outputs.keyVaultName
output keyVaultSecretUri string = foundryStack.outputs.keyVaultSecretUri
output modelGatewayConnectionName string = foundryStack.outputs.modelGatewayConnectionName
output modelGatewayConnectionId string = foundryStack.outputs.modelGatewayConnectionId



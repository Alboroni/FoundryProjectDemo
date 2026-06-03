param aiFoundryName string = 'foundry-name'
param aiProjectName string = '${aiFoundryName}-proj'
param location string = 'swedencentral'

// Model Gateway connection parameters (optional - only deploy if modelGatewayTargetUrl is provided)
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

/*
  An AI Foundry resources is a variant of a CognitiveServices/account resource type
*/ 
resource aiFoundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: aiFoundryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  properties: {
    // required to work in AI Foundry
    allowProjectManagement: true

    // Defines developer API endpoint subdomain
    customSubDomainName: aiFoundryName

    disableLocalAuth: false
  }
}

/*
  Developer APIs are exposed via a project, which groups in- and outputs that relate to one use case, including files.
  Its advisable to create one project right away, so development teams can directly get started.
  Projects may be granted individual RBAC permissions and identities on top of what account provides.
*/ 
resource aiProject 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  name: aiProjectName
  parent: aiFoundry
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

// Deploy Model Gateway connection after project is created (conditional - only if target URL is provided)
module modelGatewayConnection 'modules/modelgateway-connection-common.bicep' = if (modelGatewayTargetUrl != '') {
  name: 'modelgateway-connection-deployment'
  params: {
    projectResourceId: aiProject.id
    connectionName: 'modelgateway-${modelGatewayName}'
    targetUrl: modelGatewayTargetUrl
    authType: modelGatewayAuthType
    apiKey: modelGatewayApiKey
    clientId: clientId
    clientSecret: clientSecret
    tokenUrl: tokenUrl
    scopes: scopes
    metadata: {
      deploymentInPath: deploymentInPath
      inferenceAPIVersion: inferenceAPIVersion
    }
    isSharedToAll: false
  }
}


/*
  Optionally deploy a model to use in playground, agents and other tools.
*/
// resource modelDeployment2 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01'= {
//   parent: aiFoundry
//   name: 'FLUX.1-Kontext-pro'
//   sku : {
//     capacity: 1
//     name: 'GlobalStandard'
//   }
//   properties: {
//     model: {
//       name: 'FLUX.1-Kontext-pro'
//       format: 'Black Forest Labs'
//       version: '1'
//     }
//   }
// }

// Outputs to use in connection.bicep and other modules
output projectResourceId string = aiProject.id
output projectName string = aiProject.name
output foundryResourceId string = aiFoundry.id
output foundryName string = aiFoundry.name

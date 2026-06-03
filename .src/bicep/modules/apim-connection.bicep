// Simplified APIM connection module - deploys connection directly to AI Foundry project

@description('Resource ID of the AI Foundry project')
param projectResourceId string

@description('Name for the connection')
param connectionName string

@description('Resource ID of the APIM service')
param apimResourceId string

@description('Name of the API in APIM')
param apiName string

@description('APIM subscription name for API key auth')
param apimSubscriptionName string = 'master'

@allowed(['ApiKey', 'ManagedIdentity'])
@description('Authentication type')
param authType string = 'ApiKey'

@description('Share connection to all project users')
param isSharedToAll bool = false

@description('API version for inference calls')
param inferenceAPIVersion string = '2024-02-01'

@allowed(['true', 'false'])
@description('Whether deployment name is in URL path vs body')
param deploymentInPath string = 'true'

// Parse project resource ID to get project and foundry names
var projectIdParts = split(projectResourceId, '/')
var foundryAccountName = projectIdParts[8]
var projectName = projectIdParts[10]

// Create APIM connection resource
resource apimConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01' = {
  name: '${foundryAccountName}/${projectName}/${connectionName}'
  properties: {
    category: 'ApiManagement'
    target: apimResourceId
    authType: authType
    isSharedToAll: isSharedToAll
    metadata: {
      ApiName: apiName
      ApiVersion: inferenceAPIVersion
      SubscriptionName: apimSubscriptionName
      deploymentInPath: deploymentInPath
    }
  }
}

output connectionName string = apimConnection.name
output connectionId string = apimConnection.id

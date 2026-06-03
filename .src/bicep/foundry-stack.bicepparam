using './modules/foundry-stack.bicep'

param location = 'swedencentral'
param foundryName = 'fdry-dev-placeholder'
param projectName = 'project-dev-placeholder'
param storageAccountName = 'stdevplaceholder001'
param appInsightsName = 'appi-dev-placeholder'
param keyVaultName = 'kv-dev-placeholder'

// Pass securely from pipeline/CLI at deploy time.
param subscriptionKey = ''
param secretName = 'apim-subscription-key'

// Optional Model Gateway connection. Leave URL empty to skip connection deployment.
param modelGatewayTargetUrl = ''
param modelGatewayName = 'GatewayApi'
param modelGatewayAuthType = 'ApiKey'
param modelGatewayApiKey = ''
param clientId = ''
param clientSecret = ''
param tokenUrl = ''
param scopes = []
param inferenceAPIVersion = '2024-02-01'
param deploymentInPath = 'true'

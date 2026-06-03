using './main.bicep'

param aiFoundryName = 'fdry-sbx-aialexyo2'
param aiProjectName = 'sbx-project-01yo'
param location = 'swedencentral'

// Set a target URL to deploy the connection. Keep empty to skip.
param modelGatewayTargetUrl = ''
param modelGatewayName = 'GatewayApi'
param modelGatewayAuthType = 'ApiKey'

// ApiKey auth path
param modelGatewayApiKey = ''

// OAuth2 auth path
param clientId = ''
param clientSecret = ''
param tokenUrl = ''
param scopes = []

param inferenceAPIVersion = '2024-02-01'
param deploymentInPath = 'true'

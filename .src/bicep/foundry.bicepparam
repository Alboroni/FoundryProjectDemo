using './foundry.bicep'

param location = 'swedencentral'
param hubResourceGroupName = 'rg-foundry-hubswe2'
param foundryName = 'fdry-sbx-aialexyo2'
param projectName = 'sbx-project-01yo'
param storageAccountName = 'stfdrysbxyo001'
param appInsightsName = 'appi-foundry-sbx-yo2'
param keyVaultName = 'kv-foundry-connswedennew'
param subscriptionKey = 'ec97a15bf63d4853ac784a15bb041830' // Provide this securely during deployment
param secretName = 'apim-subscription-key'

// Model Gateway (single-shot path). Set URL to enable connection deployment.
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

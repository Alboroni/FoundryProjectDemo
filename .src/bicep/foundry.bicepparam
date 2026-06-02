using './foundry.bicep'

param location = 'swedencentral'
param hubResourceGroupName = 'rg-foundry-hubswe'
param foundryName = 'fdry-sbx-aialexyo'
param projectName = 'sbx-project-01yo'
param keyVaultName = 'kv-foundry-connswedennew'
param apimName = 'apim-alexyoAI' // Replace with your actual APIM name
param subscriptionKey = 'ec97a15bf63d4853ac784a15bb041830' // Provide this securely during deployment
param secretName = 'apim-subscription-key'

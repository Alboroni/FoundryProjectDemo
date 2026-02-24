using './foundry.bicep'

param location = 'swedencentral'
param hubResourceGroupName = 'rg-foundry-hubsweden'
param foundryName = 'fdry-sbx-aiswe'
param projectName = 'sbx-project-01'
param keyVaultName = 'kv-foundry-connsweden'
param apimName = 'apim-alexyoAI' // Replace with your actual APIM name
param subscriptionKey = '6ea5b3a80b1d44d7b4b2c885a3e82e4c' // Provide this securely during deployment
param secretName = 'apim-subscription-key'

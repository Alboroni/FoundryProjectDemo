using './foundry.bicep'

param location = 'uksouth'
param foundryName = 'fdry-sbx-ai'
param hubName = 'fdry-sbx-hub'
param projectName = 'sbx-project-01'
param apimName = 'your-apim-name' // Replace with your actual APIM name
param subscriptionKey = '' // Provide this securely during deployment
param secretName = 'apim-subscription-key'

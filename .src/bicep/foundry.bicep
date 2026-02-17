param location string = 'uksouth'
param rgName string = 'rg-foundry-sbx'
param foundryName string = 'fdry-sbx-ai'
param hubName string = 'fdry-sbx-hub'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
}

resource foundry 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: foundryName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  properties: {
    customSubDomainName: foundryName
    publicNetworkAccess: 'Enabled'
  }
}

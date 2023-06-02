param staticWebAppName string
param functionAppId string
param location string = resourceGroup().location

var supportedSwaLocations = [ 'westus2', 'centralus', 'eastus2', 'westeurope', 'eastasia', 'eastasiastage' ]

param tags object = {}
param swaAppSettings object

// we want the Sku to allow an Azure Function backend
param sku object = {
  name: 'Standard'
  tier: 'Standard'
}

resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: staticWebAppName
  location: contains(supportedSwaLocations, location) ? location : 'centralus'
  tags: union(tags, { 'azd-service-name': 'frontend' })
  sku: sku
  properties: {
    provider: 'Custom'
  }
}

resource staticWebAppBackend 'Microsoft.Web/staticSites/linkedBackends@2022-03-01' = {
  parent: staticWebApp
  name: 'swabackend'
  properties: {
    backendResourceId: functionAppId
    region: location

  }
}

resource staticWebAppSettings 'Microsoft.Web/staticSites/config@2021-01-15' = {
  parent: staticWebApp
  name: 'appsettings'
  properties: swaAppSettings
}

output name string = staticWebApp.name
output uri string = 'https://${staticWebApp.properties.defaultHostname}'

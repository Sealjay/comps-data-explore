@description('The name of the Azure Function app.')
param functionAppName string = 'func-${uniqueString(resourceGroup().id)}'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

param tags object = {
  'azd-service-name': 'backend'
}

@description('The name of the containers to deploy with the Azure Function.')
param containers array = [ 'content','contentoriginal' ]

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Location for Application Insights')
param appInsightsLocation string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
@allowed([
  'dotnet'
  'node'
  'python'
  'java'
])
param functionWorkerRuntime string = 'python'

@description('Required for Linux app to represent runtime stack in the format of \'runtime|runtimeVersion\'. For example: \'python|3.9\'')
param linuxFxVersion string

param openAiName string = ''
param searchServiceName string = ''

@allowed([ 'Hot', 'Cool', 'Premium' ])
param accessTier string = 'Hot'
param allowBlobPublicAccess bool = true
param allowSharedKeyAccess bool = true
param kind string = 'StorageV2'
param minimumTlsVersion string = 'TLS1_2'
@allowed([ 'Enabled', 'Disabled' ])
param publicNetworkAccess string = 'Enabled'

param searchIndexName string = 'gptkb'
param gpt4DeploymentName string = 'gpt4'

var hostingPlanName = functionAppName
var applicationInsightsName = functionAppName
var storageAccountName = '${uniqueString(resourceGroup().id)}stor'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  tags: tags
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    publicNetworkAccess: publicNetworkAccess
  }
  kind: kind
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobservices@2022-05-01' = if (!empty(containers)) {
  parent: storageAccount
  name: 'default'
  resource container 'containers' = [for container in containers: {
    name: container
    properties: {
      publicAccess: contains(container, 'publicAccess') ? container.publicAccess : 'None'
    }
  }]
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: hostingPlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource insight 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: appInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource functionApp 'Microsoft.Web/sites@2018-11-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  tags: union(tags, { 'azd-service-name': 'backend' })
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: insight.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'AZURE_OPENAI_SERVICE'
          value: openAiName
        }
        { name: 'AZURE_SEARCH_INDEX', value: searchIndexName }
        { name: 'AZURE_SEARCH_SERVICE', value: searchServiceName }
        { name: 'AZURE_OPENAI_GPT4_DEPLOYMENT', value: gpt4DeploymentName }
        { name: 'AzureWebJobsFeatureFlags', value: 'EnableWorkerIndexing' }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

output functionAppName string = functionApp.name
output functionAppId string = functionApp.id
output storageAccountName string = storageAccount.name
output functionPrincipalId string = functionApp.identity.principalId
output storagePrimaryEndpoints object = storageAccount.properties.primaryEndpoints

targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

var resourceGroupName = '${abbrs.resourcesResourceGroups}${environmentName}'

var functionName = '${abbrs.webSitesFunctions}${resourceToken}'
var staticWebAppName = '${abbrs.webStaticSites}${resourceToken}'
var containerName = 'content'

var searchServiceName = 'gptkb-${resourceToken}'
param searchServiceSkuName string = 'standard'
param searchIndexName string = 'gptkbindex'

var openAiServiceName = '${abbrs.cognitiveServicesAccounts}${resourceToken}'
param openAiSkuName string = 'S0'
param gpt4DeploymentName string = 'gpt4'
param gpt4ModelName string = 'gpt-4'
param gpt432kDeploymentName string = 'gpt432'
param gpt432kModelName string = 'gpt-4-32k'
param gpt35DeploymentName string = 'gpt35'
param gpt35ModelName string = 'gpt-35-turbo'

var formRecognizerServiceName = '${abbrs.cognitiveServicesFormRecognizer}${resourceToken}'
param formRecognizerSkuName string = 'S0'

@description('App settings to apply to the static web app')
param swaAppSettings object


@description('Id of the user or app to assign application roles')
param principalId string = ''

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  tags: tags
  location: location
}

module searchService 'core/search/search-services.bicep' = {
  name: 'search-service'
  scope: resourceGroup
  params: {
    name: searchServiceName
    location: location
    tags: tags
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    sku: {
      name: searchServiceSkuName
    }
    semanticSearch: 'free'
  }
}

module openAi 'core/ai/cognitiveservices.bicep' = {
  name: 'openai'
  scope: resourceGroup
  params: {
    name: openAiServiceName
    location: location
    tags: tags
    sku: {
      name: openAiSkuName
    }
    deployments: [
      {
        name: gpt4DeploymentName
        model: {
          format: 'OpenAI'
          name: gpt4ModelName
          version: '0314'
        }
        scaleSettings: {
          scaleType: 'Standard'
        }
      }
      {
        name: gpt432kDeploymentName
        model: {
          format: 'OpenAI'
          name: gpt432kModelName
          version: '0314'
        }
        scaleSettings: {
          scaleType: 'Standard'
        }
      }
      {
        name: gpt35DeploymentName
        model: {
          format: 'OpenAI'
          name: gpt35ModelName
          version: '0301'
        }
        scaleSettings: {
          scaleType: 'Standard'
        }
      }
    ]
  }
}

module functionApp 'core/host/functions.bicep' = {
  name: 'functionApp'
  scope: resourceGroup
  params: {
    functionAppName: functionName
    appInsightsLocation: location
    tags: union(tags, { 'azd-service-name': 'function' })
    location: location
    openAiName: openAi.outputs.name
    searchIndexName: searchIndexName
    searchServiceName: searchService.outputs.name
    gpt4DeploymentName: gpt4DeploymentName
    gpt35DeploymentName: gpt35DeploymentName
    gpt432kDeploymentName: gpt432kDeploymentName
    linuxFxVersion: 'Python|3.9'
  }
  dependsOn: [
    openAi
    searchService
  ]
}

module staticWebApp 'core/host/staticwebapp.bicep' = {
  name: 'staticwebapp'
  scope: resourceGroup
  params: {
    staticWebAppName: staticWebAppName
    location: location
    tags: union(tags, { 'azd-service-name': 'frontend' })
    sku: {
      name: 'Standard'
      tier: 'Standard'
    }
    functionAppId: functionApp.outputs.functionAppId
    swaAppSettings: swaAppSettings
  }
  dependsOn: [
    functionApp
  ]
}

module formRecognizer 'core/ai/cognitiveservices.bicep' = {
  name: 'formrecognizer'
  scope: resourceGroup
  params: {
    name: formRecognizerServiceName
    kind: 'FormRecognizer'
    location: location
    tags: tags
    sku: {
      name: formRecognizerSkuName
    }
  }
}

// USER ROLES
module openAiRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'openai-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: 'User'
  }
}

module formRecognizerRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'formrecognizer-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: 'a97b65f3-24c7-4388-baec-2e87135dc908'
    principalType: 'User'
  }
}

module storageRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'storage-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
    principalType: 'User'
  }
}

module storageContribRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'storage-contribrole-user'
  params: {
    principalId: principalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'User'
  }
}

module searchRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'search-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: 'User'
  }
}

module searchContribRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'search-contrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
    principalType: 'User'
  }
}

// SYSTEM IDENTITIES
module openAiRoleBackend 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'openai-role-backend'
  params: {
    principalId: functionApp.outputs.functionPrincipalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: 'ServicePrincipal'
  }
}

module storageRoleBackend 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'storage-role-backend'
  params: {
    principalId: functionApp.outputs.functionPrincipalId
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
    principalType: 'ServicePrincipal'
  }
}

module searchRoleBackend 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'search-role-backend'
  params: {
    principalId: functionApp.outputs.functionPrincipalId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: 'ServicePrincipal'
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = resourceGroup.name

output AZURE_OPENAI_SERVICE string = openAi.outputs.name
output AZURE_OPENAI_GPT4_DEPLOYMENT string = gpt4DeploymentName

output AZURE_FORMRECOGNIZER_SERVICE string = formRecognizer.outputs.name

output AZURE_SEARCH_INDEX string = searchIndexName
output AZURE_SEARCH_SERVICE string = searchService.outputs.name

output AZURE_STORAGE_ACCOUNT string = functionApp.outputs.storageAccountName
output AZURE_STORAGE_CONTAINER string = containerName

output FRONTEND_URI string = staticWebApp.outputs.uri
output API_FUNCTION_NAME string = functionApp.outputs.functionAppName

param storageName string = 'cloudtopiastorage${uniqueString(resourceGroup().id)}'
param acrName string = 'cloudtopiaacr'
param containerImage string
param staticWebAppName string = 'cloudtopiadashboard${uniqueString(resourceGroup().id)}'
param githubRepoToken string
param githubRepoUrl string
param githubBranch string = 'main'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

resource weatherContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccount.name}/default/weatherdata'
  properties: {
    publicAccess: 'Blob'
  }
  dependsOn: [
    storageAccount
  ]
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {}
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2022-09-01' = {
  name: 'weather-detector'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    containers: [
      {
        name: 'weather'
        properties: {
          image: containerImage
          resources: {
            requests: {
              cpu: 1
              memoryInGb: 1.5
            }
          }
          environmentVariables: [
            {
              name: 'STORAGE_CONNECTION_STRING'
              secureValue: storageAccount.listKeys().keys[0].value
            }
          ]
        }
      }
    ]
    osType: 'Linux'
  }
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerGroup.id, 'AcrPull')
  properties: {
    principalId: containerGroup.identity.principalId
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4a42b06b-d6b1-45f1-b6ad-d97dca549aba'
    scope: acr.id
  }
}

resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: staticWebAppName
  location: 'East US2'
  properties: {
    repositoryUrl: 'https://github.com/${githubRepoUrl}'
    branch: githubBranch
    buildProperties: {
      appLocation: '/dashboard'
      outputLocation: ''
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output blobUrl string = 'https://${storageAccount.name}.blob.core.windows.net/weatherdata/latest_weather.json'
output dashboardUrl string = staticWebApp.properties.defaultHostname

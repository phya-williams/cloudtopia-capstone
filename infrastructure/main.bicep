param storageName string
param acrName string
param containerImage string
param githubRepoToken string = ''

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'weather-simulator-container'
  location: resourceGroup().location
  properties: {
    osType: 'Linux'
    containers: [
      {
        name: 'weather-simulator'
        properties: {
          image: containerImage
          resources: {
            requests: {
              cpu: 1.0
              memoryInGb: 1.5
            }
          }
          environmentVariables: [
            {
              name: 'AZURE_STORAGE_ACCOUNT'
              value: storageName
            }
          ]
        }
      }
    ]
    imageRegistryCredentials: [
      {
        server: '${acrName}.azurecr.io'
        username: listCredentials(containerRegistry.id, containerRegistry.apiVersion).username
        password: listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords[0].value
      }
    ]
    restartPolicy: 'OnFailure'
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: '${storageAccount.name}/default/weather-logs'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccount
  ]
}

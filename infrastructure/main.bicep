@description('Name of the storage account')
param storageName string

@description('Name of the container registry')
param acrName string

@description('Full image name including tag (e.g., acrName.azurecr.io/image:tag)')
param containerImage string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: '${storageAccount.name}/default'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: 'weather-logs'
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'weather-simulator-group'
  location: resourceGroup().location
  properties: {
    osType: 'Linux'
    restartPolicy: 'OnFailure'
    containers: [
      {
        name: 'weather-simulator'
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
        username: acrName
        password: 'CloudTopiaWeather1!' // Use secure method in production
      }
    ]
  }
}

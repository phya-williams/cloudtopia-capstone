@description('Name of the storage account')
param cloudtopiaStorageName string

@description('Name of the container registry')
param cloudtopiaAcrName string

@description('Full container image name including tag (e.g., acrName.azurecr.io/image:tag)')
param cloudtopiaContainerImage string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: cloudtopiaStorageName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: '${storageAccount.name}/default'
  parent: storageAccount
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
          image: cloudtopiaContainerImage
          resources: {
            requests: {
              cpu: 1
              memoryInGb: 1.5
            }
          }
          environmentVariables: [
            {
              name: 'AZURE_STORAGE_ACCOUNT'
              value: cloudtopiaStorageName
            }
          ]
        }
      }
    ]
    imageRegistryCredentials: [
      {
        server: '${cloudtopiaAcrName}.azurecr.io'
        username: cloudtopiaAcrName
        password: 'CloudTopiaWeather1!' // Replace with secure method in production
      }
    ]
  }
}

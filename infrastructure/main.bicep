param storageName string = 'cloudtopiastorage${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2022-09-01' = {
  name: 'weather-detector'
  location: resourceGroup().location
  properties: {
    containers: [
      {
        name: 'weather'
        properties: {
          image: '<your-docker-image>'  // Replace this!
          resources: {
            requests: {
              cpu: 1
              memoryInGb: 1.5
            }
          }
          environmentVariables: [
            {
              name: 'STORAGE_CONNECTION_STRING'
              secureValue: listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value
            }
          ]
        }
      }
    ]
    osType: 'Linux'
  }
}

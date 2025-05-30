// =============================
// main.bicep - CloudTopia Infrastructure
// =============================

@description('The name of the storage account.')
param storageName string

@description('The name of the Azure Container Registry.')
param acrName string

@description('The full image name including tag to use for the container.')
param containerImage string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
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

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/default/weatherdata'
  properties: {
    publicAccess: 'None'
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
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
  name: 'cloudtopia-simulator'
  location: resourceGroup().location
  properties: {
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
              name: 'STORAGE_ACCOUNT'
              value: storageAccount.name
            }
            {
              name: 'BLOB_CONTAINER'
              value: 'weatherdata'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    imageRegistryCredentials: [
      {
        server: '${acr.name}.azurecr.io'
        username: acr.name
        password: acr.listCredentials().passwords[0].value
      }
    ]
  }
}

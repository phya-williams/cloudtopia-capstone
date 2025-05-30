param storageName string
param acrName string
param containerImage string
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccount.name}/default/weatherdata'
  properties: {
    publicAccess: 'None'
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'cloudtopia-simulator'
  location: location
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
    diagnostics: {
      logAnalytics: {
        workspaceId: '<your-log-analytics-workspace-id>'
        workspaceKey: '<your-log-analytics-key>'
      }
    }
  }
}

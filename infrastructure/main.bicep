param storageName string = 'cloudtopiastorage${uniqueString(resourceGroup().id)}'
param acrName string = 'cloudtopiaacr'
param containerImage string  // Passed dynamically from GitHub Actions

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

// Storage Container for weather logs
resource weatherContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccount.name}/default/weatherdata'
  properties: {
    publicAccess: 'Blob' // Allow public read access for the dashboard
  }
  dependsOn: [
    storageAccount
  ]
}

// Azure Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {}
}

// Container Instance to simulate weather
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
              secureValue: listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value
            }
          ]
        }
      }
    ]
    osType: 'Linux'
  }
}

// Role Assignment to allow ACI to pull from ACR
resource acrPul

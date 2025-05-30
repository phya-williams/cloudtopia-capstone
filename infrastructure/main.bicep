param location string = resourceGroup().location
param storageAccountName string = 'cloudtpstatic01'  // must be unique, 3-24 lowercase letters/numbers, no hyphens
param containerRegistryName string = 'cloudtpacr'    // must be unique, lowercase, 5-50 chars

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// Blob container #1
resource blobContainer1 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: '${storageAccount.name}/default/container1'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccount
  ]
}

// Blob container #2
resource blobContainer2 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: '${storageAccount.name}/default/container2'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccount
  ]
}

// Azure Container Registry (ACR)
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

// Container Instance
resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'cloudtop-containerinstance'
  location: location
  properties: {
    osType: 'Linux'
    restartPolicy: 'Never'
    containers: [
      {
        name: 'mycontainer'
        properties: {
          image: '${containerRegistry.loginServer}/myimage:latest'  // replace with your image name
          resources: {
            requests: {
              cpu: 1.0
              memoryInGB: 1.5
            }
          }
          // You can add environment variables, commands, etc. here if needed
        }
      }
    ]
  }
  dependsOn: [
    containerRegistry
  ]
}

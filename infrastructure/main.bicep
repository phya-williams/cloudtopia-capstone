param location string = resourceGroup().location
param cloudtopiaStorageName string
param cloudtopiaContainerName string = 'data'
param cloudtopiaAcrName string
param cloudtopiaContainerInstanceName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: cloudtopiaStorageName
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
  name: '${storageAccount.name}/default/${cloudtopiaContainerName}'
  properties: {
    publicAccess: 'None'
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: cloudtopiaAcrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: cloudtopiaContainerInstanceName
  location: location
  properties: {
    containers: [
      {
        name: 'cloudtopiacontainer'
        properties: {
          image: 'mcr.microsoft.com/azuredocs/aci-helloworld'
          resources: {
            requests: {
              cpu: 1.0
              memoryInGb: 1.5
            }
          }
          ports: [
            {
              port: 80
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          protocol: 'tcp'
          port: 80
        }
      ]
    }
  }
}

param storageName string = 'cloudtopiastorage${uniqueString(resourceGroup().id)}'
param acrName string = 'cloudtopiaacr'
param containerImage string  // New parameter for the container image

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
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
  properties: {
    containers: [
      {
        name: 'weather'
        properties: {
          image: containerImage  // Now using the parameter
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
    identity: {
      type: 'SystemAssigned'
    }
  }
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerGroup.id, 'AcrPull')
  properties: {
    principalId: containerGroup.identity.principalId
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4a42b06b-d6b1-45f1-b6ad-d97dca549aba'  // AcrPull role
    scope: acr.id
  }
}

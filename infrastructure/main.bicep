param storageName string = 'cloudtopiastorage${uniqueString(resourceGroup().id)}'
param acrName string = 'cloudtopiaacr'
param containerImage string  // Passed dynamically from GitHub Actions
param staticWebAppName string = 'cloudtopiadashboard${uniqueString(resourceGroup().id)}'
param githubRepoToken string  // GitHub token used to authorize deployment
param githubRepoUrl string    // e.g., 'user/repo-name'
param githubBranch string = 'main'

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
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerGroup.id, 'AcrPull')
  properties: {
    principalId: containerGroup.identity.principalId
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4a42b06b-d6b1-45f1-b6ad-d97dca549aba'  // AcrPull role
    scope: acr.id
  }
}

// Static Web App for dashboard
resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: staticWebAppName
  location: 'East US2'  // Must be one of the supported Static Web Apps regions
  properties: {
    repositoryUrl: 'https://github.com/${githubRepoUrl}'
    branch: githubBranch
    buildProperties: {
      appLocation: "/dashboard"  // Folder in repo with index.html
      outputLocation: ""         // Not needed for plain HTML
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Deploy GitHub Actions for Static Web App (automated)
resource staticWebAppToken 'Microsoft.Web/staticSites/userProvidedFunctionApps@2022-03-01' = if (!empty(githubRepoToken)) {
  parent: staticWebApp
  name: 'default'
  properties: {
    githubActionConfiguration: {
      githubPersonalAccessToken: githubRepoToken
    }
  }
}

// Output URLs
output blobUrl string = 'https://${storageAccount.name}.blob.core.windows.net/weatherdata/latest_weather.json'
output dashboardUrl string = staticWebApp.properties.defaultHostname

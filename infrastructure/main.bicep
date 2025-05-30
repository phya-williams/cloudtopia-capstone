param location string = resourceGroup().location

// Storage account for weather logs + static site
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'cloudtopiastatic${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    staticWebsite: {
      indexDocument: 'index.html'
      error404Document: 'index.html'
    }
  }
}

// Upload HTML dashboard via deployment script
resource uploadDashboardScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'uploadDashboard'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.52.0'
    timeout: 'PT10M'
    retentionInterval: 'P1D'
    scriptContent: '''
      # Enable static website just in case
      az storage blob service-properties update \
        --account-name ${storageAccount.name} \
        --static-website \
        --index-document index.html

      # Download HTML file from GitHub
      curl -L -o index.html https://raw.githubusercontent.com/phya-williams/cloudtopia-capstone/main/dashboard/index.html

      # Upload to $web container
      az storage blob upload \
        --account-name ${storageAccount.name} \
        --container-name '$web' \
        --name index.html \
        --file index.html \
        --content-type 'text/html' \
        --overwrite
    '''
    forceUpdateTag: '1'
    environmentVariables: []
    cleanupPreference: 'OnSuccess'
    identity: {
      type: 'UserAssigned' // optional, could also be 'SystemAssigned'
    }
  }
  dependsOn: [
    storageAccount
  ]
}

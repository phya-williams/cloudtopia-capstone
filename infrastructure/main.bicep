param location string = resourceGroup().location

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'cloudtopiastatic-pw'
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

// Web dashboard upload
resource uploadDashboardScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'uploadDashboard'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.52.0'
    timeout: 'PT10M'
    retentionInterval: 'P1D'
    scriptContent: '''
      curl -L -o index.html https://raw.githubusercontent.com/phya-williams/cloudtopia-capstone/main/dashboard/index.html
      az storage blob upload \
        --account-name ${storageAccount.name} \
        --container-name '$web' \
        --name index.html \
        --file index.html \
        --content-type 'text/html' \
        --overwrite
    '''
    forceUpdateTag: '1'
    cleanupPreference: 'OnSuccess'
  }
  dependsOn: [
    storageAccount
  ]
}

// Blob container for logs
resource weatherLogsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: '${storageAccount.name}/default/weather-logs'
  properties: {
    publicAccess: 'Blob'
  }
  dependsOn: [storageAccount]
}

// Container Instance to write multiple logs
resource logWriterContainer 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'cloudtopialogwriter'
  location: location
  properties: {
    osType: 'Linux'
    restartPolicy: 'Never'
    containers: [
      {
        name: 'log-writer'
        properties: {
          image: 'mcr.microsoft.com/azure-cli'
          resources: {
            requests: {
              cpu: 1.0
              memoryInGB: 1.5
            }
          }
          command: [
            "/bin/sh"
            "-c"
            '''
            for i in $(seq 1 5); do
              ts=$(date -u -d "$i minute ago" +"%Y-%m-%dT%H:%M:%SZ")
              echo "{
                \\"timestamp\\": \\"$ts\\",
                \\"location\\": \\"Zone $i\\",
                \\"temperature_c\\": $((20 + $i)),
                \\"humidity_percent\\": $((60 + $i)),
                \\"wind_kph\\": $((10 + $i)),
                \\"alert\\": \\"Test Alert $i\\"
              }" > sample-log-$i.json

              az storage blob upload \
                --account-name ${storageAccount.name} \
                --container-name weather-logs \
                --name sample-log-$i.json \
                --file sample-log-$i.json \
                --overwrite
            done

            sleep 300
            '''
          ]
        }
      }
    ]
  }
  dependsOn: [weatherLogsContainer]
}

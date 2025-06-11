param location string = 'eastus'
param storageAccountName string = 'cloudtopiablob2025'
param containerName string = 'weatherdata'
param vnetName string = 'cloudtopia-vnet'
param subnetName string = 'weather-subnet'
param vnetAddressPrefix string = '10.0.0.0/16'
param subnetAddressPrefix string = '10.0.0.0/24'
param workspaceName string = 'weatheranalytics'
param appInsightsName string = 'weatherappinsights'
param appServicePlanName string = 'cloudtopia-plan'
param webAppName string = 'cloudtopia-dashboard'



var nsgName = '${vnetName}-nsg'

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

// Blob Container
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccount.name}/default/${containerName}'
  properties: {
    publicAccess: 'None'
  }
}

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Virtual Network + Subnet with NSG
resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnetAddressPrefix]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// Monitoring
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}
 
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

resource servicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'F1' // Free Tier
    tier: 'Free'
  }
  kind: 'app'
  properties: {
    reserved: false
  }
}

resource nodeWebApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: servicePlan.id
    siteConfig: {
  linuxFxVersion: 'NODE|18-lts'
  appSettings: [
    {
      name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
      value: 'true'
    }
    {
      name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
      value: 'true'
    }
    {
      name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
      value: appInsights.properties.InstrumentationKey
    }
  ]
}
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    servicePlan
    appInsights
  ]
}

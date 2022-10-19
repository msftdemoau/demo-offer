@description('Web app name.')
@minLength(2)
param webAppName string = 'webApp-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Git Repo URL')
param repoUrl string = ''

@description('Git Repo Branch')
param repoBranch string = 'main'

var appServicePlanPortalName = 'AppServicePlan-${webAppName}'
var sku = 'F1'
var linuxFxVersion = 'PYTHON|3.7'

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanPortalName
  location: location
  sku: {
    name: sku
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: webAppName
  location: location
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource webAppSourceControl 'Microsoft.Web/sites/sourcecontrols@2021-02-01' = {
  name: 'web'
  parent: webApp
  properties: {
    repoUrl: repoUrl
    branch: repoBranch
    isManualIntegration: true
  }
}

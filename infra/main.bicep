param location string = resourceGroup().location
param appName string = 'jackstalley-resume'

// 1. Cosmos DB (Serverless)
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: '${appName}-db'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [{ locationName: location }]
    capabilities: [{ name: 'EnableServerless' }]
  }
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmosAccount
  name: 'ResumeData'
  properties: { resource: { id: 'ResumeData' } }
}

resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: cosmosDb
  name: 'Visitors'
  properties: {
    resource: {
      id: 'Visitors'
      partitionKey: { paths: ['/id'], kind: 'Hash' }
    }
  }
}

// 2. Static Web App
resource swa 'Microsoft.Web/staticSites@2022-09-01' = {
  name: '${appName}-web'
  location: 'westeurope'
  sku: { name: 'Free', tier: 'Free' }
  properties: {
    allowConfigFileUpdates: true
    stagingEnvironmentPolicy: 'Enabled'
  }
}

// Outputs to help the GitHub Action
output swaName string = swa.name
output cosmosConnectionString string = cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString

// main.bicep
param location string = resourceGroup().location
param appName string = 'jackstalley-resume'

// 1. Cosmos DB (Serverless - Cheapest Option)
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: '${appName}-db'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [{ locationName: location }]
    capabilities: [{ name: 'EnableServerless' }] // Key for low cost
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

// 2. Azure Static Web App (Hosting + SSL)
resource swa 'Microsoft.Web/staticSites@2022-09-01' = {
  name: '${appName}-web'
  location: 'westeurope' // SWA is global, but resource needs a region
  sku: { name: 'Free', tier: 'Free' }
  properties: {
    allowConfigFileUpdates: true
    stagingEnvironmentPolicy: 'Enabled'
  }
}

// 3. Application Insights (Monitoring)
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appName}-ai'
  location: location
  kind: 'web'
  properties: { Application_Type: 'web' }
}

// 4. Function App (PowerShell - Your Core Skill)
// Using Consumption plan for cost efficiency
resource hostingPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${appName}-plan'
  location: location
  sku: { name: 'Y1', tier: 'Dynamic' }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: '${appName}-func'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        { name: 'AzureWebJobsStorage', value: 'UseDevelopmentStorage=true' } // Update with actual storage connection if needed
        { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'powershell' }
        { name: 'APPINSIGHTS_INSTRUMENTATIONKEY', value: appInsights.properties.InstrumentationKey }
        { name: 'CosmosConnection', value: cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString }
      ]
      cors: {
        allowedOrigins: ['https://${swa.properties.defaultHostname}'] // Secure CORS
      }
    }
  }
}

// Output the SWA URL
output siteUrl string = swa.properties.defaultHostname

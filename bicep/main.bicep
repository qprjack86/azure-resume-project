param location string = resourceGroup().location
param WebsiteFilePath string = 'C:\'azure-resume-project\'azure-resume-project\'website'

var StorageAccountName = stg.name

resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  // This is the Storage Account Contributor role, which is the minimum role permission we can give. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#:~:text=17d1049b-9a84-46fb-8f53-869881c3d3ab
  name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
}

resource stg 'Microsoft.Storage/storageAccounts@2022-09-01' existing ={
  name: 'jsstorageaccount'
}

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'jswebuami'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope:stg
  name: guid(resourceGroup().id, uami.id, contributorRoleDefinition.id)
  properties: {
    principalId: uami.properties.principalId
    roleDefinitionId: contributorRoleDefinition.id
    principalType:'ServicePrincipal'
  }
}

resource deploymentscript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'webstor'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}' : {}
    }
  }
  properties: {
    azCliVersion: '2.9.1' 
    retentionInterval: 'P1D'
    timeout:'PT10M'
    cleanupPreference:'OnSuccess'
  arguments: '\'${StorageAccountName}\' \'${WebsiteFilePath}\''
  scriptContent:'''
 az storage blob service-properties update --account-name $StorageAccountName --static-website --index-document index.html
 az storage blob upload-batch --source $WebsiteFilePath --destination '$web' --account-name $StorageAccountName
'''
  }
}

param location string = resourceGroup().location

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

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: stg
  name: guid(resourceGroup().id, uami.id, contributorRoleDefinition.id)
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: uami.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentscript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deploymmentScript'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: 'latest'
    retentionInterval: 'PT10M'
    scriptContent:loadTextContent()
  }

}

// Parameters
@description('Specifies the name of the user-defined managed identity.')
param managedIdentityName string

@description('Specifies the name of the existing Azure Cosmos Db account.')
param cosmosDbAccountName string

@description('Specifies the name of the existing Service Bus namespace.')
param serviceBusNamespaceName string

@description('Specifies the name of the existing storage account.')
param blobStorageAccountName string

@description('Specifies the name of the existing Key Vault.')
param keyVaultName string

// Variables
var cosmosDbDataContributorRoleDefinitionId = resourceId('Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions', cosmosDbAccountName, '00000000-0000-0000-0000-000000000002')
var serviceBusDataOwnerRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '090c5cfd-751d-490a-894a-3ce6f1109419')
var storageBlobDataContributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

// Resources
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' existing = {
  name: managedIdentityName
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-02-15-preview' existing = {
  name: toLower(cosmosDbAccountName)
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

resource blobStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing =  {
  name: blobStorageAccountName
}

resource cosmosDbDataContributorRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-10-15' = {
  name: guid(managedIdentity.id, cosmosDbAccount.id, cosmosDbDataContributorRoleDefinitionId)
  parent: cosmosDbAccount
  properties: {
    roleDefinitionId: cosmosDbDataContributorRoleDefinitionId
    principalId: managedIdentity.properties.principalId
    scope: cosmosDbAccount.id
  }
}

resource serviceBusDataOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name:  guid(managedIdentity.id, serviceBusNamespace.id, serviceBusDataOwnerRoleDefinitionId)
  scope: serviceBusNamespace
  properties: {
    roleDefinitionId: serviceBusDataOwnerRoleDefinitionId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageBlobDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name:  guid(managedIdentity.id, blobStorageAccount.id, storageBlobDataContributorRoleDefinitionId)
  scope: blobStorageAccount
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleDefinitionId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: managedIdentity.properties.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

// Outputs
output id string = managedIdentity.id
output name string = managedIdentity.name

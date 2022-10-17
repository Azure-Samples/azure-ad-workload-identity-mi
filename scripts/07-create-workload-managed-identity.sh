#!/bin/bash

# Variables
source ./00-variables.sh

# Check if the user-assigned managed identity already exists
echo "Checking if [$managedIdentityName] user-assigned managed identity actually exists in the [$resourceGroupName] resource group..."

az identity show \
  --name $managedIdentityName \
  --resource-group $resourceGroupName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$managedIdentityName] user-assigned managed identity actually exists in the [$resourceGroupName] resource group"
  echo "Creating [$managedIdentityName] user-assigned managed identity in the [$resourceGroupName] resource group..."

  # Create the user-assigned managed identity
  az identity create \
    --name $managedIdentityName \
    --resource-group $resourceGroupName \
    --location $location \
    --subscription $subscriptionId 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$managedIdentityName] user-assigned managed identity successfully created in the [$resourceGroupName] resource group"
  else
    echo "Failed to create [$managedIdentityName] user-assigned managed identity in the [$resourceGroupName] resource group"
    exit
  fi
else
  echo "[$managedIdentityName] user-assigned managed identity already exists in the [$resourceGroupName] resource group"
fi

# Retrieve the clientId of the user-assigned managed identity
echo "Retrieving clientId for [$managedIdentityName] managed identity..."
clientId=$(az identity show \
  --name $managedIdentityName \
  --resource-group $resourceGroupName \
  --query clientId \
  --output tsv)

if [[ -n $clientId ]]; then
  echo "[$clientId] clientId  for the [$managedIdentityName] managed identity successfully retrieved"
else
  echo "Failed to retrieve clientId for the [$managedIdentityName] managed identity"
  exit
fi

# Retrieve the principalId of the user-assigned managed identity
echo "Retrieving principalId for [$managedIdentityName] managed identity..."
principalId=$(az identity show \
  --name $managedIdentityName \
  --resource-group $resourceGroupName \
  --query principalId \
  --output tsv)

if [[ -n $principalId ]]; then
  echo "[$principalId] principalId  for the [$managedIdentityName] managed identity successfully retrieved"
else
  echo "Failed to retrieve principalId for the [$managedIdentityName] managed identity"
  exit
fi

# Grant get and list permissions on key vault secrets to the managed identity
echo "Granting get permissions on secrets in [$keyVaultName] key vault to [$managedIdentityName] managed identity..."
az keyvault set-policy \
  --name $keyVaultName \
  --spn $clientId \
  --secret-permissions get list 1>/dev/null

if [[ $? == 0 ]]; then
  echo "Get and List permissions on secrets in [$keyVaultName] key vault successfully granted to [$managedIdentityName] managed identity"
else
  echo "Failed to grant Get and List permissions on secrets in [$keyVaultName] key vault to [$managedIdentityName] managed identity"
  exit
fi

if [[ $? == 0 ]]; then
  echo "Access policy successfully set for the [$managedIdentityName] managed identity on the [$keyVaultName] key vault"
else
  echo "Failed to set the access policy for the [$managedIdentityName] managed identity on the [$keyVaultName] key vault"
fi

# Get storage account resource id
storageAccountId=$(az storage account show \
  --name $storageAccountName \
  --query id \
  --output tsv)

if [[ -n $storageAccountId ]]; then
  echo "Resource id for the [$storageAccountName] storage account successfully retrieved"
else
  echo "Failed to the resource id for the [$storageAccountName] storage account"
  exit -1
fi

# Assign the Storage Blob Data Contributor role to the service principal of the AAD application with the storage account as scope
role="Storage Blob Data Contributor"
echo "Checking if service principal of the [$managedIdentityName] managed identity has been assigned to [$role] role with [$storageAccountName] storage account as scope..."
current=$(az role assignment list \
  --assignee $principalId \
  --scope $storageAccountId \
  --query "[?roleDefinitionName=='$role'].roleDefinitionName" \
  --output tsv 2>/dev/null)

if [[ $current == $role ]]; then
  echo "Service principal of the [$managedIdentityName] managed identity is already assigned to the ["$current"] role with [$storageAccountName] storage account as scope"
else
  echo "Service principal of the [$managedIdentityName] managed identity is not assigned to the [$role] role with [$storageAccountName] storage account as scope"
  echo "Assigning the service principal of the [$managedIdentityName] managed identity to the [$role] role with [$storageAccountName] storage account as scope..."

  az role assignment create \
    --assignee $principalId \
    --role "$role" \
    --scope $storageAccountId 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "Service principal of the [$managedIdentityName] managed identity successfully assigned to the [$role] role with [$storageAccountName] storage account as scope"
  else
    echo "Failed to assign the service principal of the [$managedIdentityName] managed identity to the [$role] role with [$storageAccountName] storage account as scope"
    exit
  fi
fi

# Assign the Cosmos DB Built-in Data Contributor role to the service principal of the AAD application with the Cosmos DB accout as scope
role="Cosmos DB Built-in Data Contributor"
roleId="00000000-0000-0000-0000-000000000002"
echo "Checking if service principal of the [$managedIdentityName] managed identity has been assigned to [$role] role with [$cosmosDbAccountName] Cosmos DB account as scope..."
current=$(az cosmosdb sql role assignment list \
  --account-name $cosmosDbAccountName \
  --resource-group $resourceGroupName \
  --query "[?principalId=='$principalId'].roleDefinitionId" \
  --output tsv)

if [[ -n $current ]]; then
  echo "Service principal of the [$managedIdentityName] managed identity is already assigned to the ["$role"] role with [$cosmosDbAccountName] Cosmos DB account as scope"
else
  echo "Service principal of the [$managedIdentityName] managed identity is not assigned to the [$role] role with [$cosmosDbAccountName] Cosmos DB account as scope"
  echo "Assigning the service principal of the [$managedIdentityName] managed identity to the [$role] role with [$cosmosDbAccountName] Cosmos DB account as scope..."

  az cosmosdb sql role assignment create \
    --account-name $cosmosDbAccountName \
    --resource-group $resourceGroupName \
    --scope "/" \
    --principal-id $principalId \
    --role-definition-id "$roleId" 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "Service principal of the [$managedIdentityName] managed identity successfully assigned to the [$role] role with [$cosmosDbAccountName] Cosmos DB account as scope"
  else
    echo "Failed to assign the service principal of the [$managedIdentityName] managed identity to the [$role] role with [$cosmosDbAccountName] Cosmos DB account as scope"
    exit
  fi
fi

# Get Service Bus namespace resource id
serviceBusNamespaceId=$(az servicebus namespace show \
  --name $serviceBusNamespace \
  --resource-group $resourceGroupName \
  --query id \
  --output tsv)

if [[ -n $serviceBusNamespaceId ]]; then
  echo "Resource id for the [$serviceBusNamespace] Service Bus namespace successfully retrieved"
else
  echo "Failed to the resource id for the [$serviceBusNamespace] Service Bus namespace"
  exit -1
fi

# Assign the Azure Service Bus Data Owner role to the service principal of the AAD application with the Service Bus namespace as scope
role="Azure Service Bus Data Owner"
echo "Checking if service principal of the [$managedIdentityName] managed identity has been assigned to [$role] role with [$serviceBusNamespace] Service Bus namespace as scope..."
current=$(az role assignment list \
  --assignee $principalId \
  --scope $serviceBusNamespaceId \
  --query "[?roleDefinitionName=='$role'].roleDefinitionName" \
  --output tsv 2>/dev/null)

if [[ -n $current ]]; then
  echo "Service principal of the [$managedIdentityName] managed identity is already assigned to the ["$current"] role with [$serviceBusNamespace] Service Bus namespace as scope"
else
  echo "Service principal of the [$managedIdentityName] managed identity is not assigned to the [$role] role with [$serviceBusNamespace] Service Bus namespace as scope"
  echo "Assigning the service principal of the [$managedIdentityName] managed identity to the [$role] role with [$serviceBusNamespace] Service Bus namespace as scope..."

  az role assignment create \
    --assignee $principalId \
    --role "$role" \
    --scope $serviceBusNamespaceId 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "Service principal of the [$managedIdentityName] managed identity successfully assigned to the [$role] role with [$serviceBusNamespace] Service Bus namespace as scope"
  else
    echo "Failed to assign the service principal of the [$managedIdentityName] managed identity to the [$role] role with [$serviceBusNamespace] Service Bus namespace as scope"
    exit
  fi
fi

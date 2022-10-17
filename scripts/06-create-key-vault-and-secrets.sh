#!/bin/bash

# Variables
source ./00-variables.sh

# Check if the resource group already exists
echo "Checking if [$resourceGroupName] resource group actually exists in the [$subscriptionName] subscription..."

az group show --name $resourceGroupName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$resourceGroupName] resource group actually exists in the [$subscriptionName] subscription"
  echo "Creating [$resourceGroupName] resource group in the [$subscriptionName] subscription..."

  # create the resource group
  az group create --name $resourceGroupName --location $location 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$resourceGroupName] resource group successfully created in the [$subscriptionName] subscription"
  else
    echo "Failed to create [$resourceGroupName] resource group in the [$subscriptionName] subscription"
    exit
  fi
else
  echo "[$resourceGroupName] resource group already exists in the [$subscriptionName] subscription"
fi

# Check if the key vault already exists
echo "Checking if [$keyVaultName] key vault actually exists in the [$subscriptionName] subscription..."

az keyvault show --name $keyVaultName --resource-group $resourceGroupName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$keyVaultName] key vault actually exists in the [$subscriptionName] subscription"
  echo "Creating [$keyVaultName] key vault in the [$subscriptionName] subscription..."

  # create the key vault
  az keyvault create \
    --name $keyVaultName \
    --resource-group $resourceGroupName \
    --location $location \
    --enabled-for-deployment \
    --enabled-for-disk-encryption \
    --enabled-for-template-deployment \
    --sku $keyVaultSku 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$keyVaultName] key vault successfully created in the [$subscriptionName] subscription"
  else
    echo "Failed to create [$keyVaultName] key vault in the [$subscriptionName] subscription"
    exit
  fi
else
  echo "[$keyVaultName] key vault already exists in the [$subscriptionName] subscription"
fi

# Check if the secret already exists
cosmosDbEndpointUriSecretName="RepositoryService--CosmosDb--EndpointUri"
cosmosDbEndpointUriSecretValue="https://${cosmosDbAccountName}.documents.azure.com:443/"

echo "Checking if [$cosmosDbEndpointUriSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $cosmosDbEndpointUriSecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$cosmosDbEndpointUriSecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$cosmosDbEndpointUriSecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $cosmosDbEndpointUriSecretName \
    --vault-name $keyVaultName \
    --value $cosmosDbEndpointUriSecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$cosmosDbEndpointUriSecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$cosmosDbEndpointUriSecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$cosmosDbEndpointUriSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Get Cosmos DB account primary key
cosmosDBPrimaryKey=$(az cosmosdb keys list \
  --name $cosmosDbAccountName \
  --resource-group $resourceGroupName \
  --type keys \
  --query primaryMasterKey \
  --output tsv)

# Check if the secret already exists
cosmosDbPrimaryKeySecretName="RepositoryService--CosmosDb--PrimaryKey"
cosmosDbPrimaryKeySecretValue=$cosmosDBPrimaryKey

echo "Checking if [$cosmosDbPrimaryKeySecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $cosmosDbPrimaryKeySecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 && -n $cosmosDBPrimaryKey ]]; then
  echo "No [$cosmosDbPrimaryKeySecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$cosmosDbPrimaryKeySecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $cosmosDbPrimaryKeySecretName \
    --vault-name $keyVaultName \
    --value $cosmosDbPrimaryKeySecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$cosmosDbPrimaryKeySecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$cosmosDbPrimaryKeySecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$cosmosDbPrimaryKeySecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
cosmosDbUseAzureCredentialSecretName="RepositoryService--CosmosDb--UseAzureCredential"
cosmosDbUseAzureCredentialSecretValue=$cosmosDbUseAzureCredential

echo "Checking if [$cosmosDbUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $cosmosDbUseAzureCredentialSecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$cosmosDbUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$cosmosDbUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $cosmosDbUseAzureCredentialSecretName \
    --vault-name $keyVaultName \
    --value $cosmosDbUseAzureCredentialSecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$cosmosDbUseAzureCredentialSecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$cosmosDbUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$cosmosDbUseAzureCredentialSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
cosmosDbDatabaseNameSecretName="RepositoryService--CosmosDb--DatabaseName"
cosmosDbDatabaseNameSecretValue=$cosmosDbDatabaseName

echo "Checking if [$cosmosDbDatabaseNameSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $cosmosDbDatabaseNameSecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$cosmosDbDatabaseNameSecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$cosmosDbDatabaseNameSecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $cosmosDbDatabaseNameSecretName \
    --vault-name $keyVaultName \
    --value $cosmosDbDatabaseNameSecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$cosmosDbDatabaseNameSecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$cosmosDbDatabaseNameSecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$cosmosDbDatabaseNameSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
cosmosDbCollectionNameSecretName="RepositoryService--CosmosDb--CollectionName"
cosmosDbCollectionNameSecretValue=$cosmosDbCollectionName

echo "Checking if [$cosmosDbCollectionNameSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $cosmosDbCollectionNameSecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$cosmosDbCollectionNameSecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$cosmosDbCollectionNameSecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $cosmosDbCollectionNameSecretName \
    --vault-name $keyVaultName \
    --value $cosmosDbCollectionNameSecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$cosmosDbCollectionNameSecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$cosmosDbCollectionNameSecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$cosmosDbCollectionNameSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Get Service Bus namespace connection string
serviceBusConnectionString=$(az servicebus namespace authorization-rule keys list \
  --resource-group $resourceGroupName \
  --namespace-name $serviceBusNamespace \
  --name RootManageSharedAccessKey \
  --query primaryConnectionString \
  --output tsv)

# Check if the secret already exists
serviceBusConnectionStringSecretName="NotificationService--ServiceBus--ConnectionString"
serviceBusConnectionStringSecretValue=$serviceBusConnectionString

echo "Checking if [$serviceBusConnectionStringSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $serviceBusConnectionStringSecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 && -n $serviceBusConnectionString ]]; then
  echo "No [$serviceBusConnectionStringSecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$serviceBusConnectionStringSecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $serviceBusConnectionStringSecretName \
    --vault-name $keyVaultName \
    --value $serviceBusConnectionStringSecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$serviceBusConnectionStringSecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$serviceBusConnectionStringSecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$serviceBusConnectionStringSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
serviceBusNamespaceSecretName="NotificationService--ServiceBus--Namespace"
serviceBusNamespaceSecretValue=$serviceBusNamespace

echo "Checking if [$serviceBusNamespaceSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $serviceBusNamespaceSecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$serviceBusNamespaceSecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$serviceBusNamespaceSecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $serviceBusNamespaceSecretName \
    --vault-name $keyVaultName \
    --value $serviceBusNamespaceSecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$serviceBusNamespaceSecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$serviceBusNamespaceSecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$serviceBusNamespaceSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
serviceBusUseAzureCredentialSecretName="NotificationService--ServiceBus--UseAzureCredential"
serviceBusUseAzureCredentialSecretValue=$serviceBusUseAzureCredential

echo "Checking if [$serviceBusUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $serviceBusUseAzureCredentialSecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$serviceBusUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$serviceBusUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $serviceBusUseAzureCredentialSecretName \
    --vault-name $keyVaultName \
    --value $serviceBusUseAzureCredentialSecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$serviceBusUseAzureCredentialSecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$serviceBusUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$serviceBusUseAzureCredentialSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
serviceBusQueueNameSecretName="NotificationService--ServiceBus--QueueName"
serviceBusQueueNameSecretValue=$serviceBusQueueName

echo "Checking if [$serviceBusQueueNameSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $serviceBusQueueNameSecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$serviceBusQueueNameSecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$serviceBusQueueNameSecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $serviceBusQueueNameSecretName \
    --vault-name $keyVaultName \
    --value $serviceBusQueueNameSecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$serviceBusQueueNameSecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$serviceBusQueueNameSecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$serviceBusQueueNameSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Get the Application Insights instrumentation key
applicationInsightsInstrumentationKey=$(az resource show \
  --resource-group $resourceGroupName \
  --name $applicationInsightsName \
  --resource-type "microsoft.insights/components" \
  --query properties.InstrumentationKey \
  --output tsv)

# Check if the secret already exists
applicationInsightsInstrumentationKeySecretName="ApplicationInsights--InstrumentationKey"
applicationInsightsInstrumentationKeySecretValue=$applicationInsightsInstrumentationKey

echo "Checking if [$applicationInsightsInstrumentationKeySecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $applicationInsightsInstrumentationKeySecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 && -n $applicationInsightsInstrumentationKey ]]; then
  echo "No [$applicationInsightsInstrumentationKeySecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$applicationInsightsInstrumentationKeySecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $applicationInsightsInstrumentationKeySecretName \
    --vault-name $keyVaultName \
    --value $applicationInsightsInstrumentationKeySecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$applicationInsightsInstrumentationKeySecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$applicationInsightsInstrumentationKeySecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$applicationInsightsInstrumentationKeySecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Get Storage Account connection string
dataProtectionBlobStorageConnectionString=$(az storage account show-connection-string \
  --name $storageAccountName \
  --resource-group $resourceGroupName \
  --output tsv)

# Check if the secret already exists
dataProtectionBlobStorageConnectionStringSecretName="DataProtection--BlobStorage--ConnectionString"
dataProtectionBlobStorageConnectionStringSecretValue=$dataProtectionBlobStorageConnectionString

echo "Checking if [$dataProtectionBlobStorageConnectionStringSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $dataProtectionBlobStorageConnectionStringSecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 && -n $dataProtectionBlobStorageConnectionString ]]; then
  echo "No [$dataProtectionBlobStorageConnectionStringSecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$dataProtectionBlobStorageConnectionStringSecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $dataProtectionBlobStorageConnectionStringSecretName \
    --vault-name $keyVaultName \
    --value $dataProtectionBlobStorageConnectionStringSecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$dataProtectionBlobStorageConnectionStringSecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$dataProtectionBlobStorageConnectionStringSecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$dataProtectionBlobStorageConnectionStringSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
storageAccountNameSecretName="DataProtection--BlobStorage--AccountName"
storageAccountNameSecretValue=$storageAccountName

echo "Checking if [$storageAccountNameSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $storageAccountNameSecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$storageAccountNameSecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$storageAccountNameSecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $storageAccountNameSecretName \
    --vault-name $keyVaultName \
    --value $storageAccountNameSecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$storageAccountNameSecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$storageAccountNameSecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$storageAccountNameSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
storageUseAzureCredentialSecretName="DataProtection--BlobStorage--UseAzureCredential"
storageUseAzureCredentialSecretValue=$storageUseAzureCredential

echo "Checking if [$storageUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $storageUseAzureCredentialSecretName --vault-name $keyVaultName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$storageUseAzureCredentialSecretName] secret actually exists in the [$keyVaultName] key vault"
  echo "Creating [$storageUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault..."

  # create the secret
  az keyvault secret set \
    --name $storageUseAzureCredentialSecretName \
    --vault-name $keyVaultName \
    --value $storageUseAzureCredentialSecretValue 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$storageUseAzureCredentialSecretName] secret successfully created in the [$keyVaultName] key vault"
  else
    echo "Failed to create [$storageUseAzureCredentialSecretName] secret in the [$keyVaultName] key vault"
    exit
  fi
else
  echo "[$storageUseAzureCredentialSecretName] secret already exists in the [$keyVaultName] key vault"
fi

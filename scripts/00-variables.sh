#!/bin/bash

# Container Images
frontendContainerImageTag="v2"
backendContainerImageTag="v2"

# Azure Resources
location="<azure-region>"
resourceGroupName="<azure-resource-group-name>"

# Azure Managed Identity
managedIdentityName="<azure-user-assigned-managed-identity-name>"

# Kubernetes Service account
workloadNamespace="todo"
workloadServiceAccountName="todo-sa"

# Variables for the federated identity name
federatedIdentityName="TodoWorkloadFederatedIdentity"

# Azure Container Registry
acrName="<azure-container-registry-name>"

# Azure Kubernetes Service
aksClusterName="<azure-kubernetes-service-name>"

# Azure Key Vault 
keyVaultName="<azure-key-vault-name>"
keyVaultSku="Standard"

# Azure Cosmos DB
cosmosDbAccountName="<azure-cosmos-db-account-name>"
cosmosDbUseAzureCredential="true"
cosmosDbDatabaseName="TodoApiDb"
cosmosDbCollectionName="TodoApiCollection"

# Azure Service Bus
serviceBusNamespace="<azure-service-bus-namespace-name>"
serviceBusUseAzureCredential="true"
serviceBusQueueName="todoapi"

# Azure Application Insights
applicationInsightsName="<azure-application-insights-name>"

# Azure Storage Account
storageAccountName="<azure-storage-account-name>"
storageUseAzureCredential="true"

# Azure Subscription and Tenant
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)
tenantId=$(az account show --query tenantId --output tsv)

# NGINX
nginxNamespace="ingress-basic"
nginxRepoName="ingress-nginx"
nginxRepoUrl="https://kubernetes.github.io/ingress-nginx"
nginxChartName="ingress-nginx"
nginxReleaseName="nginx-ingress"
nginxReplicaCount=2

# Azure DNS
dnsZoneName="<azure-dns-zone-name>"
dnsZoneResourceGroupName="<azure-dns-zone-resource-group-name>"
frontendSubdomain="<frontend-dns-subdomain>"
backendSubdomain="<backend-dns-subdomain>"

# Certificate Manager
certManagerNamespace="cert-manager"
certManagerRepoName="jetstack"
certManagerRepoUrl="https://charts.jetstack.io"
certManagerChartName="cert-manager"
certManagerReleaseName="cert-manager"
email="paolos@microsoft.com"
clusterIssuer="letsencrypt-nginx"
template="cluster-issuer.yml"

# Default Backend
defaultBackendTemplate="default-backend.yml"

# Workload
workloadRelease="todo"
workloadChart="../chart"

frontendContainerImageName="${acrName,,}.azurecr.io/todoweb"
frontendHostName="${frontendSubdomain,,}.${dnsZoneName,,}"
frontendReplicaCount=3

backendContainerImageName="${acrName,,}.azurecr.io/todoapi"
backendHostName="${backendSubdomain,,}.${dnsZoneName,,}"
backendReplicaCount=3

workloadDeploymentTemplate="todolist-deployments.yml"
workloadServiceTemplate="todolist-services.yml"
workloadHpaTemplate="todolist-hpas.yml"

configMapName="todolist-configmap"
configMapTemplate="config-map.yml"

aspNetCoreEnvironment="Docker"
todoApiServiceEndpointUri="todolist-api"
todoWebDataProtectionBlobStorageContainerName="todoweb"
todoApiDataProtectionBlobStorageContainerName="todoapi"

frontendIngressName="ingress-frontend"
frontendIngressTemplate="ingress-frontend.yml"
frontendSecretName="tls-frontend"
frontendServiceName="todolist-web"
frontendPort="80"

backendIngressName="ingress-backend"
backendIngressTemplate="ingress-backend.yml"
backendSecretName="tls-backend"
backendServiceName="todolist-api"
backendPort="80"
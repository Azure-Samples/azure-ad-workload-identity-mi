#!/bin/bash

# For more information, see https://azure.github.io/azure-workload-identity/docs/quick-start.html

# Variables
source ./00-variables.sh

# Install todolist application
cat $workloadDeploymentTemplate |
    yq "(.spec.template.spec.serviceAccountName)|="\""$workloadServiceAccountName"\"
exit

# Create the namespace if it doesn't already exists in the cluster
result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='$workloadNamespace')].metadata.name}")

if [[ -n $result ]]; then
  echo "[$workloadNamespace] namespace already exists in the cluster"
else
  echo "[$workloadNamespace] namespace does not exist in the cluster"
  echo "creating [$workloadNamespace] namespace in the cluster..."
  kubectl create namespace $workloadNamespace
fi

# Check if the configMap already exists
result=$(kubectl get configmap -n $workloadNamespace -o json | jq -r '.items[].metadata.name | select(. == "'$configMapName'")')

if [[ -n $result ]]; then
  echo "[$configMapName] ingress already exists"
  exit
else
  # Create the configMap
  echo "[$configMapName] ingress does not exist"
  echo "Creating [$configMapName] ingress..."
  cat $configMapTemplate |
    yq "(.metadata.name)|="\""$configMapName"\" |
    yq "(.data.aspNetCoreEnvironment)|="\""$aspNetCoreEnvironment"\" |
    yq "(.data.todoApiServiceEndpointUri)|="\""$todoApiServiceEndpointUri"\" |
    yq "(.data.todoWebDataProtectionBlobStorageContainerName)|="\""$todoWebDataProtectionBlobStorageContainerName"\" |
    yq "(.data.todoApiDataProtectionBlobStorageContainerName)|="\""$todoApiDataProtectionBlobStorageContainerName"\" |
    yq "(.data.keyVaultName)|="\""$keyVaultName"\" |
    kubectl apply -n $workloadNamespace -f -
fi

# Create todolist deployments
kubectl apply -f $workloadDeploymentTemplate -n $workloadNamespace

# Create todolist services
kubectl apply -f $workloadServiceTemplate -n $workloadNamespace

# Create todolist horizonal pod autoscalers
kubectl apply -f $workloadHpaTemplate -n $workloadNamespace

# Check if the frontend ingress already exists
result=$(kubectl get ingress -n $workloadNamespace -o json | jq -r '.items[].metadata.name | select(. == "'$frontendIngressName'")')

if [[ -n $result ]]; then
  echo "[$frontendIngressName] ingress already exists"
  exit
else
  # Create the frontend ingress
  echo "[$frontendIngressName] ingress does not exist"
  echo "Creating [$frontendIngressName] ingress..."
  cat $frontendIngressTemplate |
    yq "(.metadata.name)|="\""$frontendIngressName"\" |
    yq "(.spec.tls[0].hosts[0])|="\""$frontendHostName"\" |
    yq "(.spec.tls[0].secretName)|="\""$frontendSecretName"\" |
    yq "(.spec.rules[0].host)|="\""$frontendHostName"\" |
    yq "(.spec.rules[0].http.paths[0].backend.service.name)|="\""$frontendServiceName"\" |
    yq "(.spec.rules[0].http.paths[0].backend.service.port.number)|=$frontendPort" |
    kubectl apply -n $workloadNamespace -f -
fi

# Check if the backend ingress already exists
result=$(kubectl get ingress -n $workloadNamespace -o json | jq -r '.items[].metadata.name | select(. == "'$backendIngressName'")')

if [[ -n $result ]]; then
  echo "[$backendIngressName] ingress already exists"
  exit
else
  # Create the backend ingress
  echo "[$backendIngressName] ingress does not exist"
  echo "Creating [$backendIngressName] ingress..."
  cat $backendIngressTemplate |
    yq "(.metadata.name)|="\""$backendIngressName"\" |
    yq "(.spec.tls[0].hosts[0])|="\""$backendHostName"\" |
    yq "(.spec.tls[0].secretName)|="\""$backendSecretName"\" |
    yq "(.spec.rules[0].host)|="\""$backendHostName"\" |
    yq "(.spec.rules[0].http.paths[0].backend.service.name)|="\""$backendServiceName"\" |
    yq "(.spec.rules[0].http.paths[0].backend.service.port.number)|=$backendPort" |
    kubectl apply -n $workloadNamespace -f -
fi

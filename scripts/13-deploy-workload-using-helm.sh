#!/bin/bash

# Variables
source ./00-variables.sh

# Check if the Helm release already exists
echo "Checking if a [$workloadRelease] Helm release exists in the [$workloadNamespace] namespace..."
name=$(helm list -n $workloadNamespace | awk '{print $1}' | grep -Fx $workloadRelease)

if [[ -n $name ]]; then
  # Install the Helm chart for the tenant to a dedicated namespace
  echo "A [$workloadRelease] Helm release already exists in the [$workloadNamespace] namespace"
  echo "Upgrading the [$workloadRelease] Helm release to the [$workloadNamespace] namespace via Helm..."
  helm upgrade $workloadRelease $workloadChart \
    --set serviceAccount.name=$workloadServiceAccountName \
    --set frontendDeployment.image.repository=$frontendContainerImageName \
    --set frontendDeployment.image.tag=$frontendContainerImageTag \
    --set frontendDeployment.replicaCount=$frontendReplicaCount \
    --set backendDeployment.image.repository=$backendContainerImageName \
    --set backendDeployment.image.tag=$backendContainerImageTag \
    --set backendDeployment.replicaCount=$backendReplicaCount \
    --set nameOverride=$workloadNamespace \
    --set frontendIngress.hosts[0].host=$frontendHostName \
    --set frontendIngress.tls[0].hosts[0]=$frontendHostName \
    --set backendIngress.hosts[0].host=$backendHostName \
    --set backendIngress.tls[0].hosts[0]=$backendHostName \
    --set configMap.keyVaultName=$keyVaultName

  if [[ $? == 0 ]]; then
    echo "[$workloadRelease] Helm release successfully upgraded to the [$workloadNamespace] namespace via Helm"
  else
    echo "Failed to upgrade [$workloadRelease] Helm release to the [$workloadNamespace] namespace via Helm"
    exit
  fi
else
  # Install the Helm chart for the tenant to a dedicated namespace
  echo "The [$workloadRelease] Helm release does not exist in the [$workloadNamespace] namespace"
  echo "Deploying the [$workloadRelease] Helm release to the [$workloadNamespace] namespace via Helm..."
  helm install $workloadRelease $workloadChart \
    --create-namespace \
    --namespace $workloadNamespace \
    --set serviceAccount.name=$workloadServiceAccountName \
    --set frontendDeployment.image.repository=$frontendContainerImageName \
    --set frontendDeployment.image.tag=$frontendContainerImageTag \
    --set backendDeployment.image.repository=$backendContainerImageName \
    --set backendDeployment.image.tag=$backendContainerImageTag \
    --set nameOverride=$workloadNamespace \
    --set frontendIngress.hosts[0].host=$frontendHostName \
    --set frontendIngress.tls[0].hosts[0]=$frontendHostName \
    --set backendIngress.hosts[0].host=$backendHostName \
    --set backendIngress.tls[0].hosts[0]=$backendHostName \
    --set configMap.keyVaultName=$keyVaultName

  if [[ $? == 0 ]]; then
    echo "[$workloadRelease] Helm release successfully deployed to the [$workloadNamespace] namespace via Helm"
  else
    echo "Failed to install [$workloadRelease] Helm release to the [$workloadNamespace] namespace via Helm"
    exit
  fi
fi

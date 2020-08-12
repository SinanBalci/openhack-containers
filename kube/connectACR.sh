#!/bin/bash

# Modify for your environment. The ACR_NAME is the name of your Azure Container
# Registry, and the SERVICE_PRINCIPAL_ID is the service principal's 'appId' or
# one of its 'servicePrincipalNames' values.
ACR_NAME="registrysdk5863"
AKS_CLUSTER="myAKSCluster"
RESOURCE_GROUP="teamResources"

# get the principal id
SERVICE_PRINCIPAL_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --query "servicePrincipalProfile.clientId" --output tsv)

# Populate value required for subsequent command args
ACR_REGISTRY_ID=$(az acr show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query id --output tsv)

# Assign the desired role to the service principal. Modify the '--role' argument
# value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
az role assignment create --assignee $SERVICE_PRINCIPAL_ID --scope $ACR_REGISTRY_ID --role acrpull
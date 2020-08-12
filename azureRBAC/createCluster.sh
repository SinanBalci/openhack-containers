#!/bin/bash
aksname="MyAKSCluster3"
resourcegroup="teamResources"
SUBNET_ID="/subscriptions/89eb5de7-be0a-4488-8b3a-a78358b2d3bb/resourceGroups/teamResources/providers/Microsoft.Network/virtualNetworks/vnet/subnets/vm-subnet"

echo "Create Server Application"
# Create the Azure AD application
serverApplicationId=$(az ad app create \
    --display-name "${aksname}Server" \
    --identifier-uris "https://${aksname}Server" \
    --query appId -o tsv)

# Update the application group membership claims
az ad app update --id $serverApplicationId --set groupMembershipClaims=All

# Create a service principal for the Azure AD application
az ad sp create --id $serverApplicationId

# Get the service principal secret
serverApplicationSecret=$(az ad sp credential reset \
    --name $serverApplicationId \
    --credential-description "AKSPassword" \
    --query password -o tsv)


az ad app permission add \
    --id $serverApplicationId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope 06da0dbc-49e2-44d2-8312-53f166ab848a=Scope 7ab1d382-f21e-4acd-a863-ba3e13f7da61=Role

az ad app permission grant --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000
az ad app permission admin-consent --id  $serverApplicationId

echo "Create Client Application"

clientApplicationId=$(az ad app create \
    --display-name "${aksname}Client" \
    --native-app \
    --reply-urls "https://${aksname}Client" \
    --query appId -o tsv)

az ad sp create --id $clientApplicationId
oAuthPermissionId=$(az ad app show --id $serverApplicationId --query "oauth2Permissions[0].id" -o tsv)

az ad app permission add --id $clientApplicationId --api $serverApplicationId --api-permissions ${oAuthPermissionId}=Scope
az ad app permission grant --id $clientApplicationId --api $serverApplicationId



## az ad sp create-for-rbac --skip-assignment --name myAKSClusterServicePrincipal
echo "Creating SP"
SP="$(az ad sp create-for-rbac --skip-assignment -o json)"
sp_app_id="$(echo $SP | jq '.appId' | tr -d '"')" ##"a2ce3f87-05ab-4ad7-8038-6f724e567324"
sp_password="$(echo $SP | jq '.password' | tr -d '"')" ##"54q5wSupheplhUl~c6LnqRP0tFki30N5ZV"

echo "$SP"

echo "Sleep 20"
sleep 20

echo "role assignment"
az role assignment create --assignee $sp_app_id --scope $SUBNET_ID --role Contributor


tenantId=$(az account show --query tenantId -o tsv)

#serverApplicationId="c54d19ee-a819-445d-bc5d-9e7507ef2537"
#serverApplicationSecret="p1r6H9ttq6H_eVGjzioP7BcuHGPgsaBP3_"
#clientApplicationId="6e31b5d6-8e2f-490b-9248-7d208e15e9e1"

echo "Create Cluster"

az aks create \
    --resource-group $resourcegroup \
    --name $aksname \
    --node-count 3 \
    --generate-ssh-keys \
    --aad-server-app-id $serverApplicationId \
    --aad-server-app-secret $serverApplicationSecret \
    --aad-client-app-id $clientApplicationId \
    --aad-tenant-id $tenantId \
    --vnet-subnet-id $SUBNET_ID \
    --docker-bridge-address 172.17.0.1/16 \
    --service-cidr 172.38.0.0/16 \
    --dns-service-ip 172.38.0.10 \
    --network-plugin azure \
    --service-principal $sp_app_id \
    --client-secret $sp_password


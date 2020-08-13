#!/bin/bash
# Set environment variables
SPNAME=azure-cli-2020-08-12-13-45-15
AZURE_CLIENT_ID=$(az ad sp show --id http://${SPNAME} --query appId -o tsv)
KEYVAULT_NAME=MyKeyVaultInsights
KEYVAULT_RESOURCE_GROUP=teamResources
SUBID=89eb5de7-be0a-4488-8b3a-a78358b2d3bb

# Assign Reader Role to the service principal for your keyvault
az role assignment create --role Reader --assignee $AZURE_CLIENT_ID --scope /subscriptions/$SUBID/resourcegroups/$KEYVAULT_RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEYVAULT_NAME

az keyvault set-policy -n $KEYVAULT_NAME --key-permissions get --spn $AZURE_CLIENT_ID
az keyvault set-policy -n $KEYVAULT_NAME --secret-permissions get --spn $AZURE_CLIENT_ID
az keyvault set-policy -n $KEYVAULT_NAME --certificate-permissions get --spn $AZURE_CLIENT_ID
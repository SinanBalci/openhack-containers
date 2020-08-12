## Get credentials for Kubernetes
az aks get-credentials --resource-group teamResources --name myAKSCluster

## Connect to Kubernetes to ACR
az aks update -n myAKSCluster -g teamResources --attach-acr registrysdk5863

## Get nodes
kubectl get nodes

## Open WebConsole
az aks browse --resource-group teamResources --name myAKSCluster

## Get description of a pod
kubectl describe pod

## delete pod/service
kubectl delete -f poi.yaml
kubectl delete -l app=poi

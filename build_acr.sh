#!/bin/bash
ACR_NAME="registrysdk5863"

az acr build --image tripinsights/poi:1.0 --registry registrysdk5863 --file "dockerfiles/Dockerfile_POI" "src/poi/"
az acr build --image tripinsights/userprofile:1.0 --registry registrysdk5863 --file "dockerfiles/Dockerfile_UserProfile" "src/userprofile/"
az acr build --image tripinsights/trips:1.0 --registry registrysdk5863 --file "dockerfiles/Dockerfile_Trips" "src/trips"
az acr build --image tripinsights/tripviewer:1.0 --registry registrysdk5863 --file "dockerfiles/Dockerfile_TripViewer" "src/tripviewer/"
az acr build --image tripinsights/user-java:1.0 --registry registrysdk5863 --file "dockerfiles/Dockerfile_Java" "src/user-java/"
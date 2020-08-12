#!/bin/bash
docker build -t "tripinsights/user-java:1.0" -f dockerfiles/Dockerfile_Java src/user-java/
docker build -t "tripinsights/tripviewer:1.0"-f dockerfiles/Dockerfile_TripViewer src/tripviewer/
docker build -t "tripinsights/trips:1.0" -f dockerfiles/Dockerfile_Trips src/trips
docker build -t "tripinsights/poi:1.0" -f dockerfiles/Dockerfile_POI src/poi/
docker build -t "tripinsights/userprofile:1.0" -f dockerfiles/Dockerfile_UserProfile src/userprofile/

#docker run -d -p 8080:80
#docker run tripinsights/user-java:1.0

## Create network
docker network create mydrivingnetwork 
## Create SQL Server (Doc: https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-2017&pivots=cs1-bash)
docker run --network mydrivingnetwork -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=P@assword123" -p 1433:1433 --name sql1 -d mcr.microsoft.com/mssql/server:2017-latest
#docker exec -it sql1 /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P '<YourStrong@Passw0rd>' -Q 'ALTER LOGIN SA WITH PASSWORD=P@assword123'
docker exec sql1 /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "P@assword123" -Q "CREATE DATABASE mydrivingDB"

docker run --network mydrivingnetwork  -e "SQLFQDN=sql1" -e "SQLUSER=sa" -e "SQLPASS=P@assword123" -e "SQLDB=mydrivingDB" --name data-load openhack/data-load:v1

## Run POI
docker run --network mydrivingnetwork -d -p 8080:80 --name poi -e "SQL_USER=sa" -e "SQL_PASSWORD=P@assword123" -e "SQL_SERVER=sql1" -e "ASPNETCORE_ENVIRONMENT=Local" tripinsights/poi:1.0

## Run trips
docker run --network mydrivingnetwork  -d -p 8081:80 --name trips  -e "SQL_USER=sa" -e "SQL_PASSWORD=P@assword123" -e "SQL_SERVER=sql1" -e "OPENAPI_DOCS_URI=http://temp" tripinsights/trips:1.0

## Run User-Java
docker run --network mydrivingnetwork  -d -p 8090:80 --name user-java -e "SQL_USER=sa" -e "SQL_PASSWORD=P@assword123" -e "SQL_SERVER=sql1" tripinsights/user-java:1.0

## Run UserProfile
docker run --network mydrivingnetwork  -d -p 8091:80 --name userprofile -e "SQL_USER=sa" -e "SQL_PASSWORD=P@assword123" -e "SQL_SERVER=sql1" tripinsights/userprofile:1.0

## Run tripviewer
docker run --network mydrivingnetwork  -d -p 8082:80 --name tripviewer -e "USERPROFILE_API_ENDPOINT=http://temp" -e "TRIPS_API_ENDPOINT=http://temp" tripinsights/tripviewer:1.0

## curl -i -X GET 'http://localhost:8080/api/poi'
## curl -i -X GET 'http://localhost:8080/api/poi/healthcheck'

#docker exec -it sql1 "bash"
#/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "P@assword123"
#CREATE DATABASE mydrivingDB

#docker run -e SQLFQDN=localhost -e SQLUSER=admin -e SQLPASS=P@assword123 -e SQLDB=mydrivingDB openhack/data-load:v1

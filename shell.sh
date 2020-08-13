#!/bin/bash
network_name="network"
docker network create $network_name

docker run -d \
    --network $network_name \
    -e 'ACCEPT_EULA=Y' \
    -e 'SA_PASSWORD=localtestpw123@' \
    --name 'sqltestdb' \
    -p 1433:1433 \
    mcr.microsoft.com/mssql/server:2017-latest

sleep 20
docker ps
docker logs sqltestdb

docker exec sqltestdb /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U SA -P 'localtestpw123@' \
    -Q "CREATE DATABASE mydrivingDB"

docker run -d \
    --network $network_name \
    --name dataload \x
    -e "SQLFQDN=sqltestdb" \
    -e "SQLUSER=sa" \
    -e "SQLPASS=localtestpw123@" \
    -e "SQLDB=mydrivingDB" \
    openhack/data-load:v1

# give some time for data to load
sleep 20
docker logs dataload

docker run -d \
    --network $network_name \
    -p 8080:80 \
    --name poi \
    -e "SQL_PASSWORD=localtestpw123@" \
    -e "SQL_SERVER=sqltestdb" \
    -e "SQL_USER=sa" \
    -e "ASPNETCORE_ENVIRONMENT=Local" \
    tripinsights/poi:1.0

docker run -d \
    --network $network_name \
    -p 8081:80 \
    --name trips \
    -e "SQL_PASSWORD=localtestpw123@" \
    -e "SQL_SERVER=sqltestdb" \
    -e "SQL_USER=sa" \
    -e "OPENAPI_DOCS_URI=http://temp" \
    tripinsights/trips:1.0

docker run -d \
    --network $network_name \
    -p 8082:80 \
    --name user-java \
    -e "SQL_PASSWORD=localtestpw123@" \
    -e "SQL_SERVER=sqltestdb" \
    -e "SQL_USER=sa" \
    tripinsights/user-java:1.0 

docker run -d \
    --network $network_name \
    -p 8083:80 \
    --name userprofile \
    -e "SQL_PASSWORD=localtestpw123@" \
    -e "SQL_SERVER=sqltestdb" \
    -e "SQL_USER=sa" \
    tripinsights/userprofile:1.0

docker ps

printf "call poi\n"
curl -X GET 'http://localhost:8080/api/poi'

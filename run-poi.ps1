# Shared environment variables
$env:SQL_USERNAME = "sa"
$env:SQL_PASSWORD = "Sydo2020"
$env:SQL_SERVERNAME = "localhost"
$env:SQL_PORT = 1433
$env:SQL_CONTAINER_NAME = "sql1"

$env:DOCKER_NETWORK_NAME = "host"
$env:ASPNET_ENV = "Local"

# Build the poi container
# docker build `
#     --no-cache `
#     --build-arg IMAGE_VERSION="1.0" `
#     --build-arg IMAGE_CREATE_DATE="$(Get-Date((Get-Date).ToUniversalTime()) -UFormat '%Y-%m-%dT%H:%M:%SZ')" `
#     --build-arg IMAGE_SOURCE_REVISION="$(git rev-parse HEAD)" `
#     -f ./dockerfiles/poi.Dockerfile `
#     -t "tripinsights/poi:1.0" `
#     ./src/poi

# Run sql server
# docker run `
#     -e "ACCEPT_EULA=Y" `
#     -e "SA_PASSWORD=$env:SQL_PASSWORD" `
#     -p "$env:SQL_PORT`:1433" `
#     --name $env:SQL_CONTAINER_NAME `
#     -d mcr.microsoft.com/mssql/server:2019-latest

# Create the database
# $env:SQL_CONTAINER_ID = $(docker ps -f "name=$env:SQL_CONTAINER_NAME" -q)
# docker exec $env:SQL_CONTAINER_ID `
#     sh -c '/opt/mssql-tools/bin/sqlcmd -S "localhost,1433" -U sa -P $SA_PASSWORD -Q ""create database mydrivingDB""'

# # Load data
# docker run `
#     --network $env:DOCKER_NETWORK_NAME `
#     -e "SQLFQDN=$env:SQL_SERVERNAME" `
#     -e "SQLUSER=$env:SQL_USERNAME" `
#     -e "SQLPASS=$env:SQL_PASSWORD" `
#     -e "SQLDB=mydrivingDB" `
#     openhack/data-load:v1

# Kill running poi
docker rm -f $(docker ps -q -f name=poi)

# Example 1 - Set config values via environment variables
docker run -d `
    -p 8080:80 `
    --name poi `
    --link $env:SQL_CONTAINER_NAME `
    -e "SQL_USER=$env:SQL_USERNAME" `
    -e "SQL_PASSWORD=$env:SQL_PASSWORD" `
    -e "ASPNETCORE_ENVIRONMENT=$env:ASPNET_ENV" `
    -e "SQL_SERVER=$env:SQL_CONTAINER_NAME" `
    tripinsights/poi:1.0

Start-Sleep -s 2

write-host "Hitting health check"
curl -i -X GET 'http://localhost:8080/api/poi/healthcheck'

write-host "Hit db"
curl -i -X GET 'http://localhost:8080/api/poi' 

# Example 2 - Set configuration via files. Server will expect config values in files like /secrets/SQL_USER.
# The secrets must be mounted from a host volume (eg. $HOST_FOLDER) into the /secrets container volume.
# docker run -d `
#     -p 8080:80 `
#     --name poi `
#     -v $env:HOST_FOLDER:/secrets `
#     -e "ASPNETCORE_ENVIRONMENT=$env:ASPNET_ENV" `
#     tripinsights/poi:1.0

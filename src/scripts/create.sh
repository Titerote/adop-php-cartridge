#!/bin/bash

set +x
function createDockerContainer() {
    #echo $1, $2
    export ENVIRONMENT_NAME=$1
    export SERVICE_NAME="$(echo ${PROJECT_NAME} | tr '/' '_')_${ENVIRONMENT_NAME}"
    docker-compose -p ${SERVICE_NAME} up -d
    if [ -f index.php ]; then docker cp index.php ${SERVICE_NAME}:/var/www/html/index.php; fi;
    if [ -f info.php ]; then docker cp info.php ${SERVICE_NAME}:/var/www/html/info.php; fi;
    ## Add nginx configuration
    if [ -f $SERVICE_NAME.conf ]; then
      CFG=$SERVICE_NAME.conf
    elif [ -f "$2" ]; then
      CFG=$2
    else
      CFG=proxy.conf
    fi;
    sed -i "s/###PROXY_SERVICE_NAME###/${SERVICE_NAME}/" $CFG
    docker cp $CFG proxy:/etc/nginx/sites-enabled/${SERVICE_NAME}.conf
#    docker restart proxy
}

if [ "$ENVIRONMENT_TYPE" == "DEV" ]; then
    createDockerContainer "CI" tomcat.conf
elif [ "$ENVIRONMENT_TYPE" == "PROD" ]; then
	##Creating 2 environment PRODA and PRODB, with a upstream ngix configuration in prod-tomcat.conf
    mv tomcat.conf tomcatA.conf &&cp tomcatA.conf tomcatB.conf
    createDockerContainer "PRODA" "tomcatA.conf"
    createDockerContainer "PRODB" "tomcatB.conf"

    SERVICE_NAME_PRODA="$(echo ${PROJECT_NAME} | tr '/' '_')_PRODA"
    SERVICE_NAME_PRODB="$(echo ${PROJECT_NAME} | tr '/' '_')_PRODB"
    TOMCAT_1_IP=$( docker inspect --format '{{ .NetworkSettings.Networks.'"$DOCKER_NETWORK_NAME"'.IPAddress }}' ${SERVICE_NAME_PRODA} )
    TOMCAT_2_IP=$( docker inspect --format '{{ .NetworkSettings.Networks.'"$DOCKER_NETWORK_NAME"'.IPAddress }}' ${SERVICE_NAME_PRODB} )
    PROJECT_KEY_PROD="$(echo ${PROJECT_NAME} | tr '/' '_')_PROD"
    TOKEN_UPSTREAM_NAME="###TOKEN_UPSTREAM_NAME###"
    TOKEN_NAMESPACE="###TOKEN_NAMESPACE###"
    TOKEN_TOMCAT_1_IP="###TOKEN_TOMCAT_1_IP###"
    TOKEN_TOMCAT_1_PORT="###TOKEN_TOMCAT_1_PORT###"
    TOKEN_TOMCAT_2_IP="###TOKEN_TOMCAT_2_IP###"
    TOKEN_TOMCAT_2_PORT="###TOKEN_TOMCAT_2_PORT###"

    sed -i "s/${TOKEN_UPSTREAM_NAME}/${PROJECT_KEY_PROD}/g" prod-tomcat.conf
    sed -i "s/${TOKEN_NAMESPACE}/${PROJECT_KEY_PROD}/g" prod-tomcat.conf
    sed -i "s/${TOKEN_TOMCAT_1_IP}/${TOMCAT_1_IP}/g" prod-tomcat.conf
    sed -i "s/${TOKEN_TOMCAT_1_PORT}/8080/g" prod-tomcat.conf
    sed -i "s/${TOKEN_TOMCAT_2_IP}/${TOMCAT_2_IP}/g" prod-tomcat.conf
    sed -i "s/${TOKEN_TOMCAT_2_PORT}/8080/g" prod-tomcat.conf
    docker cp prod-tomcat.conf proxy:/etc/nginx/sites-enabled/${PROJECT_KEY_PROD}.conf
fi
## Reload nginx Tite
docker exec proxy /usr/sbin/nginx -s reload
set -x

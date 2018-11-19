#!/bin/bash

set +x 

function deleteDockerContainer() {
	echo $1, $2
	export ENVIRONMENT_NAME=$1
	export SERVICE_NAME="$(echo ${PROJECT_NAME} | tr '/' '_')_${ENVIRONMENT_NAME}"
	echo docker-compose -p ${SERVICE_NAME} stop
	docker-compose -p ${SERVICE_NAME} stop
	echo docker-compose -p ${SERVICE_NAME} rm -f
	docker-compose -p ${SERVICE_NAME} rm -f
	## Deleted nginx configuration
	docker exec proxy rm -f /etc/nginx/sites-enabled/${SERVICE_NAME}.conf
}

if [ "$ENVIRONMENT_TYPE" == "DEV" ]; then

	#echo deleteDockerContainer "CI" roofservicenow.conf
	deleteDockerContainer "CI" roofservicenow.conf
elif [ "$ENVIRONMENT_TYPE" == "PROD" ]; then
	mv tomcat.conf tomcatA.conf &&cp tomcatA.conf tomcatB.conf
	deleteDockerContainer "PRODA" "tomcatA.conf"
	deleteDockerContainer "PRODB" "tomcatB.conf"
	PROJECT_KEY_PROD="$(echo ${PROJECT_NAME} | tr '/' '_')_PROD"
	docker exec proxy rm -f /etc/nginx/sites-enabled/${PROJECT_KEY_PROD}.conf
fi

docker exec proxy /usr/sbin/nginx -s reload

set -x 

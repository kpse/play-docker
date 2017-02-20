#!/bin/bash

REPO_NAME=louis-play
ACCOUNT_URL=226019795248.dkr.ecr.ap-southeast-2.amazonaws.com
SERVICE_NAME=louis-play
TASK_FAMILY=louis-play
CLUSTER_NAME=default

function deploy {
    version=${1:-latest}
    echo deploy to ECS with version: $version
    CLUSTER_NAME=$CLUSTER_NAME BUILD_NUMBER=$version SERVICE_NAME=$SERVICE_NAME TASK_FAMILY=$TASK_FAMILY ./update-service.sh
}

function local_dev {
    bin/activator run
}

function build_push {
    version=${1:-latest}
    echo build and push image to ECS with version: $version
    echo version = $version
    sbt docker:publishLocal \
    && docker tag play-docker:1.0-SNAPSHOT $ACCOUNT_URL/$REPO_NAME:$version \
    && docker tag play-docker:1.0-SNAPSHOT $ACCOUNT_URL/$REPO_NAME:latest \
    && docker push $ACCOUNT_URL/$REPO_NAME:$version \
    && docker push $ACCOUNT_URL/$REPO_NAME:latest
}

function unittest {
    echo params : $@
    bin/activator test
}
function test_script {
    version=${1:-latest}
    echo build and push image to ECS with version: $version
    echo version = $version
}

function help_message {
    echo l for local_dev
    echo pm for build and push image to ECS
    echo d for deploy new image to ECS
    echo a for both pm and d
}

function main {
  	case $1 in
		l) local_dev "${@:2}";;
		p) git pull --rebase && unittest "${@:2}" && git push origin master ;;
		pm) unittest "${@:2}" && build_push "${@:2}" ;;
		d) deploy "${@:2}";;
		a) unittest "${@:2}" && build_push "${@:2}" && deploy "${@:2}";;
		ts) test_script "${@:2}" ;;
		t) unittest "${@:2}" ;;
		*) help_message ;;
	esac
}

main $@

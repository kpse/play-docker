#!/bin/bash
IMAGE_VERSION="v_"${BUILD_NUMBER}

# Create a new task definition for this build
sed -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" deployment/${SERVICE_NAME}.json > ${SERVICE_NAME}-v_${BUILD_NUMBER}.json
aws ecs register-task-definition --family ${TASK_FAMILY} --cli-input-json file://${SERVICE_NAME}-v_${BUILD_NUMBER}.json

# Update the service with the new task definition and desired count
TASK_REVISION=`aws ecs describe-task-definition --task-definition ${TASK_FAMILY} | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//'`
DESIRED_COUNT=`aws ecs describe-services --cluster $CLUSTER_NAME --service ${SERVICE_NAME} | egrep "desiredCount" | head -1 | tr "/" " " | awk '{print $2}' | sed 's/,$//'`
#if [ ${DESIRED_COUNT} = "0" ]; then
    DESIRED_COUNT="2"
#fi
echo --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count ${DESIRED_COUNT}
aws ecs update-service --cluster $CLUSTER_NAME --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count ${DESIRED_COUNT}
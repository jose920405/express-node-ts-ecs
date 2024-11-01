#!/bin/bash

ENV='dev'
PREFIX='spreso-main-jose'
CLUSTER_NAME=$PREFIX-cluster-$ENV
SERVICE_NAME=$PREFIX-sign-service-$ENV
TASK_DEFINITION_NAME=$PREFIX-$ENV-sign

# These 3 are used in the setTaskDefinition.js file.
export AWS_ACCOUNT_ID="552333553084"
export INTERNAL_AWS_REGION="us-east-1"
export IMAGE_NAME="spreso-sign"

echo "Pulling the previous task"
if PREVIOUS_TASK_INFO=$(aws ecs describe-task-definition --task-definition $TASK_DEFINITION_NAME --include TAGS --output json) \
  && NEW_TASK=$(node ./devopsScripts/setTaskDefinition.js "$PREVIOUS_TASK_INFO") \
  && TAGS=$(node ./devopsScripts/setTags.js "$PREVIOUS_TASK_INFO") \
  && echo $NEW_TASK > ./devopsScripts/filetask.json ; then

  echo "Previous task was pulled"
else
  echo "Error while trying to get the previous task"
  exit 1
fi

echo "Creating a new task definition revision..."
if NEW_TASK_ARN=$(aws ecs register-task-definition --cli-input-json file://devopsScripts/filetask.json --tags $TAGS --query 'taskDefinition.taskDefinitionArn' --output text) ; then

  echo "A new task definition was registered"
else
  echo "Failed trying to register a new task definition"
  exit 1
fi
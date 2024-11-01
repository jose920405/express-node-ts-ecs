#!/bin/bash

ENV='dev'
PREFIX='spreso-main-jose'
CLUSTER_NAME=$PREFIX-cluster-$ENV

# SERVICE_NAME=$PREFIX-sign-service-$ENV # Sign
SERVICE_NAME=$PREFIX-service-$ENV # main

# TASK_DEFINITION_NAME=$PREFIX-$ENV-sign # Sign
TASK_DEFINITION_NAME=$PREFIX-$ENV # main

# These 3 are used in the setTaskDefinition.js file.
export AWS_ACCOUNT_ID="552333553084"
export INTERNAL_AWS_REGION="us-east-1"

# export IMAGE_NAME="spreso-sign" # Sign
export IMAGE_NAME="spreso" # Main

# export CI_JOB_ID="1" # Sign
export CI_JOB_ID="1" # Main

# Mensaje de inicio de build
echo "Build started"
if docker-compose build ; then
  echo "Build completed on $(date)"
else
  echo "Failed trying to build the Docker image"
  exit 1
fi
echo "Build DONE"

# Login a Amazon ECR
echo "Logging in to Amazon ECR..."
if aws ecr get-login-password --region $INTERNAL_AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$INTERNAL_AWS_REGION.amazonaws.com ; then
  echo "Logging completed"
else
  echo "Failed trying to log in"
  exit 1
fi

if docker tag $IMAGE_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$INTERNAL_AWS_REGION.amazonaws.com/$IMAGE_NAME:$CI_JOB_ID \
  && docker tag $IMAGE_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$INTERNAL_AWS_REGION.amazonaws.com/$IMAGE_NAME:latest ; then

  # IMPORTANT NOTE:
  #
  # The double tag above is just to create another alias to the image.
  # The image is not changing and is not being duplicated.
  #
  # Another tag with "latest" is being created because when a terraform deployment is made, it searches for a tag called "latest".
  # So the conclusion is: The task definition defined in this project will look for the "CI_JOB_ID" tag and terraform will look for "latest"
  #
  # CLARIFICATION ABOUT THE LATEST SEQUENCE:
  #
  # ECR will automatically keep only one image with the latest tag. It means that in each deployment the new image with the latest tag
  # will be defined and ECR will automatically take the previous `latest` tag defined for the previous image and will remove it.
  # The previous image will keep the CI_JOB_ID tag
  #
  # We are adding the CI_JOB_ID because ecs needs a new tag to detect changes and create the new task, if we push the all the tasks with the 
  # name latest, ecs will not detect changes and will keep the same task running

  echo "Build tagged with ${CI_JOB_ID} and latest"
else
  echo "Failed trying to tag Docker image"
  exit 1
fi

echo "Pushing the Docker image..."
if docker image push $AWS_ACCOUNT_ID.dkr.ecr.$INTERNAL_AWS_REGION.amazonaws.com/$IMAGE_NAME:$CI_JOB_ID \
  && docker image push $AWS_ACCOUNT_ID.dkr.ecr.$INTERNAL_AWS_REGION.amazonaws.com/$IMAGE_NAME:latest ; then
  # IMPORTANT NOTE:
  #
  # The double push above does not push the image twice per tag. Only the first one is pushed. 
  # The second one is just to create a reference to the new tag.
  #
  # Docker understands that the image was already pushed because the image is the same "$IMAGE_NAME:latest" 
  # and only needs to reference the tag in the second push

  echo "Docker image was pushed to registry"
else
  echo "Failed trying to push Docker image to registry"
  exit 1
fi

### Task Definition section

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

### UPDATE ECS Service Section.

echo "Starting AWS image update"
if aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $NEW_TASK_ARN ; then

  echo "Sevice was updated"
else
  echo "Failed trying to update the service"
  exit 1
fi

aws ecs wait services-stable --cluster $CLUSTER_NAME --services $SERVICE_NAME
echo "AWS image was updated successfully"
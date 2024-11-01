#!/bin/bash

# Variables de entorno
AWS_ACCOUNT_ID="552333553084"
INTERNAL_AWS_REGION="us-east-1"
IMAGE_NAME="spreso-sign" # change this

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

# Etiquetado de la imagen. Aqui apuntamos a la imagen que se genera local en el punto de arriba cuando se hace el docker-compose build.
if docker tag ${IMAGE_NAME}:latest $AWS_ACCOUNT_ID.dkr.ecr.$INTERNAL_AWS_REGION.amazonaws.com/$IMAGE_NAME:latest ; then
  echo "Build tagged with latest"
else
  echo "Failed trying to tag Docker image"
  exit 1
fi

# Push de la imagen a ECR
echo "Pushing Docker image to ECR..."
if docker image push $AWS_ACCOUNT_ID.dkr.ecr.$INTERNAL_AWS_REGION.amazonaws.com/$IMAGE_NAME:latest ; then
  echo "Docker image was pushed to registry"
else
  echo "Failed trying to push Docker image to registry"
  exit 1
fi

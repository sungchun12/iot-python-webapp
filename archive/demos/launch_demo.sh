#!/usr/bin/env bash
###################
# launch locally
# set the project id
PROJECT_ID="iot-python-webapp-demo"

# build docker image and push to google container registry
gcloud builds submit --tag gcr.io/$PROJECT_ID/mock-example-demo

# deploy cloud run app
gcloud beta run deploy iot-python-webapp --platform managed --image gcr.io/$PROJECT_ID/mock-example-demo:latest --region us-central1 --allow-unauthenticated
###################

###################
# launch after downloading github docker image
# login to github package registry
docker login docker.pkg.github.com --username 

# pull image using above command instructions

# setup your variables
SOURCE_IMAGE="docker.pkg.github.com/sungchun12/iot-python-webapp/hello-world:1.0"
HOSTNAME="gcr.io"
PROJECT_ID="your-project-id"
IMAGE="whatever-you-like"
REGION="us-central1"
APP_NAME="whatever-you-like"

# tag the image and push to google container registry
docker tag $SOURCE_IMAGE $HOSTNAME/$PROJECT_ID/$IMAGE
docker push $HOSTNAME/$PROJECT_ID/$IMAGE

# deploy docker image to cloud run and click on the url that pops up in your terminal output
gcloud beta run deploy $APP_NAME \
--platform managed \
--image $HOSTNAME/$PROJECT_ID/$IMAGE \
--region $REGION \
--allow-unauthenticated
###################
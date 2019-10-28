#!/usr/bin/env bash

# set the project id
PROJECT_ID="iot-python-webapp-demo"

# build docker image and push to google container registry
gcloud builds submit --tag gcr.io/$PROJECT_ID/mock-example-demo

# deploy cloud run app
gcloud beta run deploy iot-python-webapp --platform managed --image gcr.io/$PROJECT_ID/mock-example-demo:latest --region us-central1 --allow-unauthenticated
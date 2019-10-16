https://cloud.google.com/run/docs/authenticating/public


gcloud beta run services add-iam-policy-binding tf-dash-cloud-run-demo \
--member="allUsers" \
--role="roles/run.invoker" \
--region="us-central1"

export GCLOUD_PROJECT_NAME="iconic-range-220603"
export BIGTABLE_CLUSTER="iot-stream-database"
export TABLE_NAME="iot-stream-table"
export CLOUD_REGION="us-central1"
export IOT_REGISTRY="iot-registry"
export ROW_FILTER=2
export GOOGLE_APPLICATION_CREDENTIALS="/Users/sungwon.chung/Desktop/repos/serverless-dash-webapp/tf_modules/service_account.json"


#tag image for google container registry
# docker tag <image-id> gcr.io/<project-id>/<image-name>
docker tag 43a265500959 gcr.io/iconic-range-220603/dash-demo-v2

#push image to google container registry
# docker push gcr.io/<project-id>/<image-name>
docker push gcr.io/iconic-range-220603/dash-demo-v2

# cloud run example
gcloud beta run deploy iot-python-webapp --platform managed --image gcr.io/iconic-range-220603/dash-demo-v2:latest --region us-central1 --allow-unauthenticated --set-env-vars=GCLOUD_PROJECT_NAME="iconic-range-220603",BIGTABLE_CLUSTER="iot-stream-database",TABLE_NAME="iot-stream-table",CLOUD_REGION="us-central1",IOT_REGISTRY="iot-registry",ROW_FILTER=2


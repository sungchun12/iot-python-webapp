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
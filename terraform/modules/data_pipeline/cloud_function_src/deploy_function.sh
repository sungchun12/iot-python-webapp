gcloud functions deploy cbt_function \
--set-env-vars GCLOUD_PROJECT_NAME=iconic-range-220603,BIGTABLE_CLUSTER=iot-stream-database,TABLE_NAME=iot-data-stream,ROW_FILTER=2 \
--entry-point handler \
--runtime python37 \
--trigger-topic data-pipeline-topic


export GOOGLE_APPLICATION_CREDENTIALS="/Users/sungwon.chung/Desktop/repos/serverless-dash-webapp/terraform/service_account.json"

set GOOGLE_APPLICATION_CREDENTIALS=C:\Users\sungwon.chung\Desktop\repos\serverless_dash_repo\serverless_dash\terraform\service_account.json

set GCLOUD_PROJECT=iconic-range-220603
set BIGTABLE_CLUSTER=iot-stream-database

python main.py \
iconic-range-220603 \
iot-stream-database
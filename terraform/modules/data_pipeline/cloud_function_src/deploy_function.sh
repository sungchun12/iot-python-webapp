gcloud functions deploy cbt_function \
--entry-point handler \
--runtime python37 \
--trigger-topic demo_topic


export GOOGLE_APPLICATION_CREDENTIALS="C:\Users\sungwon.chung\Desktop\repos\serverless_dash_repo\serverless_dash\terraform\service_account.json"

set GOOGLE_APPLICATION_CREDENTIALS=C:\Users\sungwon.chung\Desktop\repos\serverless_dash_repo\serverless_dash\terraform\service_account.json

set GCLOUD_PROJECT=iconic-range-220603
set BIGTABLE_CLUSTER=iot-stream-database

python main.py ^
iconic-range-220603 ^
iot-stream-database
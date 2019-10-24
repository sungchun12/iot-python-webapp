# all through cloud shell

# set PROJECT_ID
gcloud config set project iot-python-webapp-demo

# create bucket for encrypted service account json private key
PROJECT_ID=iot-python-webapp-demo
gsutil mb gs://$PROJECT_ID-secure-bucket-tfstate
# gsutil mb -c standard -l us-central1 -p iot-python-webapp-demo -b on gs://$PROJECT_ID-secure-bucket-tfstate
gsutil versioning set on gs://$PROJECT_ID-secure-bucket-tfstate

#create a service account
gcloud iam service-accounts create demo-service-account \
--description "service account used to launch terraform locally" \
--display-name "demo-service-account"

# list service accounts to verify creation
gcloud iam service-accounts list

#enable newly created service account based on what's listed
gcloud beta iam service-accounts enable \
demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com

# add editor encryptor, and security admin role, so it has permissions to launch many kinds of terraform resources
gcloud projects add-iam-policy-binding iot-python-webapp-demo \
--member serviceAccount:demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com \
--role roles/editor

gcloud projects add-iam-policy-binding iot-python-webapp-demo \
--member serviceAccount:demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com \
--role roles/cloudkms.cryptoKeyEncrypter

gcloud projects add-iam-policy-binding iot-python-webapp-demo \
--member serviceAccount:demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com \
--role roles/iam.securityAdmin

gcloud projects add-iam-policy-binding iot-python-webapp-demo \
--member serviceAccount:demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com \
--role roles/cloudkms.admin

# check if roles updated
# note: may not be accurate even though console shows the update
gcloud iam service-accounts get-iam-policy \
demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com

# clone git repo
git clone https://github.com/sungchun12/iot-python-webapp.git

# download the service account key where gcloud lives
gcloud iam service-accounts keys create ~/iot-python-webapp/service_account.json \
--iam-account demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com

# download locally
gcloud iam service-accounts keys create ~/Desktop/repos/serverless-dash-webapp/service_account.json \
--iam-account demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com

# move the service account key to the repo
# note: it'll be ignored
# mv service_account.json ~/iot-python-webapp

# change directory to tf_modules
cd tf_modules/

# ad hoc push to container registry from dockerfile at root directory
gcloud builds submit --tag gcr.io/iot-python-webapp-demo/dash-cloudrun-demo
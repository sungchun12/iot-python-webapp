#!/usr/bin/env bash

# all this is intended to run within cloud shell

#manual steps in cloud shell
# clone git repo
# gcloud config set project <PROJECT_ID>
# git clone https://github.com/sungchun12/iot-python-webapp.git
# cd iot_python_webapp/

# example command below
# bash ./initial_setup.sh example@gmail.com user_123 ferrous-weaver-256122 demo-service-account gcp_signup_name_3

# set command line arguments
GITHUB_EMAIL=$1
GITHUB_USERNAME=$2
PROJECT_ID=$3
SERVICE_ACCOUNT_NAME=$4
GCP_USERNAME=$5

# checks if all the command line arguments are filled
if [[ (-n "$GITHUB_EMAIL") && (-n "$GITHUB_USERNAME") && (-n "$PROJECT_ID") && (-n "$SERVICE_ACCOUNT_NAME") && (-n "$GCP_USERNAME")]]; then
    # setup git configs for authorship
    git config --global user.email $GITHUB_EMAIL
    git config --global user.name $GITHUB_USERNAME
    
    # create bucket for encrypted service account json private key
    gsutil mb gs://$PROJECT_ID-secure-bucket-tfstate
    # gsutil mb -c standard -l us-central1 -p iot-python-webapp-demo -b on gs://$PROJECT_ID-secure-bucket-tfstate
    gsutil versioning set on gs://$PROJECT_ID-secure-bucket-tfstate
    
    #create a service account
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --description "service account used to launch terraform locally" \
    --display-name $SERVICE_ACCOUNT_NAME
    
    # wait for the service account to be created
    sleep 10s
    
    # list service account to verify creation and capture email
    SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --filter=$SERVICE_ACCOUNT_NAME | grep -v "^NAME"  | shuf -n 1 | awk '{print $2}')
    
    # enable newly created service account based on what's listed
    gcloud beta iam service-accounts enable $SERVICE_ACCOUNT_EMAIL
    
    # add editor encryptor, and security admin role, so it has permissions to launch many kinds of terraform resources
    gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role roles/editor
    
    gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role roles/cloudkms.cryptoKeyEncrypter
    
    gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role roles/iam.securityAdmin
    
    gcloud projects add-iam-policy-binding $PROJECT_ID\
    --member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role roles/cloudkms.admin
    
    # check if roles updated
    # note: may not be accurate even though console shows the update
    gcloud iam service-accounts get-iam-policy $SERVICE_ACCOUNT_EMAIL
    
    # download the service account key into the repo
    gcloud iam service-accounts keys create ~/iot-python-webapp/service_account.json \
    --iam-account $SERVICE_ACCOUNT_EMAIL
    
    # enable cloud build api
    gcloud services enable cloudbuild.googleapis.com
    
    # ad hoc push to container registry from dockerfile at root directory
    gcloud builds submit --tag gcr.io/$PROJECT_ID/dash-cloudrun-demo
    
    #create terraform.tfvars file based on passed in parameters
    printf "project = "\"$PROJECT_ID\""\nservice_account_email = "\"$SERVICE_ACCOUNT_EMAIL\""\nstartup_script_username = "\"$GCP_USERNAME\""\n" > ./tf_modules/terraform.tfvars
    
    #create the terraform backend.tf storage bucket config file
    printf "terraform {\n  backend "\"gcs\"" {\n    bucket = "\"$PROJECT_ID-secure-bucket-tfstate\""\n  }\n}\n" > ./tf_modules/backend.tf
else
    echo "Make sure all these arguments are filled in the correct position GITHUB_EMAIL,GITHUB_USERNAME,PROJECT_ID,SERVICE_ACCOUNT_NAME,GCP_USERNAME ex: bash ./initial_setup.sh example@gmail.com user_123 ferrous-weaver-256122 demo-service-account gcp_signup_name_3"
fi

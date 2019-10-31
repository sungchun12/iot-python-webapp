#!/usr/bin/env bash

# all this is intended to run within cloud shell bash

#manual steps in cloud shell
# fork git repo into your own github account
# gcloud config set project <PROJECT_ID>
# git clone https://github.com/<github username>/iot-python-webapp.git
# cd iot_python_webapp/

usage() { echo "Usage: bash $0 [-e GITHUB_EMAIL] [-u GITHUB_USERNAME] [-p PROJECT_ID] [-s SERVICE_ACCOUNT_NAME] [-g GCP_USERNAME] [-b GITHUB_BRANCH_NAME] | \
Example: bash $0 -e example@gmail.com -u user_123 -p ferrous-weaver-256122 -s demo-service-account -g gcp_signup_name_3 -b master" 1>&2; exit 1;}

while getopts ":e:u:p:s:g:b:" o; do
    case "${o}" in
        e)
            e=${OPTARG}
        ;;
        u)
            u=${OPTARG}
        ;;
        p)
            p=${OPTARG}
        ;;
        s)
            s=${OPTARG}
        ;;
        g)
            g=${OPTARG}
        ;;
        b)
            b=${OPTARG}
        ;;
        *)
            usage
        ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${e}" ] || [ -z "${u}" ] || [ -z "${p}" ] || [ -z "${s}" ] || [ -z "${g}" ] || [ -z "${b}" ]; then
    usage
fi

# set command line arguments
GITHUB_EMAIL=${e}
GITHUB_USERNAME=${u}
PROJECT_ID=${p}
SERVICE_ACCOUNT_NAME=${s}
GCP_USERNAME=${g}
GITHUB_BRANCH_NAME=${b}

echo "GITHUB_EMAIL = $GITHUB_EMAIL"
echo "GITHUB_USERNAME = $GITHUB_USERNAME"
echo "PROJECT_ID = $PROJECT_ID"
echo "SERVICE_ACCOUNT_NAME = $SERVICE_ACCOUNT_NAME"
echo "GCP_USERNAME = $GCP_USERNAME"
echo "GITHUB_BRANCH_NAME = $GITHUB_BRANCH_NAME"

echo "***********************"
echo "Setup git configs for authorship"
echo "***********************"
git config --global user.email $GITHUB_EMAIL
git config --global user.name $GITHUB_USERNAME

echo "***********************"
echo "Create versioned buckets for tfstate and encrypted service account json private key"
echo "***********************"
gsutil mb gs://$PROJECT_ID-secure-bucket-tfstate
gsutil mb gs://$PROJECT_ID-secure-bucket-secrets
# gsutil mb -c standard -l us-central1 -p iot-python-webapp-demo -b on gs://$PROJECT_ID-secure-bucket-tfstate
gsutil versioning set on gs://$PROJECT_ID-secure-bucket-tfstate
gsutil versioning set on gs://$PROJECT_ID-secure-bucket-secrets

echo "***********************"
echo "Create a service account"
echo "***********************"
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
--description "service account used to launch terraform locally" \
--display-name $SERVICE_ACCOUNT_NAME

echo "***********************"
echo "Wait for the service account to be created"
echo "***********************"
sleep 10s

echo "***********************"
echo "List service account to verify creation and capture email"
echo "***********************"
SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list --filter=$SERVICE_ACCOUNT_NAME | grep -v "^NAME"  | head -n 1 | awk '{print $2}')

echo "***********************"
echo "Enable newly created service account based on what's listed"
echo "***********************"
gcloud beta iam service-accounts enable $SERVICE_ACCOUNT_EMAIL

echo "***********************"
echo "Add editor encryptor, and security admin role, so it has permissions to launch many kinds of terraform resources"
echo "***********************"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
--role roles/editor

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
--role roles/cloudkms.cryptoKeyEncrypter

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
--role roles/iam.securityAdmin

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
--role roles/cloudkms.admin

echo "***********************"
echo "Check if roles updated"
echo "Note: may not be accurate even though console shows the update"
echo "***********************"
gcloud iam service-accounts get-iam-policy $SERVICE_ACCOUNT_EMAIL

echo "***********************"
echo "Download the service account key into the repo"
echo "***********************"
gcloud iam service-accounts keys create ~/iot-python-webapp/service_account.json \
--iam-account $SERVICE_ACCOUNT_EMAIL

echo "***********************"
echo "Enable cloud build and kms apis"
echo "***********************"
gcloud services enable cloudbuild.googleapis.com
gcloud services enable cloudkms.googleapis.com

echo "***********************"
echo "Retrieve cloud build service account email"
echo "***********************"
CLOUDBUILD_SA="$(gcloud projects describe $PROJECT_ID \
--format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"

echo "***********************"
echo "Add roles to the cloud build service account that mimics the demo service account"
echo "***********************"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member serviceAccount:$CLOUDBUILD_SA \
--role roles/editor

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member serviceAccount:$CLOUDBUILD_SA \
--role roles/cloudkms.cryptoKeyEncrypterDecrypter

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member serviceAccount:$CLOUDBUILD_SA \
--role roles/iam.securityAdmin

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member serviceAccount:$CLOUDBUILD_SA \
--role roles/cloudkms.admin

echo "***********************"
echo "Create kms keyring and key for service account json file and then encrypt it into ciphertext"
echo "***********************"
keyring_name=$PROJECT_ID-keyring
key_name=$PROJECT_ID-key

gcloud kms keyrings create $keyring_name \
--location=global

gcloud kms keys create $key_name \
--purpose=encryption \
--location=global \
--keyring=$keyring_name \
--protection-level=software

gcloud kms encrypt \
--key=$key_name \
--keyring=$keyring_name \
--location=global \
--plaintext-file=service_account.json \
--ciphertext-file=ciphertext_file.enc

echo "***********************"
echo "Copy encrypted file to cloud storage bucket"
echo "***********************"
gsutil cp ciphertext_file.enc gs://$PROJECT_ID-secure-bucket-secrets

echo "***********************"
echo "Create terraform.tfvars file based on passed in parameters"
echo "***********************"
printf "project = "\"$PROJECT_ID\""\nservice_account_email = "\"$SERVICE_ACCOUNT_EMAIL\""\nstartup_script_username = "\"$GCP_USERNAME\""\ngithub_owner = "\"$GITHUB_USERNAME\""\ngithub_branch_name = "\"$GITHUB_BRANCH_NAME\""\n" > ./tf_modules/terraform.tfvars

echo "***********************"
echo "Create the terraform backend.tf storage bucket config file"
echo "***********************"
printf "terraform {\n  backend "\"gcs\"" {\n    bucket = "\"$PROJECT_ID-secure-bucket-tfstate\""\n  }\n}\n" > ./tf_modules/backend.tf

echo "***********************"
echo "Validate the secrets file is uploaded into bucket and expected changes in terraform config files"
echo "***********************"
echo "secrets file location..."
echo " "
gsutil ls -r gs://iot-python-webapp-demo-secure-bucket-secrets/
echo "***********************"
echo "terraform.tfvars contents..."
echo " "
cat ./tf_modules/terraform.tfvars
echo "***********************"
echo "backend.tf contents..."
echo " "
cat ./tf_modules/backend.tf
echo "***********************"

# push changes to remote repo
# TODO: add to manual github instructions after first_build.yaml
# git status
# git add --all
# git commit -m "Update project IDs and buckets"
# git push origin

export GCLOUD_PROJECT_NAME="iconic-range-220603"
export BIGTABLE_CLUSTER="iot-stream-database"
export TABLE_NAME="iot-stream-table"
export CLOUD_REGION="global"
export IOT_REGISTRY="iot-registry"
export ROW_FILTER=2
export KEY_RING_ID="cloud-run-keyring"
export CRYPTO_KEY_ID="test-ring"
export GOOGLE_APPLICATION_CREDENTIALS="/Users/sungwon.chung/Desktop/repos/serverless-dash-webapp/service_account.json"
export GOOGLE_APP_CREDENTIALS="CiQA50Ad3WaKLGR3xlIgKzNz7caas4ceMEtfnote43POiHAQkV8SQACvmJFehfFm/gdai0gBG5HsVXdOyz+h13UtdIHMLS0LzP/atcZnsdtSKyBP2qV2mgZwnqzOs8EM7GID09p3YB4="


# steps to encrypt private key for cloud run
# https://stackoverflow.com/questions/48602546/google-cloud-functions-how-to-securely-store-service-account-private-key-when

# https://cloud.google.com/kms/docs/secret-management#choosing_a_secret_management_solution
# TODO: can add the below scripts to a single script with file argument
# create bucket for encrypted service account json private key
gsutil mb -c standard -l us-central1 -p iconic-range-220603 -b on gs://secure-bucket-cloud-run

# delete the bucket as needed
gsutil rm -r gs://secure-bucket-cloud-run

# create a keyring
gcloud kms keyrings create cloud-run-keyring \
--location=global

#create a key
gcloud kms keys create iot-python-webapp-key \
--purpose=encryption \
--location=global \
--keyring=cloud-run-keyring \
--protection-level=software

#encrypt file using KMS
# https://cloud.google.com/sdk/gcloud/reference/kms/encrypt
gcloud kms encrypt \
--key=iot-python-webapp-key \
--keyring=cloud-run-keyring \
--location=global \
--plaintext-file=/Users/sungwon.chung/Desktop/repos/serverless-dash-webapp/tf_modules/service_account.json \
--ciphertext-file=ciphertext_file.enc

# Copy encrypted file to cloud storage bucket
gsutil cp ciphertext_file.enc gs://secure-bucket-cloud-run

# list objects in bucket
gsutil ls -r gs://secure-bucket-cloud-run

#decrypt file using KMS
gcloud kms decrypt \
--key=iot-python-webapp-key \
--keyring=cloud-run-keyring \
--location=global \
--plaintext-file=testFile.json \
--ciphertext-file=gs://secure-bucket-cloud-run/ciphertext_file

# Traceback (most recent call last): File "/usr/local/lib/python3.7/site-packages/gunicorn/arbiter.py", line 583, in spawn_worker worker.init_process() File "/usr/local/lib/python3.7/site-packages/gunicorn/workers/gthread.py", line 104, in init_process super(ThreadWorker, self).init_process() File "/usr/local/lib/python3.7/site-packages/gunicorn/workers/base.py", line 129, in init_process self.load_wsgi() File "/usr/local/lib/python3.7/site-packages/gunicorn/workers/base.py", line 138, in load_wsgi self.wsgi = self.app.wsgi() File "/usr/local/lib/python3.7/site-packages/gunicorn/app/base.py", line 67, in wsgi self.callable = self.load() File "/usr/local/lib/python3.7/site-packages/gunicorn/app/wsgiapp.py", line 52, in load return self.load_wsgiapp() File "/usr/local/lib/python3.7/site-packages/gunicorn/app/wsgiapp.py", line 41, in load_wsgiapp return util.import_app(self.app_uri) File "/usr/local/lib/python3.7/site-packages/gunicorn/util.py", line 350, in import_app __import__(module) File "/app/app.py", line 18, in <module> devices_list = cbt_data_generator.get_device_names() File "/app/access_iot_data.py", line 85, in get_device_names self.decrpyt_symmetric_text(self.__service_account_ciphertext), File "/app/access_iot_data.py", line 68, in decrpyt_symmetric_text response = client.decrypt(name, ciphertext) File "/usr/local/lib/python3.7/site-packages/google/cloud/kms_v1/gapic/key_management_service_client.py", line 1816, in decrypt request, retry=retry, timeout=timeout, metadata=metadata File "/usr/local/lib/python3.7/site-packages/google/api_core/gapic_v1/method.py", line 143, in __call__ return wrapped_func(*args, **kwargs) File "/usr/local/lib/python3.7/site-packages/google/api_core/retry.py", line 273, in retry_wrapped_func on_error=on_error, File "/usr/local/lib/python3.7/site-packages/google/api_core/retry.py", line 182, in retry_target return target() File "/usr/local/lib/python3.7/site-packages/google/api_core/timeout.py", line 214, in func_with_timeout return func(*args, **kwargs) File "/usr/local/lib/python3.7/site-packages/google/api_core/grpc_helpers.py", line 59, in error_remapped_callable six.raise_from(exceptions.from_grpc_error(exc), exc) File "<string>", line 3, in raise_from google.api_core.exceptions.InvalidArgument: 400 Decryption failed: the ciphertext is invalid.

#tag image for google container registry
# docker tag <image-id> gcr.io/<project-id>/<image-name>
# docker tag 5427d9091df4 gcr.io/iconic-range-220603/dash-cloudrun-demo

#push image to google container registry
# docker push gcr.io/<project-id>/<image-name>
# docker push gcr.io/iconic-range-220603/dash-cloudrun-demo

# all through cloud shell

#create a service account
gcloud iam service-accounts create demo-service-account \
--description "service account used to launch terraform locally" \
--display-name "demo-service-account"

# list service accounts to verify creation
gcloud iam service-accounts list

#enable newly created service account based on what's listed
gcloud beta iam service-accounts enable \
demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com

# add editor and encryptor role, so it has permissions to launch many kinds of terraform resources
gcloud projects add-iam-policy-binding iot-python-webapp-demo \
--member serviceAccount:demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com \
--role roles/editor

gcloud projects add-iam-policy-binding iot-python-webapp-demo \
--member serviceAccount:demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com \
--role roles/cloudkms.cryptoKeyEncrypter

# check if roles updated
# note: may not be accurate even though console shows the update
gcloud iam service-accounts get-iam-policy \
demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com

# clone git repo
git clone https://github.com/sungchun12/iot-python-webapp.git

# download the service account key
gcloud iam service-accounts keys create ~/service_account.json \
--iam-account demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com

# move the service account key to the repo
# note: it'll be ignored
mv service_account.json ~/iot-python-webapp

# change directory to tf_modules
cd tf_modules/

# ad hoc push to container registry from dockerfile at root directory
gcloud builds submit --tag gcr.io/iot-python-webapp-demo/dash-cloudrun-demo

# terraform deployment
terraform init
terraform plan
terraform apply

# ad hoc push to container registry from dockerfile at root directory
gcloud builds submit --tag gcr.io/iot-python-webapp-demo/dash-cloudrun-demo

# deploy infrastructure
terraform apply

# https://cloud.google.com/run/docs/authenticating/public
# make cloud run public
gcloud beta run services add-iam-policy-binding tf-dash-cloud-run-demo \
--member="allUsers" \
--role="roles/run.invoker" \
--region="us-central1"

#adjust memory limit
gcloud beta run services update dash-cloudrun-demo --memory 1Gi --platform managed --region us-central1

#destroy iot registry
gcloud iot registries delete iot-registry --region=us-central1

#destroy everything else
terraform destroy

#adjust key ring name to another version name


# terraform destroy -target google_cloud_run_service.tf-dash-cloud-run-demo

# cloud run example
gcloud beta run deploy iot-python-webapp --platform managed --image gcr.io/iconic-range-220603/dash-demo-v2:latest --region us-central1 --allow-unauthenticated --set-env-vars=GCLOUD_PROJECT_NAME="iconic-range-220603",BIGTABLE_CLUSTER="iot-stream-database",TABLE_NAME="iot-stream-table",CLOUD_REGION="us-central1",IOT_REGISTRY="iot-registry",ROW_FILTER=2


#! /bin/bash

# initial gcloud sdk
gcloud init

#install beta components
gcloud components install beta

#update the system information about Debian Linux package repositories
sudo apt-get update

#install in scope packages
sudo apt-get install python-pip openssl git -y

#use pip for needed Python components
sudo pip install pyjwt paho-mqtt cryptography

#add data to analyze for lab
git clone http://github.com/GoogleCloudPlatform/training-data-analyst

#export environment variabes
export PROJECT_ID = iconic-range-220603
export MY_REGION = us-central1

#create RSA cryptographic keypair
cd $HOME/training-data-analyst/quests/iotlab/
openssl req -x509 -newkey rsa:2048 -keyout rsa_private.pem \
-nodes -out rsa_cert.pem -subj "/CN=unused"

gcloud beta iot devices create temp-sensor-buenos-aires \
--project=$PROJECT_ID \
--region=$MY_REGION \
--registry=iot-registry \
--public-key path=rsa_cert.pem,type=rs256

gcloud beta iot devices create temp-sensor-istanbul \
--project=$PROJECT_ID \
--region=$MY_REGION \
--registry=iot-registry \
--public-key path=rsa_cert.pem,type=rs256

#download the CA root certificates from pki.google.com to the appropriate directory
cd $HOME/training-data-analyst/quests/iotlab/
wget https://pki.google.com/roots.pem

# run the simulated device in the background
python cloudiot_mqtt_example_json.py \
--project_id=$PROJECT_ID \
--cloud_region=$MY_REGION \
--registry_id=iot-registry \
--device_id=temp-sensor-buenos-aires \
--private_key_file=rsa_private.pem \
--message_type=event \
--algorithm=RS256 > buenos-aires-log.txt 2>&1 &

python cloudiot_mqtt_example_json.py \
--project_id=$PROJECT_ID \
--cloud_region=$MY_REGION \
--registry_id=iot-registry \
--device_id=temp-sensor-istanbul \
--private_key_file=rsa_private.pem \
--message_type=event \
--algorithm=RS256
##############################
#project-wide variables
variable "project" {
  default     = "iconic-range-220603"
  description = "name of your GCP project"
}

variable "location" {
  default     = "us-central1"
  description = "location of various GCP services"
}

variable "zone" {
  default     = "us-central1-b"
  description = "a granular location typically for VMs"
}

variable "version_label" {
  default     = "demo"
  description = "helpful label to version GCP resources per deployment"
}
##############################
# storage variables
variable "raw_bucket_name" {
  default     = "iot-raw-data-sung"
  description = "bucket name where all the raw streaming data is stored"
}

variable "staging_bucket_name" {
  default     = "iot-dataflow-stage-sung"
  description = "bucket name where dataflow stages data during transformations"
}

variable "storage_class" {
  default     = "REGIONAL"
  description = "type of storage depending on frequency of data use"
}

variable "versioning_enabled" {
  default     = true
  description = "you typically want to enable bucket versioning"
}

variable "main_page_suffix" {
  default     = "index.html"
  description = "behaves as bucket's directory index"
}

variable "not_found_page" {
  default     = "404.html"
  description = "custom object to return when a requested resource is not found"
}
##############################
# iot_compute variables
variable "device_name_1" {
  default     = "iot-device-1"
  description = "name of the VM to simulate an IOT device"
}

variable "device_name_1_zone" {
  default     = "us-east1-c"
  description = "zone for IOT device"
}

variable "device_name_2" {
  default     = "iot-device-2"
  description = "name of the VM to simulate an IOT device"
}

variable "device_name_2_zone" {
  default     = "us-east1-b"
  description = "zone for IOT device"
}

variable "device_name_3" {
  default     = "iot-device-3"
  description = "name of the VM to simulate an IOT device"
}

variable "device_name_3_zone" {
  default     = "europe-west2-a"
  description = "zone for IOT device"
}

variable "machine_type" {
  default     = "n1-standard-1"
  description = "we'll go with a small, standard VM"
}

variable "os_image" {
  default     = "debian-cloud/debian-9"
  description = "Typically a linux image, debian is lightweight"
}

variable "service_account_email" {
  default     = "demo-service-account@iconic-range-220603.iam.gserviceaccount.com"
  description = "Service account used for VMs"
}

variable "service_account_scopes" {
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
  description = "GCP access rights for VM which will override service account permissions if more limited"
}

variable "network_name" {
  default     = "demo-network"
  description = "Name of the VPC network for VMs to reside within"
}

variable "firewall_ssh_name" {
  default     = "ssh-access-firewall"
  description = "Name of the firewall allowing ssh access"
}

variable "firewall_ssh_description" {
  default     = "allow ssh access to VM within the project"
  description = "description for firewall"
}

variable "allow_protocol" {
  default     = "tcp"
  description = "type of ssh protocol: rdp or tcp"
}

variable "allow_ports" {
  default     = ["22"]
  description = "port to ssh into"
}
##############################
# data_pipeline variables
variable "iot_registry_name" {
  default     = "iot-registry"
  description = "Name of IOT registry to manage devices"
}

variable "http_config_state" {
  default     = "HTTP_DISABLED"
  description = "Enable or disable http protocol"
}

variable "mqtt_config_state" {
  default     = "MQTT_ENABLED"
  description = "Enable or disable mqtt protocol"
}

variable "data_pipeline_topic_name" {
  default     = "data-pipeline-topic"
  description = "Name of pubsub topic for raw device data streams"
}

variable "device_status_topic_name" {
  default     = "iot-device-status"
  description = "Name of pubsub topic for device status streams"
}

variable "dataset_name" {
  default     = "iot_dataset"
  description = "Name of BigQuery dataset for data streams"
}

variable "dataset_desc" {
  default     = "iot data warehouse"
  description = "Description of BigQuery dataset for data streams"
}

variable "table_name" {
  default     = "iot_raw_data"
  description = "Name of BigQuery table for raw data streams"
}

variable "table_desc" {
  default     = "table that accumulates all raw iot streaming data"
  description = "Description of BigQuery table for raw data streams"
}

variable "bigtable_db_name" {
  default     = "iot-stream-database"
  description = "Name of BigTable instance for raw data streams"
}

variable "bigtable_db_instance_type" {
  default     = "DEVELOPMENT"
  description = "Type of instance"
}

variable "bigtable_db_cluster_name" {
  default     = "iot-stream-database-cluster"
  description = "Name of BigTable cluster for raw data streams"
}

variable "bigtable_db_storage_type" {
  default     = "SSD"
  description = "BigTable instance storage type"
}

variable "bigtable_table_name" {
  default     = "iot-stream-table"
  description = "BigTable instance storage type"
}

variable "bigtable_table_split_keys" {
  default     = ["a", "b", "c"]
  description = "define table partition keys"
}

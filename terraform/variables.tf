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

variable "service_account_email" {
  default     = "demo-service-account@iconic-range-220603.iam.gserviceaccount.com"
  description = "Service account used for VMs"
}

variable "version_label" {
  default     = "demo"
  description = "helpful label to version GCP resources per deployment"
}
##############################
# storage variables

##############################
# iot_compute variables

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

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------
variable "project" {
}

variable "location" {
}

variable "zone" {
}

variable "service_account_email" {
}

variable "version_label" {
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator
# ---------------------------------------------------------------------------------------------------------------------
variable "iot_registry_name" {
  description = "Name of IOT registry to manage devices"
  type        = string
  default     = "iot-registry"
}

variable "http_config_state" {
  description = "Enable or disable http protocol"
  type        = string
  default     = "HTTP_DISABLED"
}

variable "mqtt_config_state" {
  description = "Enable or disable mqtt protocol"
  type        = string
  default     = "MQTT_ENABLED"
}

variable "data_pipeline_topic_name" {
  description = "Name of pubsub topic for raw device data streams"
  type        = string
  default     = "data-pipeline-topic"
}

variable "device_status_topic_name" {
  description = "Name of pubsub topic for device status streams"
  type        = string
  default     = "iot-device-status"
}

variable "dataset_name" {
  description = "Name of BigQuery dataset for data streams"
  type        = string
  default     = "iot_dataset"
}

variable "dataset_desc" {
  description = "Description of BigQuery dataset for data streams"
  type        = string
  default     = "iot data warehouse"
}

variable "table_name" {
  description = "Name of BigQuery table for raw data streams"
  type        = string
  default     = "iot_raw_data"
}

variable "table_desc" {
  description = "Description of BigQuery table for raw data streams"
  type        = string
  default     = "table that accumulates all raw iot streaming data"
}

variable "bigtable_db_name" {
  description = "Name of BigTable instance for raw data streams"
  type        = string
  default     = "iot-stream-database"
}

variable "bigtable_db_instance_type" {
  description = "Type of instance"
  type        = string
  default     = "DEVELOPMENT"
}

variable "bigtable_db_cluster_name" {
  description = "Name of BigTable cluster for raw data streams"
  type        = string
  default     = "iot-stream-database-cluster"
}

variable "bigtable_db_storage_type" {
  description = "BigTable instance storage type"
  type        = string
  default     = "SSD"
}

variable "bigtable_table_name" {
  description = "BigTable instance storage type"
  type        = string
  default     = "iot-stream-table"
}

variable "bigtable_table_split_keys" {
  description = "define table partition keys"
  type        = list
  default     = ["a", "b", "c"]
}

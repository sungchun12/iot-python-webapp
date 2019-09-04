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

# -----------------------------------------------------------------------
# IoT Core and PubSub Variables
# -----------------------------------------------------------------------
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

# -----------------------------------------------------------------------
# BigQuery Variables
# -----------------------------------------------------------------------
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

variable "partition_field_name" {
  description = "Name of field to partition by day"
  type        = string
  default     = "timestamp"
}

# -----------------------------------------------------------------------
# BigTable Variables
# -----------------------------------------------------------------------
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

variable "bigtable_column_family" {
  description = "BigTable column families"
  type        = string
  default     = "device-temperature"
}

variable "bigtable_table_split_keys" {
  description = "define table partition keys"
  type        = list
  default     = ["device", "timestamp"]
}

# -----------------------------------------------------------------------
# Dataflow Variables
# -----------------------------------------------------------------------
variable "dataflow_raw_data_job_name" {
  description = "Name of data flow job for raw data ingestion"
  type        = string
  default     = "dataflow-raw-data-stream"
}

variable "template_gcs_path_location" {
  description = "Cloud storage bucket location for dataflow job"
  type        = string
  default     = "gs://dataflow-templates/2019-05-15-00/PubSub_to_BigQuery"
}

variable "temp_staging_gcs_path" {
  description = "Cloud storage bucket location for staging temporary dataflow data"
  type        = string
  default     = "gs://iot-dataflow-stage-sung/tmp"
}

variable "on_delete_option" {
  description = "Drain or cancel the dataflow job"
  type        = string
  default     = "cancel"
}

# -----------------------------------------------------------------------
# Cloud Function Variables
# -----------------------------------------------------------------------
#passed from storage module to root module to data pipeline module
variable "source_code_bucket_name" {
}

variable "big_table_function_code_name" {
  description = "Create a zip file object within the source code bucket"
  type        = string
  default     = "big-table-function-code.zip"
}

variable "source_path" {
  description = "Path to files with function scripts"
  type        = string
  default     = "./cloud_function_src"
}

variable "cbt_function_name" {
  description = "Name of the cloud function"
  type        = string
  default     = "big-table-function"
}

variable "cbt_function_desc" {
  description = "Describes what the cloud function does"
  type        = string
  default     = "Read data from a pubsub topic and write it to a bigtable instance"
}

variable "cbt_function_runtime" {
  description = "Choose programming language runtime"
  type        = string
  default     = "python37"
}

variable "cbt_available_memory_mb" {
  description = "Choose max available memory for function"
  type        = number
  default     = 256
}

variable "cbt_function_event_type" {
  description = "Choose the function trigger type"
  type        = string
  default     = "google.pubsub.topic.publish"
}

variable "cbt_function_failure_policy" {
  description = "Choose the function trigger type"
  type        = bool
  default     = true
}

variable "cbt_function_timeout" {
  description = "How long should the function run before erroring out in seconds"
  type        = number
  default     = 60
}

variable "cbt_function_entry_point" {
  description = "The main function within the code that makes it work"
  type        = string
  default     = "main"
}

variable "row_filter" {
  description = "The number of results to retain when querying BigTable"
  type        = number
  default     = 2
}

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------
variable "credentials" {
  description = "path to service account json file"
  type        = string
  default     = "../service_account.json"
}

variable "project" {
  description = "name of your GCP project"
  type        = string
  default     = "iot-python-webapp-demo"
}

variable "location" {
  description = "default location of various GCP services"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "default granular location typically for VMs"
  type        = string
  default     = "us-central1-b"
}

variable "service_account_email" {
  description = "Service account used for VMs"
  type        = string
  default     = "demo-service-account@iot-python-webapp-demo.iam.gserviceaccount.com"
}

variable "version_label" {
  description = "helpful label to version GCP resources per deployment"
  type        = string
  default     = "demo"
}

variable "api_services" {
  description = "list of Google Cloud apis to enable when launching terraform"
  type        = list
  default     = ["iam.googleapis.com", "cloudresourcemanager.googleapis.com", "cloudfunctions.googleapis.com", "pubsub.googleapis.com", "storage-component.googleapis.com", "bigquery-json.googleapis.com", "bigquery.googleapis.com", "cloudbuild.googleapis.com", "run.googleapis.com", "cloudiot.googleapis.com", "bigtable.googleapis.com", "bigtableadmin.googleapis.com", "dataflow.googleapis.com", "compute.googleapis.com", "cloudkms.googleapis.com"]
}

variable "disable_services_on_destroy_bool" {
  description = "whether project services will be disabled when the resources are destroyed"
  type        = string
  default     = "false"
}

variable "enable_apis_bool" {
  description = "whether to actually enable the APIs. If false, this module is a no-op"
  type        = string
  default     = "true"
}

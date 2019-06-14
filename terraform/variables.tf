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


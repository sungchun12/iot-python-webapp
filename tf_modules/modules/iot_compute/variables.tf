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
variable "device_name_1" {
  description = "name of the VM to simulate an IOT device"
  type        = string
  default     = "iot-device-1"
}

variable "device_name_1_zone" {
  description = "zone for IOT device"
  type        = string
  default     = "us-east1-c"
}

variable "device_name_2" {
  description = "name of the VM to simulate an IOT device"
  type        = string
  default     = "iot-device-2"
}

variable "device_name_2_zone" {
  description = "zone for IOT device"
  type        = string
  default     = "us-east1-b"

}

variable "device_name_3" {
  description = "name of the VM to simulate an IOT device"
  type        = string
  default     = "iot-device-3"
}

variable "device_name_3_zone" {
  description = "zone for IOT device"
  type        = string
  default     = "europe-west2-a"
}

variable "machine_type" {
  description = "we'll go with a small, standard VM"
  type        = string
  default     = "n1-standard-1"
}

variable "os_image" {
  description = "Typically a linux image, debian is lightweight"
  type        = string
  default     = "debian-cloud/debian-9"
}

variable "service_account_scopes" {
  description = "GCP access rights for VM which will override service account permissions if more limited"
  type        = list
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "network_name" {
  description = "Name of the VPC network for VMs to reside within"
  type        = string
  default     = "demo-network"
}

variable "firewall_ssh_name" {
  description = "Name of the firewall allowing ssh access"
  type        = string
  default     = "ssh-access-firewall"
}

variable "firewall_ssh_description" {
  description = "description for firewall"
  type        = string
  default     = "allow ssh access to VM within the project"
}

variable "allow_protocol" {
  description = "type of ssh protocol: rdp or tcp"
  type        = string
  default     = "tcp"
}

variable "allow_ports" {
  description = "port to ssh into"
  type        = list
  default     = ["22"]
}

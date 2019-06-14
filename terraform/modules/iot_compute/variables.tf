variable "project" {
}

variable "location" {
}

variable "zone" {
}

variable "version_label" {
}

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

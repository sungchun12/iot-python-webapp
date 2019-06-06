#project-wide variables
variable "project" {
  default = "iconic-range-220603"
}

variable "location" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-b"
}

variable "version_label" {
  default = "demo"
}

#storage variables
variable "storage_class" {
  default = "REGIONAL"
}

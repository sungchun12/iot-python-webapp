# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------
variable "secrets" {
}

variable "project" {
}

variable "location" {
}

variable "version_label" {
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------
variable "key_ring_name" {
  description = "name of the keyring to manage cryptographic keys"
  type        = string
  default     = "cloud-run-keyring-v17"

}

variable "webapp_key_name" {
  description = "name of the key used to decrpyt the cipher text file"
  type        = string
  default     = "iot-python-webapp-key"

}


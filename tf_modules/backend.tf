terraform {
  backend "gcs" {
    bucket = "lumpy-space-pirate-secure-bucket-tfstate"
  }
}

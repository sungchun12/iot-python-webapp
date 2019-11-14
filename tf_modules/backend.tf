terraform {
  backend "gcs" {
    bucket = "lumpy-space-princess-secure-bucket-tfstate"
  }
}

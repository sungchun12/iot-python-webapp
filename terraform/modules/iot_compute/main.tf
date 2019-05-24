resource "google_compute_instance" "iot-device-1" {
  name         = "iot-device-1"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = ["demo"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {}

  network_interface {
    # link creatd vpc network
    network       = "${google_compute_network.demo-network.self_link}"
    access_config = {}
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["service-157930433863@compute-system.iam.gserviceaccount.com", "compute-ro", "storage-ro"]
  }
}

data "google_compute_network" "demo-network" {
  name                    = "demo-network"
  auto_create_subnetworks = "true"
}

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

  # Local SSD disk
  scratch_disk {}

  network_interface {
    # link creatd vpc network
    network       = "${google_compute_network.demo-network.self_link}"
    access_config = {}
  }

  metadata_startup_script = "echo hi > /test.txt"

  # service_account {
  #   scopes = ["service-157930433863@compute-system.iam.gserviceaccount.com", "compute-ro", "storage-ro"]
  # }
}

resource "google_compute_instance" "iot-device-2" {
  name         = "iot-device-2"
  machine_type = "n1-standard-1"
  zone         = "us-east1-b"

  tags = ["demo"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  # Local SSD disk
  scratch_disk {}

  network_interface {
    # link creatd vpc network
    network       = "${google_compute_network.demo-network.self_link}"
    access_config = {}
  }

  metadata_startup_script = "echo hi > /test.txt"

  # service_account {
  #   scopes = ["service-157930433863@compute-system.iam.gserviceaccount.com", "compute-ro", "storage-ro"]
  # }
}

resource "google_compute_instance" "iot-device-3" {
  name         = "iot-device-3"
  machine_type = "n1-standard-1"
  zone         = "europe-west2-a"

  tags = ["demo"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  # Local SSD disk
  scratch_disk {}

  network_interface {
    # link creatd vpc network
    network       = "${google_compute_network.demo-network.self_link}"
    access_config = {}
  }

  metadata_startup_script = "echo hi > /test.txt"

  # service_account {
  #   scopes = ["service-157930433863@compute-system.iam.gserviceaccount.com", "compute-ro", "storage-ro"]
  # }
}

resource "google_compute_network" "demo-network" {
  name                    = "demo-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "ssh-access-firewall" {
  name        = "ssh-access-firewall"
  description = "allow ssh access to VM within the project"
  network     = "${google_compute_network.demo-network.self_link}"
  direction   = "INGRESS"

  # need to configure ssh access from a variable IP address I'll specify
  # IP address must be ignored in git repo
  # tie the ssh access to a service account and ingress any IP range

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

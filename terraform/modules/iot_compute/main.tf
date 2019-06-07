resource "google_compute_instance" "iot-device-1" {
  name         = var.device_name_1
  machine_type = var.machine_type
  zone         = var.device_name_1_zone

  tags = [var.version_label]

  boot_disk {
    initialize_params {
      image = var.os_image
    }
  }

  # Local SSD disk
  scratch_disk {
  }

  network_interface {
    # link creatd vpc network
    network = google_compute_network.demo-network.self_link
    access_config {
    }
  }

  metadata_startup_script = <<SCRIPT
  ${file("${path.module}/startup_script.sh")}
  SCRIPT

  service_account {
    email = var.service_account_email
    scopes = var.service_account_scopes
  }
}

resource "google_compute_instance" "iot-device-2" {
  name = var.device_name_2
  machine_type = var.machine_type
  zone = var.device_name_2_zone

  tags = [var.version_label]

  boot_disk {
    initialize_params {
      image = var.os_image
    }
  }

  # Local SSD disk
  scratch_disk {
  }

  network_interface {
    # link creatd vpc network
    network = google_compute_network.demo-network.self_link
    access_config {
    }
  }

  metadata_startup_script = <<SCRIPT
  ${file("${path.module}/startup_script.sh")}
  SCRIPT

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }
}

resource "google_compute_instance" "iot-device-3" {
  name         = var.device_name_3
  machine_type = var.machine_type
  zone         = var.device_name_3_zone

  tags = [var.version_label]

  boot_disk {
    initialize_params {
      image = var.os_image
    }
  }

  # Local SSD disk
  scratch_disk {
  }

  network_interface {
    # link creatd vpc network
    network = google_compute_network.demo-network.self_link
    access_config {
    }
  }

  metadata_startup_script = <<SCRIPT
  ${file("${path.module}/startup_script.sh")}
  SCRIPT

  service_account {
    email = var.service_account_email
    scopes = var.service_account_scopes
  }
}

resource "google_compute_network" "demo-network" {
  name = var.network_name
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "ssh-access-firewall" {
  name = var.firewall_ssh_name
  description = "allow ssh access to VM within the project"
  network = google_compute_network.demo-network.self_link
  direction = "INGRESS"

  # need to configure ssh access from a variable IP address I'll specify
  # IP address must be ignored in git repo
  # tie the ssh access to a service account and ingress any IP range

  allow {
    protocol = var.allow_protocol
    ports = var.allow_ports
  }
}


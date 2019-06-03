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
  scratch_disk {
  }

  network_interface {
    # link creatd vpc network
    network = google_compute_network.demo-network.self_link
    access_config {
    }
  }

  metadata_startup_script = <<SCRIPT
    #define temporary environment path variables
    iot_directory="/home/sungwon_chung1/iot"
    files_directory="/training-data-analyst/quests/iotlab/"
    demo_directory="$iot_directory$files_directory"

    #update the system information about Debian Linux package repositories
    sudo apt-get update

    #install in scope packages
    sudo apt-get install python-pip openssl git git-core -y

    #use pip for needed Python components
    sudo pip install pyjwt paho-mqtt cryptography

    #make a new directory
    sudo mkdir $iot_directory

    #add data to analyze
    cd $iot_directory; git clone https://github.com/GoogleCloudPlatform/training-data-analyst.git

    #create RSA cryptographic keypair
    cd $demo_directory
    sudo openssl req -x509 -newkey rsa:2048 -keyout rsa_private.pem \
    -nodes -out rsa_cert.pem -subj "/CN=unused"

    #download the CA root certificates from pki.google.com to the appropriate directory
    sudo wget https://pki.google.com/roots.pem
    SCRIPT

  service_account {
    email = "demo-service-account@iconic-range-220603.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_instance" "iot-device-2" {
  name = "iot-device-2"
  machine_type = "n1-standard-1"
  zone = "us-east1-b"

  tags = ["demo"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
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
    email  = "demo-service-account@iconic-range-220603.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

resource "google_compute_instance" "iot-device-3" {
  name = "iot-device-3"
  machine_type = "n1-standard-1"
  zone = "europe-west2-a"

  tags = ["demo"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
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

  metadata_startup_script = "terraform/modules/iot_compute/startup_script.sh"
  # service_account {
  #   scopes = ["service-157930433863@compute-system.iam.gserviceaccount.com", "compute-ro", "storage-ro"]
  # }
}

resource "google_compute_network" "demo-network" {
  name = "demo-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "ssh-access-firewall" {
  name = "ssh-access-firewall"
  description = "allow ssh access to VM within the project"
  network = google_compute_network.demo-network.self_link
  direction = "INGRESS"

  # need to configure ssh access from a variable IP address I'll specify
  # IP address must be ignored in git repo
  # tie the ssh access to a service account and ingress any IP range

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
}


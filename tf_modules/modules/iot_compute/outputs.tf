output "iot-device-1-metadata" {
  value = google_compute_instance.iot-device-1.name
}

output "iot-device-2-metadata" {
  value = google_compute_instance.iot-device-2.name
}

output "iot-device-3-metadata" {
  value = google_compute_instance.iot-device-3.name
}

output "vpc-network-metadata" {
  value = google_compute_network.demo-network.name
}

output "ssh-access-firewall-metadata" {
  value = google_compute_firewall.ssh-access-firewall.name
}

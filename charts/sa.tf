provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Create health check
resource "google_compute_health_check" "default" {
  name               = "example-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2

  http_health_check {
    port = 80
    request_path = "/"
  }
}

# Reference to an existing instance group
data "google_compute_instance_group" "default" {
  name = "example-instance-group"
  zone = "us-central1-a"
}

# Backend service
resource "google_compute_backend_service" "default" {
  name                            = "example-backend-service"
  protocol                        = "HTTP"
  port_name                       = "http"
  timeout_sec                     = 10
  connection_draining_timeout_sec = 0
  health_checks                   = [google_compute_health_check.default.self_link]
  load_balancing_scheme           = "EXTERNAL"

  backend {
    group = data.google_compute_instance_group.default.self_link
    balancing_mode = "UTILIZATION"
    max_utilization = 0.8
  }
}

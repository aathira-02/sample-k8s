resource "google_container_cluster" "pci_gke_cluster" {
  name       = var.cluster_name
  location   = var.region
  project    = var.project_id

  network    = local.network
  subnetwork = local.subnetwork

  initial_node_count  = var.initial_node_count
  deletion_protection = var.gke_cluster_deletion_protection
  enable_autopilot    = true

  resource_labels = {
    "mesh_id" = "proj-${var.project_id}"
  }

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account    = module.gke_node_sa.service_account_email
      boot_disk_kms_key  = module.kms_gke_boot_enc_layer.key_id
    }
  }

  binary_authorization {
    evaluation_mode = var.enable_binary_authorization
  }

  release_channel {
    channel = var.release_channel
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  database_encryption {
    state     = "ENCRYPTED"
    key_name  = module.kms_gke_app_layer.key_id
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.gke_master_ipv4_cidr_block

    master_global_access_config {
      enabled = var.global_access
    }
  }

  master_authorized_networks_config {
    cidr_blocks = [
      {
        cidr_block   = "10.10.0.0/24"
        display_name = "admin-network"
      },
      {
        cidr_block   = "192.168.100.0/24"
        display_name = "corp-network"
      }
    ]
  }

  security_posture_config {
    vulnerability_mode = "VULNERABILITY_ENTERPRISE"
  }

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
      "APISERVER",
      "CONTROLLER_MANAGER",
      "SCHEDULER"
    ]
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }

    recurring_window {
      start_time = "2025-10-01T03:00:00Z"
      end_time   = "2025-10-01T06:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=MO"
    }

    maintenance_exclusion {
      exclusion_name = "holiday-exclusion"
      start_time     = "2025-12-25T00:00:00Z"
      end_time       = "2025-12-26T00:00:00Z"
    }
  }
}

resource "google_gke_hub_membership" "membership" {
  membership_id = var.fleet_membership_type
  location      = var.region
  project       = var.project_id

  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.pci_gke_cluster.id}"
    }
  }

  depends_on = [
    google_container_cluster.pci_gke_cluster
  ]
}

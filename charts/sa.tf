resource "google_service_account" "service_accounts" {
  for_each = var.service_accounts

  account_id   = each.key
  display_name = each.value.description
  project      = var.project_id
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = {
    for sa_name, sa in var.service_accounts : 
    for role in sa.roles : 
    "${sa_name}-${role}" => {
      sa_email = "${sa_name}@${var.project_id}.iam.gserviceaccount.com"
      role     = role
    }
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.sa_email}"
}





project_id = "gpcp2p-q-pymt"

service_accounts = {
  "gke-sa" = {
    description = "Service account for GKE"
    roles = [
      "roles/container.nodeServiceAccount",
      "roles/logging.logWriter"
    ]
  }

  "cloudbuild-sa" = {
    description = "Service account for Cloud Build"
    roles = [
      "roles/cloudbuild.builds.editor",
      "roles/storage.admin"
    ]
  }

  "monitoring-sa" = {
    description = "Monitoring service account"
    roles = [
      "roles/monitoring.viewer",
      "roles/logging.viewer"
    ]
  }
}


variable "project_id" {
  description = "Project ID where the service accounts will be created"
  type        = string
}

variable "service_accounts" {
  description = <<EOF
Map of service accounts with roles. Example:
{
  "gke-sa" = {
    description = "Service account for GKE"
    roles       = [
      "roles/container.nodeServiceAccount",
      "roles/logging.logWriter"
    ]
  },
  "cloudbuild-sa" = {
    description = "Service account for Cloud Build"
    roles       = [
      "roles/cloudbuild.builds.editor",
      "roles/storage.admin"
    ]
  }
}
EOF
  type = map(object({
    description = string
    roles       = list(string)
  }))
}

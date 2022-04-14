resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/editor"

  members = [
    "user:javioreto@gmail.com",
    "serviceAccount:steady-tape-345517@appspot.gserviceaccount.com",
    "serviceAccount:195566316688@cloudservices.gserviceaccount.com"
  ]
}

#####################################################################
############################ Segunda Parte ##########################
#####################################################################

### Bucket to export google and cloud data bases.
module "cloud-storage" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "3.1.0"
  # insert the 3 required variables here
  project_id = var.project_id
  names      = ["cloud_sql_backup_jean_flores"]
  prefix     = "bkt"
  location   = "US"
  labels = {
    "name" = "bkt-us-cloud_sql_backup_jean_flores"
  }
}

### Cloud SQL instance
resource "google_sql_database_instance" "master" {
  name                = "master-instance"
  database_version    = "MYSQL_5_7"
  region              = var.region
  project             = var.project_id
  deletion_protection = false

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    user_labels = {
      "created_by" = "terraform"
    }
    backup_configuration {
      binary_log_enabled = true
      enabled            = true
      ### Start time 12:00 in UTC-5
      start_time                     = "17:00"
      transaction_log_retention_days = 7
    }
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name = "12me"
        ### My IP
        value = "161.132.235.229"
      }
      authorized_networks {
        name = "cloudshell"
        ### My IP
        value = "35.196.11.81"
      }
    }
  }
}

### Users for cloud sql
resource "google_sql_user" "users" {
  for_each = var.mysql_users
  name     = each.value.name
  instance = each.value.instance
  password = each.value.pwd
  project  = var.project_id
}

### Databases for cloud sql
resource "google_sql_database" "database" {
  for_each = toset(var.databases)
  name     = each.key
  project  = var.project_id
  instance = google_sql_database_instance.master.name
}


#####################################################################
############################ Tercera Parte ##########################
#####################################################################

### Image with apache installed
data "google_compute_image" "my_image" {
  name    = "ubuntu-apache"
  project = var.project_id
}

# resource "google_compute_network" "vpc_network" {
#   name = "new-terraform-network"
# }


# ### Get default network
data "google_compute_network" "my-network" {
  name    = "default"
  project = var.project_id
}

### Instance template
resource "google_compute_instance_template" "default" {
  name        = "appserver-template"
  description = "This template is used to create app server instances."
  project     = var.project_id

  tags = ["http-server", "https-server", "allow-lb-service"]

  labels = {
    created_by = "terraform"
  }

  instance_description = "description assigned to instances"
  machine_type         = "n1-standard-1"
  can_ip_forward       = true

  // Create a new boot disk from an image
  disk {
    source_image = data.google_compute_image.my_image.self_link
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    # network = google_compute_network.vpc_network.name
    access_config {}
  }

  metadata = {
    foo = "bar"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.service_account
    scopes = ["cloud-platform", "userinfo-email", "compute-ro", "storage-ro"]
  }
}

### Compute target pool
resource "google_compute_target_pool" "target_pool" {
  name    = "my-target-pool"
  project = var.project_id
  region  = var.region
}

### Instance group manager
resource "google_compute_instance_group_manager" "instance_group_manager" {
  project = var.project_id
  name    = "instance-group-manager"
  base_instance_name = "instance-group-manager"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.default.self_link
    name              = "primary"
  }

  target_pools = [google_compute_target_pool.target_pool.self_link]
}

## Autoscaler
resource "google_compute_autoscaler" "autoscaler" {
  project = var.project_id
  name    = "my-autoscaler"
  zone    = var.zone
  target  = google_compute_instance_group_manager.instance_group_manager.self_link

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 0
    cooldown_period = 60

    cpu_utilization {
      target = 0.02
    }
  }
}

### Create load balancer
module "lb" {
  source       = "GoogleCloudPlatform/lb/google"
  version      = "2.2.0"
  project      = var.project_id
  region       = var.region
  name         = "load-balancer"
  service_port = 80
  target_tags  = ["my-target-pool"]
  network      = data.google_compute_network.my-network.name
  ip_protocol  = "TCP"
  # allowed_ips  = ["0.0.0.0/0"]
}
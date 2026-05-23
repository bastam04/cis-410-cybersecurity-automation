terraform {
  required_version = ">= 1.6"

  backend "gcs" {
    bucket = "cis410-btamer-tfstate"
    prefix = "terraform/week8"
  }

  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "terraform_remote_state" "week7" {
  backend = "gcs"
  config = {
    bucket = "cis410-btamer-tfstate"
    prefix = "terraform/week7"
  }
}

resource "google_cloud_run_v2_service" "flask_app" {
  name     = "cis410-flask-app"
  location = var.region

  template {
    containers {
      image = var.container_image
      ports { container_port = 5000 }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.week7.outputs.vpc_name
        subnetwork = data.terraform_remote_state.week7.outputs.subnet_name
      }
      egress = "PRIVATE_RANGES_ONLY"
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.flask_app.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}


resource "google_app_engine_application" "app" {
  project       = var.project_id
  location_id   = "us-central"
  database_type = "CLOUD_DATASTORE_COMPATIBILITY"
}

resource "google_storage_bucket" "bucket" {
  name     = "keepcoding-jean-flores-appengine-static-content1"
  location = "US"
  project  = var.project_id
}

resource "google_storage_bucket_object" "object" {
  name   = "gae.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./gae.zip"
}

resource "google_project_service" "service" {
  project = var.project_id
  service = "appengineflex.googleapis.com"

  disable_dependent_services = false
}

resource "google_project_iam_member" "gae_api" {
  project = google_project_service.service.project
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-195566316688@gae-api-prod.google.com.iam.gserviceaccount.com"
}

resource "google_app_engine_standard_app_version" "myapp_v1" {
  project             = var.project_id
  version_id          = "v1"
  service             = "default"
  runtime             = "python27"
  runtime_api_version = "1"

  entrypoint {
    shell = "python ./gae/main.py"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.bucket.name}/${google_storage_bucket_object.object.name}"
    }
  }

  env_variables = {
    CLOUDSQL_CONNECTION_NAME = "steady-tape-345517:us-central1:master-instance"
    CLOUDSQL_USER            = "alumno"
    CLOUDSQL_PASSWORD        = "googlecloud"
  }

  delete_service_on_destroy = true

  handlers {
    # url_regex = ".*"
    url_regex                   = "/.*"
    redirect_http_response_code = "REDIRECT_HTTP_RESPONSE_CODE_301"
    security_level              = "SECURE_ALWAYS"
    auth_fail_action            = "AUTH_FAIL_ACTION_REDIRECT"
    login                       = "LOGIN_OPTIONAL"
    script {
      script_path = "./gae/main.py"
    }
  }

  libraries {
    name = "webapp2"
  }

  libraries {
    name    = "MySQLdb"
    version = "latest"
  }
  libraries {
    name = "MySQL-python"
  }
}

resource "google_app_engine_standard_app_version" "practica" {
    project = var.project_id
    version_id = "version-1-0-0"
    service = "practica"
    runtime = "python27"
    runtime_api_version = "1"

    entrypoint {
      shell = "python ./gae/main.py"
    }

    deployment {
      zip {
        source_url = "https://storage.googleapis.com/${google_storage_bucket.bucket.name}/${google_storage_bucket_object.object.name}"
      }
    }

  env_variables = {
    CLOUDSQL_CONNECTION_NAME = "steady-tape-345517:us-central1:master-instance"
    CLOUDSQL_USER="alumno"
    CLOUDSQL_PASSWORD="googlecloud"
  }

    delete_service_on_destroy = true

    handlers {
        # url_regex = ".*"
        url_regex = "/.*"
        redirect_http_response_code = "REDIRECT_HTTP_RESPONSE_CODE_301"
        security_level              = "SECURE_ALWAYS"
        auth_fail_action            = "AUTH_FAIL_ACTION_REDIRECT"
        login                       = "LOGIN_OPTIONAL"
        script {
          script_path = "./gae/main.py"
        }
    }

    libraries {
      name = "webapp2"
      version = "latest"
    }

    libraries {
      name = "MySQLdb"
      version = "latest"
    }
    libraries {
      name = "MySQL-python"
      version = "latest"
    }
}

resource "google_app_engine_standard_app_version" "practica1" {
    project = var.project_id
    version_id = "version-2-0-0"
    service = "practica"
    runtime = "python27"
    runtime_api_version = "1"

    entrypoint {
      shell = "python ./gae/main.py"
    }

    deployment {
      zip {
        source_url = "https://storage.googleapis.com/${google_storage_bucket.bucket.name}/${google_storage_bucket_object.object.name}"
      }
    }

  env_variables = {
    CLOUDSQL_CONNECTION_NAME = "steady-tape-345517:us-central1:master-instance"
    CLOUDSQL_USER="alumno"
    CLOUDSQL_PASSWORD="googlecloud"
  }

    delete_service_on_destroy = true

    handlers {
        # url_regex = ".*"
        url_regex = "/.*"
        redirect_http_response_code = "REDIRECT_HTTP_RESPONSE_CODE_301"
        security_level              = "SECURE_ALWAYS"
        auth_fail_action            = "AUTH_FAIL_ACTION_REDIRECT"
        login                       = "LOGIN_OPTIONAL"
        script {
          script_path = "./gae/main.py"
        }
    }

    libraries {
      name = "webapp2"
      version = "latest"
    }

    libraries {
      name = "MySQLdb"
      version = "latest"
    }
    libraries {
      name = "MySQL-python"
      version = "latest"
    }
}

resource "google_app_engine_service_split_traffic" "liveapp" {
    project = var.project_id
    service = google_app_engine_standard_app_version.practica1.service

    migrate_traffic = false

    split {
        shard_by = "RANDOM"
        allocations = {
            ( google_app_engine_standard_app_version.practica1.version_id) = 0.5
            ( google_app_engine_standard_app_version.practica.version_id) = 0.5
        }
    }
}
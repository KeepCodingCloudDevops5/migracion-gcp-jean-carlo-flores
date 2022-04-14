variable "project_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "mysql_users" {
  type        = map(any)
  description = "(optional) describe your variable"
  default = {
    key1 = "val1"
    key2 = "val2"
  }
}

variable "databases" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type = string
  default = "us-central1-a"
}

variable "service_account" {
  type = string
  default = "195566316688-compute@developer.gserviceaccount.com"
}
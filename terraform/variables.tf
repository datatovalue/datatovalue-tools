variable "project_id" {
  type        = string
  description = "The name of the GCP Project."
}

variable "regions" {
  type        = list(string)
  description = "The list of deployment regions."
}

variable "release_version" {
  type        = string
  description = "The semantic version of the latest deployed function."
}
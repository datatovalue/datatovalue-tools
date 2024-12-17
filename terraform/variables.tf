variable "project_id" {
  type        = string
  description = "The name of the GCP Project"
}

variable "regions" {
  type        = list(string)
  description = "The list of deployment regions"
}

variable "release_version" {
  type        = string
  description = "The version of the deployed function set in the form 1.0.0 etc."
}
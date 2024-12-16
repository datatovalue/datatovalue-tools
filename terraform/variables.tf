variable "project_id" {
  type        = string
  description = "The name of the GCP Project"
}

variable "regions" {
  type        = list(string)
  description = "The list of deployment regions"
}

variable "region_master" {
  type        = string
  description = "The source region from which to deploy code across regions"
}
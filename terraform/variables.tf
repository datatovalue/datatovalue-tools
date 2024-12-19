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

variable "template_project_id" {
  type        = string
  description = "The name of the GCP Project used for SQL teamplates."
}

variable "template_dataset_id" {
  type        = string
  description = "The name of the dataset used for SQL teamplates."
}
variable "services" {
  type = list(string)
  description = "A list of services that should be enabled."
  default = ["compute.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com", 
    "containerregistry.googleapis.com",
	"container.googleapis.com"]
}

variable "project_id" {
  type = string
  description = "The id of the GCP project Terraform should run and create resources on."
}

variable "region" {
  type = string
  description = "The GCP region (ex.: for creating resources)."
}

variable "zone" {
  type = string
  description = "The GCP zone (ex.: for creating resources)."
}

variable "cluster_name" {
  type = string
  description = "The name of the cluster."
}

variable "node_pool_name" {
  type = string
  description = "The name of the node pool."
}

variable "network_name" {
  type = string
  description = "The name of the network."
}

variable "subnetwork_name" {
  type = string
  description = "The name of the subnetwork."
}
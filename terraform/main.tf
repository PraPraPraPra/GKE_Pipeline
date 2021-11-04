#TODO: Need to describe vars!
#TODO: Find someway to store usefull docs and explainations without crowding the code
#TODO: Should there be a step-by-step walkthrough on what everything does?
terraform {
  #https://www.terraform.io/docs/language/providers/requirements.html
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

#Set provider
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference
provider "google" {
  project = var.project_id
  # WHY do we need region here if projects have no regions?
  region  = var.region
  zone    = var.zone
  
  #WHY are we enabling batching?
  batching{
    enable_batching = false
  }
}

#Activate a list of Google Services that are needed
#https://www.terraform.io/docs/language/resources/syntax.html
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
#https://www.terraform.io/docs/language/meta-arguments/for_each.html
resource "google_project_service" "gp-service" {

  #WHY am I converting to set (from string) instead of just having the var as a set?
  for_each = toset( var.services )

  project = var.project_id
  service = each.key

  #WHY is disable_on_destroy = false?
  disable_on_destroy = false
}


resource "google_compute_network" "network" {
  name = "fernando-network12345"
  project = var.project_id

  auto_create_subnetworks = false

  depends_on = [
    google_project_service.gp-service,
  ]

}


resource "google_compute_subnetwork" "subnetwork" {
  name = "fernando-subnetwork12345"
  project = var.project_id

  ip_cidr_range = "10.2.0.0/24"
  region = var.region

  network = google_compute_network.network.id


  depends_on = [
    google_project_service.gp-service,
  ]

}


resource "google_container_cluster" "container_cluster" {
  name = var.cluster_name
  location = var.zone

  network = google_compute_network.network.id
  subnetwork = google_compute_subnetwork.subnetwork.id

  #You can't create a Cluster with 0 nodes, so you just create one with the minimum amount
  #and then delete them.
  remove_default_node_pool = true
  initial_node_count = 1

  depends_on = [
    google_project_service.gp-service,
  ]
}


resource "google_container_node_pool" "container_node_pool" {
  name = var.node_pool_name
  location = var.zone

  cluster = google_container_cluster.container_cluster.name
  #node_count should be 2. I'm using 1 to save resources: should still work fine.
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-medium"
    
    #Why is oauth_scopes here? I really should understand why.
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    #disable-legacy-endpoints is already true... Right? Should look this up.
    metadata = {
      disable-legacy-endpoints = true    
    }

  }

}
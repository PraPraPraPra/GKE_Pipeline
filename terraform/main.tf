terraform {
#https://www.terraform.io/docs/language/providers/requirements.html
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference
provider "google" {

  project = vars.project_id
  region  = vars.region
  zone    = vars.zone

  batching {
      enable_batching = false
  }
}
#https://www.terraform.io/docs/language/resources/syntax.html
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
#https://www.terraform.io/docs/language/meta-arguments/for_each.html
resouce "google_project_service" "gp-service"{
  project = vars.project_id
  
  #for_each accepts a MAP or a SET
  for_each = vars.services_list
  service = each.value

  disable_on_destroy = false
}
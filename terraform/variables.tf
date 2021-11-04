variable "services_list" {
  type = list(string)
  default = ["compute.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com", 
    "containerregistry.googleapis.com",
	"container.googleapis.com"]
}
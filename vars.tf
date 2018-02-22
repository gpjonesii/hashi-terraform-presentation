variable "location" {
    description = "Azure Region all resources will be deployed to"
    default = "US East 2"
}

variable "environment" {
    description = "Deployment Environment for Tags"
    default = "development"
}
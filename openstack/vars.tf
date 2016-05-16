variable "count" {
  default = 2
}

variable "user_name" {
    description = "Openstack username."
}

variable "password" {
    description = "Openstack password."
}

variable "tenant_name" {
    description = "Openstack Tenant name."
}

variable "domain_name" {
    description = "Openstack Tenant name."
    default = "default"
}

variable "auth_url" {
    description = "Openstack keystone URL."
}

variable "region" {
    description = "Openstack region name."
    default = "RegionOne"
}

variable "image_id" {
    description = "Openstack image id."
    default = "b4e4e429-2b63-48fe-b885-855211cdf4e8"
}

variable "flavor_id" {
    description = "Openstack flavor id."
    default = "2"
}

variable "key_pair" {
    description = "Openstack key pair name."
}

variable "network" {
    description = "Openstack network."
}

variable "key_file" {
    description = "SSH private key file path"
}

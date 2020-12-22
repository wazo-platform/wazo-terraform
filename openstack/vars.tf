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

variable "endpoint_type" {
    description = "Openstack endpoint type use from service catalog."
    default = "internal"
}

variable "region" {
    description = "Openstack region name."
    default = "RegionOne"
}

variable "image_id" {
    description = "Openstack image id."
    default = "b99574c3-33f5-4e3b-a5a6-e284cc0dcc4e"
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

variable "availability_zone" {
    description = "Openstack availability zone."
}

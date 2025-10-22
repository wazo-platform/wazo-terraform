variable "names_prefix" {
  description = "Prefix to add to all names of managed resources"
  type        = string
  default     = ""
}

variable "region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "subnet_id" {
  description = "ID of your subnet to use in EC2."
}

variable "public_stacks" {
  description = "If True stacks will be reachable from internet"
  type        = bool
  default     = false
}

variable "additional_allowed_cidr_ranges" {
  description = "List of CIDR to add as allowed to reach stacks"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "Instance type in AWS."
  default     = "t3a.medium"
}

variable "vpc_id" {
  description = "ID of the VPC to use."
}

variable "amazon_ami_name_filter" {
  description = "Filter to apply on names to retrieve AMI"
  type        = string
  default     = "debian-12*"
}

variable "amazon_ami_architecture" {
  description = "Which architecture to filter ami on. Should be coherent with instance_type variable."
  type        = string
  default     = "x86_64"
}

variable "nb_instances" {
  description = "Number of Wazo instances to create."
  default     = 2
}

variable "public_key_path" {
  description = "Path to ssh public key file to use to deploy instances."
  type        = string
}

variable "private_key_path" {
  description = "Path to ssh private key file to use to deploy instances."
  type        = string
}

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

variable "bastion_host" {
  description = "Address of the SSH jumphost used to reach the instances. When set, instances are provisioned through it using their private IP."
  type        = string
  default     = null
}

variable "bastion_user" {
  description = "User to connect with on the SSH jumphost. Defaults to the user used on the instances."
  type        = string
  default     = null
}

variable "bastion_port" {
  description = "SSH port of the jumphost. Defaults to 22."
  type        = number
  default     = null
}

variable "bastion_private_key_path" {
  description = "Path to the ssh private key file to use to connect to the jumphost. Defaults to private_key_path."
  type        = string
  default     = null
}

variable "bastion_host_key" {
  description = "Public key from the jumphost to verify it against. Defaults to no verification."
  type        = string
  default     = null
}

variable "cloud_config_files" {
  description = "Cloud-config files to append to wazo instance cloud-config."
  type        = list(string)
  default     = []
}

variable "install_script_path" {
  description = "Path to the install script to upload and run on instances. Defaults to the bundled wazo-platform install script."
  type        = string
  default     = null
}

variable "wazo_version" {
  description = "Version of Wazo to install, e.g. \"26.08\". Installs the wazo-<version> tag of wazo-ansible and pins the engine packages to the frozen wazo-<version> distribution of the archive repository. Defaults to the latest development version."
  type        = string
  default     = null

  validation {
    condition     = var.wazo_version == null || var.wazo_version == "" || can(regex("^[0-9]{2}\\.[0-9]{2}(\\.[0-9]+)?$", var.wazo_version))
    error_message = "The wazo_version value must be a Wazo version such as \"26.08\" or \"26.08.1\", without the \"wazo-\" prefix."
  }
}

variable "install_script_args" {
  description = "Arguments to pass to the install script."
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Size of the instances root volume in GiB. Defaults to the AMI snapshot size."
  type        = number
  default     = null
}

variable "ha_mode" {
  description = "Enable automatic ha configuration between created instances. Will need 2 instance to work."
  type        = bool
  default     = false
}

variable "custom_security_group_id" {
  type    = string
  default = null
}

variable "custom_security_group" {
  type    = bool
  default = false
}

variable "enable_root_password" {
  type    = bool
  default = false
}

variable "root_password" {
  sensitive = true
  type      = string
  default   = ""
}

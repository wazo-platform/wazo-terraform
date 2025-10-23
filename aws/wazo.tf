provider "aws" {
  region = var.region
}

module "wazo" {
  source                         = "../modules/aws"
  names_prefix                   = var.names_prefix
  region                         = var.region
  subnet_id                      = var.subnet_id
  public_stacks                  = var.public_stacks
  additional_allowed_cidr_ranges = var.additional_allowed_cidr_ranges
  instance_type                  = var.instance_type
  vpc_id                         = var.vpc_id
  amazon_ami_name_filter         = var.amazon_ami_name_filter
  amazon_ami_architecture        = var.amazon_ami_architecture
  nb_instances                   = var.nb_instances
  public_key_path                = var.public_key_path
  private_key_path               = var.private_key_path
  ha_mode                        = true
}

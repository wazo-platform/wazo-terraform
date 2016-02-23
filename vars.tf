variable "access_key" {
    description = "AWS access key."
}

variable "secret_key" {
    description = "AWS secret key."
}

variable "region" {
    description = "The AWS region to create things in."
    default = "us-east-1"
}

variable "key_name" {
    description = "Name of the keypair to use in EC2."
}

variable "subnet_id" {
    description = "Name of your subnet ID to use in EC2."
}

variable "private_key" {
    description = "Path to your private key."
}

variable "instance_type" {
    description = "Instance type in AWS."
    default = "t2.micro"
} 

variable "vpc_id" {
    description = "VPC ID"
}

variable "amazon_amis" {
    description = "Amazon Linux Debian AMIs"
    default = {
        us-east-1 = "ami-8b9a63e0"
    }
}

variable "count" {
  default = 2
}

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

variable "private_subnets" {
  default = "10.20.1.0/24"
}

variable "private_subnets2" {
  default = "10.20.3.0/24"
}


variable "public_subnets" {
  default = "10.20.2.0/24"
}

variable "public_subnets2" {
  default = "10.20.4.0/24"
}


variable "public_az" {
  default = "us-east-1a"
}

variable "public_az2" {
  default = "us-east-1c"
}



variable "private_az" {
  default = "us-east-1b"
}

variable "private_az2" {
  default = "us-east-1d"
}


variable "instance_type" {
  default = "t2.micro"
}

variable "public_key_path" {
  default = "/Users/rbhar1/.ssh/id_rsa.pub"
}

# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=

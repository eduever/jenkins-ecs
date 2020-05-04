provider "aws" {
  region  = var.aws_region
  profile = "nzbadmin"
}

terraform {
  required_version = ">= 0.12"
}

############# backend ##################

terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-infra-automation04"
    region         = "us-east-1"
    key            = "terraform-state-files/main.tfstate"
    dynamodb_table = "terraform-state-locking04"
  }
}

############# VPC ####################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  enable_classiclink   = "false"
  instance_tenancy     = "default"
  tags = {
    env = "test"
  }
}

############# SUBNETS ####################

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = var.public_az
  tags = {
    env = "test"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets2
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = var.public_az2
  tags = {
    env = "test"
  }
}


resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets
  map_public_ip_on_launch = "false" //it makes this a public subnet
  availability_zone       = var.private_az
  tags = {
    env = "test"
  }
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets2
  map_public_ip_on_launch = "false" //it makes this a public subnet
  availability_zone       = var.private_az2
  tags = {
    env = "test"
  }
}


############# IG ####################


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    env = "test"
  }
}

############# SECURITY GROUPS ####################

resource "aws_security_group" "ssh_allowed" {
  vpc_id = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["71.59.236.132/32"] // This means, all ip address are allowed to ssh ! 
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["71.59.236.132/32"] // This means, all ip address are allowed to ssh ! 
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["71.59.236.132/32"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["71.59.236.132/32"]
  }
  tags = {
    env = "test"
  }
}


############# ROUTE TABLES ####################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    env = "test"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    env = "test"
  }
}

############# ROUTE TABLE ASSOICATIONS ####################

resource "aws_route_table_association" "public_rt_ass" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_rt_ass2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private_rt_ass" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_rt_ass2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}


###################### Key pair #######################

resource "aws_key_pair" "auth" {
  key_name   = "id_rsa"
  public_key = file(var.public_key_path)
}

###################### EC2 Instance #######################
resource "aws_iam_instance_profile" "instance_profile" {
  name = "jenkins_instance_profile"
  role = aws_iam_role.iam_role_name.name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2-instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.ssh_allowed.id}"]
  subnet_id              = aws_subnet.public.id
  tags = {
    Terraform = "true"
    product   = "jenkins"
    env       = "test"
  }
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  key_name             = "id_rsa"
}

output "instance_ips" {
  value = ["${aws_instance.ec2-instance.*.public_ip}"]
}

###############  IAM ROLE & POLICY #######################

resource "aws_iam_role" "iam_role_name" {
  name               = "tf-jenkins-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    environment = "test"
  }
}

resource "aws_iam_role_policy" "iam_role_policy" {
  name   = "tf-jenkins-role-policy"
  role   = aws_iam_role.iam_role_name.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ecr:*",
            "Resource": "arn:aws:ecr:*:175546642044:repository/myapp-ecr-repo"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ecs:*",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::terraform-infra-automation04"
        }
    ]
}EOF
}

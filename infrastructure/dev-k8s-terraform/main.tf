provider "aws" {
  region = "us-east-1a"
}

variable "sec-gr-k8s" {
  default = "petclinic-k8s-sec-group-13-tr"
}

variable "subnet-id" {
  default = "subnet-0299c3444e01c3cc6"
}

variable "ami-id" {
  default = "ami-005fc0f236362e99f"
}

data "aws_vpc" "name" {
  default = true
}

resource "aws_security_group" "k8s-sec-gr" {
  name = var.sec-gr-k8s
  vpc_id = data.aws_vpc.name.id
  tags = {
    Name = var.sec-gr-k8s
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  ingress {
    from_port = 30000
    to_port = 32767
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "petclinic-master-server-s3-role" {
  name               = "petclinic-master-server-role"
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

}

resource "aws_iam_role_policy_attachment" "petclinic_s3_policy" {
  role       = aws_iam_role.petclinic-master-server-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "petclinic-master-server-profile" {
  name = "petclinic-master-server-profile"
  role = aws_iam_role.petclinic-master-server-s3-role.name
}

resource "aws_instance" "kube-master" {
    ami = var.ami-id
    instance_type = "t3a.medium"
    iam_instance_profile = aws_iam_instance_profile.petclinic-master-server-profile.name
    vpc_security_group_ids = [ aws_security_group.k8s-sec-gr.id ]
    key_name = "clarus"
    subnet_id = var.subnet-id
    availability_zone = "us-east-1a"
    tags = {
        Name = "kube-master"
        Project = "tera-kube-ans"
        Role = "master"
        Id = "1"
        environment = "dev"
    }  
}

resource "aws_instance" "worker-1" {
    ami = var.ami-id
    instance_type = "t3a.medium"
    iam_instance_profile = aws_iam_instance_profile.petclinic-master-server-profile.name
    vpc_security_group_ids = [ aws_security_group.k8s-sec-gr.id ]
    key_name = "clarus"
    subnet_id = var.subnet-id
    availability_zone = "us-east-1a"
    tags = {
        Name = "worker-1"
        Project = "tera-kube-ans"
        Role = "worker"
        Id = "1"
        environment = "dev"
    }  
}

resource "aws_instance" "worker-2" {
    ami = var.ami-id
    instance_type = "t3a.medium"
    iam_instance_profile = aws_iam_instance_profile.petclinic-master-server-profile.name
    vpc_security_group_ids = [ aws_security_group.k8s-sec-gr.id ]
    key_name = "clarus"
    subnet_id = var.subnet-id
    availability_zone = "us-east-1a"
    tags = {
        Name = "worker-2"
        Project = "tera-kube-ans"
        Role = "worker"
        Id = "2"
        environment = "dev"
    }  
}

output kube-master-ip {
  value       = aws_instance.kube-master.public_ip
  sensitive   = false
  description = "public ip of the kube-master"
}

output worker-1-ip {
  value       = aws_instance.worker-1.public_ip
  sensitive   = false
  description = "public ip of the worker-1"
}

output worker-2-ip {
  value       = aws_instance.worker-2.public_ip
  sensitive   = false
  description = "public ip of the worker-2"
}
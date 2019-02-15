# Documents networking relevant to the scope of this project - VPC, ACLs, subnets, and security groups

# We're staying within the free tier so I just imported the default VPC to avoid incuring additional costs
resource "aws_vpc" "default" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  lifecycle {
    prevent_destroy = "true"
  }
}

# todo seperate public and private subnets
# query the subnets that are currently available in the default VPC
data "aws_subnet_ids" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# tighten the ACL for enhanced security. This protects against misconfigured security groups
resource "aws_network_acl" "default" {
  vpc_id     = "${aws_vpc.default.id}"
  subnet_ids = ["${data.aws_subnet_ids.default.ids}"]

  # Network Time Protocol (NTP) - we don't want to lose track of time
  egress {
    protocol   = "udp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 123
    to_port    = 123
  }

  ingress {
    protocol   = "udp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 123
    to_port    = 123
  }

  # HyperText Transfer Protocol (HTTP)
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # HyperText Transfer Protocol Secure (HTTPS)
  egress {
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Ephemeral Ports
  egress {
    protocol   = "tcp"
    rule_no    = 900
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 900
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Ephemeral Ports
  egress {
    protocol   = "udp"
    rule_no    = 901
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "udp"
    rule_no    = 901
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
}

# Begin Security Groups
module "security_group_web_traffic" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${module.label_ceros_evaluation.id}-sg-http-web-traffic"
  description = "Security group for load balancer that only allows HTTP traffic through"
  vpc_id      = "${aws_vpc.default.id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "security_group_lb_to_instance" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${module.label_ceros_evaluation.id}-sg-lb-to-instance"
  description = "Security group shared by the load balancer and instances such that they can communicate to each other"
  vpc_id      = "${aws_vpc.default.id}"

  ingress_with_self = [
    {
      rule = "all-all"
    },
  ]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

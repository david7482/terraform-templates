region = "us-east-1"
name = "david74-vpc"
tags = {
  "Environment" = "internal"
  "Purpose" = "test"
}
cidr = "10.1.0.0/16"
azs = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
public_subnets = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24"]
private_subnets = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24", "10.1.14.0/24", "10.1.15.0/24"]
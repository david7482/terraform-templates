region = "us-west-2"
name   = "david74-vpc"
tags = {
  "Environment" = "internal"
  "Purpose"     = "test"
}
cidr            = "10.1.0.0/16"
azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
public_subnets  = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
private_subnets = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
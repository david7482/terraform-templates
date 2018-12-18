region = "ap-northeast-1"
name = "myvpc"
tags = {
  "Environment" = "internal"
  "Purpose" = "test"
}
cidr = "10.0.0.0/16"
azs = ["ap-northeast-1a", "ap-northeast-1c"]
public_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
variable "region" {
  default = "ap-northeast-1"
}

variable "ami" {
  type = "map"

  default = {
    "ap-northeast-1" = "ami-0ad15a5a72c4f8bb6"
    "us-east-1"      = "ami-0fa3a798d9d07f987"
  }
}

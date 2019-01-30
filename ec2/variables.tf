variable "region" {
  default = "ap-northeast-1"
}

variable "ami" {
  type = "map"

  default = {
    "ap-northeast-1" = "ami-044c1940d801a38d6"
    "us-east-1"      = "ami-015a7a34dba7c99d6"
  }
}

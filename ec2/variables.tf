variable "region" {
  default = "ap-northeast-1"
}

variable "ami" {
  type = "map"

  default = {
    "ap-northeast-1" = "ami-0c5c5f2328012a2d4"
    "us-east-1"      = "ami-0a50b5b2d99760cf2"
  }
}

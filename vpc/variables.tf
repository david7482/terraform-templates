variable "region" {
  default = ""
}

variable "name" {
  default = ""
}

variable "tags" {
  type    = "map"
  default = {}
}

variable "cidr" {
  default = "0.0.0.0/0"
}

variable "azs" {
  type    = "list"
  default = []
}

variable "public_subnets" {
  type    = "list"
  default = []
}

variable "private_subnets" {
  type    = "list"
  default = []
}

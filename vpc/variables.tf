variable "region" {
  default = ""
}

variable "name" {
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "cidr" {
  default = "0.0.0.0/0"
}

variable "azs" {
  type    = list(string)
  default = []
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "private_subnets" {
  type    = list(string)
  default = []
}

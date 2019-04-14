variable "region" {
  default = ""
}

variable "env" {
  default = ""
}

variable "cluster_name" {
  default = ""
}

variable "tags" {
  type    = "map"
  default = {}
}

variable "vpc_id" {
  default = ""
}

variable "route53_zone_name" {
  default = "david74.xyz"
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "app_image" {
  default = ""
}

variable "app_port" {
  default = 80
}

variable "app_count" {
  default = 1
}

variable "max_app_count" {
  default = 4
}

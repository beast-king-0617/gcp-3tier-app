variable "project_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "hostname" {
  description = "FQDN covered by the managed certificate."
  type        = string
}

variable "dns_zone_name" {
  description = "Cloud DNS managed zone name for DNS authorization and app A records."
  type        = string
}

variable "labels" {
  type    = map(string)
  default = {}
}

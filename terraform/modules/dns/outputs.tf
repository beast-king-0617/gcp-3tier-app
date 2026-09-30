output "zone_name" {
  value = local.zone_name
}

output "zone_dns_name" {
  value = local.zone_dns_name
}

output "name_servers" {
  description = "NS records to delegate at the registrar when create_zone=true."
  value       = var.create_zone ? google_dns_managed_zone.public[0].name_servers : []
}

output "instances" {
  description = "The GCP instance resources"
  value       = module.instances[*].instance
}

output "names_ips" {
  description = "Hash of name/IP"
  value = merge(module.instances[*].name_ip...)
  # value = merge(
  #   [for v in module.instances : v.name_ip]
  # )
}
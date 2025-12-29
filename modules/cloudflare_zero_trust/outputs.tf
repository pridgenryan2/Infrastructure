output "tunnel_id" {
  value = cloudflare_zero_trust_tunnel.this.id
}

output "tunnel_cname" {
  value = cloudflare_zero_trust_tunnel.this.cname
}

output "access_application_ids" {
  value = { for name, app in cloudflare_zero_trust_access_application.this : name => app.id }
}

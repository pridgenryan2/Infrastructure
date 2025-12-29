terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "= 5.15.0"
    }
  }
}

resource "cloudflare_zero_trust_tunnel" "this" {
  account_id = var.account_id
  name       = var.tunnel_name
  secret     = var.tunnel_secret
}

resource "cloudflare_zero_trust_tunnel_route" "this" {
  for_each = { for route in var.tunnel_routes : route.network => route }

  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel.this.id
  network    = each.value.network
  comment    = try(each.value.comment, null)
}

resource "cloudflare_zero_trust_access_application" "this" {
  for_each = var.access_applications

  account_id       = var.account_id
  zone_id          = var.zone_id
  name             = each.key
  domain           = each.value.domain
  type             = try(each.value.type, "self_hosted")
  session_duration = try(each.value.session_duration, "24h")
}

locals {
  access_policies = {
    for entry in flatten([
      for app_name, app in var.access_applications : [
        for policy in app.policies : {
          key      = "${app_name}:${policy.name}"
          app_name = app_name
          policy   = policy
        }
      ]
    ]) : entry.key => entry
  }
}

resource "cloudflare_zero_trust_access_policy" "this" {
  for_each = local.access_policies

  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.this[each.value.app_name].id
  name           = each.value.policy.name
  decision       = each.value.policy.decision

  include {
    email        = try(each.value.policy.include.emails, [])
    email_domain = try(each.value.policy.include.email_domains, [])
    ip           = try(each.value.policy.include.ips, [])
    group        = try(each.value.policy.include.group_ids, [])
  }

  require {
    email        = try(each.value.policy.require.emails, [])
    email_domain = try(each.value.policy.require.email_domains, [])
    ip           = try(each.value.policy.require.ips, [])
    group        = try(each.value.policy.require.group_ids, [])
  }
}

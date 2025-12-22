terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "= 5.15.0"
    }
  }
}

data "cloudflare_account" "this" {
  filter {
    name = "${var.cloudflare_account_name}-${var.environment}"
  }
}

resource "cloudflare_registrar_domain" "production_primary" {
  account_id = data.cloudflare_account.this.account_id
  domain_name = "siguiente.io"
  auto_renew = true
  locked = true
  privacy = true
}

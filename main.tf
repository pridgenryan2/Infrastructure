terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "= 5.15.0"
    }
  }
}

data "cloudflare_account" "this" {
  filter = {
    name = "Siguiente"
  }
}

resource "cloudflare_registrar_domain" "production" {
  account_id = data.cloudflare_account.this.account_id
  domain_name = "siguiente.io"
  auto_renew = true
  locked = true
  privacy = true
}



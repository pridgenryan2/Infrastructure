variable "account_id" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "tunnel_name" {
  type = string
}

variable "tunnel_secret" {
  type        = string
  description = "Tunnel secret (base64)."
  sensitive   = true
}

variable "tunnel_routes" {
  type = list(object({
    network = string
    comment = optional(string)
  }))
  default = []
}

variable "access_applications" {
  type = map(object({
    domain           = string
    type             = optional(string)
    session_duration = optional(string)
    policies = list(object({
      name     = string
      decision = string
      include = object({
        emails        = optional(list(string))
        email_domains = optional(list(string))
        ips           = optional(list(string))
        group_ids     = optional(list(string))
      })
      require = optional(object({
        emails        = optional(list(string))
        email_domains = optional(list(string))
        ips           = optional(list(string))
        group_ids     = optional(list(string))
      }), {})
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for app in var.access_applications : alltrue([
        for policy in app.policies :
        length(try(policy.include.emails, [])) +
        length(try(policy.include.email_domains, [])) +
        length(try(policy.include.ips, [])) +
        length(try(policy.include.group_ids, [])) > 0
      ])
    ])
    error_message = "Each access policy include must define at least one principal."
  }
}

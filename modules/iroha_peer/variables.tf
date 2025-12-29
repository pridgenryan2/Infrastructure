variable "peer_count" {
  type        = number
  description = "Number of Iroha peers to deploy."
  default     = 1

  validation {
    condition     = var.peer_count > 0
    error_message = "peer_count must be greater than zero."
  }
}

variable "peer_name_prefix" {
  type        = string
  description = "Prefix for peer IDs and instance names."
  default     = "iroha-peer"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the peer instances."
}

variable "instance_type" {
  type        = string
  description = "Instance type for the peer instances."
  default     = "t3.small"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets to spread peers across."
}

variable "vpc_id" {
  type        = string
  description = "VPC for the peer security group."
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key pair name for peer instances."
  default     = null
}

variable "associate_public_ip" {
  type        = bool
  description = "Whether peers should receive public IPs."
  default     = false
}

variable "p2p_port" {
  type        = number
  description = "Iroha P2P port."
  default     = 1337
}

variable "api_port" {
  type        = number
  description = "Iroha API port."
  default     = 8080
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "CIDR ranges allowed to access peer ports."
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to AWS resources."
  default     = {}
}

variable "peer_public_keys" {
  type        = list(string)
  description = "Pre-coordinated peer public keys (ordered by peer index)."
  default     = []
}

variable "peer_kms_key_ids" {
  type        = list(string)
  description = "AWS KMS key IDs to pull peer public keys from."
  default     = []
}

variable "chain_id" {
  type        = string
  description = "Chain ID to include with genesis inputs."
  default     = "iroha-chain"
}

variable "genesis_extra" {
  type        = map(any)
  description = "Additional genesis fields to merge into genesis JSON output."
  default     = {}
}

variable "topology_extra" {
  type        = map(any)
  description = "Additional topology fields to merge into topology JSON output."
  default     = {}
}

locals {
  provided_key_count = length(var.peer_public_keys) + length(var.peer_kms_key_ids)
}

variable "validate_peer_keys" {
  type        = bool
  description = "Require peer keys to match peer_count when supplied."
  default     = true

  validation {
    condition = (
      !var.validate_peer_keys ||
      local.provided_key_count == 0 ||
      local.provided_key_count == var.peer_count
    )
    error_message = "When provided, peer_public_keys + peer_kms_key_ids must match peer_count."
  }
}

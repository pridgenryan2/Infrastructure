terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  kms_public_keys = [for key in data.aws_kms_public_key.peer : trimspace(key.public_key_pem)]
  provided_keys   = [for key in var.peer_public_keys : trimspace(key)]
  peer_keys       = length(local.kms_public_keys) > 0 || length(local.provided_keys) > 0 ? concat(local.provided_keys, local.kms_public_keys) : []
}

data "aws_kms_public_key" "peer" {
  for_each = toset(var.peer_kms_key_ids)
  key_id   = each.value
}

resource "aws_security_group" "peer" {
  name_prefix = "${var.peer_name_prefix}-iroha-"
  description = "Iroha peer ingress"
  vpc_id      = var.vpc_id

  ingress {
    description = "Iroha P2P"
    from_port   = var.p2p_port
    to_port     = var.p2p_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  ingress {
    description = "Iroha API"
    from_port   = var.api_port
    to_port     = var.api_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_instance" "peer" {
  count = var.peer_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element(var.subnet_ids, count.index % length(var.subnet_ids))
  vpc_security_group_ids      = [aws_security_group.peer.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = var.associate_public_ip

  tags = merge(var.tags, {
    Name = "${var.peer_name_prefix}-${count.index + 1}"
  })
}

locals {
  peer_addresses = [for instance in aws_instance.peer : "${instance.private_ip}:${var.p2p_port}"]
  peer_ids       = [for index in range(var.peer_count) : "${var.peer_name_prefix}-${index + 1}"]

  genesis_peers = [
    for index in range(var.peer_count) : {
      peer_id    = local.peer_ids[index]
      address    = local.peer_addresses[index]
      public_key = try(local.peer_keys[index], null)
    }
  ]

  topology_peers = [
    for index in range(var.peer_count) : {
      peer_id    = local.peer_ids[index]
      address    = local.peer_addresses[index]
      public_key = try(local.peer_keys[index], null)
    }
  ]
}

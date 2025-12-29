locals {
  genesis_inputs = merge(
    {
      chain_id = var.chain_id
      peers    = local.genesis_peers
    },
    var.genesis_extra
  )

  topology_inputs = merge(
    {
      peers = local.topology_peers
    },
    var.topology_extra
  )
}

output "instance_ids" {
  value = aws_instance.peer[*].id
}

output "private_ips" {
  value = aws_instance.peer[*].private_ip
}

output "peer_public_keys" {
  value = local.peer_keys
}

output "genesis_peers" {
  value = local.genesis_peers
}

output "topology_peers" {
  value = local.topology_peers
}

output "genesis_inputs" {
  value = local.genesis_inputs
}

output "topology_inputs" {
  value = local.topology_inputs
}

output "genesis_json" {
  value = jsonencode(local.genesis_inputs)
}

output "topology_json" {
  value = jsonencode(local.topology_inputs)
}

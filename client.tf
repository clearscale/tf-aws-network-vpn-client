resource "aws_security_group" "this" {
  count = (length(var.security_group_ids) <= 0) ? 1 : 0

  name        = module.std.names.aws.dev.general
  description = var.description
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  count = (length(var.security_group_ids) <= 0) ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = var.description
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr
  vpc_id                 = var.vpc_id

  self_service_portal   = "enabled"
  session_timeout_hours = 12

  authentication_options {
    type                           = "federated-authentication"
    saml_provider_arn              = var.saml_provider_arn
    self_service_saml_provider_arn = var.self_service_saml_provider_arn
  }

  connection_log_options {
    enabled = false
  }

  client_connect_options {
    enabled = false
  }

  client_login_banner_options {
    banner_text = "Connecting to AWS Environment - Authorized Access Only"
    enabled     = true
  }

  dns_servers = local.dns_servers

  security_group_ids = (((length(var.security_group_ids) <= 0))
    ? [aws_security_group.this[0].id]
    : var.security_group_ids
  )

  transport_protocol = "udp"
  split_tunnel       = false

  tags = {
    Name = module.std.names.aws.dev.general
  }
}

resource "aws_ec2_client_vpn_network_association" "this" {
  for_each = toset(var.subnet_ids)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  description            = "All user ingress"
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_route" "this" {
  for_each = tomap({
    for route in local.routes : "${route.subnet}.${route.cidr}" => route
  })
  description            = each.value.description
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  destination_cidr_block = each.value.cidr
  target_vpc_subnet_id   = each.value.subnet
}

resource "aws_vpn_gateway" "this" {
  amazon_side_asn = "64512"

  tags = merge(
    {
      Name = "${module.std.names.aws.dev.general}-vgw"
    },
    var.tags
  )

  vpc_id = var.vpc_id
}

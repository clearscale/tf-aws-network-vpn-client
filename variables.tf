locals {
  dns_servers = (length(var.dns_servers) > 0
    ? var.dns_servers
    : [cidrhost(var.vpc_cidr, 2)] # Default VPC DNS server
  )

  # Client VPN Routes
  cidrs  = [ # Routes to add in addition to VPC cidr
    "0.0.0.0/0"
  ]
  routes = [
    for pair in setproduct(var.subnet_ids, local.cidrs) : {
      subnet = pair[0]
      cidr   = pair[1]
      description = (pair[1] == var.vpc_cidr ? "Default Route" : null)
    }
  ]
}

variable "prefix" {
  type        = string
  description = "(Optional). Prefix override for all generated naming conventions."
  default     = "cs"
}

variable "client" {
  type        = string
  description = "(Optional). Name of the client"
  default     = "ClearScale"
}

variable "project" {
  type        = string
  description = "(Optional). Name of the client project."
  default     = "pmod"
}

variable "account" {
  description = "(Optional). Current cloud provider account info."
  type = object({
    key      = optional(string, "current")
    provider = optional(string, "aws")
    id       = optional(string, "*") 
    name     = string
    region   = optional(string, null)
  })
  default = {
    id   = "*"
    name = "shared"
  }
}

variable "env" {
  type        = string
  description = "(Optional). Name of the current environment."
  default     = "dev"
}

variable "region" {
  type        = string
  description = "(Optional). Name of the region."
  default     = "us-west-1"
}

variable "name" {
  type        = string
  description = "(Optional). The name of the resource, application, or service."
  default     = "vpn"
}

variable "description" {
  description = "The description of the Client VPN."
  default     = "Client VPN"
}

variable "client_cidr" {
  description = "The network range to use for clients. Must be a /22 or larger."
  type        = string
}

variable "server_certificate_arn" {
  description = "The ARN of the server certificate."
  type        = string
}

variable "client_certificate_arn" {
  description = "The ARN of the client certificate."
  type        = string
  default     = null
}

variable "saml_provider_arn" {
  description = "The ARN of the SAML provider for federated authentication."
  type        = string
}

variable "self_service_saml_provider_arn" {
  description = "The ARN of the self-service SAML provider."
  type        = string
}

variable "dns_servers" {
  description = "VPC CIDR (var.vpc_cidr) block .2 address. Example: VPC is 10.51.0.0/19, DNS is 10.51.0.2."
  type        = list(string)
  default     = []
}

variable "vpn_port" {
  description = "The port to use for the Client VPN."
  type        = number
  default     = 443
}

variable "vpc_id" {
  description = "The ID of the VPC to associate with the Client VPN."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC associated with the Client VPN (CIDR for var.vpc_id)."
  type        = string
}
variable "subnet_ids" {
  description = "A list of subnet IDs to be associated with the Client VPN. These are the subnets associated with var.vpc_id."
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs to apply to the Client VPN network interface. If none are specified a security group is created automatically."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to be merged with the default tags"
  type        = map(string)
  default     = {}
}

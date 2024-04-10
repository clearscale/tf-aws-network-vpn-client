#
# ClearScale Standardization
#
module "std" {
  source =  "github.com/clearscale/tf-standards.git?ref=v1.0.0"

  accounts = [var.account]
  prefix   = var.prefix
  client   = var.client
  project  = var.project
  env      = var.env
  region   = var.region
  name     = var.name
}
locals {
  resource_prefix = "${var.project}-${var.environment}"

  common_tags = {
    environment  = var.environment
    owner        = var.owner
    project      = var.project
    managed-by   = "terraform"
    week         = "3"
  }
}

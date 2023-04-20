variable "avx_gcp_account_name" {
  description = "GCP account as it appears in the controller."
  type        = string
}

variable "transit_gateway_name" {
  description = "Transit Gateway to connect this spoke to."
  type        = string
}

variable "insane_mode" {
  description = "Enable insane mode on this spoke. Be sure to specify an appropriate instance size."
  type        = bool
  default     = false
}

variable "network_domain" {
  description = "Network domain to associate this spoke with. Optional."
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the GKE spoke."
  type        = string
}

variable "region" {
  description = "Region to deploy Aviatrix Spoke and GKE."
  type        = string
}

variable "cidr" {
  description = "CIDR for the Spoke Gateway and GKE ranges. Use /23."
  type        = string

  validation {
    condition     = split("/", var.cidr)[1] == "23"
    error_message = "This module needs a /23."
  }
}

variable "aviatrix_spoke_instance_size" {
  description = "Size of the Aviatrix Spoke Gateway."
  type        = string
  default     = null
}

variable "compute_instance_size" {
  description = "Size of the Compute instance."
  type        = string
  default     = "e2-small"
}

variable "number_of_compute_instances" {
  description = "Number of instances to deploy."
  type        = number
  default     = 1
}

variable "use_aviatrix_firenet_egress" {
  description = "Apply the avx_snat_noip tag to nodes for Egress"
  type        = bool
  default     = true
}

variable "public_key" {
  description = "Public key for the instances."
  type        = string
}

locals {

  avx       = cidrsubnet(var.cidr, 1, 0) # 10.0.0.0/22 -> 10.0.0.0/24
  instances = cidrsubnet(var.cidr, 1, 1) # 10.0.0.0/22 -> 10.0.1.0/26

  tags = var.use_aviatrix_firenet_egress ? ["avx-snat-noip"] : null
}
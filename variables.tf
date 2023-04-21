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

variable "use_aviatrix_egress" {
  description = "Apply the avx_snat_noip tag to nodes for Egress; disables public IP."
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public key for the instances."
  type        = string
}

variable "network_tags" {
  description = "List of tags to apply to the instance. avx-snat-noip is applied if use_aviatrix_egress is set true."
  type        = list(string)
  default     = []
}

locals {

  avx       = cidrsubnet(var.cidr, 1, 0) # 10.0.0.0/22 -> 10.0.0.0/24
  instances = cidrsubnet(var.cidr, 1, 1) # 10.0.0.0/22 -> 10.0.1.0/26

  network_tags = var.use_aviatrix_egress ? concat(["avx-snat-noip"], var.network_tags) : var.network_tags
}
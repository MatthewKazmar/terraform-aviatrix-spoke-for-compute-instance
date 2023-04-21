data "aviatrix_account" "this" {
  account_name = var.avx_gcp_account_name
}

data "http" "myip" {
  url = "http://ifconfig.me"
}

module "instance_spoke" {
  source         = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version        = "1.5.0"
  cloud          = "GCP"
  region         = var.region
  name           = "${var.name}-spoke"
  gw_name        = "${var.name}-spoke-gateway"
  instance_size  = var.aviatrix_spoke_instance_size
  insane_mode    = var.insane_mode
  cidr           = local.avx
  account        = var.avx_gcp_account_name
  transit_gw     = var.transit_gateway_name
  network_domain = var.network_domain
}

resource "google_compute_subnetwork" "instances" {
  project = data.aviatrix_account.this.gcloud_project_id

  name          = "${var.name}-instances"
  ip_cidr_range = local.instances
  region        = var.region
  network       = module.instance_spoke.vpc.id
}

#
resource "google_compute_firewall" "this" {
  name    = "${var.name}-admin-rule"
  network = module.instance_spoke.vpc.id

  allow {
    protocol = "all"
  }

  source_ranges = ["35.235.240.0/20", "${data.http.myip.response_body}/32"]
}

module "instances" {
  source = "github.com/MatthewKazmar/terraform-gcp-vm"

  count = var.number_of_compute_instances

  avx_gcp_account_name = var.avx_gcp_account_name
  region               = var.region
  ssh_public_key       = var.public_key
  name                 = "${var.name}-${count.index}"
  subnetwork_self_link = google_compute_subnetwork.instances.self_link
  instance_number      = count.index
  network_tags         = local.network_tags
  machine_type         = var.compute_instance_size
}

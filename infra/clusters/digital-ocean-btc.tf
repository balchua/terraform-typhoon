module "digital-ocean-btc" {
  source = "git::https://github.com/poseidon/typhoon//digital-ocean/container-linux/kubernetes?ref=v1.16.0"

  region = "sgp1"
  dns_zone = "geek.per.sg"

  cluster_name = "btc"
  controller_count = 1
  controller_type = "s-4vcpu-8gb"
  worker_count = 3
  worker_type = "s-4vcpu-8gb"
  ssh_fingerprints = ["${var.digitalocean_ssh_fingerprint}"]

  enable_aggregation = "true"
  # output assets dir
  asset_dir = "/home/thor/.secrets/clusters/btc"
}

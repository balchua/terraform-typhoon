module "digital-ocean-btc" {
  source = "git::https://github.com/poseidon/typhoon//digital-ocean/container-linux/kubernetes?ref=v1.9.2"
  #  source = "../../typhoon-master/digital-ocean/container-linux/kubernetes"

  region = "sgp1"
  dns_zone = "geek.per.sg"

  cluster_name = "btc"
  image = "coreos-stable"
  controller_count = 1
  controller_type = "s-2vcpu-4gb"
  worker_count = 3
  worker_type = "s-2vcpu-4gb"
  ssh_fingerprints = [
    "${var.digitalocean_ssh_fingerprint}"]

  # output assets dir
  asset_dir = "/home/thor/.secrets/clusters/btc"
}


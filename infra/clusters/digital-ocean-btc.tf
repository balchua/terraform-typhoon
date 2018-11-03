module "digital-ocean-btc" {
  source = "git::https://github.com/poseidon/typhoon//digital-ocean/container-linux/kubernetes?ref=v1.12.1"

  providers = {
    digitalocean = "digitalocean.default"
    local = "local.default"
null = "null.default"
template = "template.default"
tls = "tls.default"
}

  region = "nyc3"
  dns_zone = "geek.per.sg"

  cluster_name = "btc"
  controller_count = 1
  controller_type = "s-4vcpu-8gb"
  worker_count = 3
  worker_type = "s-4vcpu-8gb"
ssh_fingerprints = ["${var.digitalocean_ssh_fingerprint}"]
#ssh_fingerprints = ["77:45:be:8b:e9:38:8e:04:55:d5:71:5b:3c:c6:68:57"]

  # output assets dir
  asset_dir = "/home/thor/.secrets/clusters/btc"
}

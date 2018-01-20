module "digital-ocean-btc" {
  #source = "git::https://github.com/poseidon/typhoon//digital-ocean/container-linux/kubernetes"
  source = "../../typhoon-master/digital-ocean/container-linux/kubernetes"

  region = "sgp1"
  dns_zone = "geek.per.sg"

  cluster_name = "btc"
  image = "coreos-stable"
  controller_count = 1
  controller_type = "4gb"
  worker_count = 4
  worker_type = "4gb"
  ssh_fingerprints = [
    "77:45:be:8b:e9:38:8e:04:55:d5:71:5b:3c:c6:68:57"]

  # output assets dir
  asset_dir = "/home/thor/.secrets/clusters/btc"
}

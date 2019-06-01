resource "digitalocean_kubernetes_cluster" "doks-cluster" {
  name    = "doks-cluster"
  region  = "sgp1"
  version = "1.14.1-do.3 "

  node_pool {
    name       = "worker-nodes"
    size       = "s-8vcpu-32gb"
    node_count = 3
  }
}

resource "local_file" "doks-config" {
  content     = "${digitalocean_kubernetes_cluster.doks-cluster.kube_config.0.raw_config}"
  filename = "doks-config.yaml"
}

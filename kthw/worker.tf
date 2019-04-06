resource "digitalocean_droplet" "kube-worker" {
  count = "3"
  image = "ubuntu-18-04-x64"
  name = "kube-worker-${count.index}"
  region = "sgp1"
  size = "s-4vcpu-8gb"
  private_networking = true
  ssh_keys = [
    "${var.digitalocean_ssh_fingerprint}"]

  tags = [
    "${digitalocean_tag.workers.id}",
  ]

}

# Tag to label workers
resource "digitalocean_tag" "workers" {
  name = "kube-worker"
}

resource "digitalocean_record" "workers-record-a" {
  count = "${digitalocean_droplet.kube-worker.count}"

  # DNS zone where record should be created
  domain = "geek.per.sg"

  name  = "kube-khthw-workers"
  type  = "A"
  ttl   = 300
  value = "${element(digitalocean_droplet.kube-worker.*.ipv4_address, count.index)}"
}





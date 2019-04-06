resource "digitalocean_droplet" "kube-master" {
  count = "3"
  image = "ubuntu-18-04-x64"
  name = "kube-master-${count.index}"
  region = "sgp1"
  size = "s-4vcpu-8gb"
  private_networking = true
  ssh_keys = [
    "${var.digitalocean_ssh_fingerprint}"]

  tags = [
    "${digitalocean_tag.master.id}",
  ]

}

# Tag to label workers
resource "digitalocean_tag" "master" {
  name = "kube-master"
}


resource "digitalocean_record" "master" {
  count = "1"

  # DNS zone where record should be created
  domain = "geek.per.sg"

  # DNS record (will be prepended to domain)
  name = "kube-khthw-master"
  type = "A"
  ttl  = 300

  # IPv4 addresses of controllers
  value = "${element(digitalocean_droplet.kube-master.*.ipv4_address, count.index)}"
}

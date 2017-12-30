resource "digitalocean_droplet" "experiment" {
  image = "ubuntu-16-04-x64"
  name = "ubuntu1"
  region = "sgp1"
  size = "512mb"
  ssh_keys = [
    "${var.digitalocean_ssh_fingerprint}"]

  connection {
    user = "root"
    type = "ssh"
    key_file = "${var.digitalocean_private_key}"
    timeout = "2m"
  }
}
resource "digitalocean_droplet" "nfs-server" {
  image = "ubuntu-16-04-x64"
  name = "nfs-server"
  region = "sgp1"
  size = "1gb"
  private_networking = true
  ssh_keys = [
    "${var.digitalocean_ssh_fingerprint}"]

  user_data = "${template_file.nfs_server_config.rendered}"


  connection {
    user = "root"
    type = "ssh"
    private_key = "${file(var.digitalocean_private_key)}"
    timeout = "2m"
  }

}

# Controller Container Linux Config
resource "template_file" "nfs_server_config" {

  template = "${file("${path.module}/templates/nfs-server.yaml.tmpl")}"

}



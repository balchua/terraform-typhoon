/*
resource "digitalocean_droplet" "nfs-client" {
  image = "ubuntu-16-04-x64"
  name = "nfs-client"
  region = "sgp1"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.digitalocean_ssh_fingerprint}"]

  connection {
    user = "root"
    type = "ssh"
    private_key = "${file(var.digitalocean_private_key)}"
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
      sudo apt-get update
      echo "gotta sleep for some reason" && sleep 5
      sudo apt-get update
      sudo apt-get install -y nfs-common
      sudo mkdir -p /export/files
      sudo chmod 777 /export/files
      sudo mount ${digitalocean_droplet.nfs-server.ipv4_address_private}:/export/files /export/files
      echo "this is $(hostname)" >> /export/files/test.txt

    EOF
    ]
  }
}
*/

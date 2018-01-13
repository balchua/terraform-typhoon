resource "digitalocean_droplet" "nfs-server" {
  image = "ubuntu-16-04-x64"
  name = "nfs-server"
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
      sudo apt-get install -y nfs-kernel-server
      sudo mkdir -p /export/files
      sudo chmod 777 /etc/exports /etc/hosts.allow /export/files
      echo "/export/files *(rw,no_root_squash)" >>  /etc/exports
      echo "rspbind = ALL
      portmap = ALL
      nfs = ALL" >> /etc/hosts.allow
      sudo chmod 755 /etc/exports /etc/hosts.allow
      sudo /etc/init.d/nfs-kernel-server restart
      sudo showmount -e
      echo "hi there this is the server $(hostname)" > /export/files/test.txt

    EOF
    ]
  }

}

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
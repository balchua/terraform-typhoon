resource "digitalocean_record" "nfs-server" {
  # DNS zone where record should be created
  domain = "geek.per.sg"
  name = "nfs-server"
  type = "A"
  ttl = 300
  value = "${digitalocean_droplet.nfs-server.ipv4_address}"
}

resource "digitalocean_record" "demo" {
  # DNS zone where record should be created
  domain = "geek.per.sg"
  name = "demo"
  type = "CNAME"
  ttl = 43200
  value = "btc-workers.geek.per.sg."
}

resource "digitalocean_record" "zipkin" {
  # DNS zone where record should be created
  domain = "geek.per.sg"
  name = "zipkin"
  type = "CNAME"
  ttl = 43200
  value = "btc-workers.geek.per.sg."
}


resource "digitalocean_record" "grafana" {
  # DNS zone where record should be created
  domain = "geek.per.sg"
  name = "grafana"
  type = "CNAME"
  ttl = 43200
  value = "btc-workers.geek.per.sg."
}
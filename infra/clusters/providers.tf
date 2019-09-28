provider "digitalocean" {
  version = "1.7.0"
  token = "${chomp(file("~/.config/digital-ocean/token"))}"
}

provider "ct" {
  version = "0.4.0"
}

provider "local" {
  version = "~> 1.0"
  alias = "default"
}

provider "null" {
  version = "~> 2.1"
  alias = "default"
}

provider "template" {
  version = "~> 2.1"
  alias = "default"
}

provider "tls" {
  version = "~> 2.0"
  alias = "default"
}


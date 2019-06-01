provider "digitalocean" {
  version = "~> 1.3.0"
  token = "${chomp(file("~/.config/digital-ocean/token"))}"
  alias = "default"
}

provider "ct" {
  version = "0.3.1"
}

provider "local" {
  version = "~> 1.0"
  alias = "default"
}

provider "null" {
  version = "~> 1.0"
  alias = "default"
}

provider "template" {
  version = "~> 1.0"
  alias = "default"
}

provider "tls" {
  version = "~> 1.0"
  alias = "default"
}


terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.25.0"
    }
  }
}
#-----------------------------------_GITHUB--------------------------------------
provider "github" {
  token = var.github_token
  owner = var.github_owner
}
#-----------------------------------_GITHUB--------------------------------------


#-----------------------------------Docker--------------------------------------
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "nginx_ssh_ansible" {
  name         = "nginx_ssh_ansible:latest"
  build {
    context    = "./"   # chemin vers le Dockerfile
    dockerfile = "Dockerfile"
  }
  keep_locally = true
}

# Crée 2 conteneurs avec count
resource "docker_container" "nginx" {
  count = 2
  name  = "projet_AT_${count.index + 1}"
  image = docker_image.nginx_ssh_ansible.name

  ports {
    internal = 80
    external = 8080 + count.index  # nginx
  }

  ports {
    internal = 22
    external = 2222 + count.index  # SSH
  }
}
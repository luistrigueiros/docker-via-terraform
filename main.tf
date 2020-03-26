provider "docker" {}

variable wordpress_port {
  default = "8080"
}


resource "docker_volume" "db_data" {}

resource "docker_network" "wordpress_net" {
  name = "wordpress_net"
}

resource "docker_container" "db" {
  name  = "db"
  image = "mysql:5.7"
  restart = "always"
  network_mode = "wordpress_net"
  env = [
    "MYSQL_ROOT_PASSWORD=wordpress",
    "MYSQL_PASSWORD=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_DATABASE=wordpress"
  ]
  mounts {
    type = "volume"
    target = "/var/lib/mysql"
    source = "db_data"
  }
}

resource "docker_container" "wordpress" {
  depends_on = [docker_container.db]

  name  = "wordpress"
  image = "wordpress:latest"
  restart = "always"
  network_mode = "wordpress_net"
  env = [
    "WORDPRESS_DB_HOST=db:3306",
    "WORDPRESS_DB_PASSWORD=wordpress"
  ]
  ports {
    internal = "80"
    external = var.wordpress_port
  }
}

job "kibana" {
  datacenters = ["dc1"]

  task "run-kibana" {
    driver = "docker"

    config {
      image = "..."

      port_map {
        kibana_http = 5601
      }
    }

    resources {
      cpu    = 1024
      memory = 3000

      network {
        port "kibana_http" {
          static = 5601
        }
      }
    }

    service {
      name = "service-kibana"
      port = "kibana_http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }
  }
}

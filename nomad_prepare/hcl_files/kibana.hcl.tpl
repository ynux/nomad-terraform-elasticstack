job "kibana" {
  datacenters = ["eu-central-1a","eu-central-1b","eu-central-1c"]

  task "run-kibana" {
    driver = "docker"

    config {
      image = "docker.elastic.co/kibana/kibana-oss:7.2.0"

      port_map {
        kibana_http = 5601
      }
    }

    env {
       "ELASTICSEARCH_HOSTS" = "http://$ES_FIRST_IP:9200"
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

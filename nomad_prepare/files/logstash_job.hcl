job "logstash" {

  datacenters = ["eu-central-1a","eu-central-1b","eu-central-1c"]
  task "logstash" {
    driver = "docker"

    env {}

    config {
      image = "docker.elastic.co/logstash/logstash:7.2.0"
    }

    resources {
      cpu    = 4000
      memory = 2048

      network {
        port "beats2logstash" {
          mbits  = 500
          static = 1704
        }
      }
    }

    service {
      name = "logstash"
      tags = ["protocol-beats"]
      port = "beats2logstash"
    }
  }
}

job "logstash" {

  task "logstash" {
    driver = "docker"

    env {}

    config {
      image = "docker.elastic.co/logstash/logstash:"
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

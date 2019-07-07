job "logstash" {
  datacenters = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  task "logstash" {
    driver = "docker"

    config {
      image = "docker.elastic.co/logstash/logstash-oss:7.2.0"

      volumes = [
        "/home/ubuntu/pipeline/:/usr/share/logstash/pipeline/",
      ]
    }

    resources {
      cpu    = 4000
      memory = 2048

      network {
        port "beats2logstash" {
          mbits  = 500
          static = 5044
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

job "elasticsearch_docker" {
  datacenters = ["eu-central-1a","eu-central-1b","eu-central-1c"]
  constraint {
    operator  = "distinct_hosts"
    value     = "true"
  }
  constraint {
    attribute = "${node.class}"
    value     = "elasticsearch"
  }

  group "elasticsearch-group-docker" {
    count = 3
    restart {
      attempts = 3
      delay    = "30s"
      interval = "30m"
      mode = "delay"
    }

    reschedule {
      attempts  = 0
      unlimited = false
    }

    task "run-elasticsearch-docker" {
      driver = "docker"
      config {
        image = "docker.elastic.co/elasticsearch/elasticsearch-oss:7.2.0"
        network_mode = "host"
        volumes = [
          "/opt/elasticsearch/data:/usr/share/elasticsearch/data"
        ]

        port_map {
          elasticsearch_rest = 9200
          elasticsearch_intra = 9300
        }
      }

      env {
        "cluster.name" = "search-meetup-munich"
        "network.bind_host"                  = "0.0.0.0"
        "network.publish_host"               = "${NOMAD_IP_elasticsearch_intra}"
        "discovery.seed_hosts"               = "$ES_FIRST_IP"
        "cluster.initial_master_nodes"       = "$ES_FIRST_IP"
        "ES_JAVA_OPTS"                       = "-Xms1g -Xmx1g"
      }

      resources {
        cpu = 50	
        memory = 1500 
        network {
          mbits = 50
          port "elasticsearch_rest" { static = 9200 }
          port "elasticsearch_intra" { static = 9300 }
        }
      }

      service {
        name = "rest-elasticsearch-docker"
        port = "elasticsearch_rest"
        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout = "5s"
        }
      }

      service {
        name = "intra-elasticsearch-docker"
        port = "elasticsearch_intra"
        check {
          type = "tcp"
          interval = "10s"
          timeout = "5s"
        }
      }
    }
  }
}


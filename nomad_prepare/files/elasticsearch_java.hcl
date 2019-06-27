job "elasticsearch_java" {
  datacenters = ["eu-central-1a","eu-central-1b","eu-central-1c"]
  group "elasticsearch-group-java" {
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

    task "run-elasticsearch-java" {
      driver = "java"
      user = "elasticsearch"
      env = {
        ES_HOME = "/usr/share/elasticsearch"
        ES_PATH_CONF = "/etc/elasticsearch"
        PID_DIR = "/var/run/elasticsearch"
      }
      config {
        class_path = "/usr/share/elasticsearch/jdk/lib/server/:/usr/share/elasticsearch/lib/*"
        class = "org.elasticsearch.bootstrap.Elasticsearch"
        jvm_options = ["-Xms512m", "-Xmx512m","-XX:+UseConcMarkSweepGC","-XX:CMSInitiatingOccupancyFraction=75","-XX:+UseCMSInitiatingOccupancyOnly","-XX:+AlwaysPreTouch","-server","-Djava.awt.headless=true","-Dfile.encoding=UTF-8","-Djna.nosys=true","-Djdk.io.permissionsUseCanonicalPath=true","-Dio.netty.noUnsafe=true","-Dio.netty.noKeySetOptimization=true","-Dio.netty.recycler.maxCapacityPerThread=0","-Dlog4j.shutdownHookEnabled=false","-Dlog4j2.disable.jmx=true","-Dlog4j.skipJansi=true","-XX:+HeapDumpOnOutOfMemoryError","-Dio.netty.allocator.type=unpooled","-Des.path.home=/usr/share/elasticsearch","-Des.path.conf=/etc/elasticsearch","-Des.distribution.flavor=default","-Des.distribution.type=deb","-Des.bundled_jdk=true","-cp","/usr/share/elasticsearch/lib/*"]
      }
      resources {
        cpu = 50	
        memory = 800 
        network {
          mbits = 50
          port "elasticsearch_rest" { static = 9200 }
          port "elasticsearch_intra" { static = 9300 }
        }
      }

      service {
        name = "rest-elasticsearch"
        port = "elasticsearch_rest"
        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout = "5s"
        }
      }

      service {
        name = "intra-elasticsearch"
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



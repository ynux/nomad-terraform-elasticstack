job "curator" {
  datacenters = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  type = "batch"

  periodic {
    cron             = "44 10 * * * *"
    prohibit_overlap = true
    time_zone        = "UTC"
  }

  task "run-curator" {
    driver = "exec"

    config {
      command = "/usr/bin/curator"
      args    = ["--config", "/opt/elasticsearch-curator/curator.yml", "/opt/elasticsearch-curator/action.yml", "--dry-run"]
    }

    resources {
      cpu    = 250
      memory = 256
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Radically simplified version of https://github.com/hashicorp/terraform-aws-nomad/blob/master/main.tf
# only use for demo 
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
   region = "eu-central-1"
}

# from .env_vars

variable "vpc_id" {
    type = string
}

variable "subnet_ids" {
    type = list
}

variable "security_group_id" {
    type = string
}

variable "ssh_key_name" {
    type = string
}

variable "my_ip" {
    type = string
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE SERVER NODES (consul & nomad)
# using my fork for terraform 0.12
# ---------------------------------------------------------------------------------------------------------------------

module "servers" {
  source = "github.com/ynux/terraform-aws-consul//modules/consul-cluster?ref=terraform_012"

  cluster_name  = "search-meetup"
  cluster_size  = 3
  instance_type = "t2.micro"
  
  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = "nomad-example"
  cluster_tag_value = "auto-join"

  ami_id    = "ami-0ed6a4bca29eaf964"
  user_data = <<-EOF
              #!/bin/bash
              # This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
              # run-nomad and run-consul scripts to configure and start Consul and Nomad in server mode. Note that this script
              # assumes it's running in an AMI built from the Packer template in examples/nomad-consul-ami/nomad-consul.json.
              
              set -e
              
              # Send the log output from this script to user-data.log, syslog, and the console
              # From: https://alestic.com/2010/12/ec2-user-data-output/
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              
              # These variables are passed in via Terraform template interplation
              /opt/consul/bin/run-consul --server --cluster-tag-key nomad-example --cluster-tag-value "auto-join"
              /opt/nomad/bin/run-nomad --server --num-servers "3"
              EOF

  vpc_id = "${var.vpc_id}"
  allowed_ssh_cidr_blocks = ["${var.my_ip}/32"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
  subnet_ids                  = "${var.subnet_ids}"
  tags = [
    {
      key                 = "Environment"
      value               = "development"
      propagate_at_launch = true
    },
  ]
}

module "nomad_security_group_rules" {
  source = "github.com/ynux/terraform-aws-nomad//modules/nomad-security-group-rules?ref=terraform_012"
  security_group_id = "${var.security_group_id}"
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CLIENT NODES
# ---------------------------------------------------------------------------------------------------------------------

module "clients" {
  source = "github.com/ynux/terraform-aws-nomad//modules/nomad-cluster?ref=terraform_012"

  cluster_name  = "search-meetup"
  instance_type = "t2.micro"

  # Give the clients a different tag so they don't try to join the server cluster
  cluster_tag_key   = "nomad-clients"
  cluster_tag_value = "auto-join"

  # We are basic and static today
  min_size         = 2
  max_size         = 2
  desired_capacity = 2

  ami_id    = "ami-0ed6a4bca29eaf964"
  user_data = <<-EOF
              #!/bin/bash
              # This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
              # run-nomad and run-consul scripts to configure and start Nomad and Consul in client mode. Note that this script
              # assumes it's running in an AMI built from the Packer template in examples/nomad-consul-ami/nomad-consul.json.
              
              set -e
              
              # Send the log output from this script to user-data.log, syslog, and the console
              # From: https://alestic.com/2010/12/ec2-user-data-output/
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              
              # These variables are passed in via Terraform template interplation
              /opt/consul/bin/run-consul --client --cluster-tag-key "nomad-example" --cluster-tag-value "auto-join"
              /opt/nomad/bin/run-nomad --client
              EOF

  subnet_ids                  = "${var.subnet_ids}"
  vpc_id                      = "${var.vpc_id}"
  allowed_ssh_cidr_blocks     = ["${var.my_ip}/32"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our client Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies" {
  source = "github.com/ynux/terraform-aws-consul//modules/consul-iam-policies?ref=terraform_012"

  iam_role_id = "${module.clients.iam_role_id}"
}

output "num_nomad_servers" {
  value = "${module.servers.cluster_size}"
}

output "asg_name_servers" {
  value = "${module.servers.asg_name}"
}

output "launch_config_name_servers" {
  value = "${module.servers.launch_config_name}"
}

output "iam_role_arn_servers" {
  value = "${module.servers.iam_role_arn}"
}

output "iam_role_id_servers" {
  value = "${module.servers.iam_role_id}"
}

output "num_clients" {
  value = "${module.clients.cluster_size}"
}

output "asg_name_clients" {
  value = "${module.clients.asg_name}"
}

output "launch_config_name_clients" {
  value = "${module.clients.launch_config_name}"
}

output "iam_role_arn_clients" {
  value = "${module.clients.iam_role_arn}"
}

output "iam_role_id_clients" {
  value = "${module.clients.iam_role_id}"
}




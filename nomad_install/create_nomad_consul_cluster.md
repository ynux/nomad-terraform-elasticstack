# Create a Nomad Cluster, with Consul

This is not our main task, so let's steal the code. Cheapest way i could find: [Nomad AWS Module](https://github.com/hashicorp/terraform-aws-nomad/blob/master/README.md#deploy-nomad-and-consul-in-the-same-cluster)

Choices:
1. Consul and Nomad on same cluster
1. Use HashiCorp's pre baked images, ami-0d9516a85e0c28bb0


Steps:
1. install terraform, Terraform v0.12.2 + provider.aws v2.15.0
2. have your aws access key and secret key in .aws/credentials
1. Start 3 ec2 with this ami and have a look what they do - with xxx.tf, 
terraform init, as in [terraform getting started guide](https://learn.hashicorp.com/terraform/getting-started/build.html)
3. 


Use  hclfmt

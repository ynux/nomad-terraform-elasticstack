### Build your Nomad Cluster on AWS
on your local machine, install:

for nomad and consul cluster installation
* packer
* terraform
* git
to prepare the job deployments on nomad
* ansible
* aws client, or use console

have an aws account, put credentials into environment or $HOME/.aws/credentials file

Versions that worked for me:
  *  Packer v1.4.1
  *  Terraform v0.12.2
  *  + provider.aws v2.16.0
  *  git version 2.20.1
  *  aws-cli/1.16.171

#### Build amis with nomad and consul 

clone git [hashicorp's terraform aws nomad repository](https://github.com/hashicorp/terraform-aws-nomad.git) . Edit examples/nomad-consul-ami/nomad-consul.json with desired region and versions, e.g.
```
  "variables": {
    "aws_region": "eu-central-1",
    "nomad_version": "0.9.3",
    "consul_module_version": "v0.6.1",
    "consul_version": "1.5.1"
  },
```
Run 
```
packer validate nomad-consul.json
packer build nomad-consul.json
``` 
This will create two amis, ubuntu and amazon linux. *Note there may be small costs involved, to minimize these, delete the amis and snapshots when you're done.*
Make a note of the two new ami ids. *The amazon linux ami didn't work for me*
#### Build the Cluster
Set your variables, e.g. like this:
```
export TF_VAR_ssh_key_name="xxx"
export TF_VAR_num_clients=4
export TF_VAR_ami_id="ami-idnotedinpreviousstep"
``` 
From here on, you may want to use my [fork, branch "elasticsearch"](https://github.com/ynux/terraform-aws-nomad/tree/elasticsearch). Some minor changes were needed for the terraform version 0.12, and some more ports opened for the elastic stack.

Back in the root directory of the git repository terraform-aws-nomad, run 
```
terraform init
source .env_vars
terraform plan
terraform apply
```

*When you succeed, you will have 7 ec2 instances running, so watch the costs and run `terraform destroy` when you are done*

#### Have a Look

Get the public IPs of your nomad servers in the AWS console or with `aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-server" --query "Reservations[*].Instances[*].PublicIpAddress" --output text`. Ssh to them as ubuntu, and run (Nomad v0.9.3, Consul v1.5.1):
 
```
consul members
nomad server members
nomad node status
```
If all this comes back nicely, proceed to [preparing the nomad cluster](../nomad_prepare)
Or connect to the GUIs of nomad and elasticsearch from outside, using a server's IP and ports 4646 or 8500 respectively.



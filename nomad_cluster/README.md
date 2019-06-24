### Build your Nomad Cluster on AWS
on your local machine, install:

* packer
* terraform
* ansible
* git

have an aws account, put credentials into environment or $HOME/.aws/credentials file

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
Note the two new ami ids.
#### Build the Cluster
Set your variables, e.g. like this:
```
export TF_VAR_ssh_key_name="xxx"
export TF_VAR_num_clients=4
export TF_VAR_ami_id="ami-idnotedinpreviousstep"
``` 
Back in the root directory of the git repository terraform-aws-nomad, run 
```
terraform init
terraform plan
terraform apply
```
If you use terraform > 0.12, some small changes will be required in the terraform nomad and consul modules. See e.g. https://github.com/ynux/terraform-aws-nomad/tree/terraform_012 and https://github.com/ynux/terraform-aws-consul/tree/terraform_012 .

#### Have a Look

Get the public IPs of your nomad servers in the AWS console or with `aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-server" --query "Reservations[*].Instances[*].PublicIpAddress" --output text`. Ssh to them as ubuntu or ec2-user, and run:
 



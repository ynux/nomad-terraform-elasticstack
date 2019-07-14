### Prepare the Nomad Cluster

Using ansible 2.8.1

Before we can start the nomad jobs, the cluster needs [task drivers](https://www.nomadproject.io/docs/drivers/index.html) on client nodes, some system settings, some software and some files.

For the Elastic Stack components, this means that the nodes need:
* elasticsearch: docker, plus some system prereqs and a data directory
* kibana, logstash: docker, plus pipeline config for logstash
* curator: binaries, config, and chroot change in the nomad config
* filebeat will be installed directly, not under nomad control, install on nomad clients and servers
* and we have to integrate the consul dns if we want to use the service names

Remarks:
* I'm not really attaching volumes to the elasticsearch servers - not persistent, not for production.
* We pin 3 elasticsearch nodes to 3 nomad nodes (job constraint)
* We deploy only 1 logstash instance 
* For a real life setup, you may want to be able to see your logs even when your nomad cluster is gone. In this case, install a second filebeat instance to send them to another elastic stack
* The playbooks copy the Nomad Job Definitions (hcl-files) to all nomad nodes, this is just for convenience (nomad installed, everything accessible, quick troubleshooting)

#### Prepare ansible

Populate your [inventory.ini](./inventory.ini) with the public IPs of your ec2 instances. Get them e.g. with 
```
aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-server" --query "Reservations[*].Instances[*].PublicIpAddress" --output text
aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-client" --query "Reservations[*].Instances[*].PublicIpAddress" --output text
```
Put 3 client nodes into the nomad\_clients\_elasticsearch group, the fourth in the nomad\_client group of your inventory.ini.
Put the path to your key into your [ansible.cfg](./ansible.cfg.example).
Install elastic's beats ansible role with `ansible-galaxy install -r requirements.yml`

##### Put one private IP into inventory.ini

Elasticsearch needs a `cluster.initial_master_nodes` for the initial bootstrap, and some `discovery.seed_hosts` to have the nodes discover each other. For the latter we could install the aws discovery plugin. For the first I'm not sure how to solve it. It has to be same, otherwise you might end up with three clusters.

I took the cheap way out: Put one elasticsearch internal IP and use it via ansible templates. It works. 

So please get one elasticsearch private IP , e.g. with `aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-client" --query "Reservations[*].Instances[*].[PublicIpAddress,PrivateIpAddress]" --output table`. Put it as `es_first` variable into the inventory.ini.

#### Run Playbooks

```
# Test if nodes are reachable
ansible all -m ping
# install filebeat on all instances
ansible-playbook filebeat.yml
# Install docker on all nomad client nodes
ansible-playbook nomad_clients.yml
# Install curator binaries and change chroot
ansible-playbook curator.yml
# Assign node class "elasticsearch", prepare OS, create data dir
ansible-playbook elasticsearch_nomad_clients.yml
# Integrate consul into DNS
ansible-playbook etc_hosts.yml
# Copy config and nomad job definition files to all client nodes
ansible-playbook copy_files.yml

### Very few checks - I should do more
ansible-playbook check_nomad_clients.yml
```
#### A note on name resolution

The components have to find one another:
* Beats has to find Logstash
* Logstash has to find Elasticsearch
* Elasticsearch has to find each other - we use one private IP for this
* Kibana has to find Elasticsearch
* Curator has to find Elasticsearch 

Consul will register the services and the IPs, but no one will know that they should look up `*.service.consul` at localhost port 8600.

`dig @<consul server> -p 8600 rest-elasticsearch-docker.service.consul. ANY`
`dig @localhost service-kibana.service.consul. ANY`

How to integrate Consul DNS with your existing DNS depends on your existing DNS.

In my case, the AMI seemed to have a very basic setup that I didn't want to mess with. So I went for putting the services into `/etc/hosts`. This is not a great solution, just enough to get the demo working. 

#### Result

We now have everything in place to start our jobs on nomad. Proceed to [nomad\_action](../nomad_action)

#### Random Remarks
To show that we aren't scared of go templates:
`nomad node status -verbose -t '{{range .}}{{ .NodeClass }}{{"\n"}}{{end}}'`
`nomad node status -verbose -t '{{range .}}{{ if (eq .NodeClass "elasticsearch") }} {{ .Address }}{{"\n"}}{{end}}{{end}}'`
`nomad node status -verbose -t '{{range .}}{{ if and (eq .NodeClass "elasticsearch") (eq .Status "ready") }} {{ .Address }}{{"\n"}}{{end}}{{end}}'`
Achieve the same with jq - installed anyway (jq is installed by packer)
`nomad node status -verbose -json | jq '.[].NodeClass'`
nomad node status -verbose -json | jq '.[] | select(.NodeClass == "elasticsearch") | select(.Status == "ready") | .Address'`

To see that elastic isn't scared of new java versions:
`ansible nomad_clients -m shell -a "java -version"`

Check consul services:
`curl http://127.0.0.1:8500/v1/catalog/service/intra-elasticsearch | json_pp`


consul template to return one elasticsearch IP:
```
{{ with service "rest-elasticsearch-docker" }}
{{ with index . 0 }}
{{ .Address }}{{ end }}{{ end }}
```


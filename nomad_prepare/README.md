### Prepare the Nomad Cluster

ansible 2.8.1

Before we can really start the nomad jobs, the cluster needs [task drivers](https://www.nomadproject.io/docs/drivers/index.html) on client nodes, some system settings, some software and some files.

For the Elastic Stack components, this means:
* elasticsearch: docker, plus some system prereqs and a data directory
* kibana, logstash: docker, plus pipeline config
* curator: exec, periodic job, config, and chroot change
* filebeat installed directly, not under nomad control, install on nomad clients and servers
* connect services with consul dns


Remarks:
* I'm not really attaching volumes to the elasticsearch servers
* We pin 3 elasticsearch nodes to 3 nomad nodes (job constraint)
* We deploy only 1 logstash instance 
* For a real life setup, if you want to see the logs when the nomad cluster is gone, install a second filebeat instance to send them to another elastic stack
* Consul DNS works fine - outside the containers. For now, I put hardcoded IPs into the configurations used by dockered services (in config and hcl files)

#### Prepare ansible

Populate your [inventory.ini](./inventory.ini) with the public IPs of your ec2 instances. Get them e.g. with 
```
aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-server" --query "Reservations[*].Instances[*].PublicIpAddress" --output text
aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-client" --query "Reservations[*].Instances[*].PublicIpAddress" --output text
```
Put 3 client nodes into the nomad\_clients\_elasticsearch group.
Put the path to your key into your [ansible.cfg](./ansible.cfg.example).
install elastic's beats ansible role with `ansible-galaxy install elastic.beats,7.0.0`

Check your setup with `ansible all -m ping`
Note to self: If you wonder about the path where the role is installed, run `ansible-galaxy info elastic.beats`.) And the role is not great, e.g. restart when config file changes is broken.

#### Put IP into config and hcl files

Unfortunately, i couldn't make consul dns work in the containers. Also, i didn't manage to automatically fill the master ip in the elasticsearch environment. For now, please do it manually:
* get the private IP of one of the elasticserch instance
* get another private elasticsearch IP for logstash 
```
sed 's/$ES_FIRST_IP/172.31.41.218/' hcl_files/kibana.hcl.tpl > hcl_files/kibana.hcl
sed 's/$ES_FIRST_IP/172.31.41.218/' hcl_files/elasticsearch_docker.hcl.tpl > hcl_files/elasticsearch_docker.hcl
sed 's/$ES_OTHER_IP/172.31.27.73/' config_files/pipeline/logstash.conf.tpl > config_files/pipeline/logstash.conf
```
#### Run Playbooks and Check Setup

```
# install filebeat on all instances
ansible-playbook filebeat.yml
# Install docker on all nomad client nodes
ansible-playbook nomad_clients.yml
# Install curator binaries and change chroot
ansible-playbook curator.yml
# Assign node class "elasticsearch", prepare OS, create data dir
ansible-playbook elasticsearch_nomad_clients.yml
# Integrate consul into DNS
ansible-playbook consul_dns.yml
# Copy config and nomad job definition files to all client nodes
ansible-playbook copy_files.yml

### Very few checks - I should do more
ansible-playbook check_elasticsearch_nomad_clients_docker.yml
ansible-playbook check_nomad_clients.yml
```
#### Result

The consul service should be visible:
`dig @<consul server> -p 8600 rest-elasticsearch-docker.service.consul. ANY`
`dig @localhost service-kibana.service.consul. ANY`

There should be GUIs reachable from everywhere at `<nomad_consul_server>:4646` `<nomad_consul_server>:8500`

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

`aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-client" --query "Reservations[*].Instances[*].[PublicIpAddress,PrivateIpAddress]" --output table`

consul template to return one elasticsearch IP:
```
{{ with service "rest-elasticsearch-docker" }}
{{ with index . 0 }}
{{ .Address }}{{ end }}{{ end }}
```


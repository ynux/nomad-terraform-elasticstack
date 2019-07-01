### Prepare the Nomad Cluster

ansible 2.8.1

The cluster needs [task drivers](https://www.nomadproject.io/docs/drivers/index.html) on client nodes

Plan:
* elasticsearch: java
* kibana, curator, logstash: docker
* curator: exec (python)
* filebeat not under nomad control

This means that we prepare in this step:
* 3 client nodes get disks and java, and node_class=elasticsearch to pin the jobs
* docker for all clients
* filebeat for nomad clients and servers

Remarks:
* I'm not really attaching volumes to the elasticsearch servers
* We deploy only 1 logstash instance 
* For a real life setup, if you want to see the logs when the nomad cluster is gone, install a second filebeat instance to send them to another elastic stack

#### Prepare ansible

Populate your [inventory.ini](./inventory.ini) with the public IPs of your ec2 instances. Get them e.g. with `aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-server" --query "Reservations[*].Instances[*].PublicIpAddress" --output text; aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-client" --query "Reservations[*].Instances[*].PublicIpAddress" --output text`
Put 3 client nodes into the nomad_clients_elasticsearch group.

Put the path to your key into your [ansible.cfg](./ansible.cfg).

Check your setup with `ansible all -m ping -i inventory.ini`
install elastic's elasticsearch ansible role with `ansible-galaxy install elastic.elasticsearch,7.1.1`
Note to self: If you wonder about the path where the role is installed, run `ansible-galaxy info elastic.elasticsearch`.)

#### Run Playbooks and Check Setup

```
ansible-playbook elasticsearch_nomad_clients.yml -i inventory.ini 
ansible-playbook nomad_clients.yml -i inventory.ini 
# give nomad a minute to register the task drivers
sleep 60
ansible-playbook check_elasticsearch_nomad_clients.yml -i inventory.ini
ansible-playbook check_nomad_clients.yml -i inventory.ini
```
#### Configuring Elasticsearch: Ansible or Environment Variables + Nomad?

To configure Elasticsearch (path.data, cluster.name, ...), we could:
* Put it into ansible yml
* Put env vars into the ansible yml, and fill them in the nomad hcl file [elasticsearch documentation: environemnt vars](https://www.elastic.co/guide/en/elasticsearch/reference/current/settings.html#_environment_variable_substitution)
Do what makes you happy. I go with ansible.

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

### Prepare the Nomad Cluster

ansible 2.8.1

The cluster needs [task drivers](https://www.nomadproject.io/docs/drivers/index.html) on client nodes

Plan:
* elasticsearch: java
* kibana, curator, logstash: docker
* curator: exec
* filebeat not under nomad control

This means:
* 3 client nodes get disks and java, and node_class=elasticsearch to pin the jobs
* docker for all clients
* filebeat for nomad clients and servers

Remarks:
* I'm not really attaching volumes to the elasticsearch servers
* Only 1 logstash instance 
* For a real life setup, if you want to see the logs when the nomad cluster is gone, install a second filebeat to send them to another elastic stack

#### Prepare ansible

Populate your [inventory.ini](./inventory.ini) with the public IPs of your ec2 instances. Get them e.g. with `aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-server" --query "Reservations[*].Instances[*].PublicIpAddress" --output text; aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-client" --query "Reservations[*].Instances[*].PublicIpAddress" --output text`
Put 3 client nodes into the nomad_clients_elasticsearch group.

Put the path to your key into your [ansible.cfg](./ansible.cfg).

Check your setup with `ansible all -m ping -i inventory.ini`
install elastic's elasticsearch ansible role with `ansible-galaxy install elastic.elasticsearch,7.1.1`
Note to self: If you wonder about the path where the role is installed, run `ansible-galaxy info elastic.elasticsearch`.)
#### run playbooks

```
ansible-playbook elasticsearch_nomad_clients.yml -i inventory.ini 
ansible-playbook check.yml -i inventory.ini 
```

#### 
check
1 - assign node_class


#### Random Remarks
To show that we aren't scared of go templates:
`nomad node status -verbose -t '{{range .}}{{ .NodeClass }}{{"\n"}}{{end}}'`
instead of
`nomad node status -verbose -json | jq '.[].NodeClass'`
(jq is installed by packer)
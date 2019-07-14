### Use nomad to run the Elastic Stack

We put the nomad job hcl files on the nomad client nodes, and will run them from there. This obviously is just a lazy choice, the idea really is that you run it from your machine.

ssh as ubuntu to one of the client nodes, the [hcl files](../nomad_prepare/hcl_files) and [config files](../nomad_prepare/config_files) should be waiting for you here. The following part isn't automated, because the idea of this demo is to get that unique nomad hands on experience.

#### Elasticsearch
```
nomad run elasticsearch.hcl
nomad status elasticsearch
# get allocation id xxx, and run
nomad status xxx
nomad logs -stderr xxx
nomad logs xxx
```
also, check the syslog for oom killings.
If there are no issues, check if the service is in consul via the GUI, or with `consul catalog services`. 
Try if elasticsearch talks to you. 
`nomad node status -verbose` will give you the internal IPs of the nodes with class "elasticsearch". Curl to `elasticsearchip:9200`, if this works, to `elasticsearchip:9200/_cat/nodes`. If you see three nodes and one master, celebrate.
Try `curl http://rest-elsticearch.service.consul:9200/_cat/nodes`. 

Recovery changed in Elasticsearch 7, i'm not convinced of what i'm doing here, it worked for the demo.

#### Kibana
```
nomad run kibana.hcl
```
Get the external ip, e.g. by noting the node id, getting the internal ip with `nomad node status -verbose`, and retrieving the external IP from aws. Try to connect from outside to `kibana-ip:5601`. It should be empty - if it comes up at all. If Kibana isn't ready for a long time, most of the time elasticsearch is not reachable where kibana's config (in the hcl file) expects it.

#### Logstash
```
nomad run logstash.hcl
```
This should start the flow of events. Logstash takes some time to start, check the logs. When it's there, a new index should appear. If it doesn't ... Try restarting filebeat. Doublecheck the elasticsearch IP in the pipeline config.
#### Consul DNS

Now the consul services should be there, check with 
```
consul catalog services
# should come back with something like
#consul
#intra-elasticsearch
#logstash
#nomad
#nomad-client
#rest-elasticsearch
#service-kibana
```
Now is a good time to put the IPs of those services into `/etc/hosts`, which is our very basic way of integrating the Consul DNS with the existing DNS. In production, you'll want something more dynamic. This "solution" here means that you have to rerun it every time e.g. logstash moves to another node. You could run consul-template as a daemon, for example.	
Go back to `nomad_prepare`, and run
```
ansible-playbook etc_hosts.yml
```
#### Curator
```
nomad run curator.hcl
```
Curator is a bit more fun, being a periodic and exec job. Note how we had to change the chroot in the nomad client config to make this work. Feel free to schedule the job so that you can see it running.
 
#### Add Consul Services to /etc/hosts

The services won't find each other yet. Please go back to [nomad\_prepare](../nomad_prepare) and run 
```
ansible-playbook etc_hosts.yml
```

#### Result
Find the public IP of your Kibana instance, e.g. with:
```
# on ec2 instance:
nomad status kibana
# returns node id
nomad node status -verbose | grep <node id>
# returns private ip
# on your laptop:
aws ec2 describe-instances --filter "Name=tag:Name,Values=nomad-example-client" --query "Reservations[*].Instances[*].[PublicIpAddress,PrivateIpAddress]" --output table
# returns public ip
# in browser, open http://<public kibana ip>:5601
```
There you should be able to create an index pattern and see logs flowing in.

This is how far this demo goes. In a real setup, the serious work would start here.

#### What comes then?

Cleanup! Go to your terraform-nomad directory and run `terraform destroy`. Also, remove the baked AMI.

If this wasn't demo but real:
* elasticsearch: fix mapping - e.g. `agent.hostname` should be a keyword
* kibana: create visualizations
* filebeat: make sure you get all logs, also those of the containers run by nomad
* fix the DNS-Consul connection
* establish monitoring and so on and so forth
* and generally, be kind with each other & save the world

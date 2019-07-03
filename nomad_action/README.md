### Use nomad to run the Elastic Stack

We put the nomad job hcl files on the nomad client nodes, and will run them from there. This obviously is just a lazy choice, the idea really is that you run it from your machine.

ssh as ubuntu to one of the client nodes, the [hcl files](../nomad_prepare/hcl_files) and [config_files](../nomad_prepare/config_files) should be waiting for you here. The following part isn't automated, because the idea of this demo is to get that unique nomad hands on experience.

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
Try `curl http://rest-elsticearch.service.consul:9200/_cat/nodes`. 

#### What comes then?

* fix mapping of elasticsearch - e.g. `agent.hostname` should be a keyword
* create visualizations
* and generally, be kind with each other & save the world

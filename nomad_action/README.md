### Use nomad to run the Elastic Stack

Ssh to a on of the client nodes, the [hcl files](../nomad_prepare/files) should be waiting for you here. This part isn't automated, because the idea of this demo is to get that unique hands on experience.

```
nomad run elasticsearch_java.hcl
nomad status elasticsearch_java
# get allocation id xxx, and run
nomad status xxx
nomad logs -stderr xxx
nomad logs xxx
```
also, check the syslog for oom killings.
	
sudo chown -R elasticsearch. /etc/elasticsearch/

/usr/share/elasticsearch/jdk/bin/java -Xms512m -Xmx512m -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly -XX:+AlwaysPreTouch -server -Djava.awt.headless=true -Dfile.encoding=UTF-8 -Djna.nosys=true -Djdk.io.permissionsUseCanonicalPath=true -Dio.netty.noUnsafe=true -Dio.netty.noKeySetOptimization=true -Dio.netty.recycler.maxCapacityPerThread=0 -Dlog4j.shutdownHookEnabled=false -Dlog4j2.disable.jmx=true -Dlog4j.skipJansi=true -XX:+HeapDumpOnOutOfMemoryError -Dio.netty.allocator.type=unpooled -Des.path.home=/usr/share/elasticsearch -Des.path.conf=/etc/elasticsearch -Des.distribution.flavor=default -Des.distribution.type=deb -Des.bundled_jdk=true -cp /usr/share/elasticsearch/lib/* org.elasticsearch.bootstrap.Elasticsearch -p /var/run/elasticsearch/elasticsearch.pid --quiet

translate into job.hcl for java task driver

Comes up (when i got class_path right), but nomad or elasticsearch crash, too little memory for both (t2.micro, 1G RAM)
-> change instance_type in terraform to t3.large, 8 GB RAM
-> Autoscaling group: kill nodes, new ones have new instance type, reprovision
Nice!
When you change the memory for elasticsearch in the jvm.options, don't forget to change limits in job.hcl - else nomad will kill elasticsearch

open ports 9200, 9300 by changing terraform, append contents of security_groups_elasticsearch.tf
to have them discover each other:
* ansible, we have the elasticsearch host group defined anyway
* nomad template
* plugin - a bit old 

#### What comes then?

* fix mapping of elasticsearch - e.g. `agent.hostname` should be a keyword
* create visualizations
* and generally, be kind with each other & save the world

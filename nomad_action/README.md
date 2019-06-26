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

translate into job.hcl

nomad run elasticsearch_java.hcl
nomad stat

Jun 26 10:17:50 ip-172-31-20-113 kernel: [ 9984.562022] Task in /nomad/ca87c1f2-b1a1-bcde-9ebc-efaa1d3c0d3c killed as a result of limit of /nomad/ca87c1f2-b1a1-bcde-9ebc-efaa1d3c0d3c


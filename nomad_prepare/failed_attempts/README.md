This is a collection of code that nearly works.

1. Run elasticsearch with the java task driver. I installed elasticsearch with elastic's elasticsearch ansible role and made the elasticsearch java (12!) the default java. Then I struggled to get elasticsearch up and running. Turns out to be a hassle - a service is so much more than a java process. There's status handling and commands like ulimit before and checking for configs and ... all those nice things systemd or init.d did for you when you were young. At some point I gave up and went for the docker driver.
install elastic's elasticsearch ansible role with `ansible-galaxy install elastic.elasticsearch,7.1.1`

2. Then I tried to marry Consul Services and DNS with the server's DNS. It nearly works. With the `consul_dns.yml` you'll be able to resolve the consul services. But only outside containers. And you lose the rest of the world. I think this AMI comes with a very basic DNS setup that works for AWS, but not for more complex use cases.
What does work is using consul-templates to generate lines for /etc/hosts.

3. Consul templates are a powerful tool, and I managed to get the IPs magically. But not to get rid of the blanks. So i gave up. 

# Create an Elastic Stack on Nomad, for Nomad; with SearchGuard

for the Search Meetup in Munich, July 2019

1. Set up a nomad cluster with terraform: [nomad\_install](./nomad_install)
2. Prepare task drivers (java, docker), install filebeat: [nomad\_prepare](./nomad_prepare)
3. Spin up elasticsearch, logstash, kibana, curator [nomad\_in\_action](./nomad_in_action)
3. Protect with SearchGuard

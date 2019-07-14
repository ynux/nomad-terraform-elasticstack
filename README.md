# Create an Elastic Stack on Nomad, for Nomad; with SearchGuard

for the Search Meetup in Munich, July 2019

This is a demo setup. Not for production, not for complete automation - i intentionally do steps manually where i want to show the system.

The target is to have a basic elastic stack running on a nomad cluster, collecting logs from the nodes. This is not for spinning up elasticsearch clusters on nomad on demand and in big numbers - for this, check out York Gersie's talk "Elasticsearch as a Service using the HashiStack".

1. Set up a nomad cluster with packer and terraform: [nomad\_install](./nomad_install)
2. Prepare the cluster with ansible: [nomad\_prepare](./nomad_prepare)
3. Spin up elasticsearch, logstash, kibana, curator [nomad\_action](./nomad_action)
3. Protect with SearchGuard - I didn't manage to do this part, tell me if you're interested

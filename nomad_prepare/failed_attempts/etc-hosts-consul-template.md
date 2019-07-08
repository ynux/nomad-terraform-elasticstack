```
root@ip-172-31-27-36:~# wget https://releases.hashicorp.com/consul-template/0.20.0/consul-template_0.20.0_linux_386.tgz
root@ip-172-31-27-36:~# tar -xvf consul-template_0.20.0_linux_386.tgz
consul-template
root@ip-172-31-27-36:~# cat etc_hosts.tpl 
{{range services}}# {{.Name}}{{range service .Name}}
{{.Address}} {{ .Name}}.service.consul {{end}}

{{end}}

root@ip-172-31-27-36:~# ./consul-template -template="etc_hosts.tpl:output.txt" -once
root@ip-172-31-27-36:~# cat output.txt 
# consul
172.31.11.1 consul.service.consul 
172.31.17.52 consul.service.consul 
172.31.34.62 consul.service.consul 

# nomad
172.31.11.1 nomad.service.consul 
172.31.11.1 nomad.service.consul 
172.31.11.1 nomad.service.consul 
172.31.17.52 nomad.service.consul 
172.31.17.52 nomad.service.consul 
172.31.17.52 nomad.service.consul 
172.31.34.62 nomad.service.consul 
172.31.34.62 nomad.service.consul 
172.31.34.62 nomad.service.consul 

# nomad-client
172.31.12.71 nomad-client.service.consul 
172.31.27.36 nomad-client.service.consul 
172.31.15.53 nomad-client.service.consul 
172.31.32.144 nomad-client.service.consul 



root@ip-172-31-27-36:~# 
```

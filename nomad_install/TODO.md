# some notes
version 7.1, new is 9.3 - but this is packered into the image, not sure if i want to change this


# status:

nomad nodes don't find each other
consul does
```

[ec2-user@ip-172-31-47-2 config]$ consul members
Node                 Address             Status  Type    Build  Protocol  DC            Segment
i-0414d396bc6c12e0f  172.31.47.2:8301    alive   server  1.0.3  2         eu-central-1  <all>
i-0a44f9b4a28daa8bb  172.31.26.165:8301  alive   server  1.0.3  2         eu-central-1  <all>
i-0be353773d209d858  172.31.3.66:8301    alive   server  1.0.3  2         eu-central-1  <all>
i-05a4a4400bd00d17e  172.31.34.80:8301   alive   client  1.0.3  2         eu-central-1  <default>
i-0cf19f8d68e72f91a  172.31.23.136:8301  alive   client  1.0.3  2         eu-central-1  <default>

```
i had to open port 4648 in the security group


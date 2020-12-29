# auto-k3s

Initalize terraform
`terraform init terraform`

Apply 
`terraform apply -var="hcloud_token=<HETZNER_TOKEN>" terraform`

This will setup 

- 3 servers with k3s installed
- 1 load balancer with 1 service forwarding all tls 6443 (k8) traffic
- 1 network with all of the above connected

## TODO

1. Certmanager

Get certmanager working along side traefik

2. Loadbalencer

2 options here:

- Set the hetzner loadbalancer to forward all http and https traefik on 443 and 80 and somehow share the cert manager cert with hetzner
- Use metallb and use a floating ip for the external ip


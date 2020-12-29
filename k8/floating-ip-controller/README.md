# Floating IP controller

Taken from here:
https://community.hetzner.com/tutorials/install-kubernetes-cluster

In order to use an internal load balancer a single IP will be required to route
traffic. This ip will be equal to a Hetzner floating ip. Since a floating ip
can only be assigned to a single node, if this nodes goes down (becomes Not
Ready) then this controller will move the floating ip to a different node.

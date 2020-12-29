# Create a network for all nodes and lb
resource "hcloud_network" "k3s_network" {
  name = "k3s_network"
  ip_range = "10.0.1.0/24"
}

resource "hcloud_network_subnet" "k3s_subnet" {
  network_id = hcloud_network.k3s_network.id
  type = "cloud"
  network_zone = "eu-central"
  ip_range   = "10.0.1.0/24"
}


# Create load balancer
resource "hcloud_load_balancer" "load_balancer" {
  name = "k3s-load-balancer"
  load_balancer_type = "lb11"
  location = var.location
}

# Create inital server
resource "hcloud_server" "server_0" {
  name = "server-0"
  image = "ubuntu-20.04"
  server_type = "cx11"
  location = var.location 
  ssh_keys = ["jelgar@UbuntuPC"]
  
  connection {
    type        = "ssh"
    user        = "root" 
    host        = self.ipv4_address
    private_key = file(var.ssh_key_private)
  }

  provisioner "remote-exec" {
    inline = ["curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=' --write-kubeconfig ~/.kube/config --write-kubeconfig-mode 644 --cluster-init' K3S_TOKEN='${var.k3s_token}' sh - "]
  }
}

# Join the rest
resource "hcloud_server" "servers" {
  count = var.server_nodes_count - 1
  name = "server-${count.index + 1}"
  image = "ubuntu-20.04"
  server_type = "cx11"
  location = var.location
  ssh_keys = ["jelgar@UbuntuPC"]
  
  connection {
    type        = "ssh"
    user        = "root"
    host        = self.ipv4_address
    private_key = file(var.ssh_key_private)
  }

  provisioner "remote-exec" {
    inline = ["curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=' --write-kubeconfig ~/.kube/config --write-kubeconfig-mode 644 --cluster-init --server https://${hcloud_server.server_0.ipv4_address}:6443 --tls-san ${hcloud_load_balancer.load_balancer.ipv4}' K3S_TOKEN='${var.k3s_token}' sh - "]
  }

}

# Target all load balancers
resource "hcloud_load_balancer_target" "load_balancer_target_server_0" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  server_id        = hcloud_server.server_0.id
}

resource "hcloud_load_balancer_target" "load_balancer_target_servers" {
  count = var.server_nodes_count - 1 
  type             = "server"
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  server_id        = hcloud_server.servers[count.index].id
}

resource "hcloud_load_balancer_service" "load_balancer_service" {
    load_balancer_id = hcloud_load_balancer.load_balancer.id
    protocol = "tcp"
    listen_port = "6443"
    destination_port = "6443"
}

# Add all servers and lb to network
resource "hcloud_load_balancer_network" "load_balancer_network" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  network_id = hcloud_network.k3s_network.id
  ip = "10.0.1.2"
}

resource "hcloud_server_network" "server_0_network" {
  server_id = hcloud_server.server_0.id
  network_id = hcloud_network.k3s_network.id
  ip = "10.0.1.3"
}

# Add all nodes to k3s network
resource "hcloud_server_network" "servers_network" {
  count = var.server_nodes_count - 1
  server_id = hcloud_server.servers[count.index].id
  network_id = hcloud_network.k3s_network.id
  ip = "10.0.1.${count.index + 4}"
}

# resource "null_resource" "copy_kube_config" {
#   provisioner "local-exec" {
#     command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${hcloud_server.server_0.ipv4_address}:.kube/config ~/.kube/config; sed -i 's/127.0.0.1/${hcloud_load_balancer.load_balancer.ipv4}/g' ~/.kube/config"
#   }
# }

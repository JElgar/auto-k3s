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

# Create first server
resource "hcloud_server" "server-0" {
  name = "server-0"
  image = "ubuntu-20.04"
  server_type = "cx11"
  location = "nbg1"
  ssh_keys = ["jelgar@UbuntuPC"]
  
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${self.ipv4_address}"
    private_key = "${file(var.ssh_key_private)}"
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
  location = "nbg1"
  ssh_keys = ["jelgar@UbuntuPC"]
  
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${self.ipv4_address}"
    private_key = "${file(var.ssh_key_private)}"
  }

  provisioner "remote-exec" {
    inline = ["curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=' --write-kubeconfig ~/.kube/config --write-kubeconfig-mode 644 --cluster-init --server https://${hcloud_server.server-0.ipv4_address}:6443' K3S_TOKEN='${var.k3s_token}' sh - "]
  }

}

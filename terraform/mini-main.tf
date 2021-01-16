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

# Create inital server
resource "hcloud_server" "server_0" {
  name = "server-0"
  image = "ubuntu-20.04"
  server_type = "cx21"
  location = var.location 
  ssh_keys = ["jelgar@UbuntuPC"]
}

resource "hcloud_server_network" "server_0_network" {
  server_id = hcloud_server.server_0.id
  network_id = hcloud_network.k3s_network.id
  ip = "10.0.1.3"
}

# Run ansible playbook on all servers
resource "null_resource" "provisioner" {
  provisioner "local-exec" {
    command = "ansible-playbook -e 'server_0=${hcloud_server.server_0.ipv4_address}' -e 'servers=' ansible/install-k3s.yml"
  }
}

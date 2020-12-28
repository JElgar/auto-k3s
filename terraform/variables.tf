variable "server_nodes_count" {
  description = "number of server nodes"
  default = 3
}

variable "agent_nodes_count" {
  description = "number of agent nodes"
  default = 1
}

variable "k3s_token" {
  description = "super secret token for k3s"
  default = "super_secret_token"
}

variable "ssh_key_private" {
    description = "The private ssh key for hetzner"
    default = "~/.ssh/hetzner_dev_rsa"
}

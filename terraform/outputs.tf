output "server_0_ip" {
    description = "Ip of server 0"
    value = "${hcloud_server.server_0.ipv4_address}"
}

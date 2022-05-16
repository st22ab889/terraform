output "ip" {
  # 使用 server[*] 这种表示法来引用所有实例的公网 IP 地址, "[*]"表示包含全部索引的资源。
  # 如果只想引用第一台实例的公网 IP 地址, 可以使用 server[0] 这样表示。
  # join 函数将 IP 地址列表拼接在一起
  value = join("\n", aws_instance.server[*].public_ip)  
  description = "AWS EC2 public IP"
}
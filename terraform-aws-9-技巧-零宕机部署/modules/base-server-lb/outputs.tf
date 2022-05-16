output "ip" {
  value       = join("\n", aws_instance.server[*].public_ip)
  description = "AWS EC2 public IP"
}

# 定义 dns 输出变量便于获取弹性 IP 的域名信息
output "dns" {
  value       = aws_eip.lb.public_dns
  description = "AWS EIP DNS"
}
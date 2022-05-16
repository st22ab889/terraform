output "WEB_IP" {
  # 注意:在这里是引用模块的输出, 格式：module.[模块名称].[模块输出]
  value = module.nginx-server.ip
  description = "NGINX web server ip address"
}

output "SS_IP" {
  value = module.ss-server.ip
  description = "Shadowsocks server ip address"
}

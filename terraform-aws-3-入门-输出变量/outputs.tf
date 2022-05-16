# outputs.tf 文件用来保存输出变量,输出变量由 output 块组成
output "DNS" {
  # value 参数表示输出变量返回给用户的结果
  value = aws_instance.web.public_dns
  description = "AWS EC2 public DNS"
}

output "IP" {
  value = aws_instance.web.public_ip
  description = "AWS EC2 public IP"
  # 如果返回的信息比较敏感(比如密码之类的信息),可以把这个参数设为true
  sensitive = true
}

/*
* 运行"terraform apply"命令后会打印出输出变量的值,此时也可以使用下面两种方式查看输出变量的值
*   "terraform output"命令查看输出变量
*   "terraform output 变量名称"查看指定输出变量的值
*/
/*
 * 创建 AWS EC2 实例
 * 允许通过 SSH 登录
 */

# terraform 具有许多内置函数,包括数值、字符串、集合、编码、文件系统、日期与时间、哈希及加密、IP子网、类型转换等类别

provider "aws" {
  # "var.变量名"表示引用变量
  region = var.region
}

resource "aws_instance" "web" {
  # lookup 是内置函数, lookup 可以从map中获取值,在本地中通过查询aws数据中心区域，从而取得ami的id
  ami = lookup(var.amis, var.region)
  instance_type = var.instance_type
  key_name = aws_key_pair.ssh.key_name
  # 通过该参数 terraform 在创建 EC2 实例后能够调用脚本,从而在远程系统中利用apt命令安装nginx web 服务
  user_data = file("setup_nginx.sh")
  # 通过 tags 参数可以将 EC2 实例命名为 nginx-web-server
  tags = {
    Name = "nginx-web-server"
  }
}

# 添加 SSH 登录密钥
resource "aws_key_pair" "ssh" {
  key_name = "admin"
  # file 函数读取给定文件的内容,并以字符串形式返回
  public_key = file(var.public_key)
}

// 开放 22 端口,允许 SSH 登录
resource "aws_security_group_rule" "ssh" {
  type = "ingress"
  from_port = 22 
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]        
  security_group_id = var.security_group
}

# 开放 80 端口,允许 web 访问
resource "aws_security_group_rule" "web" {
  type = "ingress"
  from_port = 80  
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = var.security_group
}
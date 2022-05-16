/*
 * 创建 AWS EC2 实例
 * 允许通过 SSH 登录
 */

# 模板就是可以让文件中的部分内容用变量来替代,从而能够有更广泛的适用场景。
# Graphviz 这个工具可以显示出 terraform 各个资源之间的依赖图。
provider "aws" {
  region = var.region
}


data "aws_security_groups" "default" {
  filter {
    name = "group-name"
    valuse = ["default"]
  }
}

resource "aws_instance" "web" {
  ami = lookup(var.amis, var.region)
  instance_type = var.instance_type
  key_name = aws_key_pair.ssh.key_name
  user_data = templatefile("setup_nginx.sh", {time = timestamp()})
  tags = {
    Name = "nginx-web-server"
  }
}

resource "aws_key_pair" "ssh" {
  key_name = "admin"
  public_key = file(var.public_key)
}

# 开放 22 端口,允许 SSH 登录
resource "aws_security_group_rule" "ssh" {
  type = "ingress"
  from_port = 22 
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = data.aws_security_groups.default.ids[0]
}

# 开放 80 端口,允许 web 访问
resource "aws_security_group_rule" "web" {
  type = "ingress"
  from_port = 80  
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = data.aws_security_groups.default.ids[0]
}

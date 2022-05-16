/*
 * 基础服务模块 
 * 使用 base-server 模块创建基本的服务器,在此基础上可以根据自身的需要搭建各种服务 ssh 模块用来准备ssh相关的事务,包括添加SSH公钥、开放SSH端口
 * 
 * 利用 terraform 模块可以实现重复使用基础设施资源,在 terraform 本身看来, 模块之不过是一个或多个资源的容器,通过 terraform 的模块机制,
 * 对想要重用的资源进行封装,然后像函数一样方便的调用. 简而言之, terraform 模块只是不包含 provider 的代码.
 *
 * 在terraform的模块目录中,同样包含 main.tf、variables.tf、outputs.tf 三个文件:
 *    main.tf 定义模块中用来管理的一个或多个基础设施的资源
 * 	  variables.tf 是模块的输入,相当于函数的参数
 * 	  outputs.tf 是模块的输出,相当于函数的返回值
 */
data "aws_security_groups" "default" {
  filter {
    name = "group-name"
    valuse = ["default"]
  }
}

# 创建 EC2 实例
resource "aws_instance" "server" {
  ami = lookup(var.amis, var.region)
  instance_type = var.instance_type
  key_name = var.ssh_key_name
  user_data = var.server_script
  tags = {
    Name = var.server_name
  }
}

# 开放其它端口
resource "aws_security_group_rule" "other" {
  type = "ingress"
  from_port = var.server_port 
  to_port = var.server_port
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = data.aws_security_groups.default.ids[0]
}
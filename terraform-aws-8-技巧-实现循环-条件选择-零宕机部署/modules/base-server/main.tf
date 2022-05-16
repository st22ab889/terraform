/*
 * 基础服务模块
 * 
 * 默认情况下, terraform 的资源块只允许创建一个基础设施资源对象, 通过使用 count 元参数能够让 terraform 一次性创建多个基础设施资源对象, 
 * 对于创建服务器集群的应用场景, 在count 原参数的帮助下就方便很多。
 */
data "aws_security_groups" "default" {
  filter {
    name = "group-name"
    valuse = ["default"]
  }
}

# 创建 EC2 实例
resource "aws_instance" "server" {
  # count 参数只接收整数值, 这里设置 count 的值为2,表示让 terraform 创建 2 台 EC2 实例
  count = 2
  ami = lookup(var.amis, var.region)
  instance_type = var.instance_type
  key_name = var.ssh_key_name
  user_data = var.server_script
  tags = {
    # count.index 为这些实例的相应索引,从0开始计数
    Name = "${var.server_name}-${count.index}"
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
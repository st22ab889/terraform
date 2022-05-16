/*
 * 基础服务器模块
 */
data "aws_security_groups" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

# 创建 EC2 实例
resource "aws_instance" "server" {
  ami           = lookup(var.amis, var.region)
  instance_type = var.instance_type
  key_name      = var.ssh_key_name
  user_data     = var.server_script
  tags = {
    Name = "${var.server_name}"
  }

  # lifecycle 也是 terraform 元参数, 通过这个参数可以对资源的生命周期进行控制,从而最终改变 terraform 的默认行为
  # lifecycle 官方文档: https://www.terraform.io/language/meta-arguments/lifecycle
  lifecycle {
    # create_before_destroy 设置为 true 表示让 terraform 先创建要替换的基础设施资源,然后再销毁原来的资源对象
    create_before_destroy = true
  }
  
  # lifecycle 还支持下列参数: 
  #   prevent_destroy 值为 true 时, 将阻止 terraform 销毁基础设施资源
  #   ignore_changes   值为一个list, 通过设置特定的资源属性以便让 terraform 忽略更新相关的资源对象
}

# 开放其它端口
resource "aws_security_group_rule" "other" {
  type              = "ingress"
  from_port         = var.server_port
  to_port           = var.server_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_groups.default.ids[0]
}

# 绑定弹性 IP 地址
# 为了利用 terraform 实现零宕机部署, 为 EC2 实例绑定一个弹性IP地址, 这样即便旧的 EC2 实例被销毁, 仍然能通过弹性IP地址访问新建的 EC2 实例.
# aws的弹性IP地址由"aws_eip"资源类型实现, 其中 instance 参数用来关联 EC2 实例, 而 vpc 参数告诉该弹性IP地址应当在VPC(VPC就是虚拟网络)中.
resource "aws_eip" "lb" {
  instance = aws_instance.server.id
  vpc      = true
}
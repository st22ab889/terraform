/*
 * 基础服务器模块
 *
 * 在 terraform 的 HCL 配置语言中, 另外一个能够实现循环效果的元参数是 for_each, 与 count 不同的是, for_each 元参数只支持 map 和 set 这两种类型。
 */
data "aws_security_groups" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

# 创建 EC2 实例
resource "aws_instance" "server" {
  # 因为 terraform 的 HCL配置语言并没有字面量的集合表示法, 所以利用 toset 函数将列表转换为集合类型, for_each 元参数一旦被设置,便能使用它的 each 对象
  for_each      = toset(["dev", "test"])
  ami           = lookup(var.amis, var.region)
  instance_type = var.instance_type
  key_name      = var.ssh_key_name
  user_data     = var.server_script
  tags = {
    # 在此将 each.key 作为 ec2 实例的后缀, each 还有个对象是 each.value ,不过在使用集合的情况下和 each.key 效果一样
    Name = "${var.server_name}-${each.key}"
  }
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
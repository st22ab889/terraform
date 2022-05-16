/*
 * 创建 AWS EC2 实例
 * 允许通过 SSH 登录
 */

# terrafrom 的输入变量可以将代码参数化, 而输出变量可以将返回的重要数据通过输出变量资源属性的值就能以适当的方式暴露给用户

provider "aws" {
  region = var.region
}

# 使用数据源的方式获取 security_group_id, 也就是利用数据源直接从云供应商抓取想要的数据信息.
# 数据源使用 data 块进行声明; "aws_security_groups"表示使用这个数据源; "default"为数据源的名称,这项可以自定义.
data "aws_security_groups" "default" {
  # 使用过滤参数找出符合条件的安全组,即名为"default"的安全组,该参数通过名值对进行条件过滤
  filter {
    # 这里根据"group-name"过滤,要求匹配值"default"
    name = "group-name"
    valuse = ["default"]
  }
}

resource "aws_instance" "web" {
  ami = lookup(var.amis, var.region)
  instance_type = var.instance_type
  key_name = aws_key_pair.ssh.key_name
  user_data = file("setup_nginx.sh")
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
  # 引用数据源,因为返回的列表类型,所以通过索引下标的形式引用
  security_group_id = data.aws_security_groups.default.ids[0]
}

# 开放 80 端口,允许 web 访问
resource "aws_security_group_rule" "web" {
  type = "ingress"
  from_port = 80  
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  # 引用数据源    
  security_group_id = data.aws_security_groups.default.ids[0]
}

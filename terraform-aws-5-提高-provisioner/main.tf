/*
 * 创建 AWS EC2 实例
 * 允许通过 SSH 登录
 */

/*
 * 上节搭建 nginx web 服务使用云供应商的 user_data(用户数据)来运行shell 脚本, 以便安装 nginx 服务器,实际上 terraform 也提供了 Provisioner(供应者) 的方式来执行这种操作,
 * 通过Provisioner能够在基础设施资源创建或销毁时能执行定制化的操作,而且Provisioner可以和Chef、Puppet、Ansible、SaltStack等配置管理工具结合使用,从而能够利用现有配置管理资源.
 *
 * connection和provisioner块以便在 terraform 在创建 EC2 实例后执行后期操作
 *    connection 参考文档：https://www.terraform.io/language/resources/provisioners/connection
 *    provisioners 参考文档：https://www.terraform.io/language/resources/provisioners/syntax
 *
 * terraform 还提供了一些其它 provisioners: (注意:下面并没有列出所有的 Provisioner) 
 *     Chef Provisioner: 用于在远端服务器执行chef管理配置工具
 *     Habitat Provisioner: 利用 habitat 工具在远端服务器上管理应用及服务
 *     local-exec Provisioner: terraform 创建基础设施资源后,调用本机的命令
 *     Salt Masterless Provisioner: 用于在远端服务器执行SaltStack管理工具 
 *
 * 当虚拟服务器创建完成后,通常需要执行些后期的操作,比如安装软件包,配置系统以及服务等.为了说明 Provisioner 的具体用法,本次搭建科学上网服务. 
 */

provider "aws" {
  region = var.region
}

data "aws_security_groups" "default" {
  filter {
    name = "group-name"
    valuse = ["default"]
  }
}

# 创建 EC2 实例,运行 Docker 容器
resource "aws_instance" "ss" {
  ami = lookup(var.amis, var.region)
  instance_type = var.instance_type
  key_name = aws_key_pair.ssh.key_name
  tags = {
    Name = "ssh-server"
  }

  # 连接远端服务器
  # connection 块告诉 terraform 用哪种方式与远端机器通信,比如远端服务器是linux,一般可以使用ssh进行通信,如果是windows,可以利用 winrm
  connection {
    type = "ssh"
    # 登录远端服务器的用户名, SSH默认为root, winrm默认为Administrator
    user = "ubuntu"
    private_key = file(id_rsa)
    host = aws_instance.ss.public_ip
  }

  # 为了使shadowsocks服务更加好用,需要将对其进行定制化的配置,以便满足特定需求. ss-config.json是shadowsocks配置文件模板.
  # terraform 提供的 file provisioner 能够将文件或目录复制到远端服务器上,这一步将shadowsocks配置文件上传到远端服务器.
  provisioner "file" {
    # 非模板文件可以使用 source 参数来指定源文件或内容
    content = templatefile("ss-config.json", {server = aws_instance.ss.public_ip, password = var.ss_password})
    destination = "/var/tmp/ss-config.json"
  }

  # 安装 Docker,并运行 SS 容器
  # 本例中 terraform 需要在远程服务器上安装 docker, 然后利用docker容器提供shadowsocks服务,所以选用 remote-exec provisioner,
  # 通过 remote-exec provisioner 不仅能够在远端服务器上执行各种命令,而且也可以运行脚本.
  provisioner "remote-exec" {
    # inline 参数可以接收一个命令列表,在EC2实例创建后就可以按顺序执行里面的命令
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io",
      
      # 使用 shadowsocks 默认配置
      # "sudo docker run -e PASSWORD=${var.ss_password} -p 8388:8388/udp -d shadowsocks/shadowsocks-libev"
      
      # 使用 shadowsocks 自定义配置
      "sudo docker run -v /var/tmp:/var/tmp -e ARGS='-c /var/tmp/ss-config.json' -p 8388:8388 -p 8388:8388/udp -d shadowsocks/shadowsocks-libev"
    ]
    # script 参数用于执行单个脚本,scripts 用来执行多个脚本. inline、script、scripts 这些参数是互斥的,不能同时使用
  }
}

# 添加 SSH 登录密钥
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

# 开放 8388 端口,允许 ss 访问
resource "aws_security_group_rule" "ss" {
  type = "ingress"
  from_port = 8388 
  to_port = 8388
  protocol = "all"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = data.aws_security_groups.default.ids[0]
}

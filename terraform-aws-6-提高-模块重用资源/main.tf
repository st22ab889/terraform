/*
 * 使用基础服务器模块
 */
provider "aws" {
  region = var.region
}

# 调用模块,通过 prep-ssh 模块准备 SSH 公钥并开放 SSH 端口
module "ssh-key-name" {
  source = "./modules/prep-ssh"
  
  public_key = var.public_key
}

# 通过 base-server 模块创建 nginx web server
module "nginx-server" {
  # source 参数指定本地模块的路径或远程模块的地址
  source = "./modules/base-server"

  # 自定义模块输入变量
  server_name = "nginx-server"
  server_port = 80
  server_script = templatefile("setup__nginx.sh", { time = timestamp() })
  # 下面的模块输入变量使用默认值在 variables.tf 文件中指定
  region = var.region
  amis = var.amis
  instance_type = var.instance_type
  ssh_key_name = module.ssh-key-name.key_name
}

# 通过 base-server 模块创建 shadowsocks proxy server
module "ss-server" {
  source = "./modules/base-server"
  
  server_name = "ss-server"
  server_port = 8388
  # 为了统一使用 base-server 模块，把搭建 shadowsocks的命令转换为了脚本, 该脚本文件的模板文件为 setup_ss.sh
  server_script = templatefile("setup_ss.sh", { password = var.ss_password })
  region = var.region
  amis = var.amis
  instance_type = var.instance_type
  ssh_key_name = module.ssh-key-name.key_name
}
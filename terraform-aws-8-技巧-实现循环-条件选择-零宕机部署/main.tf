/*
 * 应用基础服务器模块
 *
 * terraform 的每个资源块除了它所支持的特定参数外, 也有一种被称为 Meta-Argument 元参数的参数, 所谓元参数是指这种参数能够应用到任意的资源块中, 
 * 从而最终达到更改资源原有行为的目的, 事实上 provisioner 和 connection 就是元参数, 本节使用 count 和 for_each 这两个元参数实现循环效果。
 *
 * terraform 提供了三目运算符, 结合 count 元参数就能实现 if 判断。
 * 示例: 当为不同的环境准备基础设施资源时, 每个环境所需要的 EC2 实例数量并不一样, 比如测试环境需要两台, 而生产环境需要更多,如果结合 terraform 工作区,
 *      那么就能够根据相应的条件进行选择。
 * 
 * "terraform get"命令用于下载并更新 terraform 模块 
 */
provider "aws" {
  region = "ap-northeast-1"
}

module "ssh-key-name" {
  source = "./modules/prep-ssh"

  public_key = "id_rsa.pub"
}

module "nginx-server" {

  // 使用 count 元参数实现多实例
  # source = "./modules/base-server"
  
  // 使用 for_each 元参数实现多实例
  # source = "./modules/base-server-foreach"
  
  // 使用三目运算符和工作区实现 if 判断 
  source = "./modules/base-server-if"

  server_name   = "nginx-server"
  server_port   = 80
  server_script = templatefile("setup_nginx.sh", { time = "Hello, 2019" })
  region        = "ap-northeast-1"
  amis          = { ap-northeast-1 = "ami-0cb1c8cab7f5249b6" }
  instance_type = "t2.micro"
  ssh_key_name  = module.ssh-key-name.key_name
}
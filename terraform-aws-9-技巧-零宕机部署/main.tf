/*
 * 应用基础服务器模块
 * 
 * 零宕机部署:
 *    1.对于关键的服务而言, 在更新或升级时通常会使用零宕机部署方式, 也就是说在变更过程中不停机, 这种部署方式能够将风险将到最低, 
 *      使用户得到无感知的友好升级体验。
 *    2.默认情况下 terraform 是按照先销毁后创建的顺序部署, 很难不使服务受到影响, 假如可以控制 terrform 的操作顺序, 
 *      即先创建基础设施资源再销毁就能实现零宕机。
 */
provider "aws" {
  region = "ap-northeast-1"
}

module "ssh-key-name" {
  source = "./modules/prep-ssh"

  public_key = "id_rsa.pub"
}

module "nginx-server" {
  // 零宕机部署
  source = "./modules/base-server-lb"

  server_name   = "nginx-server"
  server_port   = 80
  server_script = templatefile("setup_nginx.sh", { time = "Hello again,  2019" })
  region        = "ap-northeast-1"
  amis          = { ap-northeast-1 = "ami-0cb1c8cab7f5249b6" }
  instance_type = "t2.micro"
  ssh_key_name  = module.ssh-key-name.key_name
}
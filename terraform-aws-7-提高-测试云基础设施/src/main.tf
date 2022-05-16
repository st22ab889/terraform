/*
 * 测试基础服务器模块
 * 只有经过测试的基础设施代码创建的基础设施才会更加可靠,虽然可以直接执行 terraform 命令来进行手动测试, 但是这个方式的效率较低, 本节主要讲解自动化测试。
 * 
 * terratest (https://github.com/gruntwork-io/terratest) 简介:
 *    本例中使用 terratest 作为 terraform 代码的测试工具, terratest是用来为基础设施代码编写自动化测试的 GO 程序库,具有简单易用的特点, 
 *    terratest 不仅能够测试 terraform 代码、Template(模板)、docker 镜像, 而且还支持 aws，谷歌 cloud, 微软azure 等云厂商 API。
 *
 * 在使用 terratest 之前需要确保所用操作系统包含 go 和 Dep(Dep是Goland的依赖包管理工具):
 *     DEP(已过时)：https://github.com/golang/dep  
 *     mod(代替DEP)：https://golang.org/ref/mod   
 *        
 * 测试原理就是利用 go 的内置库 testing 来编写 GO 的自动化测试用例, 因此只需执行"go test"就可以直接运行测试套件。
 * 在执行 go test 之前需要通过 dep 工具获取依赖库,确保依赖库在 test 目录中。
 * 
 * 测试用到的相关命令如下:
 *    "dep init" 命令将初始化自动化测试项目,同时在当前目录创建 Gopkg.lock 和 Gopkg.toml 文件 以及 vendor 目录。
 *    "dep ensure" 获取 go 依赖库。
 *    "go test -v -timeout 30m" 执行自动化测试。 
 *        -v 表示冗余输出(会详细显示所有测试函数运行细节),。
 *        -timeout 设置测试超时时间, 默认值为 10 分钟, 这里设置为 30 分钟以避免因时间不够而被迫中断测试。
 */
provider "aws" {
  region = "ap-northeast-1"
}

module "ssh-key-name" {
  source = "../modules/prep-ssh"

  public_key = "../id_rsa.pub"
}

# 由于在此直接对 terraform 参数进行赋值,所以不再需要输入变量定义
module "nginx-server" {
  source = "../modules/base-server"

  server_name   = "nginx-server"
  server_port   = 80
  server_script = templatefile("../setup_nginx.sh", { time = "Hello, 2019" })
  region        = "ap-northeast-1"
  amis          = { ap-northeast-1 = "ami-0cb1c8cab7f5249b6" }
  instance_type = "t2.micro"
  ssh_key_name  = module.ssh-key-name.key_name
}
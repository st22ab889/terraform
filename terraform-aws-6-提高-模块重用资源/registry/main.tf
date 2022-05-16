/*
 * 使用外部模块
 * 使用 terraform 官方认可的 ec2-instance 模块创建 ec2-instance
 */

/*
 * 除了把 terraform 模块托管到 github 之类的公共代码仓库之外, terraform 本身也提供了 Terraform Registry,
 * 这是一个用来公开分发 terraform 模块的平台,具有来自 terraform 官方或社区分享的各种模块,包括 AWS、Google Cloud、微软azure、阿里云等等。
 */

 provider "aws" {
   region = var.region
 }

# 调用模块
module "ec2-instance" {
    # source 参数指定 Terraform Registry 中的模块的源地址, version 参数表示模块版本
    source = "terraform-aws-modules/ec2-instance/aws"
    version = "2.8.0"

    # 下面是 ec2-instance 模块的必须参数
    ami = "ami-0cb1c8cab7f5249b6"               # ami ID
    instance_type = "t2.micro"                  # 实例类型
    name = "myec2"                              # 服务器名称
    vpc_security_group_ids = "sg-a361e5da"      # 安全组
}
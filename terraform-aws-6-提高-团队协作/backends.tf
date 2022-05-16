terraform {
  # remote 是使用的远端存储, 块里面是 terraform cloud backend 的参数
  backend "remote" {
    hostname = "app.terraform.io"    # 指定远端存储的主机名称,这里是 terraform cloud 的域名 
    organization = "selfhost"        # 该参数设置包含目标工作区的组织名称

    # backend 块还支持 token 参数,用来和远端存储进行授权认证,敏感信息不适合保存在代码仓库中,但是可以通过其它方式配置

    workspaces {
      name = "tfbook"       # 要使用的远程工作区名称
    }
  }
}
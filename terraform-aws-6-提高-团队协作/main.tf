/*
 * 默认情况下, terraform 将状态文件 terraform.tfstate 存储在本机, 个人独立使用 terraform 没有任何影响，
 * 如果团队都需要运行 terraform, treraform 可以通过支持远程状态从而解决团队人员协同使用 terraform 的问题。
 *
 * treraform 远端状态:
 *    远端状态就是将 treraform 产生的基础设施资源状态的数据写入到远端的存储中,terraform 支持许多远端存储类型,包括 terrform cloud、
 *    Consul、亚马逊s3、etcd等，terrform cloud 不仅提供免费的状态存储，而且配置和使用比较简单。
 * 
 * 使用 terrform cloud 作为远端状态存储步骤:
 *    1.注册 terraform cloud, 然后先创建新的组织。
 *    2.接着创建一个新的工作区,通过工作区可以将基础设施组织起来,并与团队成员一起工作,设置工作区步骤如下:
 * 	    2.1 如果代码没有存储在公共代码仓库,可以直接跳过设置.
 * 	    2.2 设置工作区名称(这个名称要唯一).
 * 	    2.3 将执行模式更改为本机,然后保存配置.通过这些设置后,terraform cloud 将只用于存储和同步远端状态.
 *
 * 为了配置 terraform 远端状态文件的存储位置,以便把状态文件存储在远端,需要在 terrform 块中添加 backend 后端块,
 * 一旦将 terraform 的状态文件存储在 terraform cloud 上，作为团队中每一个成员都能共享该状态文件。 
 * 
 * 配置 terraform 远端状态文件的存储位置以及授权认证：
 *    "outputs.tf"文件中 backend 块支持 token 参数,用来和远端存储进行授权认证,敏感信息不适合保存在代码仓库中,可以通过下面的方式将 token 信息保存在本机:
 *        linux或mac：打开用户主目录下的 .terraformrc 文件,如果没有就创建,然后将文件中的token替换为在 terraform cloud 上生成的 token。
 *        windows：这个配置文件名为 terraform.rc, 位于 "[用户]/AppData" 目录。
 *    完成后需要重新执行 "terraform init" 命令,当再次应用 terraform 代码时, terraform 就会将状态文件存储到 terraform cloud。
 *    "terraform init" 命令完成后可以打开 terraform cloud 验证远端存储。
 * 新版本 terraform 授权认证机制发生变化,详见文档：https://learn.hashicorp.com/tutorials/terraform/cloud-login?in=terraform/cloud-get-started
 * 
 * 执行 "terraform init" 命令后,在输出信息中的可以看到"state lock"字样:
 *    (1) 输出信息中的 state lock 就是状态锁, terraform 在执行命令前检查状态锁看是否有其他人使用状态文件,若没有才继续往下执行。
 *    当命令执行完成后,再释放状态锁,使用状态锁的好处在于能够阻止团队中的成员在某个时刻同时执行 terraform,从而避免出现错误。
 *    (2) 在 terraform cloud 上也可以看到状态锁的相关信息,可以知道团队中哪个成员锁定了状态,同时这里也具有管理状态锁的功能,
 *    可以通过解锁按钮解锁,不过不建议这样做,如果有人正在执行 terraform 命令,可能会出现难以预料的错误。
 * 
 * terraform 工作区: 
 *    (1) 通过 terraform 工作区能创建互相隔离的环境,这是由于 terraform 将状态文件与工作区绑定在一起的缘故,换而言之每个工作区都有不同的 terraform 状态文件,
 *    在真实的应用场景中, 开发、测试、生产环境的基础设施资源状态可能都将不同,在同一个 terraform 代码的当前目录很难满足多个环境的要求,为此 terraform 提供
 *    工作区这样的机制来解决此类问题
 *    (2)前面在准备 terraform cloud 时就创建了工作区存储状态文件, 事实上 terraform 还提供workspace 子命令用来执行有关工作区的操作:
 *        (2.1) "terraform workspace new" 用来新创建工作区, 比如为开发环境创建一个名为 dev 的工作区:
 *              terraform workspace new dev
 *        (2.2) 查看当前有哪些工作区。注意：default 为 terraform 默认工作区, default 工作区不能被删除，工作区前面的 * 号表示当前正在使用的工作区。
 *              terraform workspace list 
 *        (2.3) "terraform select" 切换工作区, 比如切换到 default 工作区:
 *              terraform select default
 *        (2.4) "terraform delete" 删除工作区, 比如删除 dev 工作区:
 *              terraform delete dev
 */

provider "aws" {
  region = var.region
}

module "ssh-key-name" {
  source = "./modules/prep-ssh"
  
  public_key = var.public_key
}

module "nginx-server" {
  source = "./modules/base-server"

  server_name = "nginx-server"
  server_port = 80
  server_script = templatefile("setup__nginx.sh", { time = timestamp() })
  region = var.region
  amis = var.amis
  instance_type = var.instance_type
  ssh_key_name = module.ssh-key-name.key_name
}

module "ss-server" {
  source = "./modules/base-server"
  
  server_name = "ss-server"
  server_port = 8388
  server_script = templatefile("setup_ss.sh", { password = var.ss_password })
  region = var.region
  amis = var.amis
  instance_type = var.instance_type
  ssh_key_name = module.ssh-key-name.key_name
}
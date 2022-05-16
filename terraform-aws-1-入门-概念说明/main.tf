/*
 * 创建 AWS EC2 实例
 * 允许通过 SSH 登录
 */

/*
 * terrafrom 的配置文件一般以 ".tf" 或".tf.json"结尾.
 *    ".tf"为terraform原生配置文件格式,也成 HCL 语言,推荐使用这种格式.
 *    ".tf.json"为 json 格式配置文件.
 */

/*
 * provide 代表云/服务供应商,由于云/服务供应商提供的api都不相同,所以terrafrom为了支持它们采用了插件化的架构,并通过各自的provide实现.
 * 所支持的provide: https://registry.terraform.io/browse/providers
*/
provider "aws" {
  // region 为aws 云数据中心所在的地理区域
  region = "ap-northeast-1"
}

# 创建第一个 aws 云基础设施资源 EC2 实例
# resource用来声明创建或更改的基础设施资源对象,比如计算实例,对象存储,虚拟网络,数据库实例等等
# aws_instance 代表本次使用的资源类型, aws_instance 表示 EC2(EC2，Elastic Compute Cloud) 实例,资源类型通常是"provider名称_"为前缀.
# web 是资源名称,资源名称在同一个模块中应当是唯一的, terraform 不允许有相同的资源名称存在.
# terraform 将资源类型和名称连起来作为该资源的唯一标识,本例中资源标识为 aws_instance.web 
resource "aws_instance" "web" {
  # ami 表示亚马逊机器镜像,它是 aws 用来启动 EC2 实例的操作系统镜像.  
  # ami 跟 aws 数据中心的地理区域相关,不同的区域具有不同的 ami id,这里的 ami id 特定存在于东京区域中
  ami = "ami-a3ed72c5"          # 指定 ami 的id
 
  # instance_type参数表示将要启动的 EC2 实例类型,实例类型表明能够使用哪种类型的服务器,比如CPU有多少,内存有多大,网络带宽占好多等
  instance_type = "t2.micro" # 这里使用微型实例类型,该类型属于免费层级
  # aws instance 资源还包括许多其它的配置参数,只有这两个配置参数必须提供

  key_name = aws_key_pair.ssh.key_name // aws_key_pair.ssh 是资源标识符,key_name是资源属性
}

// 添加 SSH 登录密钥
resource "aws_key_pair" "ssh" {
  key_name = "admin"
  public_key = "ssh-rsa ......"
}

// 设置防火墙规则(开放 22 端口,允许 SSH 登录)
resource "aws_security_group_rule" "ssh" {
  type = "ingress"  // type 指定防火墙规则类型, ingress表示入栈
  # from_port 和 to_port 表示开启端口的起始和结束范围
  from_port = 22    
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]        // 表示允许访问实例的IP范围,"0.0.0.0/0" 表示任何实例都可以访问 EC2 实例
  security_group_id = "sg-a361e5da"    // 该参数指定默认安全组的ID,这条防火墙规则将被加入到安全组中,安全组ID可以从aws的web控制台获取
  
  # terraform 支持的数据类型,参考: https://www.terraform.io/language/values/variables
}
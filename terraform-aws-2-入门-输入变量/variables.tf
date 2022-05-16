/*
 * 每一个输入变量都由 variable 变量快组成,在 variable 右边是输入变量的名称,这个名称是唯一的标识符,在同一个 terraform 模块中不能重复.
 * type、default、description (terraform主要包含这三种参数)是输入变量的参数,每一个参数都是可选的
 *      type 支持 string、number、布尔等简单类型,也支持 list、 set、map、对象、tuple等复杂类型
 *      default 用来设置变量默认值. 注意:只能使用字面值,不能引用其它表达式对象
 *      description 描述意图
 * terraform 支持的数据类型,参考: https://www.terraform.io/language/values/variables
 */

variable "region" {
  type = string
  default = "ap-northeast-1"
  description = "AWS region"
}

variable "amis" {
  type = map
  default = {
    ap-northeast-1 = "ami-a3ed72c5"
  }
  description = "AMI ID"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
  description = "EC2 instance type"
}

variable "public_key" {
  type = string
  default = "id_rsa.pub"
  description = "SSH public key"
}

# 这里 security_group 是一个输入变量, 因为这里没有指定默认值
variable "security_group" {
  type = string
  description = "security group id"
}

/*
 * 设置输入变量的值有四种方式:
 *   1. 当执行 "terraform plan" 或 "terraform apply"时, 如果输入变量没有设置默认值,那么terraform 将提示输入一个值
 *   2. 通过 "-var"(可以在命令行中多次使用)命令行指定,例如 terraform plan -var security_group=sg-a361e5da 
 *   3. 通过变量定义文件 terraform.tfvars 指定,  如果这个文件是别的名称,需要在命令行通过 "-var-file" 选项指定
 *   4. 通过环境变量的形式来设置输入变量,不过环境变量需要在原输入变量的前面加上 "TF_VAR_"前缀,如下:
 *        export TF_VAR_security_group="sg-a361e5da"
 *        terraform plan
 */
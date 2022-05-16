# terraform 安装在本地，通过provide连接到远程主机
provider "kubernetes" {
  config_path   = "../admin.conf"
  # config_path   = "/etc/kubernetes/admin.conf"
}

# 名称必须以字母或下划线开头，并且只能包含字母、数字、下划线和破折号
resource "kubernetes_namespace" "start_terraform" {
  metadata {
    name = "terraform"
  }
}

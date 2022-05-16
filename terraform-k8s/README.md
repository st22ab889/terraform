# terraform kubernetes 官方文档 #
* https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider?in=terraform/kubernetes
* https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
* https://learn.hashicorp.com/collections/terraform/cli


# terraform -version #
```
C:\Users\WuJun>terraform -version
Terraform v1.1.9
on windows_amd64
```


# terraform init #
```
C:\Users\WuJun\Desktop\jenkins\terraform\terraform-k8s>terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/kubernetes...
- Installing hashicorp/kubernetes v2.10.0...
- Installed hashicorp/kubernetes v2.10.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

# terraform plan #
```
C:\Users\WuJun\Desktop\jenkins\terraform\terraform-k8s>terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # kubernetes_namespace.start_terraform will be created
  + resource "kubernetes_namespace" "start_terraform" {
      + id = (known after apply)

      + metadata {
          + generation       = (known after apply)
          + name             = "terraform"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if
you run "terraform apply" now.
```

# terraform apply #
```
C:\Users\WuJun\Desktop\jenkins\terraform\terraform-k8s>terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # kubernetes_namespace.start_terraform will be created
  + resource "kubernetes_namespace" "start_terraform" {
      + id = (known after apply)

      + metadata {
          + generation       = (known after apply)
          + name             = "terraform"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

kubernetes_namespace.start_terraform: Creating...
kubernetes_namespace.start_terraform: Creation complete after 0s [id=terraform]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

# 验证 terraform 是否运行成功  #
```
[root@centos7 aaron]# kubectl get namespaces
NAME                   STATUS   AGE
blog                   Active   215d
default                Active   242d
kube-node-lease        Active   242d
kube-ops               Active   210d
kube-public            Active   242d
kube-system            Active   242d
kubernetes-dashboard   Active   242d
terraform              Active   25s
```
package test

// 利用 go 的内置库 testing 来编写 GO 的自动化测试用例, 因此只需执行"go test"就可以直接运行测试套件。
// 测试文件的文件名必须以_test.go结尾, 这是 GO 测试套件的惯用约定!

import (
	// 下面是 Golang 内置库
	"crypto/tls"
	"fmt"
	"testing"
	"time"
	// 下面是引用 terratest 库
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// 测试函数必须以 Test 开头,这同样是 testing 库的约定
func TestBaseserverExample(t *testing.T)  {
	// 配置 Terraform
	opts := &terraform.Options{
		// 通过 TerraformDir 指定要测试的 Terraform 代码所在的位置
		TerraformDir: "../",
	}

	// 测试完成后，执行 `terraform destroy` 清理资源(销毁创建的基础设施以便清理掉不再需要的资源)
	defer terraform.Destroy(t, opts)

	// 初始化并运行 Terraform 代码
	terraform.InitAndApply(t, opts)

	// 执行 `terraform output` 以获取输出变量的值
	serverIp := terraform.OutputRequired(t, opts, "ip")
	url := fmt.Sprintf("http://%s", serverIp)

	// 设置 TLS，http_helper 需要
	tlsConfig := tls.Config{}

	// 期望得到的 HTTP 状态及消息
	expectedStatus := 200
	expectedBody := "Created: Hello, 2019"

	// 设置重试次数
	maxRetries := 30
	timeBetweenRetries := 10 * time.Second

	// 验证 HTTP,该函数用来请求上一步构造的网址,并跟期望的 htpp 状态码及消息进行比较,从而达到验证 nginx web 服务是否正常可用的目的
	http_helper.HttpGetWithRetry(
		t,
		url,
		&tlsConfig,
		expectedStatus,
		expectedBody,
		maxRetries,
		timeBetweenRetries,
	)
}
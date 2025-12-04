import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct InsecureNetworkPage {
  @State responseText: string = '等待请求...';

  fetchDataOverHttp() {
    this.responseText = '请求中...';
    // VULNERABILITY: 使用 HTTP 明文传输
    const url = 'http://httpbin.org/get?param=sensitive_data'; // 若设备无法直连，可改成 http://example.com
    // Secure version (示例): const url = 'https://api.example.com/secure'; 并配置证书校验/Pinning
    const httpRequest = http.createHttp();
    httpRequest.request(url, { method: http.RequestMethod.GET, readTimeout: 5000 }, (err, data) => {
      if (err) {
        this.responseText = `请求失败: ${JSON.stringify(err)}`;
        httpRequest.destroy();
        return;
      }
      let body = '';
      try {
        if (typeof data.result === 'string') {
          body = data.result;
        } else if (data.result instanceof ArrayBuffer) {
          body = String.fromCharCode(...new Uint8Array(data.result));
        } else {
          body = JSON.stringify(data.result);
        }
      } catch (e) {
        body = `解析响应失败: ${e}`;
      }
      this.responseText = `请求成功！HTTP ${data.responseCode}\n响应内容:\n${body}`;
      httpRequest.destroy();
    });
  }

  build() {
    Column({ space: 20 }) {
      Text('不安全的网络通信').fontSize(24).fontWeight(FontWeight.Bold).margin({ bottom: 20 })

      Button('通过HTTP获取数据')
        .onClick(() => this.fetchDataOverHttp())

      Scroll() {
        Text(this.responseText)
          .width('100%')
          .padding(10)
          .backgroundColor('#f0f0f0')
          .borderRadius(10)
      }
      .layoutWeight(1)

      Text('操作指引：\n请使用抓包工具 (如 Burp Suite, Charles) 监控本机的网络流量，你将能看到明文传输的HTTP请求和响应。')
        .padding(15)
        .backgroundColor('#f0f0f0')
        .borderRadius(10)
        .margin({ top: 20 })
    }
    .padding(20)
    .width('100%')
  }
}

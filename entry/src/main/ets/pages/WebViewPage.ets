import web from '@ohos.web.webview';
import { BusinessError } from '@kit.BasicServicesKit';

// VULNERABILITY: 暴露给JS的原生对象
class JsBridge {
  getSensitiveInfo(): string {
    // 模拟返回敏感信息
    return `设备SN: MOCK_SN_1234567890, API_Level: ${globalThis.ohos_api_version}`;
  }
}

@Entry
@Component
struct WebViewPage {
  @State urlInput: string = 'https://www.bing.com';
  webviewController: web.WebviewController = new web.WebviewController();

  aboutToAppear() {
    try {
      this.webviewController.registerJavaScriptProxy(new JsBridge(), 'nativeBridge', ['*']);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`registerJavaScriptProxy failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  build() {
    Column() {
      Text('WebView 漏洞集合').fontSize(24).fontWeight(FontWeight.Bold).padding({ top: 20, bottom: 10 })

      Row({ space: 10 }) {
        TextInput({ placeholder: '输入任意URL并加载', text: this.urlInput })
          .onChange(val => this.urlInput = val)
          .layoutWeight(1)
        Button('加载')
          .onClick(() => {
            // VULNERABILITY: 未对URL进行任何校验，直接加载
            this.webviewController.loadUrl(this.urlInput);
          })
      }.width('90%').padding({ bottom: 10 })

      Web({ src: $rawfile('vuln.html'), controller: this.webviewController })
        .javaScriptAccess(true)
        .onControllerAttached(() => {
          this.webviewController.registerJavaScriptProxy(
            new JsBridge(),
            'nativeBridge',
            ['getSensitiveInfo']   // 方法名写全
          );
        })
        .layoutWeight(1)

      Text('操作指引：\n1. H5页面已加载。\n2. 点击H5页面的按钮，它会通过JS调用原生代码获取信息。\n3. 尝试使用Chrome DevTools远程调试，或通过注入JS代码来调用 `nativeBridge.getSensitiveInfo()` 方法。\n4. 任意URL加载: 在上方输入框输入恶意网址或file://协议路径进行测试。')
        .padding(15)
        .backgroundColor('#f0f0f0')
        .borderRadius(10)
        .margin(20)
    }
    .width('100%').height('100%')
  }
}
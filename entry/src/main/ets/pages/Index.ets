import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@kit.BasicServicesKit';

interface VulnerabilityItem {
  title: string;
  description: string;
  targetPage: string;
}

@Entry
@Component
struct Index {
  // 更新漏洞列表
  private vulnerabilityList: VulnerabilityItem[] = [
    { title: '1. 不安全的数据存储 & 日志', description: '明文存储账号密码到Preferences', targetPage: 'pages/InsecureStoragePage' },
    { title: '2. 不安全的网络通信', description: '使用HTTP明文传输数据', targetPage: 'pages/InsecureNetworkPage' },
    { title: '3. 硬编码敏感信息', description: '密钥硬编码在ArkTS代码中', targetPage: 'pages/HardcodedKeyPage' },
    { title: '4. WebView 漏洞集合', description: 'JS-Bridge漏洞 & 任意URL加载', targetPage: 'pages/WebViewPage' },
    { title: '5. SO原生库漏洞', description: '密钥硬编码在.so文件中', targetPage: 'pages/NdkPage' },
    { title: '6. SQLite SQL注入', description: 'SQL查询语句拼接用户输入', targetPage: 'pages/SqlInjectionPage' },
    { title: '7. 模拟支付', description: '防截屏、安全键盘等', targetPage: 'pages/SecurePaymentPage' },
    { title: '8. 导出的组件 (页面劫持)', description: '一个包含敏感信息的页面被导出', targetPage: '#' }
  ];

  build() {
    Row() {
      Column() {
        Text('HarmonyOS 安全靶场')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .padding({ top: 20, bottom: 20 })

        List({ space: 10 }) {
          ForEach(this.vulnerabilityList, (item: VulnerabilityItem) => {
            ListItem() {
              this.buildListItem(item.title, item.description)
            }
            .onClick(() => {
              if (item.targetPage === '#') {
                this.showDialog('组件暴露漏洞说明', '本应用内有一个名为 SecretAbility 的隐藏页面已被导出。请使用 adb 命令尝试拉起它：\n\naa start -b com.example.harmonyvulnerabledemo -a SecretAbility');
              } else if (item.targetPage === '##') {
                this.showDialog('后台Socket监听说明', '应用已在后台启动TCP服务，监听9999端口。\n请使用 adb forward tcp:9999 tcp:9999 转发端口，然后用 nc localhost 9999 连接并发送指令 (如 GET_DEVICE_INFO)。');
              } else {
                router.pushUrl({ url: item.targetPage });
              }
            })
          })
        }
        .width('90%')
        .layoutWeight(1)
      }
      .width('100%')
    }
    .height('100%')
  }

  // 抽离出Dialog显示函数
  showDialog(title: string, message: string) {
    try {
      promptAction.showDialog({
        title: title,
        message: message,
        buttons: [{ text: '好的', color: '#007DFF' }]
      });
    } catch (error) {
      const err = error as BusinessError;
      console.error(`showDialog failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  @Builder
  buildListItem(title: string, description: string) {
    Column() {
      Text(title).fontSize(18).fontWeight(FontWeight.Bold).width('100%').textAlign(TextAlign.Start)
      Text(description).fontSize(14).fontColor(Color.Gray).width('100%').textAlign(TextAlign.Start).margin({ top: 5 })
    }
    .padding(15).backgroundColor(Color.White).borderRadius(10).shadow({ radius: 5, color: '#1F000000' })
  }
}
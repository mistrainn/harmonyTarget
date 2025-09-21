import promptAction from '@ohos.promptAction';

@Entry
@Component
struct HardcodedKeyPage {
  // VULNERABILITY: 密钥被硬编码在代码中
  private readonly SECRET_KEY = "this_is_a_very_secret_key_123";
  private readonly MAP_API_KEY = "AKfj-s93f_thisIsAFakeBaiduMapKey";
  @State plainText: string = 'Hello HarmonyOS';
  @State encryptedText: string = '';

  // 简单的异或加密算法，用于演示
  xorEncrypt(input: string, key: string): string {
    let output = '';
    for (let i = 0; i < input.length; i++) {
      output += String.fromCharCode(input.charCodeAt(i) ^ key.charCodeAt(i % key.length));
    }
    return output;
  }

  build() {
    Column({ space: 20 }) {
      Text('硬编码敏感信息 (ArkTS)').fontSize(24).fontWeight(FontWeight.Bold).margin({ bottom: 20 })

      TextInput({ placeholder: '输入要加密的文本', text: this.plainText })
        .onChange(val => this.plainText = val)

      Button('使用硬编码密钥加密')
        .onClick(() => {
          this.encryptedText = this.xorEncrypt(this.plainText, this.SECRET_KEY);
          promptAction.showToast({ message: '加密完成' });
        })

      Text('加密结果:')
      Text(this.encryptedText).fontColor(Color.Red)

      Text('操作指引：\n请反编译本应用的HAP包，在ArkTS代码中搜索字符串，即可找到硬编码的密钥 "this_is_a_very_secret_key_123"。')
        .padding(15)
        .backgroundColor('#f0f0f0')
        .borderRadius(10)
        .margin({ top: 30 })
    }
    .padding(20)
    .width('100%')
  }
}
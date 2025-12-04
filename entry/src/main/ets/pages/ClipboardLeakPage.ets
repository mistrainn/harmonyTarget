import { BusinessError, pasteboard } from '@kit.BasicServicesKit';

@Entry
@Component
struct ClipboardLeakPage {
  @State sensitiveText: string = '卡号 4111 1111 1111 1111, CVV 888, OTP 123456';
  @State hijackLog: string[] = ['未监听剪贴板'];
  @State lastSeen: string = '空';
  private pollTimer: number = -1;
  private systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();

  aboutToDisappear() {
    this.stopSniff();
  }

  private pushLog(msg: string) {
    const next = [...this.hijackLog, msg];
    this.hijackLog = next.slice(-6);
  }

  private async copySensitive() {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.sensitiveText);
      await this.systemPasteboard.setData(data);
      this.pushLog('已将敏感信息写入剪贴板（未做清理）。');
    } catch (error) {
      const err = error as BusinessError;
      this.pushLog(`写入失败: ${err.code} ${err.message}`);
    }
  }

  private async readClipboardOnce() {
    try {
      const data = await this.systemPasteboard.getData();
      const record = data.getRecord(0);
      const text = record ? record.toPlainText() : '<空>';
      this.lastSeen = text ?? '<空>';
      this.pushLog(`被动窃取剪贴板: ${this.lastSeen}`);
    } catch (error) {
      const err = error as BusinessError;
      this.pushLog(`读取失败: ${err.code} ${err.message}`);
    }
  }

  private startSniff() {
    if (this.pollTimer !== -1) {
      return;
    }
    // VULNERABILITY: 后台轮询剪贴板，未经用户授权
    this.pushLog('开始后台轮询剪贴板（无用户感知）...');
    this.pollTimer = setInterval(() => {
      this.readClipboardOnce();
    }, 2500);
  }

  private stopSniff() {
    if (this.pollTimer !== -1) {
      clearInterval(this.pollTimer);
      this.pollTimer = -1;
      this.pushLog('停止监听。');
    }
  }

  build() {
    Column() {
      Text('剪贴板劫持与敏感信息泄露')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .padding({ top: 20, bottom: 10 })

      Text('步骤：复制敏感信息 → 驻后台轮询读取 → 日志/上传（这里用日志模拟）。')
        .fontSize(14)
        .fontColor(Color.Gray)
        .width('90%')
        .padding({ bottom: 10 })

      Column({ space: 8 }) {
        Text('敏感文本样例（可编辑）：').fontSize(14).fontColor(Color.Grey)
        TextInput({ text: this.sensitiveText, placeholder: '输入要复制的敏感数据' })
          .width('100%')
          .onChange(val => this.sensitiveText = val)
          .padding(10)
          .backgroundColor('#f6f6f6')
          .borderRadius(8)
      }.width('90%')

      Row({ space: 12 }) {
        Button('复制到剪贴板')
          .onClick(() => this.copySensitive())
          .backgroundColor('#d9534f')
          .fontColor(Color.White)
        Button('开始后台监听')
          .onClick(() => this.startSniff())
        Button('停止监听')
          .onClick(() => this.stopSniff())
      }.padding({ top: 12, bottom: 12 })
      // Secure version (示例): 仅在用户明确触发时读取剪贴板，并及时清空
      // Button('读取一次并清空')
      //   .onClick(async () => {
      //     const data = await this.systemPasteboard.getData();
      //     await this.systemPasteboard.clear();
      //   })

      Column({ space: 6 }) {
        Text(`最近一次读取：${this.lastSeen}`).fontSize(14).fontColor(Color.Red)
        Text('日志（模拟外传记录）：').fontSize(14).fontColor(Color.Grey)
        ForEach(this.hijackLog, (line: string) => {
          Text(line).fontSize(12).width('100%')
        })
      }
      .width('90%')
      .padding(12)
      .backgroundColor('#f0f0f0')
      .borderRadius(10)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}

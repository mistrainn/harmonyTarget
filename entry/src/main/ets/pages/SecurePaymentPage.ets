import window from '@ohos.window';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct SecurePaymentPage {
  private win: window.Window | undefined = undefined;

  async aboutToAppear() {
    try {
      let windowClass = await window.getTopWindow(getContext(this));
      this.win = windowClass;
      // VULNERABILITY (from a feature perspective): 开启防截屏
      await this.win.setWindowPrivacyMode(true);
      promptAction.showToast({ message: '防截屏模式已开启' });
    } catch (exception) {
      console.error('Failed to set privacy mode. Cause: ' + JSON.stringify(exception));
    }
  }

  async aboutToDisappear() {
    // 离开页面时恢复，避免影响其他页面
    if (this.win) {
      try {
        await this.win.setWindowPrivacyMode(false);
      } catch (exception) {
        console.error('Failed to reset privacy mode. Cause: ' + JSON.stringify(exception));
      }
    }
  }

  build() {
    Column({ space: 20 }) {
      Text('模拟支付 (安全特性)').fontSize(24).fontWeight(FontWeight.Bold).margin({ bottom: 20 })

      Text('支付金额').width('100%').textAlign(TextAlign.Start)
      TextInput({ text: '100.00' })
        .type(InputType.Number) // 使用数字安全键盘

      Text('支付密码').width('100%').textAlign(TextAlign.Start)
      TextInput({ placeholder: '请输入6位密码' })
        .type(InputType.Password) // 使用密码安全键盘
        .maxLength(6)

      Button('确认支付')
        .width('80%')
        .onClick(() => {
          promptAction.showToast({ message: '模拟支付成功' });
        })

      Text("安全特性演示：\n1. 防截屏/录屏: 当前页面已开启防截屏，请尝试截图，预期会失败或得到黑屏。\n2. 安全键盘: 点击密码框，系统会弹出安全键盘。\n3. 后台安全提示: 将App滑到后台，在多任务卡片上应有安全提示（此特性依赖系统实现）。")
        .padding(15)
        .backgroundColor('#f0f0f0')
        .borderRadius(10)
        .margin({ top: 30 })
    }
    .padding(20).width('100%')
  }
}
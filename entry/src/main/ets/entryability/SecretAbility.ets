import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

export default class SecretAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage) {
    // 设置UI加载
    windowStage.loadContent('pages/SecretPage', (err, data) => {
      // 在这里可以处理加载错误
    });
  }
}

// SecretPage.ets
// 为了简单，我们把页面也定义在这里。实际项目中应分开。
@Component
struct SecretPage {
  build() {
    Column({ space: 20 }) {
      Text('秘密页面')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
      Image($r('app.media.icon'))
        .width(100)
      Text('这是一个被导出的秘密页面！')
        .fontSize(20)
        .fontColor(Color.Red)
      Text('在正常流程下，你不应该能看到我。')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
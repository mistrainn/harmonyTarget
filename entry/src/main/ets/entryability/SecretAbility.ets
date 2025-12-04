import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

export default class SecretAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage) {
    windowStage.loadContent('pages/SecretPage', (err) => {
      if (err?.code) {
        console.error(`Failed to load secret page: ${JSON.stringify(err)}`);
      }
    });
  }
}

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

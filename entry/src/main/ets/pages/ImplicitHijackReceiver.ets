import { Want } from '@kit.AbilityKit';
import { getLeakedWant } from '../entryability/LeakyImplicitAbility';

@Entry
@Component
struct ImplicitHijackReceiver {
  private readonly wantSnapshot: Want | undefined = getLeakedWant();

  build() {
    Column({ space: 10 }) {
      Text('LeakyImplicitAbility 已截获隐式 Want')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .padding({ top: 20, bottom: 10 })

      Text(`action: ${this.wantSnapshot?.action ?? '未知'}`)
        .fontSize(16)
        .fontColor(Color.Red)

      Text('收到的 parameters：')
        .fontSize(14)
        .fontColor(Color.Grey)

      Text(JSON.stringify(this.wantSnapshot?.parameters ?? {}, null, 2))
        .fontSize(12)
        .backgroundColor('#f6f6f6')
        .padding(12)
        .borderRadius(10)
        .width('90%')

      Text('漏洞说明：隐式 Want 未指定 bundle/ability，任意导出组件都能拦截并读取敏感数据。')
        .fontSize(14)
        .fontColor(Color.Gray)
        .padding(15)
        .backgroundColor('#f0f0f0')
        .borderRadius(10)
        .width('90%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}

import { BusinessError } from '@kit.BasicServicesKit';
import { Want, common } from '@kit.AbilityKit';

const IMPLICIT_ACTION = 'com.example.SECRET_SHARE';

@Entry
@Component
struct ImplicitHijackPage {
  @State sendLog: string = '未发送';

  private buildLeakWant(): Want {
    return {
      action: IMPLICIT_ACTION,
      type: 'text/plain',
      // VULNERABILITY: 不指定 bundle/ability，敏感数据随隐式 Want 外泄
      parameters: {
        authToken: 'demo-token-77e1-45c8-90cc',
        location: '31.2304,121.4737',
        note: '私有通道消息，将被任意 App 劫持'
      }
    };
  }
  // Secure version (示例): 显式指定 bundle/ability 或使用权限校验
  // private buildSecureWant(): Want {
  //   return {
  //     bundleName: 'com.example.vulnerableappdemo',
  //     abilityName: 'SecureReceiverAbility',
  //     action: IMPLICIT_ACTION,
  //     parameters: { ... }
  //   };
  // }

  private startImplicitShare() {
    const ctx = getContext(this) as common.UIAbilityContext;
    const want = this.buildLeakWant();
    ctx.startAbility(want).then(() => {
      this.sendLog = `已发送隐式 Want（action=${IMPLICIT_ACTION}），若有同 action 的第三方将被劫持`;
    }).catch((error: BusinessError) => {
      // 若无匹配组件，退化为显式拉起自身能力以便演示
      if (error.code === 16000019) {
        const fallback: Want = {
          bundleName: 'com.example.vulnerableappdemo',
          abilityName: 'LeakyImplicitAbility',
          action: IMPLICIT_ACTION,
          parameters: want.parameters
        };
        ctx.startAbility(fallback).then(() => {
          this.sendLog = '隐式匹配失败，已用显式方式拉起本应用演示页面（正常情况下应被其它 App 劫持）';
        }).catch((inner: BusinessError) => {
          this.sendLog = `隐式+显式均失败: ${inner.code} ${inner.message}`;
        });
      } else {
        this.sendLog = `发送失败: ${error.code} ${error.message}`;
      }
    });
  }

  build() {
    Column() {
      Text('隐式 Want 泄露 / 劫持')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .padding({ top: 20, bottom: 10 })

      Column({ space: 8 }) {
        Text('敏感数据样例（未绑定包名/组件，默认走隐式路由）：')
          .fontSize(14)
          .fontColor(Color.Grey)
        Text(`action: ${IMPLICIT_ACTION}`)
          .fontSize(14)
          .fontColor(Color.Red)
        Text(JSON.stringify(this.buildLeakWant().parameters, null, 2))
          .fontSize(12)
          .backgroundColor('#f6f6f6')
          .padding(10)
          .borderRadius(8)
      }
      .width('90%')
      .padding({ bottom: 12 })

      Button('发送隐式 Want（可被劫持）')
        .backgroundColor('#d9534f')
        .fontColor(Color.White)
        .onClick(() => this.startImplicitShare())
        .width('90%')
        .padding({ top: 10, bottom: 10 })

      Text(this.sendLog)
        .fontSize(14)
        .fontColor('#d9534f')
        .width('90%')
        .padding({ top: 10, bottom: 10 })

      Text('复现提示：\n1）当前 App 内置导出的 LeakyImplicitAbility 会截获该 Want 并显示参数；\n2）若系统提示“暂无可用打开方式”，会自动降级为显式拉起本应用；\n3）安装“攻击者” HAP 或用 aa start -a com.example.SECRET_SHARE -b <恶意包名> 劫持，观察敏感数据外泄。')
        .fontSize(14)
        .fontColor(Color.Gray)
        .padding(15)
        .backgroundColor('#f0f0f0')
        .borderRadius(10)
        .width('90%')
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}

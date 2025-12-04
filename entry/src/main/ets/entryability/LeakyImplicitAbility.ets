import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { Want } from '@kit.AbilityKit';

let latestLeakyWant: Want | undefined;

export default class LeakyImplicitAbility extends UIAbility {
  onCreate(want: Want): void {
    latestLeakyWant = want;
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/ImplicitHijackReceiver', (err) => {
      if (err && err.code) {
        console.error(`Failed to load hijack receiver page: ${JSON.stringify(err)}`);
      }
    });
  }
}

export function getLeakedWant(): Want | undefined {
  return latestLeakyWant;
}

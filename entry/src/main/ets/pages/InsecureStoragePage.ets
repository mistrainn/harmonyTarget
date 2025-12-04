import dataPreferences from '@ohos.data.preferences';
import hilog from '@ohos.hilog';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct InsecureStoragePage {
  @State username: string = 'testuser';
  @State password: string = 'Password123';
  private context = getContext(this);

  async onSaveClick() {
    try {
      const pref = await dataPreferences.getPreferences(this.context, 'vuln_credential');

      // VULNERABILITY: 明文存储用户名和密码
      await pref.put('username', this.username);
      await pref.put('password', this.password);
      await pref.flush();

      // VULNERABILITY: 在日志中明文打印敏感信息
      hilog.error(0x0001, 'VULN_APP_LOG', 'Insecure Logging: User %{public}s password is %{public}s', this.username, this.password);
      const fakeSessionToken = 'Bearer_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6InRlc3R1c2VyIn0.fake_signature';
      hilog.error(0x0001, 'VULN_APP_LOG', 'Login success for %{public}s, password: %{public}s, session: %{public}s', this.username, this.password, fakeSessionToken);

      // Secure version (示例): 使用加密存储 + 不打印敏感信息
      // const encPref = await dataPreferences.getPreferences(this.context, 'secure_credential');
      // await encPref.put('username', encrypt(this.username));
      // await encPref.put('password', encrypt(this.password));
      // await encPref.flush();
      // hilog.info(0x0001, 'SAFE_LOG', 'Login success for %{private}s', this.username);

      promptAction.showToast({ message: '凭据已明文保存，并已打印到日志' });
    } catch (e) {
      promptAction.showToast({ message: `保存失败: ${e}` });
    }
  }

  build() {
    Column({ space: 20 }) {
      Text('不安全的数据存储 & 日志').fontSize(24).fontWeight(FontWeight.Bold).margin({ bottom: 20 })

      TextInput({ placeholder: '用户名', text: this.username }).onChange(val => this.username = val)
      TextInput({
        placeholder: '密码',
        text: this.password
      })
        .type(InputType.Password)
        .onChange(val => this.password = val)

      Button('保存凭据 (明文)')
        .onClick(() => this.onSaveClick())

      Text('操作指引：\n1. 点击保存后，请进入设备shell环境。\n2. 找到应用沙箱目录：/data/storage/el2/base/haps/entry/preferences。\n3. 查看 vuln_credential.xml 文件内容。\n4. 同时使用 hilog 命令查看日志输出。')
        .padding(15)
        .backgroundColor('#f0f0f0')
        .borderRadius(10)
        .margin({ top: 30 })
    }
    .padding(20)
    .width('100%')
  }
}

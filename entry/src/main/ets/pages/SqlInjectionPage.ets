import relationalStore from '@ohos.data.relationalStore';
import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';

const DB_NAME = 'vuln_user.db';
const TABLE_NAME = 'users';
const TAG = '[SQL_INJECTION]';

@Entry
@Component
struct SqlInjectionPage {
  @State searchName: string = '';
  @State searchResult: string = '尚未查询';
  private store: relationalStore.RdbStore | null = null;

  async aboutToAppear() {
    // 初始化数据库并插入数据
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1 // S1表示设备级加密
      };
      this.store = await relationalStore.getRdbStore(getContext(this), config);
      hilog.info(0x0001, TAG, '数据库获取成功');

      // 创建表
      const CREATE_TABLE_SQL = `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT)`;
      await this.store.executeSql(CREATE_TABLE_SQL);
      hilog.info(0x0001, TAG, '表创建成功');

      // 清空并插入预置数据
      await this.store.executeSql(`DELETE FROM ${TABLE_NAME}`);
      await this.store.executeSql(`INSERT INTO ${TABLE_NAME}(name, description) VALUES ('admin', '系统管理员, 掌握最高权限')`);
      await this.store.executeSql(`INSERT INTO ${TABLE_NAME}(name, description) VALUES ('alice', '普通用户, 财务部门')`);
      await this.store.executeSql(`INSERT INTO ${TABLE_NAME}(name, description) VALUES ('bob', '普通用户, 技术部门')`);
      hilog.info(0x0001, TAG, '预置数据插入成功');

    } catch (e) {
      this.searchResult = `数据库初始化失败: ${JSON.stringify(e)}`;
      hilog.error(0x0001, TAG, `数据库初始化失败: ${JSON.stringify(e)}`);
    }
  }

  async onSearch() {
    if (!this.store) {
      promptAction.showToast({ message: '数据库未准备好' });
      return;
    }
    try {
      // VULNERABILITY: 直接将用户输入拼接到SQL语句中
      const vulnerableSql = `SELECT * FROM ${TABLE_NAME} WHERE name = '${this.searchName}'`;
      hilog.info(0x0001, TAG, `Executing vulnerable SQL: ${vulnerableSql}`);

      const resultSet = await this.store.querySql(vulnerableSql);
      let resultStr = `查询到 ${resultSet.rowCount} 条结果:\n`;
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          const id = resultSet.getLong(resultSet.getColumnIndex('id'));
          const name = resultSet.getString(resultSet.getColumnIndex('name'));
          const desc = resultSet.getString(resultSet.getColumnIndex('description'));
          resultStr += `ID: ${id}, Name: ${name}, Desc: ${desc}\n`;
        } while (resultSet.goToNextRow());
      }
      this.searchResult = resultStr;
      resultSet.close();

      // Secure version (示例): 使用参数化查询避免注入
      // const stmt = await this.store.prepare(`SELECT * FROM ${TABLE_NAME} WHERE name = ?`);
      // const safeResult = await stmt.executeQuery([this.searchName]);
      // stmt.close();
    } catch (e) {
      this.searchResult = `查询失败: ${JSON.stringify(e)}`;
      hilog.error(0x0001, TAG, `查询失败: ${JSON.stringify(e)}`);
    }
  }

  build() {
    Column({ space: 20 }) {
      Text('SQLite SQL注入漏洞').fontSize(24).fontWeight(FontWeight.Bold).margin({ bottom: 20 })

      TextInput({ placeholder: '输入用户名搜索', text: this.searchName })
        .onChange(val => this.searchName = val)

      Button('搜索')
        .onClick(() => this.onSearch())

      Scroll() {
        Text(this.searchResult)
          .width('100%')
          .padding(10)
          .backgroundColor('#f0f0f0')
          .borderRadius(10)
      }.layoutWeight(1)

      Text("操作指引：\n在输入框中尝试输入 `' OR '1'='1` 并点击搜索，观察是否能查询出所有用户信息。")
        .padding(15)
        .backgroundColor('#f0f0f0')
        .borderRadius(10)
        .margin({ top: 20 })
    }
    .padding(20).width('100%')
  }
}

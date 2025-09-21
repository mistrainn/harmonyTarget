# VulnerableAppDemo21

一个专为安全培训打造的 HarmonyOS NEXT 示范应用。项目刻意实现了多种常见的移动端安全漏洞，用来演示在 ArkTS 代码中漏洞是如何产生、如何被发现以及潜在的风险点。

> ⚠️ **仅供教学与实验使用。** 请勿将此代码用于生产环境或任何恶意活动。

## 漏洞场景速览

- 明文存储与日志泄露：账号密码直接写入 `Preferences`
- 不安全的网络通信：使用 HTTP 明文请求，缺少 TLS 保护
- ArkTS 代码中的硬编码密钥
- WebView 误用：任意 URL 加载、暴露 JS Bridge
- `.so` 原生库内嵌密钥（NDK 演示）
- 字符串拼接导致的 SQLite SQL 注入
- 模拟安全支付流程：截屏、防窥、输入保护等场景演练
- 导出的 `SecretAbility` 页面可被外部组件直接拉起

## 项目结构

```
├── AppScope/app.json5        # 全局应用信息
├── entry/                    # 主模块
│   ├── src/main/ets/pages/   # 各漏洞示例页面
│   ├── src/main/resources/   # UI 资源
│   ├── build-profile.json5   # （模板）构建配置
│   └── hvigorfile.ts         # 模块级构建脚本
├── docs/signing-setup.md     # 本地签名材料操作指南
└── hvigorfile.ts             # 应用级构建脚本
```

## 快速开始

### 环境要求

- DevEco Studio 5.0 及以上（HarmonyOS NEXT 工具链）
- DevEco Studio 自带的 Node.js / Hvigor 工具
- HarmonyOS NEXT 真机或模拟器，API ≥ 19（5.1.1）

## 签名说明

仓库不会保存任何真实证书或密码。若需发布专用 HAP，请参考 [`docs/signing-setup.md`](docs/signing-setup.md)，将个人签名信息写入本地的 `build-profile.local.json5`。

## 学习与实战建议

- 反编译生成的 HAP，尝试定位 ArkTS 和 `.so` 里的硬编码密钥。
- 通过代理劫持 HTTP 流量，观察未加密通信的风险。
- 在 SQLite 演示页面输入 SQL 注入 payload，体验攻击链。
- 使用 `aa start -b com.example.vulnerableappdemo -a SecretAbility` 手动拉起导出的能力，理解组件暴露问题。

## 免责声明

本项目面向实验室、培训和 CTF 等学习场景。作者不对滥用带来的任何后果负责。在测试第三方软件时请遵循负责任的披露原则。


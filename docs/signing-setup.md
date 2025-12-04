# 签名配置指引

项目不包含任何真实签名材料，构建/发布需使用你的本地证书与 profile。

## 配置步骤

1. 将根目录的 `build-profile.json5` 复制为 `build-profile.local.json5`，在副本中填写你的证书、密钥库、profile 的绝对路径和密码。
2. `build-profile.local.json5` 已加入 `.gitignore`，确保不要提交到版本库。
3. 构建前的常见做法：
   - 直接在 `build-profile.local.json5` 中维护个人配置，并在本地脚本中引用；或
   - 用脚本在构建前临时覆盖 `build-profile.json5`，构建后恢复。
4. 仅在本地机器存放证书，避免通过仓库、IM、邮件等渠道分发。

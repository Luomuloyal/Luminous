# Luminous 上线前清单（App + Backend）

更新时间：2026-04-03
适用范围：当前仓库（Flutter App + backend）

---

## 1) P0 必须完成（不完成不要上线）

### 1.1 密钥与凭据安全整改

- [ ] 立刻轮换所有疑似已暴露的密钥/凭据（邮箱授权码、JWT Secret、DOUBAO API Key、数据库密码等）。
- [ ] 把生产密钥迁移到部署平台密钥管理（如 CI/CD Secret、服务器环境变量），不要保存在仓库文件中。
- [ ] 确认 `backend/.env.development` 和 `backend/.env.production` 不包含真实线上密钥后再继续发布。

验收标准：
- 任意成员拉取代码后，仓库内不存在可直接用于生产环境的真实密钥。

---

### 1.2 环境文件与忽略规则修正

- [ ] 修改 `backend/.gitignore`，补充忽略规则：`.env.*`（并保留示例文件，例如 `.env.example`）。
- [ ] 新建并维护 `backend/.env.example`，仅保留占位值和必填说明。
- [ ] 检查历史提交是否包含敏感 env 内容；若有，按团队流程执行历史清理与强制换密钥。

验收标准：
- 新增/修改密钥不会被 Git 跟踪。

---

### 1.3 生产 API 地址与 CORS 收敛

- [ ] 生产构建使用 `--dart-define=API_BASE_URL=https://你的生产域名`，不要使用本地默认地址。
- [ ] 核对 `lib/constants/constants.dart`：仅保留本地默认值逻辑，生产地址通过 `dart-define` 注入。
- [ ] 核对后端 `CORS_ORIGIN`：只允许真实线上域名，移除测试域名与通配。

验收标准：
- 生产包请求地址正确，跨域策略仅放行白名单域名。

---

### 1.4 Android 正式签名与包信息

- [ ] 准备正式 keystore，填写 `android/key.properties`（该文件不入库）。
- [ ] 核对 `android/app/build.gradle.kts`：release 必须使用正式签名，不可回落 debug 签名。
- [ ] 核对 `applicationId` 与商店包名一致。

验收标准：
- 生成的 release 包由正式证书签名，可上传商店。

---

### 1.5 版本号与发布元信息

- [ ] 更新 `pubspec.yaml` 中 `version`（如 `3.1.0+34` -> `3.1.1+35`）。
- [ ] 更新本次发布说明（新增功能、修复项、已知限制）。

验收标准：
- 构建产物版本号与发布记录一致。

---

## 2) P1 建议首发前完成（强烈建议）

### 2.1 后端启动脚本健壮性

- [ ] 修改 `backend/package.json` 的 `start:prod`，建议使用：

```bash
node --env-file=.env.production dist/server.js
```

说明：当前写法 `node dist/server.js --env-file=.env.production` 在多数 Node 环境下不会按预期加载 env。

验收标准：
- `npm run build && npm run start:prod` 后，后端能读取生产环境变量并正常启动。

---

### 2.2 AI 调用稳定性与用户体验

- [ ] 保持已实现的接口级超时策略：
  - 安全分析文本接口（90s）
  - 详情文本接口（90s）
  - 视觉扫描接口（120s）
- [ ] 保持已实现的“局部 loading + 红色取消按钮 + 取消轻提示”。
- [ ] 补充失败分级提示：超时 / 取消 / 服务异常 给出不同文案（可后续迭代）。

验收标准：
- 弱网与慢响应场景可恢复、可中断、可反馈。

---

### 2.3 日志与隐私最小化

- [ ] 全量复查前后端日志，避免打印 token、邮箱、手机号、密钥、完整请求体。
- [ ] 明确生产日志级别（info/warn/error），关闭不必要 debug 输出。

验收标准：
- 生产日志不含高敏信息。

---

### 2.4 数据与回滚准备

- [ ] 准备 MySQL / MongoDB / Redis 发布前备份。
- [ ] 准备回滚步骤（上一版本包、上一版后端镜像或构建产物、回滚命令）。

验收标准：
- 出现严重故障时，30 分钟内可回滚到上一稳定版本。

---

## 3) P2 上线当天执行清单（按顺序）

1. [ ] 本地最终检查：
   - `flutter analyze`
   - `flutter test`
   - `cd backend && npm ci && npm run build`
2. [ ] 生产参数注入并构建：
   - Android：`flutter build apk --release --dart-define=API_BASE_URL=https://你的生产域名`
3. [ ] 部署后端并检查健康状态（建议增加 `/healthz` 探针）。
4. [ ] 灰度验证关键路径：
   - 注册/登录
   - 药品搜索与详情
   - AI 安全分析
   - AI 扫描
   - 提醒创建/编辑/开关/打卡
5. [ ] 观察 30-60 分钟错误日志与接口耗时，再全量放量。

---

## 4) 需要改动的文件列表（按优先级）

高优先级（P0）：
- `backend/.env.development`：移除真实凭据并替换为占位。
- `backend/.env.production`：填入真实生产参数（不入库）。
- `backend/.gitignore`：补充 `.env.*` 忽略规则。
- `lib/constants/constants.dart`：确认生产通过 `API_BASE_URL` 注入，不硬编码线上地址。
- `android/app/build.gradle.kts`：确保 release 必走正式签名。
- `pubspec.yaml`：更新版本号。

建议级（P1）：
- `backend/package.json`：修正 `start:prod` 脚本参数顺序。
- （可新增）`backend/.env.example`：沉淀标准模板。

---

## 5) 快速自检结论模板（可直接复用）

- [ ] 安全：密钥已轮换，仓库无真实生产凭据。
- [ ] 配置：生产 API、CORS、数据库连接均正确。
- [ ] 构建：App release 包可安装，后端构建可启动。
- [ ] 功能：核心路径冒烟通过。
- [ ] 监控：上线后日志/告警可用。
- [ ] 回滚：已验证回滚预案可执行。

满足以上 6 项后再发布到生产环境。

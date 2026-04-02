# 测试目录说明

本目录为 Flutter 单元测试与组件测试。

## 运行方式

在项目根目录执行：

```bash
flutter test
```

指定单文件：

```bash
flutter test test/<file_name>.dart
```

## 组织建议

1. 测试文件命名使用 `*_test.dart`。
2. 页面测试优先覆盖核心流程和边界状态。
3. 与后端响应模型相关的逻辑，优先在 `viewmodels` 对应测试中覆盖。
4. 每次接口字段变更后，补充或修复相关测试。

## 常见问题

- 若出现依赖初始化问题，先执行 `flutter pub get`。
- 若出现平台插件相关报错，优先检查是否可用 mock 替代平台调用。
- 若涉及真实后端联调场景，可先在根目录执行 `docker compose up -d --build` 启动后端与数据库依赖。

## 相关文档

- 项目总览: [../README.md](../README.md)
- 代码学习文档: [../Study/README.md](../Study/README.md)

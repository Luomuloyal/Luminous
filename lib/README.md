# lib 目录说明

`lib` 是 Flutter App 的主代码目录。

## 目录结构

- `api/`: 接口请求封装
- `assets/`: App 资源文件
- `components/`: 可复用 UI 组件
- `constants/`: 全局常量与 API 路径
- `docs/`: 项目内部规范文档
- `pages/`: 页面层
- `routes/`: 路由与主题相关入口
- `startup/`: 启动流程初始化
- `stores/`: 全局状态与本地存储
- `utils/`: 通用工具
- `viewmodels/`: 数据模型与结果映射

## 关键入口

- 应用入口: `main.dart`
- 网络入口: `utils/dio_request.dart`

## 开发建议

1. 页面逻辑优先放在 `pages/` + `viewmodels/`，避免页面文件过重。
2. 公共状态放 `stores/`，避免页面间重复持有状态。
3. API 路径统一使用 `constants/constants.dart`，不要在业务代码中硬编码。
4. 公共组件抽到 `components/`，并保持参数语义清晰。

## 相关文档

- 文档目录: [docs/README.md](docs/README.md)
- 项目总览: [../README.md](../README.md)

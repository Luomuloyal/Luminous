# Lucent OpenAPI Client

最后更新: 2026-05-30

## 位置

- 生成客户端：`packages/lucent_openapi/`
- 主工程统一封装：`lib/core/network/lucent_dio_client.dart`
- 导出入口：`lib/core/network/lucent_api.dart`

## 当前策略

- 使用 Lucent 的 `docs/openapi.json`
- 使用 OpenAPI Generator 的 `dart-dio` 生成器
- 生成代码作为 `path package` 放在 `Luminous/packages/`
- 业务层不要直接依赖生成器目录结构，统一通过 `LucentDioClient`

## 重新生成

在 `Luminous/` 目录执行：

```bash
npx @openapitools/openapi-generator-cli generate ^
  -i ..\Lucent\docs\openapi.json ^
  -g dart-dio ^
  -o packages\lucent_openapi ^
  --additional-properties=serializationLibrary=json_serializable,pubName=lucent_openapi,pubLibrary=lucent_openapi,sourceFolder=src,finalProperties=true,skipCopyWith=true,useEnumExtension=true,enumUnknownDefaultCase=true
```

然后进入生成包执行：

```bash
cd packages\lucent_openapi
dart pub get
dart run build_runner build
```

再回到主工程：

```bash
cd ..\..
flutter pub get
```

## 使用方式

```dart
import 'package:luminous/core/network/lucent_api.dart';

final client = LucentDioClient(
  baseUrl: 'http://127.0.0.1:3000',
  accessToken: '<jwt>',
);

final authApi = client.authApi;
final appApi = client.appApi;
```

## 说明

- 当前 OpenAPI 只覆盖 `health` 和 `auth`
- 随着 Lucent API 扩展，重新导出 `openapi.json` 后再重生成
- 生成代码允许保留生成器风格，不手改；需要自定义行为时放在主工程封装层

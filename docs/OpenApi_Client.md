# Lucent OpenAPI Client

Last updated: 2026-05-30

## Files

- Generated package: `packages/lucent_openapi/`
- Wrapper: `lib/core/network/lucent_dio_client.dart`
- Export: `lib/core/network/lucent_api.dart`

## Behavior

- Generated from `../Lucent/docs/openapi.json` with `dart-dio`
- Business code uses `LucentDioClient`, not generated internals
- Token storage prefers secure storage, with platform fallback
- `Accept-Language` is injected by the network layer
- Authorization is injected when an access token exists; generated `secure` metadata is not trusted because the current generator emits empty lists
- `401002` triggers refresh and retry
- Dio errors are unwrapped through `LucentErrorMapper`
- `ChangeEmailDto` follows Lucent contract: `newEmail` + `code`

## Regenerate

```bash
npx @openapitools/openapi-generator-cli generate ^
  -i ..\Lucent\docs\openapi.json ^
  -g dart-dio ^
  -o packages\lucent_openapi ^
  --additional-properties=serializationLibrary=json_serializable,pubName=lucent_openapi,pubLibrary=lucent_openapi,sourceFolder=src,finalProperties=true,skipCopyWith=true,useEnumExtension=true,enumUnknownDefaultCase=true

cd packages\lucent_openapi
dart pub get
dart run build_runner build --delete-conflicting-outputs
cd ..\..
flutter pub get
```

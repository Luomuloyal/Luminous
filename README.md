# Luminous

Flutter personal health copilot. Current mainline is the reset five-tab shell backed by Lucent.

## Baseline

- Tabs: `today / record / medicine / mine / more`
- Design tokens: color / type / spacing / radius / shadow / breakpoints
- API client: `packages/lucent_openapi`
- Network layer: `lib/core/network/`
- i18n: Flutter `gen-l10n`

## Commands

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

## Docs

Start with [docs/README.md](docs/README.md).

Key shared docs live in `../Lucent/docs/public/`:

- [ROADMAP](../Lucent/docs/public/ROADMAP.md)
- [api-contract](../Lucent/docs/public/api-contract.md)
- [design-system](../Lucent/docs/public/design-system.md)

Key frontend docs:

- [docs/MigrationLog.md](docs/MigrationLog.md)
- [docs/OpenApi_Client.md](docs/OpenApi_Client.md)
- [docs/Localization.md](docs/Localization.md)
- [docs/UI_Implementation_Plan.md](docs/UI_Implementation_Plan.md)

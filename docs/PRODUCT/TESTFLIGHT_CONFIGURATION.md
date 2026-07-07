# TestFlight configuration

Дата подготовки: 07.07.2026.

## Текущая локальная конфигурация

- Project: `StillThinking.xcodeproj`.
- Scheme: `StillThinking`.
- Bundle identifier: `com.everlastingholder.StillThinking`.
- Version: `1.0`.
- Build: `1`.
- Development team в проекте: `9B7MLUGM59`.
- Release configuration существует в project и scheme.

## Локально проверяемые команды

```sh
xcodebuild build \
  -project StillThinking.xcodeproj \
  -scheme StillThinking \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

## Требуется вне локального репозитория

- Проверить App Store Connect app record для bundle identifier.
- Подтвердить distribution signing и provisioning profile.
- Выполнить archive/export/upload через Xcode Organizer или `xcodebuild -archivePath ... archive` с включённой подписью.
- Заполнить TestFlight notes из `docs/PRODUCT/RELEASE_NOTES_BETA.md`.

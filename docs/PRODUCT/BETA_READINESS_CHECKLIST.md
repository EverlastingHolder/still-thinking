# Beta readiness checklist

Дата проверки: 07.07.2026.

## Локальные проверки

- [x] SwiftLint strict без нарушений.
- [x] `Localizable.xcstrings` проходит JSON-валидацию.
- [x] Debug test target проходит на iOS Simulator.
- [x] Release build проходит локально без code signing.
- [ ] Archive с distribution signing выполнен.
- [ ] Загрузка build в TestFlight выполнена.

## Основные сценарии

- [x] Первый запуск и onboarding проверены на крупном тексте EN/dark.
- [x] Запись мысли, планирование возврата и Today flow покрыты Swift Testing.
- [x] Archive, поиск и timeline покрыты Swift Testing.
- [x] Settings: pause/resume, privacy notifications, export и delete all data покрыты Swift Testing.
- [x] Pending notifications пересоздаются при запуске.
- [x] Timezone и изменение системного времени покрыты scheduler/settings тестами.
- [x] Migration baseline покрыт SwiftData tests.

## Privacy и logging

- [x] Логи не содержат текст мыслей и ответов.
- [x] Уведомления по умолчанию не содержат текст мысли.
- [x] Экспорт локальных данных выполняется только по действию пользователя.
- [x] Release logging policy покрыта тестами.

## Блокеры перед TestFlight

- [ ] Нужны distribution signing credentials и доступ к App Store Connect.
- [ ] Нужны финальные metadata: build number, release notes, privacy answers.

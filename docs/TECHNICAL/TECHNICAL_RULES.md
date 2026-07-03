# Technical rules

## Платформа и язык

- iOS application.
- Swift 6 language mode.
- Strict concurrency checking включён.
- SwiftUI — основной UI framework.
- SwiftData — локальное persistence-хранилище.
- Observation (`@Observable`) — состояние presentation-слоя.
- Swift Testing — unit- и integration-тесты.
- SwiftLint — обязательная статическая проверка.

Минимальная версия iOS фиксируется в Xcode project и меняется только отдельным решением.

## Системные frameworks

Разрешены по назначению:

- `UserNotifications` — локальные уведомления;
- `LocalAuthentication` — локальная блокировка;
- `OSLog` — технические события без приватного содержимого;
- `Foundation` и `SwiftData` — доменные типы и persistence;
- стандартные Apple frameworks, необходимые конкретной согласованной feature.

## Внешние зависимости

По умолчанию production-зависимости отсутствуют.

Добавление package/SDK требует:

1. обоснования проблемы;
2. сравнения со стандартными Apple API;
3. оценки privacy, maintenance и binary size;
4. отдельного согласования;
5. фиксации решения в документации.

Не добавлять автоматически Alamofire, Realm, Firebase, DI containers, navigation frameworks или design-system libraries.

## Архитектура

- Feature-oriented presentation.
- Доменные сущности не зависят от SwiftUI и persistence.
- SwiftData models расположены в Data и преобразуются в domain models при необходимости.
- System effects скрыты за узкими клиентами/протоколами.
- View отображает состояние и отправляет intent/action.
- `@Observable` model/view model координирует presentation state.
- Use case содержит бизнес-правило, когда оно не является простой операцией репозитория.
- Repository отвечает за хранение, выборку и mutation данных.

Абстракция вводится только при реальной границе ответственности, необходимости подмены в тестах или нескольких реализациях.

## Swift Concurrency

- Не отключать strict concurrency.
- Не использовать `@unchecked Sendable` без документированного доказательства безопасности.
- Не использовать `nonisolated(unsafe)` как быстрый обход ошибки.
- UI state изолируется на `MainActor`, если это требуется моделью доступа.
- Async API учитывают cancellation.
- Actor не создаётся без mutable shared state, который он действительно защищает.
- Не удерживать actor isolation во время долгой внешней операции без необходимости.

## Время и детерминированность

Бизнес-логика не должна напрямую зависеть от:

- `Date.now`;
- случайного `UUID()`;
- текущей таймзоны;
- реального notification center;
- реальной биометрии.

Эти значения и эффекты внедряются через зависимости для тестирования и Preview.

## Persistence

- SwiftData — единственный production store MVP.
- Preview и tests используют in-memory container.
- Изменение schema требует оценки migration.
- Удаление данных должно учитывать связанные reflections и schedules.
- Notification identifier хранится отдельно от доменной сущности, если он нужен для отмены.
- База данных является источником истины для срока возвращения; локальное уведомление — только канал доставки.

## Privacy

Запрещено сохранять в logs, analytics, crash breadcrumbs или test artifacts:

- текст мысли;
- текст reflection;
- поисковый запрос;
- содержимое sealed thought;
- полный текст уведомления, если он содержит запись пользователя.

По умолчанию notification не показывает содержимое мысли.

Для MVP допустима формулировка: данные хранятся локально и защищены средствами iOS. Нельзя заявлять отдельное end-to-end/database encryption без соответствующей реализации.

## Error handling

- Пустой `catch` запрещён.
- Ошибка либо обрабатывается, либо передаётся вверх, либо логируется безопасным техническим событием.
- Пользовательские сообщения об ошибках не должны раскрывать внутренние детали.
- Повторяемые ошибки переводятся в типизированные доменные/presentation состояния.

## Локализация и accessibility

- Пользовательские строки не размещаются в domain/data logic.
- UI проектируется с учётом RU и EN.
- Новые экраны поддерживают Dynamic Type.
- Интерактивные элементы имеют accessibility label/traits при необходимости.
- Цвет не является единственным носителем статуса.

## Запрещено в MVP без отдельного решения

- backend и аккаунты;
- CloudKit sync;
- сетевой слой;
- Firebase и сторонняя аналитика;
- AI-анализ пользовательских мыслей;
- голосовые записи и attachments;
- геолокация;
- social/public features;
- subscriptions/paywall;
- XCUITest target;
- background processing, не необходимый локальным уведомлениям.

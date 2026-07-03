# Testing

## Фреймворк

Для unit- и integration-тестов используется Swift Testing:

```swift
import Testing

@Suite("Return scheduler")
struct ReturnSchedulerTests {
    @Test("Marks an overdue thought as returned")
    func marksOverdueThoughtAsReturned() async throws {
        #expect(true)
    }
}
```

Используй:

- `@Suite` для группировки поведения;
- `@Test` с описанием ожидаемого результата;
- `#expect` для проверок;
- `#require` для обязательных preconditions;
- parameterized tests для набора однотипных случаев.

XCTest не используется для unit- и integration-тестов. XCUITest не входит в текущий MVP и требует отдельного решения.

## Что тестируется обязательно

- переходы `ThoughtStatus`;
- определение просроченных мыслей;
- создание, перенос и отмена расписания;
- защита от дублирующих уведомлений;
- выбор reflection prompt;
- добавление reflection;
- завершение, отпускание и повторное откладывание;
- repository mapping;
- SwiftData persistence и migrations;
- обработка фиксированного времени и часового пояса;
- regression каждого детерминированно воспроизводимого дефекта.

## Требования к тестам

Тесты должны быть:

- детерминированными;
- независимыми от порядка запуска;
- быстрыми;
- независимыми от production store;
- независимыми от реальных permission dialogs;
- независимыми от текущей даты и локальной таймзоны;
- читаемыми как описание поведения.

Запрещено:

- использовать произвольный `sleep` для синхронизации;
- обращаться к реальному `UNUserNotificationCenter`;
- запускать LocalAuthentication;
- использовать shared mutable global state;
- проверять private implementation details вместо поведения;
- менять expectation только ради зелёного теста.

## Тестовые зависимости

Для системных эффектов предоставляются controllable dependencies:

- `Clock` с фиксированным временем;
- UUID generator;
- notification scheduling client;
- authentication client;
- in-memory repository/SwiftData container;
- logger sink без приватных данных.

Абстракция создаётся вокруг реальной границы эффекта, а не вокруг каждого типа.

## Исправление дефекта

Предпочтительный порядок:

1. Воспроизвести дефект.
2. Добавить тест, падающий по ожидаемой причине.
3. Внести минимальное исправление.
4. Запустить новый тест.
5. Запустить связанный suite.
6. Запустить полный test target.
7. Проверить пользовательский сценарий в Simulator, если дефект видим пользователю.

Если дефект нельзя покрыть unit/integration-тестом, зафиксируй причину и ручной regression scenario.

## Запуск

Сначала определить project/workspace, scheme и доступный Simulator. Затем:

```bash
xcodebuild test \
  -project <Project>.xcodeproj \
  -scheme <Scheme> \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>' \
  CODE_SIGNING_ALLOWED=NO
```

Для workspace:

```bash
xcodebuild test \
  -workspace <Workspace>.xcworkspace \
  -scheme <Scheme> \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>' \
  CODE_SIGNING_ALLOWED=NO
```

При падении:

1. Найди первый причинный failure.
2. Определи: production-дефект, неверный тест или недетерминированность.
3. Исправь причину.
4. Повтори затронутый suite.
5. Перед завершением повтори полный test target.

## Границы покрытия

Coverage не является самостоятельной целью. Приоритет:

1. доменные переходы и правила времени;
2. persistence и system-effect boundaries;
3. ошибки и edge cases;
4. простые View passthrough и generated code — только при реальной ценности.

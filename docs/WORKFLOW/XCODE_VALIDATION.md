# Xcode validation

## Назначение

Правила проверки build, SwiftUI Preview и пользовательских сценариев в iOS Simulator.

## 1. Определение проекта и scheme

Не угадывай имена project/workspace и scheme.

```bash
find . -maxdepth 3 \( -name "*.xcworkspace" -o -name "*.xcodeproj" \)
```

Если найден workspace, используй его. Иначе — project.

```bash
xcodebuild -list -workspace <Workspace>.xcworkspace
# или
xcodebuild -list -project <Project>.xcodeproj
```

## 2. Выбор Simulator

Не фиксируй модель iPhone или версию iOS в инструкциях агента.

```bash
xcrun simctl list devices available
xcodebuild -showdestinations \
  -project <Project>.xcodeproj \
  -scheme <Scheme>
```

Приоритет:

1. уже запущенный совместимый iPhone Simulator;
2. доступный iPhone с актуальной установленной runtime;
3. destination, зафиксированный CI.

Для CLI используй UDID:

```text
platform=iOS Simulator,id=<SIMULATOR_UDID>
```

## 3. Build

```bash
xcodebuild build \
  -project <Project>.xcodeproj \
  -scheme <Scheme> \
  -configuration Debug \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>' \
  CODE_SIGNING_ALLOWED=NO
```

Для workspace замени `-project` на `-workspace`.

Успешный анализ отдельного файла в редакторе не считается build-проверкой.

## 4. SwiftUI Preview

### Когда Preview обязателен

Обновляй или добавляй `#Preview`, когда изменяется:

- экран;
- переиспользуемый компонент с состоянием;
- форма ввода;
- карточка мысли;
- timeline;
- empty/loading/error/content state;
- layout, чувствительный к длинному тексту, теме или Dynamic Type.

### Требования

Preview должен:

- использовать детерминированные данные;
- использовать фиксированное время и UUID;
- использовать in-memory persistence;
- не обращаться к production store;
- не планировать реальные уведомления;
- не вызывать биометрию;
- не использовать сеть;
- не содержать реальных пользовательских данных.

Рекомендуемые состояния:

- empty;
- typical content;
- long text;
- validation/error;
- dark mode;
- large Dynamic Type.

Не создавай Preview для каждой незначительной комбинации. Покрывай риски layout и состояния.

### Проверка через Xcode MCP

Если Xcode MCP доступен:

1. Открой соответствующий файл/Preview.
2. Запусти или обнови Canvas.
3. Проверь отсутствие crash и diagnostics.
4. Переключи необходимые конфигурации.
5. Проверь длинный текст, dark mode и крупный Dynamic Type, если они релевантны.

Если MCP недоступен, Preview должен как минимум компилироваться, а визуальная проверка переносится в Simulator. В отчёте явно укажи, что Canvas не был просмотрен.

## 5. Ручная проверка в Simulator

Для пользовательского изменения:

1. Запусти приложение.
2. Перейди к сценарию обычным пользовательским путём.
3. Проверь основной сценарий.
4. Проверь минимум один edge/error case.
5. Перезапусти приложение, если затронуто persistence или восстановление состояния.
6. Проверь light/dark mode для заметного UI.
7. Проверь крупный Dynamic Type для нового экрана.
8. Проверь privacy-поведение, если затронуты уведомления, блокировка или application switcher.

Ключевые сценарии проекта:

- пустой архив;
- создание мысли;
- повторное открытие сохранённой мысли;
- просроченное возвращение;
- добавление reflection;
- повторное откладывание;
- завершение или отпускание;
- запрет уведомлений;
- разблокировка приложения.

## 6. Роль Xcode MCP и CLI

- Xcode MCP используется для Canvas, diagnostics и интерактивного UI.
- `xcodebuild` используется для воспроизводимого build/test.
- `simctl` используется для управления Simulator при необходимости.
- Ни один из этих инструментов не заменяет остальные проверки.

## 7. Если окружение недоступно

Если Xcode, Simulator или MCP недоступны:

- выполни доступные lint/build/tests;
- укажи точную причину ограничения;
- не заявляй, что Preview или UI проверены;
- дай короткий ручной сценарий для разработчика.

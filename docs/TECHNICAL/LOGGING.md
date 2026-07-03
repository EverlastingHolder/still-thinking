# Logging

## Цель

Система логирования должна позволять быстро включать и отключать вывод отдельных областей приложения без удаления логов из кода.

Пример: разработчик может оставить в консоли только логи базы данных и `ThoughtCapture`, полностью скрыв уведомления, навигацию и другие feature.

Система решает четыре задачи:

1. Разделяет события по каналам.
2. Фильтрует каналы и уровни до вывода в консоль.
3. Позволяет менять конфигурацию через Xcode Scheme и debug-only интерфейс.
4. Не допускает утечки пользовательского содержимого.

## Основной принцип

Код не создаёт независимые «логгеры» вручную в каждом файле. Существует единая logging infrastructure, которая выдаёт компонентам logger, уже привязанный к конкретному каналу.

```swift
private let logger: LoggerClient

logger.debug("Loading thoughts")
logger.error("Thought loading failed", metadata: ["errorCode": code])
```

Канал задаётся в composition root:

```swift
let databaseLogger = loggerFactory.makeLogger(for: .database)
let captureLogger = loggerFactory.makeLogger(for: .featureThoughtCapture)
```

Feature и repository не должны знать, какие другие каналы включены.

## Каналы

Канал описывает источник события, а не его важность.

Базовый набор:

```text
app
database
notifications
authentication
scheduling
navigation
feature.thoughtCapture
feature.today
feature.reflection
feature.timeline
feature.archive
feature.settings
```

Будущие области добавляют свой канал только при появлении реального кода. Например, `network` добавляется вместе с согласованным сетевым слоем, а не заранее.

Каналы должны иметь стабильные строковые значения, пригодные для:

- Xcode launch arguments;
- OSLog category;
- Console filters;
- debug menu;
- тестовой конфигурации.

Не создавать канал на каждый файл или тип. Канал соответствует подсистеме или feature.

## Уровни

Уровень описывает важность события:

```text
debug
info
notice
error
fault
```

Правила:

- `debug` — подробная диагностика разработки;
- `info` — значимое штатное событие;
- `notice` — необычное, но обработанное состояние;
- `error` — операция завершилась ошибкой;
- `fault` — нарушение инварианта или состояние, которое не должно происходить.

Не использовать `error` для обычного пользовательского отказа, empty state или denied permission, если приложение корректно это обрабатывает.

## Фильтрация

`LogConfiguration` содержит минимум:

```swift
struct LogConfiguration: Sendable {
    let enabledChannels: Set<LogChannel>
    let minimumLevel: LogLevel
}
```

Событие выводится только когда:

1. его канал включён;
2. уровень не ниже `minimumLevel`;
3. текущая build-конфигурация разрешает такой вывод.

Фильтрация должна происходить до формирования дорогого сообщения и metadata. Message API должен поддерживать ленивое вычисление, чтобы отключённый канал почти не создавал накладных расходов.

## Источники конфигурации

Приоритет от большего к меньшему:

1. Xcode launch arguments.
2. Environment variables.
3. Debug-only сохранённые настройки разработчика.
4. Значения проекта по умолчанию.

Более высокий источник полностью определяет явно переданные параметры, но не обязан сбрасывать остальные параметры.

### Xcode launch arguments

Рекомендуемые аргументы:

```text
-STLogChannels database,feature.thoughtCapture
-STLogLevel debug
```

Специальные режимы:

```text
-STLogAll YES
-STLogNone YES
```

Пример для просмотра только базы данных:

```text
-STLogChannels database
-STLogLevel debug
```

Пример для двух областей:

```text
-STLogChannels database,notifications
-STLogLevel info
```

Неизвестное имя канала не должно приводить к crash. Оно игнорируется с одним безопасным диагностическим сообщением от канала `app`.

### Environment variables

Допустимый эквивалент для CI, scripts и локальных конфигураций:

```text
ST_LOG_CHANNELS=database,feature.reflection
ST_LOG_LEVEL=debug
ST_LOG_ALL=1
ST_LOG_NONE=1
```

Launch arguments имеют приоритет над environment variables.

## Debug-only экран управления

В Debug build допускается раздел:

```text
Settings → Developer → Logging
```

Он позволяет:

- включить или отключить каждый канал;
- выбрать минимальный уровень;
- включить все;
- отключить все;
- сбросить настройки к значениям по умолчанию;
- увидеть активный источник конфигурации.

Изменения должны применяться без перезапуска приложения, если logging infrastructure уже поддерживает thread-safe runtime configuration.

Требования:

- экран компилируется только для Debug;
- он не доступен в Release;
- debug-настройки не синхронизируются и не входят в пользовательский экспорт;
- launch arguments должны иметь понятный приоритет над сохранёнными toggles;
- реализация runtime store должна быть безопасной для Swift 6 и не использовать `@unchecked Sendable` как обход.

Если live-обновление ещё не реализовано, первая версия может применять настройки после перезапуска приложения. Это должно быть явно указано в UI.

## Значения по умолчанию

### Debug

Рекомендуемая политика:

- `app` включён;
- feature-каналы включаются по необходимости;
- минимальный уровень — `info`;
- `error` и `fault` не должны теряться из-за слишком шумного `debug` вывода.

Конкретный default-набор фиксируется при реализации и покрывается тестом.

### Release

Release не использует пользовательские debug toggles.

Рекомендуемая политика:

- `debug` и подробный `info` отключены;
- остаются только безопасные `error`/`fault` технические события, действительно полезные для диагностики;
- никакие launch arguments не должны случайно включать приватный подробный вывод в production build;
- текст пользователя не логируется при любом уровне.

## OSLog

Production sink строится поверх `OSLog.Logger`.

Правила mapping:

- один subsystem — bundle identifier приложения;
- один OSLog category — один `LogChannel.rawValue`;
- уровни приложения отображаются на соответствующие возможности OSLog;
- Xcode Console может дополнительно фильтровать вывод по subsystem/category.

App-level filtering и Console filtering дополняют друг друга:

- app-level filter не создаёт ненужные события;
- Console filter помогает анализировать уже разрешённый вывод.

`print`, `debugPrint` и прямое создание `Logger` внутри feature/data/services запрещены. Все события проходят через проектный logging client.

## Предлагаемые компоненты

Минимальная структура:

```text
Services/Logging/
├── LogChannel.swift
├── LogLevel.swift
├── LogConfiguration.swift
├── LoggerClient.swift
├── LoggerFactory.swift
└── OSLogSink.swift
```

При появлении live toggles могут быть добавлены:

```text
Services/Logging/
├── LogConfigurationStore.swift
├── LogConfigurationParser.swift
└── DebugLogPreferences.swift

Features/Settings/DeveloperLogging/
├── DeveloperLoggingView.swift
└── DeveloperLoggingModel.swift
```

Не создавать все типы заранее. Добавлять компонент вместе с первым реальным использованием.

## Ответственность компонентов

### `LogChannel`

Типобезопасный список стабильных каналов. Не принимать произвольную строку в production call site.

### `LogLevel`

Сравнимый уровень важности и mapping в sink.

### `LogConfiguration`

Снимок активных каналов и минимального уровня.

### `LoggerClient`

Интерфейс, который получает feature/repository. Он уже scoped к одному каналу и не позволяет вызывающему коду менять глобальную конфигурацию.

### `LoggerFactory`

Создаётся в composition root и выдаёт scoped logger для конкретного канала.

### `OSLogSink`

Единственное место, непосредственно использующее OSLog API.

### `LogConfigurationStore`

Нужен только для runtime toggles. Обновляет конфигурацию thread-safe способом и предоставляет logger актуальный snapshot.

## Metadata

Metadata должна быть структурированной и безопасной.

Допустимо:

```text
thoughtCount=12
scheduleState=overdue
notificationAuthorization=denied
migrationVersion=2
operation=createThought
errorCode=repositoryWriteFailed
```

Запрещено:

```text
thoughtText=...
reflectionText=...
searchQuery=...
notificationBody=...
userProvidedTitle=...
```

Идентификаторы сущностей не логируются полностью без необходимости. Для correlation использовать короткий session/operation identifier, не позволяющий восстановить пользовательское содержимое.

## Privacy

Запрещено логировать:

- текст мысли;
- reflection;
- поисковый запрос;
- sealed content;
- notification body с пользовательским текстом;
- biometric details;
- экспортированные пользовательские данные;
- файловые пути, содержащие чувствительные имена;
- полное описание ошибки, если оно включает пользовательские данные.

OSLog privacy annotations не являются разрешением передавать чувствительные данные. Лучший способ защиты — не формировать такие значения для logger.

## Ошибки

Не логировать одну ошибку на каждом слое.

Правило владения:

- низкий слой добавляет технический context либо возвращает типизированную ошибку;
- слой, который принимает окончательное решение об обработке, пишет одно событие;
- повторный лог допустим только при добавлении действительно новой границы или результата recovery.

Иначе одна проблема создаст несколько одинаковых строк.

## Тестирование

Обязательные тесты logging infrastructure:

- включённый канал передаёт событие sink;
- отключённый канал не вызывает sink;
- `minimumLevel` фильтрует низкие уровни;
- `STLogAll` включает все зарегистрированные каналы;
- `STLogNone` отключает все каналы;
- launch arguments имеют приоритет над environment/debug preferences;
- неизвестные каналы не вызывают crash;
- runtime toggle применяется согласно выбранной модели;
- message/metadata для отключённого канала не вычисляются;
- Release policy не разрешает подробные debug-события;
- recording sink позволяет тестировать события без OSLog.

Тесты не должны читать Xcode Console.

## Preview

Preview используют no-op или recording logger.

Preview не должен:

- писать шум в Xcode Console;
- зависеть от launch arguments;
- менять debug preferences;
- обращаться к OSLog для проверки UI.

Для экрана Developer Logging Preview должен использовать локальную in-memory конфигурацию.

## Добавление нового канала

1. Убедиться, что существующий канал не подходит.
2. Добавить стабильное значение в `LogChannel`.
3. Указать владельца канала в feature/service.
4. Добавить канал в debug UI и parser.
5. Обновить тесты `all channels`.
6. Не включать новый шумный канал по умолчанию без причины.
7. Проверить, что сообщения не содержат пользовательских данных.

## Definition of Done для logging

- [ ] Call sites используют scoped `LoggerClient`.
- [ ] Канал можно включить и отключить конфигурацией.
- [ ] Уровень фильтруется до передачи в OSLog.
- [ ] Отключённый лог не вычисляет дорогие данные.
- [ ] Нет `print` и прямых feature-level `OSLog.Logger`.
- [ ] Нет пользовательского содержимого в сообщениях и metadata.
- [ ] Конфигурация покрыта Swift Testing.
- [ ] Debug UI отсутствует в Release.
- [ ] Фактический активный набор каналов можно быстро определить при отладке.

# Project structure

## Цель

Физическая структура каталогов должна отражать архитектуру и упрощать навигацию через CodeGraph и Xcode.

## Базовая структура

```text
StillThinking/
├── App/
│   ├── StillThinkingApp.swift
│   ├── AppEnvironment.swift
│   ├── AppRouter.swift
│   └── AppCompositionRoot.swift
│
├── Features/
│   ├── Onboarding/
│   ├── ThoughtCapture/
│   ├── Today/
│   ├── Reflection/
│   ├── ThoughtTimeline/
│   ├── Archive/
│   └── Settings/
│
├── Domain/
│   ├── Models/
│   ├── UseCases/
│   ├── Repositories/
│   └── Scheduling/
│
├── Data/
│   ├── SwiftDataModels/
│   ├── Repositories/
│   ├── Mappers/
│   └── Migrations/
│
├── Services/
│   ├── Notifications/
│   ├── Authentication/
│   ├── Export/
│   ├── Logging/
│   ├── Clock/
│   └── Identifiers/
│
├── DesignSystem/
│   ├── Components/
│   ├── Typography/
│   ├── Layout/
│   ├── Motion/
│   └── Theme/
│
├── PreviewSupport/
│   ├── Fixtures/
│   ├── Containers/
│   └── Dependencies/
│
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.xcstrings
    └── PrivacyInfo.xcprivacy

StillThinkingTests/
├── Domain/
├── Data/
├── Services/
├── Features/
└── TestSupport/
```

На старте это каталоги внутри одного app target и одного test target. Разделение на Swift Packages или framework targets выполняется только при измеримой необходимости.

## Структура feature

Feature не обязан содержать все возможные подпапки. Создавай только реально используемые.

```text
Features/ThoughtCapture/
├── ThoughtCaptureView.swift
├── ThoughtCaptureModel.swift
├── ThoughtCaptureState.swift
├── ThoughtCaptureAction.swift
├── Components/
└── Preview/
```

Для простой feature допустимо меньше файлов:

```text
Features/Onboarding/
├── OnboardingView.swift
└── OnboardingModel.swift
```

Не создавай пустые `Domain`, `Data`, `Presentation` каталоги только ради шаблона.

## Правила зависимостей

```text
App → Features → Domain
App → Data/Services
Data → Domain
Services → Domain contracts при необходимости
DesignSystem → не зависит от Features
PreviewSupport → может собирать fake implementations для Preview
```

Запрещённые зависимости:

- `Domain → SwiftUI`;
- `Domain → SwiftData`;
- `Domain → UserNotifications`;
- `Data → Features`;
- `DesignSystem → Features`;
- одна feature → presentation/types другой feature;
- production target → test target.

Общий пользовательский переход между feature координируется через AppRouter/composition layer, а не прямой импорт View другой feature.

## Именование файлов

- Имя файла совпадает с основным типом: `ReturnScheduler.swift`.
- Один основной публичный/internal top-level type на файл.
- Малые private helper-типы могут находиться рядом с владельцем.
- Extensions размещаются рядом с типом либо в `Type+Purpose.swift`, если файл становится перегруженным.
- Protocol именуется по роли: `ThoughtRepository`, а не `IThoughtRepository`.
- Default implementation именуется конкретно: `SwiftDataThoughtRepository`.
- Fake/Stub/Spy доступны только в PreviewSupport или test target.

## Запрещённые каталоги

Не создавать размытые контейнеры:

- `Helpers`;
- `Managers`;
- `Common`;
- `Shared`;
- `Utils`;
- `Misc`.

Если тип невозможно положить в конкретную область, сначала уточни его ответственность. Узкий каталог вроде `Services/Clock` допустим.

## Domain

`Domain/Models` содержит независимые сущности и value types:

- `Thought`;
- `Reflection`;
- `ReturnSchedule`;
- статусы и opinion state.

`Domain/Repositories` содержит контракты хранения.

`Domain/UseCases` создаётся для бизнес-операций, которые:

- затрагивают несколько зависимостей;
- содержат переход состояния;
- должны тестироваться независимо;
- не являются простой CRUD-операцией.

Не создавать use case как одно строчное перенаправление без дополнительной семантики.

## Data

`Data/SwiftDataModels` содержит только persistence models.

Правила:

- SwiftData model не передаётся напрямую во View;
- mapping централизован;
- relationships и cascade/nullify правила определены явно;
- schema changes сопровождаются migration assessment;
- preview/test containers не используют production store URL.

## Services

Системный framework изолируется в своей области:

```text
Services/Notifications/
├── NotificationClient.swift
├── LocalNotificationClient.swift
└── NotificationRequestFactory.swift
```

Protocol/Client должен отражать нужды приложения, а не копировать весь Apple API.

## DesignSystem

В DesignSystem помещается только действительно переиспользуемый UI.

Правило двух использований:

- первый локальный компонент остаётся внутри feature;
- после второго реального использования оценивается перенос в DesignSystem;
- перенос не должен добавлять feature-specific terminology.

## PreviewSupport

Содержит:

- sample domain models;
- фиксированный Clock;
- in-memory ModelContainer factory;
- fake notification/authentication clients;
- наборы данных для длинного текста и edge states.

PreviewSupport не содержит production business logic и не импортируется release-кодом вне `#if DEBUG`, если это требуется конфигурацией target.

## Tests

Структура тестов зеркалит production-области.

```text
StillThinkingTests/Domain/Scheduling/ReturnSchedulerTests.swift
StillThinkingTests/Data/SwiftDataThoughtRepositoryTests.swift
StillThinkingTests/Features/ThoughtCapture/ThoughtCaptureModelTests.swift
```

Общие test doubles находятся в `StillThinkingTests/TestSupport`, но только если используются несколькими suites.

## Добавление нового файла

Перед созданием:

1. Найди владельца ответственности через CodeGraph.
2. Проверь, нет ли существующего типа с такой ролью.
3. Выбери самый узкий подходящий каталог.
4. Убедись, что зависимость направлена внутрь архитектуры.
5. Добавь файл в корректный target.
6. Добавь/обнови тесты и Preview.
7. Проверь, что физический путь и Xcode group не расходятся.

## Добавление нового feature

Новая feature допустима, если она есть в `docs/PRODUCT/FEATURES.md` либо явно согласована.

Минимальный порядок:

1. Создать каталог `Features/<FeatureName>`.
2. Добавить View и presentation model.
3. Использовать domain contracts, не обращаться к SwiftData/system APIs напрямую.
4. Добавить Preview states.
5. Добавить Swift Testing для model/use case.
6. Подключить feature через composition root/router.
7. Обновить feature map и implementation plan при изменении scope.

# Implementation plan

## Назначение

Порядок реализации `Still Thinking`. Каждый этап должен завершаться собираемым состоянием проекта и проверяемым результатом.

Feature ID соответствуют `docs/PRODUCT/FEATURES.md`.

## Общие правила

- Следующий этап начинается после выполнения exit criteria текущего.
- Каждая feature реализуется отдельной веткой от `develop` и PR в `develop`.
- Крупный этап делится на несколько PR, а не реализуется одной большой веткой.
- В каждый PR входят соответствующие Swift Testing и Preview.
- Архитектурная инфраструктура добавляется только перед первой реальной потребностью.
- Release в `master` выполняется только после Beta readiness.

---

# Phase 0. Repository and project bootstrap

Связанные features: `FND-01`, `FND-02`.

## Задачи

1. Создать Xcode project и app target.
2. Создать Swift Testing target.
3. Включить Swift 6 language mode и strict concurrency.
4. Создать shared scheme.
5. Добавить `.gitignore` для Xcode/macOS/Codex artifacts.
6. Добавить `.swiftlint.yml` и reproducible lint command.
7. Добавить базовый PR CI: lint, Simulator build, tests.
8. Убедиться, что ветка `develop` существует и является основной рабочей веткой процесса.

## Проверка

- пустое приложение собирается;
- test target запускается;
- SwiftLint запускается;
- CI проходит на PR в `develop`.

## Exit criteria

- [ ] Xcode project открыт и собирается.
- [ ] Swift Testing выполняет минимум один smoke test.
- [ ] Shared scheme доступна `xcodebuild`.
- [ ] SwiftLint и CI настроены.

---

# Phase 1. Architecture skeleton

Связанные features: `FND-03`, `FND-06`, `FND-07`.

## Задачи

1. Создать каталоги по `PROJECT_STRUCTURE.md` без пустой избыточной иерархии.
2. Добавить `AppEnvironment` и composition root.
3. Добавить `Clock` и UUID dependency.
4. Создать безопасный logger interface.
5. Создать PreviewSupport и TestSupport только для первых реальных doubles.
6. Подготовить AppRouter, если первый flow требует навигации.

## Проверка

- зависимости создаются в composition root;
- feature не использует service locator;
- fake Clock используется в smoke test и Preview.

## Exit criteria

- [ ] Есть один понятный composition path от App к feature.
- [ ] System effects можно подменять.
- [ ] Нет неиспользуемых слоёв и пустых протоколов.

---

# Phase 2. Domain and persistence

Связанные features: `FND-04`, `FND-05`.

## Задачи

1. Реализовать domain models: Thought, Reflection, ReturnSchedule.
2. Определить статусы и допустимые переходы.
3. Создать repository contracts.
4. Создать SwiftData models и mapping.
5. Реализовать production repository.
6. Реализовать in-memory container для tests и Preview.
7. Определить delete rules для связанных сущностей.
8. Зафиксировать первую schema version.

## Тесты

- создание и чтение мысли;
- сохранение reflections;
- переходы статуса;
- cascade/nullify behavior;
- удаление цепочки;
- mapping domain ↔ persistence.

## Exit criteria

- [ ] Persistence не протекает в SwiftUI View.
- [ ] Repository integration tests проходят.
- [ ] In-memory container используется в tests/Preview.

---

# Phase 3. Thought creation vertical slice

Связанные features: `THO-01`, `THO-02`.

## Задачи

1. Реализовать экран ввода.
2. Реализовать presentation model/state.
3. Добавить validation текста.
4. Добавить выбор срока возвращения.
5. Сохранить Thought и ReturnSchedule одним согласованным действием.
6. Добавить Preview: empty, typical, long text, validation, dark mode.
7. Подключить flow к composition root.

## Тесты

- пустая мысль не сохраняется;
- корректная мысль сохраняется;
- срок в прошлом отклоняется;
- выбранные presets дают ожидаемую дату с fixed Clock;
- ошибка repository отображается как presentation state.

## Simulator scenario

Создать мысль, закрыть приложение, открыть снова и убедиться, что запись сохранена.

## Exit criteria

- [ ] Пользователь может создать мысль и выбрать дату.
- [ ] Состояние переживает перезапуск приложения.
- [ ] Preview и tests проходят.

---

# Phase 4. Return scheduler and notifications

Связанные features: `SCH-01`, `NOT-01`.

## Задачи

1. Реализовать ReturnScheduler domain/service logic.
2. Реализовать NotificationClient поверх UserNotifications.
3. Запрашивать permission в контексте feature.
4. Планировать нейтральное уведомление.
5. Поддержать перенос и отмену.
6. Исключить дублирование identifier/request.
7. При старте находить просроченные schedules независимо от notification delivery.
8. Обработать denied permission без потери основной функции.

## Тесты

- schedule создаётся;
- перенос отменяет старое уведомление и создаёт новое;
- завершённая мысль не уведомляется;
- duplicate scheduling не создаёт второй request;
- overdue schedule становится returned;
- denied permission не ломает сохранение.

## Simulator scenario

Проверить granted и denied permission, перенос даты и возврат просроченной записи.

## Exit criteria

- [ ] База является источником истины.
- [ ] Уведомление не содержит приватный текст по умолчанию.
- [ ] Нет дублирующих pending requests.

---

# Phase 5. Today and reflection flow

Связанные features: `TOD-01`, `REF-01`, `REF-02`, `REF-03`.

## Задачи

1. Реализовать Today empty/content states.
2. Показать исходную мысль и дату.
3. Добавить библиотеку базовых prompts.
4. Сохранить reflection.
5. Поддержать opinion state.
6. Поддержать завершение, отпускание и повторное откладывание.
7. Обновить schedule/status атомарно на уровне use case/repository transaction boundary.

## Тесты

- сохранение reflection;
- opinion state;
- завершение;
- release;
- reschedule;
- повторная обработка одного returned item не создаёт дубликат.

## Simulator scenario

Пройти полный цикл: создать → вернуть → ответить → отложить снова → завершить.

## Exit criteria

- [ ] Основной продуктовый цикл работает end-to-end.
- [ ] Все переходы статуса протестированы.
- [ ] Today не превращается в бесконтрольный inbox.

---

# Phase 6. Timeline and archive

Связанные features: `TIM-01`, `ARC-01`, `ARC-02`.

## Задачи

1. Реализовать timeline одной мысли.
2. Отображать исходную запись, reflections, даты и статусы.
3. Реализовать archive sections/filters.
4. Реализовать локальный поиск.
5. Добавить empty search state.
6. Убедиться, что поисковый запрос не логируется.

## Тесты

- сортировка timeline;
- фильтрация по статусу;
- поиск по тексту;
- удалённые записи не появляются;
- длинные цепочки отображаются в правильном порядке.

## Exit criteria

- [ ] История мысли читаема и последовательна.
- [ ] Archive покрывает основные статусы.
- [ ] Поиск работает локально и приватно.

---

# Phase 7. Settings and privacy

Связанные features: `SET-01`, `SEC-01`, `DAT-01`.

## Задачи

1. Настройки privacy для уведомлений.
2. Разрешённое время уведомлений.
3. Пауза возвращений.
4. LocalAuthentication lock.
5. Fallback при недоступной биометрии.
6. Скрытие чувствительного состояния при background, если согласовано.
7. Удаление одной мысли.
8. Полное удаление данных с подтверждением.

## Тесты

- authentication state transitions через fake client;
- pause/resume scheduling;
- изменение notification settings пересобирает pending requests;
- полное удаление очищает связанные данные;
- ошибки удаления обрабатываются безопасно.

## Exit criteria

- [ ] Приватный контент не раскрывается по умолчанию.
- [ ] Блокировка не делает данные недоступными без понятного fallback.
- [ ] Пользователь может удалить данные.

---

# Phase 8. Onboarding and product polish

Связанные features: `ONB-01`, `UX-01`, `LOC-01`.

## Задачи

1. Реализовать короткий onboarding.
2. Объяснить механику возвращения и privacy.
3. Добавить RU/EN localization.
4. Проверить Dynamic Type и VoiceOver.
5. Проверить light/dark mode.
6. Проверить длинные тексты и пустые состояния.
7. Отполировать motion без навязчивой gamification.

## Exit criteria

- [ ] Новый пользователь понимает основной цикл.
- [ ] Ключевые экраны доступны с VoiceOver и крупным текстом.
- [ ] RU и EN не ломают layout.

---

# Phase 9. Beta readiness

Связанные features: `EXP-01`, `REL-01`, `MIG-01`, `QA-01`.

## Задачи

1. Экспорт локальных данных.
2. Восстановление pending notifications.
3. Проверка смены таймзоны и системного времени.
4. Migration tests.
5. Privacy audit логов и уведомлений.
6. Полный regression checklist.
7. TestFlight configuration.
8. Release notes и известные ограничения.

## Exit criteria

- [ ] Все Foundation/MVP/Beta blockers закрыты.
- [ ] CI зелёный.
- [ ] Full test target проходит.
- [ ] Основные сценарии вручную проверены.
- [ ] Нет известных privacy/blocking defects.
- [ ] Build готов к ограниченному TestFlight.

---

# Phase 10. First release

## Git flow

1. Создать `release/1.0.0` от `develop`.
2. Разрешить только release fixes и metadata.
3. Выполнить полный regression.
4. PR release → master.
5. Создать tag/release.
6. Вернуть release changes в develop.

## После релиза

- собирать только обезличенную техническую обратную связь;
- проверить, возвращаются ли пользователи к возвращённым мыслям;
- не начинать Post-MVP функции до оценки основной механики;
- обновить feature map и roadmap по результатам beta/release.

---

# Порядок PR внутри этапа

Рекомендуемый размер:

1. Domain/contracts.
2. Data/service implementation.
3. Presentation/UI vertical slice.
4. Edge cases и polish.

Но не разделяй так, чтобы промежуточный PR оставлял мёртвую инфраструктуру без использования. Вертикальный рабочий срез предпочтительнее заранее созданных слоёв.

# Изменение плана

Если порядок или scope меняется:

1. Обновить этот документ.
2. Обновить `FEATURES.md`.
3. Указать причину и зависимости.
4. Не начинать несогласованную крупную feature только потому, что технически удобно.

# Privacy audit логов и уведомлений

Дата проверки: 07.07.2026.

## Область

- постоянные логи через `LoggerClient`;
- локальные уведомления возвращения мыслей;
- экспорт локальных данных.

## Результат

- Логи используют статические сообщения и техническую metadata: операция, статус, количество, размер файла и тип ошибки.
- Текст мыслей, ответов и поисковых запросов не передаётся в metadata логов.
- Тело уведомления по умолчанию нейтральное и не содержит текст мысли.
- Текст мысли может быть показан в уведомлении только при явной пользовательской настройке `showsThoughtTextInNotifications`.
- Экспорт локальных данных намеренно содержит пользовательские данные и создаётся только по действию пользователя через системный share flow.

## Regression-покрытие

- `SwiftDataThoughtRepositoryTests.repositoryWritesDatabaseEventsWithoutUserContent` проверяет database-логи.
- `ReturnSchedulerTests.schedulesNeutralNotificationAndStoresIdentifier` проверяет нейтральное тело уведомления по умолчанию.
- `ReturnSchedulerTests.schedulingDoesNotWriteUserContentToLogs` проверяет scheduler-логи.
- `SettingsModelTests.exportCreatesLocalDataDocument` проверяет явный экспорт локального JSON-документа.

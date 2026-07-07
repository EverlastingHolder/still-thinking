# Формат локального экспорта данных

Документ описывает формат файла, который создаётся из настроек приложения через действие экспорта локальных данных.

## Общие правила

- Формат: JSON.
- Кодировка: UTF-8.
- Имя файла: `still-thinking-export-<ISO-8601-date>.json`, где символ `:` в дате заменён на `-`.
- Экспорт создаётся локально на устройстве и передаётся только через системный share sheet.
- Файл содержит пользовательский текст мыслей и ответов, поэтому его нужно считать приватным пользовательским документом.

## Версия 1

Корневой объект:

```json
{
  "formatVersion": 1,
  "exportedAt": "2026-07-07T08:00:00Z",
  "settings": {
    "hasCompletedOnboarding": true,
    "showsThoughtTextInNotifications": false,
    "notificationStartHour": 9,
    "notificationEndHour": 21,
    "returnsPaused": false,
    "privacyLockEnabled": false
  },
  "thoughts": []
}
```

`thoughts` содержит элементы:

```json
{
  "thought": {
    "id": "00000000-0000-0000-0000-000000000001",
    "text": "Текст мысли",
    "status": "pending",
    "createdAt": "2026-07-07T08:00:00Z",
    "updatedAt": "2026-07-07T08:00:00Z"
  },
  "reflections": [],
  "schedules": []
}
```

`reflections` содержит сохранённые ответы пользователя:

```json
{
  "id": "00000000-0000-0000-0000-000000000002",
  "thoughtID": "00000000-0000-0000-0000-000000000001",
  "text": "Ответ",
  "opinionState": "unchanged",
  "createdAt": "2026-07-07T08:00:00Z"
}
```

`schedules` содержит локальные расписания возврата:

```json
{
  "id": "00000000-0000-0000-0000-000000000003",
  "thoughtID": "00000000-0000-0000-0000-000000000001",
  "dueAt": "2026-07-08T08:00:00Z",
  "state": "scheduled",
  "notificationIdentifier": null,
  "createdAt": "2026-07-07T08:00:00Z",
  "updatedAt": "2026-07-07T08:00:00Z"
}
```

# Правила репозитория

## Назначение

Документ фиксирует обязательные правила GitHub-репозитория `still-thinking` и рекомендуемую конфигурацию защищённых веток.

## Основные ветки

### `master`

Назначение:

- только стабильные версии;
- состояние, соответствующее опубликованному или готовому к публикации release;
- изменения поступают только из `release/*` и `hotfix/*` через Pull Request.

Запрещено:

- прямой push;
- прямой commit через веб-интерфейс GitHub;
- force push;
- удаление;
- переименование;
- изменение истории;
- merge обычных `feature/*`, `fix/*`, `docs/*`, `chore/*`, `test/*` и `refactor/*` напрямую.

### `develop`

Назначение:

- основная интеграционная ветка;
- база для обычной разработки;
- целевая ветка для `feature/*`, `fix/*`, `docs/*`, `chore/*`, `test/*` и `refactor/*`.

Запрещено:

- прямой push;
- прямой commit через веб-интерфейс GitHub;
- force push;
- удаление;
- переименование;
- изменение истории.

## Обязательный путь изменений

```text
feature/* ─┐
fix/* ─────┤
docs/* ────┤
chore/* ───┼──> Pull Request ──> develop
refactor/* ┤
test/* ────┘

develop ──> release/* ──> Pull Request ──> master
master ───> hotfix/* ───> Pull Request ──> master
                                      └──> develop
```

## Обязательные правила Pull Request

- Один PR решает одну цель.
- Описание PR пишется на русском языке.
- Заголовок PR формулируется на русском языке; технический префикс Conventional Commits допустим.
- PR содержит инструкцию проверки.
- PR перечисляет фактически выполненные проверки.
- Несвязанный рефакторинг в PR запрещён.
- Все обсуждения должны быть разрешены до merge.
- Merge выполняется только после успешных обязательных проверок.
- Сам merge выполняется только по явному решению владельца репозитория.

## Рекомендуемые GitHub Rulesets

Нужно создать два активных branch ruleset.

### Ruleset `Защита master`

Целевая ветка:

```text
master
```

Включить:

- Restrict deletions.
- Block force pushes.
- Require a pull request before merging.
- Require conversation resolution before merging.
- Require status checks to pass — после появления CI.
- Require branches to be up to date before merging — после стабилизации CI.
- Запрет обхода правил по умолчанию, кроме явно назначенного аварийного администратора.

Не включать обязательное линейное дерево истории, если для `release/*` и `hotfix/*` используются merge commits.

### Ruleset `Защита develop`

Целевая ветка:

```text
develop
```

Включить:

- Restrict deletions.
- Block force pushes.
- Require a pull request before merging.
- Require conversation resolution before merging.
- Require status checks to pass — после появления CI.
- Require branches to be up to date before merging — после стабилизации CI.

## Проверки статуса

После создания CI в обязательные checks добавить минимум:

```text
SwiftLint
Сборка для Simulator
Swift Testing
```

Точные названия checks должны совпадать с именами jobs в GitHub Actions.

До появления CI нельзя указывать несуществующие required checks: это заблокирует merge всех PR.

## Локальные Git hooks

В репозитории есть tracked hooks в `.githooks/`.

Включить их в локальном clone:

```bash
git config core.hooksPath .githooks
```

`pre-commit` проверяет:

- запрет commit напрямую в `master` и `develop`;
- whitespace-ошибки в staged diff;
- отсутствие staged `DerivedData`, `.DS_Store`, `xcuserdata` и `.xcuserstate`;
- SwiftLint для staged Swift-файлов, если `swiftlint` установлен.

`pre-push` проверяет:

- запрет push в `master` и `develop`;
- запрет non-fast-forward push;
- соответствие рабочих веток префиксам Git Flow.

Hooks не заменяют GitHub Rulesets. Они дают раннюю локальную ошибку, а серверные rulesets остаются обязательной защитой репозитория.

## Approval policy

Пока в репозитории один разработчик:

- не требовать обязательное одобрение другого пользователя, если это делает merge невозможным;
- обязательно требовать PR, успешные проверки и разрешение обсуждений.

После появления второго участника:

- включить минимум одно обязательное approval;
- сбрасывать approval при новых значимых commit, если это поддерживается выбранной конфигурацией;
- запретить автору учитывать собственное approval.

## Default branch

Основной веткой репозитория рекомендуется сделать:

```text
develop
```

Это гарантирует, что новые PR и локальные clone по умолчанию ориентированы на рабочую интеграционную ветку, а не на release-ветку `master`.

## Разрешённые способы merge

Для обычных PR в `develop`:

- предпочтительно Squash and merge;
- merge commit допустим только при обоснованной необходимости сохранить структуру commit.

Для `release/*` и `hotfix/*`:

- допустим merge commit;
- после merge изменения обязательно возвращаются в `develop`.

Rebase and merge не используется для общих release/hotfix-веток, если это усложняет обратное слияние.

## Удаление веток

- `master` и `develop` никогда не удаляются автоматически или вручную.
- `feature/*`, `fix/*`, `docs/*`, `chore/*`, `test/*`, `refactor/*`, `release/*` и `hotfix/*` удаляются после успешного merge и завершения обратного слияния, если оно требуется.
- Перед удалением ветки нужно убедиться, что её изменения доступны в целевой ветке.

## Действия агента

Codex и другие агенты:

- не пушат напрямую в `master` или `develop`;
- не удаляют `master` и `develop`;
- не перемещают refs этих веток;
- не выполняют force push;
- не выполняют merge без явной команды;
- создают рабочую ветку от правильной базы;
- пишут описание PR на русском языке;
- указывают фактические проверки и ограничения.

## Ручная настройка GitHub

Так как правила веток являются настройками GitHub, они не активируются наличием этого Markdown-файла.

Владелец репозитория должен открыть:

```text
Settings → Rules → Rulesets
```

и создать rulesets по конфигурации выше.

После настройки нужно проверить:

1. Прямой push в `develop` отклоняется.
2. Прямой push в `master` отклоняется.
3. Force push отклоняется.
4. Удаление обеих веток запрещено.
5. PR без обязательных checks нельзя слить.
6. После успешных checks PR можно слить выбранным способом.

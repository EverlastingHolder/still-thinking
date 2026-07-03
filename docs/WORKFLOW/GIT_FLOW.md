# Git flow

## Назначение веток

- `master` — только стабильное состояние, соответствующее release.
- `develop` — основная интеграционная ветка текущей разработки.
- `feature/*` — новая функциональность.
- `fix/*` — исправления, не являющиеся срочным production hotfix.
- `refactor/*` — структурные изменения без изменения поведения.
- `test/*` — тестовая инфраструктура и отдельные тестовые задачи.
- `chore/*` — инструменты, конфигурация и обслуживание.
- `docs/*` — документация.
- `release/*` — подготовка версии к выпуску.
- `hotfix/*` — срочное исправление версии из `master`.

## Обычная разработка

Все обычные ветки создаются от актуального `develop`:

```bash
git status --short --branch
git switch develop
git pull --ff-only
git switch -c feature/create-thought
```

Целевая ветка Pull Request для `feature/*`, `fix/*`, `refactor/*`, `test/*`, `chore/*` и `docs/*` — `develop`.

Прямые коммиты в `develop` и `master` запрещены после bootstrap.

## Feature branch

1. Создать от `develop`.
2. Реализовать одну цель.
3. Выполнить проверки.
4. Открыть PR в `develop`.
5. После merge удалить feature-ветку.

Ветка не должна жить дольше необходимого. Если работа большая, раздели её на вертикальные законченные части.

## Release branch

Когда `develop` готов к выпуску:

```bash
git switch develop
git pull --ff-only
git switch -c release/1.0.0
```

В `release/*` разрешены только:

- version/build number;
- release notes;
- финальные исправления дефектов;
- локализация и метаданные релиза;
- изменения CI/CD, необходимые для выпуска.

Новые функции в release-ветку не добавляются.

После проверки:

1. PR `release/1.0.0` → `master`.
2. После merge создать tag версии.
3. Вернуть release-изменения в `develop` отдельным merge/PR.
4. Удалить release-ветку.

## Hotfix branch

Срочное исправление production создаётся от `master`:

```bash
git switch master
git pull --ff-only
git switch -c hotfix/1.0.1-notification-crash
```

После проверки:

1. PR `hotfix/*` → `master`.
2. Создать patch tag/release.
3. Обязательно вернуть hotfix в `develop`.
4. Удалить hotfix-ветку.

Hotfix нельзя оставить только в `master`, иначе дефект вернётся в следующем release.

## Pull Request

Один PR решает одну цель и содержит:

```markdown
## Что изменено

## Почему

## Как проверить

## Проверки
- [ ] SwiftLint
- [ ] Simulator build
- [ ] Swift Testing
- [ ] Preview
- [ ] Manual Simulator flow

## Риски / ограничения
```

PR не должен содержать несвязанный рефакторинг или форматирование всего проекта.

## Merge policy

Предпочтительный способ merge для feature/fix/docs/chore PR — squash merge, если история отдельных коммитов не несёт самостоятельной ценности.

Для `release/*` и `hotfix/*` допустим merge commit, чтобы сохранить границу ветки и упростить обратный merge в `develop`.

Конкретный merge выполняется только по явной команде пользователя.

## Коммиты

Используется Conventional Commits:

```text
feat: add thought creation flow
fix: prevent duplicate notification scheduling
test: cover overdue thought transition
docs: split development workflow
chore: configure SwiftLint
```

Требования:

- один логический результат на коммит;
- сообщение описывает результат;
- тесты бизнес-правки обычно входят в тот же коммит;
- перед коммитом проверяется staged diff;
- generated-файлы, DerivedData и секреты не коммитятся.

## Запрещено без явной команды

- прямой push в `master` или `develop`;
- merge PR;
- `git push --force` и `--force-with-lease`;
- rebase опубликованной общей ветки;
- reset с потерей пользовательских изменений;
- удаление remote branches;
- изменение истории опубликованных коммитов;
- массовое удаление untracked-файлов.

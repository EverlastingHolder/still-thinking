# Development documentation index

Этот файл — короткая точка входа в рабочие правила проекта. Подробные инструкции разделены по темам.

## Обязательно перед любой кодовой задачей

1. [`WORKFLOW/DEVELOPMENT_PROCESS.md`](WORKFLOW/DEVELOPMENT_PROCESS.md) — общий цикл выполнения задачи и Definition of Done.
2. [`WORKFLOW/GIT_FLOW.md`](WORKFLOW/GIT_FLOW.md) — ветки, Pull Request, release и hotfix.
3. [`WORKFLOW/TOOLING.md`](WORKFLOW/TOOLING.md) — CodeGraph, Xcode MCP и CLI fallback.
4. [`ARCHITECTURE/PROJECT_STRUCTURE.md`](ARCHITECTURE/PROJECT_STRUCTURE.md) — размещение файлов и зависимости между областями.
5. [`TECHNICAL/TECHNICAL_RULES.md`](TECHNICAL/TECHNICAL_RULES.md) — обязательный стек, ограничения и запреты.

## Читать по типу задачи

- UI, Preview, Xcode или Simulator: [`WORKFLOW/XCODE_VALIDATION.md`](WORKFLOW/XCODE_VALIDATION.md)
- Unit/integration-тесты и исправление дефектов: [`WORKFLOW/TESTING.md`](WORKFLOW/TESTING.md)
- Новая продуктовая функция: [`PRODUCT/FEATURES.md`](PRODUCT/FEATURES.md)
- Выбор следующего этапа реализации: [`PRODUCT/IMPLEMENTATION_PLAN.md`](PRODUCT/IMPLEMENTATION_PLAN.md)
- Настройка и обслуживание Codex: [`CODEX_SETUP.md`](CODEX_SETUP.md)

## Приоритет требований

1. Явная текущая задача пользователя.
2. Корневой `AGENTS.md`.
3. Тематические документы из этого индекса.
4. Существующий код и тесты.

При конфликте остановись и укажи конкретные противоречащие требования. Не выбирай молча удобный вариант.

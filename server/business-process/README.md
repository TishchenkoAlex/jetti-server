# Business Process: первый исполняемый сценарий

Первый вертикальный сценарий реализован для `Document.CashRequest` и запускается при проведении документа (`ON_POST`). Seed создаёт иерархическую группу `BP.CashRequest`, четыре правила и черновик шаблона `CashRequestApproval`.

## Подготовка

1. Применить SQL-схему подсистемы из каталога `sql`.
2. Выполнить `004.seed.cash-request-process.sql`.
3. Выполнить `005.verify.cash-request-process.sql`. Ожидаемый результат — `validationResult = VALID` и `resolvedRules = 4`.
4. Выполнить `006.business-process.permissions.sql` для выдачи пользователю `jetti` минимальных runtime-прав.
5. Локально проверить контракты JS-модулей командой `npm run test:business-process-seed`.
6. Активировать возвращённый seed-скриптом шаблон:

   ```http
   POST /api/business-process/templates/{templateId}/activate
   ```

Активация обязательна: `TemplateService` проверяет структуру шаблона, назначения ссылок на правила и компилируемость JS-модулей.

## Позитивный маршрут

1. Создать и провести `Document.CashRequest`, у которого заполнен автор типа `Catalog.User`.
2. Убедиться, что документ перешёл в `AWAITING`.
3. Получить задачи текущего пользователя:

   ```http
   GET /api/business-process/tasks/my
   ```

4. Получить решения задачи. Пользователю должны быть доступны только `APPROVE` и `REJECT`:

   ```http
   GET /api/business-process/tasks/{taskId}/decisions
   ```

5. Согласовать задачу:

   ```http
   POST /api/business-process/tasks/{taskId}/decide
   Content-Type: application/json

   { "decision": { "key": "APPROVE", "comment": null } }
   ```

Ожидаемый итог: задача `APPROVED`, процесс `COMPLETED`, документ `APPROVED`.

## Отклонение и таймаут

Для `REJECT` обязателен комментарий. Ожидаемый итог — задача и процесс `REJECTED`, документ `REJECTED`.

Для проверки таймаута можно вызвать планировщик с датой позже `deadline.at` задачи:

```http
POST /api/business-process/scheduler/tick
Content-Type: application/json

{ "now": "<ISO date later than task deadline>", "limit": 100 }
```

Ожидаемый итог: `overdueTasks = 1`, `autoCompletedTasks = 1`, решение задачи `TIMEOUT` с источником `SYSTEM`, процесс и документ `REJECTED`.

Полную последовательность событий можно проверить запросом:

```http
GET /api/business-process/instances/{instanceId}/events
```

## Автоматический планировщик

Периодический запуск регистрируется в общей Bull-очереди при старте API. По умолчанию он отключён, чтобы сервер не запускал обработку до применения SQL-схемы и активации первого шаблона.

Настройки окружения:

- `BUSINESS_PROCESS_SCHEDULER_ENABLED=true` — включить регистрацию repeat-job;
- `BUSINESS_PROCESS_SCHEDULER_INTERVAL_MS=60000` — интервал, минимум 10 секунд;
- `BUSINESS_PROCESS_SCHEDULER_LIMIT=500` — максимум кандидатов каждого типа за один tick, не более 5000.

Текущее состояние конфигурации и распределённой SQL-блокировки доступно администратору:

```http
GET /api/business-process/scheduler/status
```

Повторный и ручной запуск защищены общей session-level блокировкой SQL Server `BusinessProcess.Scheduler.Tick`. Если другой экземпляр уже выполняет tick, результат имеет `run.status = SKIPPED_LOCKED`.

## Интеграционный smoke-прогон

Проверить готовность подключённой базы без изменения данных:

```bash
npm run test:business-process-integration:preflight
```

Preflight выводит только агрегированные признаки: наличие схемы, активного шаблона, число разрешённых правил и количество подходящих документов. Идентификаторы и параметры подключения не выводятся.

Для полного прогона нужно явно выбрать заявку без существующих экземпляров БП и передать её идентификатор через окружение:

```bash
BUSINESS_PROCESS_SMOKE_CASH_REQUEST_ID=<uuid> npm run test:business-process-integration
```

На Windows переменную можно установить через `$env:BUSINESS_PROCESS_SMOKE_CASH_REQUEST_ID`. Runner последовательно проверяет `APPROVE`, `REJECT` и `TIMEOUT`. Каждый сценарий выполняется в отдельной SQL-транзакции, завершается намеренным rollback и затем проверяет, что статус документа и данные процесса не сохранились.

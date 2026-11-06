# HTTP API для разработчиков

Описание составлено по обработчикам текущего сервера. Схемы документов, форм и регистров зависят от типа и метаданных; для конкретной интеграции сверяйте поля с метаданными и кодом соответствующей модели. Примеры с заполнителями требуют значений из вашей среды.

## Адреса и формат

Базовый адрес — адрес экземпляра сервера, например `http://localhost:3000`. Основные маршруты имеют префикс `/api`, авторизация пользователя — `/auth`, интеграционные маршруты — `/exchange`. Тела запросов обычно передаются как JSON с заголовком `Content-Type: application/json`. Максимальный размер JSON и URL-encoded тела — 50 MB.

Все маршруты `/api` требуют JWT. У `/auth` и `/exchange` защита установлена на отдельных обработчиках: маршруты входа доступны без JWT, остальные перечисленные ниже маршруты требуют его. Передавайте токен в заголовке:

```http
Authorization: Bearer <jetti-jwt>
```

Отсутствующий, недействительный или истёкший токен даёт HTTP 401 с JSON-полем `message`. Общий обработчик ошибок обычно возвращает HTTP 500 и текст ошибки, но некоторые обработчики возвращают собственные коды и JSON. Не рассчитывайте на единую схему ошибок для всех маршрутов.

## Авторизация

### Вход пользователя

`POST /auth/login` принимает `email`, `token` и `timezoneOffset`. Поле `token` — токен Microsoft Graph: сервер запрашивает `/v1.0/me/`, а пользователя ищет в Jetti. Ответ содержит `account`, Jetti `token` и, если получена, `photo` в base64. Время жизни Jetti JWT — 72 часа.

```json
{
  "email": "user@example.com",
  "token": "<microsoft-graph-access-token>",
  "timezoneOffset": 0
}
```

`GET /auth/account` возвращает данные текущего пользователя. `POST /auth/refresh` требует действующий JWT и возвращает новый JWT и `account`; принимает `timezoneOffset` в теле. `GET /auth/subsystems` и `GET /auth/subsystems/menu` возвращают доступные подсистемы и меню.

### Вход сервисной интеграции

`POST /exchange/login` принимает email из настроенного `SERVICE_ACCOUNTS` и пароль из `EXCHANGE_ACCESS_KEY`. При успехе возвращает `{ "account": ..., "token": "..." }`; токен действует 24 часа. `timezoneOffset` необязателен.

```http
POST /exchange/login
Content-Type: application/json

{
  "email": "<service-email>",
  "password": "<exchange-access-key>",
  "timezoneOffset": 0
}
```

Используйте полученный Jetti JWT в последующих запросах. Секрет и токены храните в безопасной конфигурации, а не в исходном коде или примерах с реальными значениями.

## Документы и справочники

Идентификаторы в примерах — GUID из вашей базы. Значения `type`, допустимые поля и обязательные реквизиты определяются метаданными и логикой модели. Удобно начинать с `GET /api/getDocMetaByType/:type` или `POST /api/view`.

| Метод и путь | Назначение |
| --- | --- |
| `GET /api/byId/:id` | Получить плоское представление объекта; если объект не найден, ответ может быть `null`. |
| `GET /api/document/:id` | Получить представление с вложенным `doc` и `docByKeys`; отсутствующий объект возвращается как `null`. |
| `GET /api/getDocMetaByType/:type` | Получить `Prop` и `Props` типа из метаданных сервера. |
| `GET /api/document/meta/:type/:operationId` | Получить метаданные `prop` и `props` для типа и операции. |
| `POST /api/view` | Получить модель и метаданные для отображения: `schema`, `model`, `columnsDef`, `metadata`, `settings`. Тело содержит `type` и, для существующего объекта, `id`. |
| `POST /api/list` | Получить список для интерфейса; тело — `DocListRequestBody` из `jetti-middle`, включая тип, фильтры и сортировку. |
| `POST /api/save` | Сохранить документ; тело разбирается `DocumentServer.parse`, ответ — модель представления. |
| `POST /api/savepost` | Сохранить и провести документ; ответ — модель представления. |
| `GET /api/post/:id`, `GET /api/unpost/:id` | Провести или отменить проведение; ответ содержит `id` и `posted`. Эти GET-запросы изменяют состояние. |
| `DELETE /api/:id` | Переключить признак удаления объекта, вернуть модель представления. Повторный вызов отменяет отметку удаления. |
| `DELETE /api/document/:id` | Аналогично переключить признак удаления; при успехе возвращает `{ "Status": "OK" }`. |
| `POST /api/baseon`, `POST /api/executecommand` | Создание на основании и выполнение команды документа; формат зависит от вызываемой логики. |
| `POST /api/valueChanges/:type/:property`, `POST /api/command/:type/:command` | Обработчики изменения поля и команды объекта; контракт зависит от типа. |
| `GET /api/ancestors/:id/:level`, `GET /api/descendants/:id`, `GET /api/haveDescendants/:id` | Навигация по иерархии. |
| `GET /api/getHistoryById/:id`, `GET /api/restore/:type/:id` | Получение истории и представления её версии. |

Пример запроса метаданных и объекта:

```sh
curl "$BASE_URL/api/getDocMetaByType/Catalog.Company" \
  -H "Authorization: Bearer $JETTI_TOKEN"

curl "$BASE_URL/api/document/$DOCUMENT_ID" \
  -H "Authorization: Bearer $JETTI_TOKEN"
```

### Запись через интеграционный маршрут

`POST /api/document` принимает объект с `document` и `options`. Он ищет объект по `options.searchKey` и применяет `options.updateType`: `Insert`, `Update` или `InsertOrUpdate`. Для режимов, отличных от `Insert`, обработчик требует `searchKey`. Поля документа задаются в `document.doc` или `document.docByKeys`; допустимые поля и обязательные значения определяет модель. Для новой `Document.Operation` нужен `document.doc.Operation`.

```json
{
  "document": {
    "type": "<тип>",
    "doc": { "<поле>": "<значение>" }
  },
  "options": {
    "updateType": "InsertOrUpdate",
    "searchKey": [{ "key": "<поле поиска>", "value": "<значение>" }],
    "commands": [],
    "queueFlow": 1
  }
}
```

Это иллюстрация структуры, а не готовый документ: реальные ключи поиска, реквизиты и `queueFlow` нужно выбирать по контракту интеграции. При успехе возвращается документ с `docByKeys`. Ошибки валидации и ошибки внутри обработчика могут возвращаться с HTTP 405 и JSON-строкой, включая `Unknow error: ...`. При сохранении применяются проверки пользователя, компании, контура и бизнес-правил.

`POST /api/executeOperation` вызывает метод серверного модуля операции. Текущий обработчик применяет `JSON.parse` к `req.body` и читает `operationId` и `args`, затем выбирает `args.method` или `RESTMethod`; обычный JSON-объект в теле он напрямую не обрабатывает. Перед использованием согласуйте формат с реализацией и проверьте на тестовом экземпляре. В Swagger путь указан как `/executeOperation`, но фактический префикс маршрута — `/api`.

## Поиск, регистры и формы

| Метод и путь | Назначение и вход |
| --- | --- |
| `POST /api/suggest/:type?filter=...` | Подсказки по типу; тело содержит `filters`. Ветка без `filter` не отправляет ответ, поэтому передавайте непустой фильтр. |
| `GET /api/register/movements/list/:id` | Список типов движений документа по регистрам. |
| `GET /api/register/account/movements/view/:id` | Движения документа по регистру бухгалтерии. |
| `GET /api/register/accumulation/list/:id`, `GET /api/register/info/list/:id` | Типы регистров накопления или сведений документа. |
| `GET /api/register/accumulation/:type/:id`, `GET /api/register/info/:type/:id` | Движения документа по выбранному типу регистра. |
| `POST /api/register/info/byFilter/:type` | Запрос регистра сведений; тело — массив `{ key, value }`. |
| `POST /api/accum/balance` | Остатки: `registerName`, `date`, `fields`, `groupBy`, `filter`, `topRows`. |
| `POST /api/accum/turnover` | Обороты: `registerName`, `period`, `fields`, `groupBy`, `filter`, `topRows`. |
| `POST /api/info/sliceLast` | Последний срез: `type`, `date`, `company`, `analytics`. |
| `GET /api/form/view/:type` | Метаданные формы: `metadata` и `schema`. |
| `POST /api/form/:type/execute` | Выполнить форму по модели из тела запроса. |
| `POST /api/form/:type/:method`, `POST /api/form/:type/nonmodel/:method` | Выполнить метод формы; возвращаемое значение зависит от формы и варианта маршрута. |

Форматы фильтров и результата определяются типом регистра и реализацией `jetti-middle`. Маршруты регистров и форм описаны в `server/routes/registers.ts`, `utils.ts` и `form.ts`.

## Очереди и обмен

`POST /api/jobs/add` принимает `{ "data": ..., "opts": ... }`, ставит задачу в Bull и возвращает её представление. `GET /api/jobsCount`, `/api/jobsActive`, `/api/jobs` и `/api/jobs/:id` показывают состояние очереди и задач.

`GET` и `POST /exchange/v1.0/hello` возвращают JSON-строку `hello`. Маршруты обмена ниже принимают JWT и добавляют данные в SQL-очередь `exc.Queue`:

| Метод и путь | Тип записи очереди |
| --- | --- |
| `POST /exchange/v1.0/income/invoice` | `Invoice` |
| `POST /exchange/v1.0/income/order` | `Order` |
| `POST /exchange/v1.0/income/expense` | `Expense` |
| `POST` или `PATCH /exchange/v1.0/Employee` | `Employee` |
| `POST /exchange/v1.0/queue` | `Queue` |
| `POST /exchange/v1.1/queue` | `DataType` из строки или `Queue_v1.1` по умолчанию |

Для `v1.1/queue` тело может быть объектом или массивом объектов; `ExchangeCode` и `ExchangeBase` дополнительно сохраняются в колонках очереди. Успешный ответ этих обработчиков — JSON-число `200`: это подтверждение вставки, а не завершения последующей обработки. Для массива `v1.1` вставка выполняется пакетами, поэтому при ошибке часть записей может уже существовать; повтор следует согласовать с правилами дедупликации потребителя.

Служебные `POST /exchange/v2/info`, `/exchange/v2/network` и `/exchange/v2/curl` требуют JWT и дополнительное поле `pwd`. Это диагностические маршруты; `info` возвращает окружение процесса и журнал, поэтому его ответ может содержать конфиденциальные данные.

## Остальные группы

- `/api/BP/*` — бизнес-процессы и задачи; маршруты и поля запроса описаны в `server/routes/bp.ts`.
- `/api/attachments/*` — добавление, удаление и получение вложений; см. `server/routes/documents.ts`.
- `POST /api/user/settings` — команды `get`, `save` и `delete` настроек; `GET /api/user/roles` в текущем коде возвращает фиксированный массив `['Admin']`, а не список ролей из JWT.
- Дополнительные маршруты документов, команд, операций и истории перечислены в `server/routes/documents.ts`.

Swagger UI доступен на `/swagger`, его исходный файл — `server/swagger.json`. Это частичная спецификация, и не все её пути совпадают с фактическими. Неизвестный GET-путь может попасть в общий обработчик и вернуть HTTP 200 с текстом состояния сервера, поэтому такой ответ сам по себе не подтверждает существование API-маршрута.

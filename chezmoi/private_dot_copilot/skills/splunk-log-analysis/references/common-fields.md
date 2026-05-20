# Common Fields in GitHub's Splunk Indexes

## `rails` index (web requests)

| Field | Description | Example |
|---|---|---|
| `controller` | Rails controller | `PullRequestsController` |
| `action` | Rails action | `show` |
| `elapsed` | Request duration (seconds) | `0.453` |
| `status` / `http.status_code` | HTTP status code (both field names are valid) | `200` |
| `route` | Rails route pattern | `/repositories/:repository_id/issues/:id` |
| `path_info` | Request path | `/github/github/issues/123` |
| `user` | Authenticated username (web) | `monalisa` |
| `current_user` | Authenticated username (API) | `monalisa` |
| `repo` | Repository nwo | `github/github` |
| `repo_visibility` | Repository visibility | `private` |
| `request_id` | Unique request identifier | `A1C0:764A:82C13F:878361:62F2C36F` |
| `request_category` | Request type | `api`, `browser` |
| `request_method` | HTTP method | `GET`, `POST` |
| `request_host` | Request hostname | `github.com` |
| `code.namespace` | Ruby class/namespace | `Search::Queries::IssueQuery` |
| `catalog_service` | Service catalog name | `github/issues` |
| `stamp` | Deployment stamp | `dotcom` |
| `app` | Application name | `github`, `hookshot`, `heaven` |
| `version` | API version (API requests) | `v3` |
| `timeout` | Whether request timed out | `true` |

## `prod-exceptions` index

Uses **different field names** than the `rails` index:

| Field | Rails equivalent | Example |
|---|---|---|
| `rails.controller.name` | `controller` | `PullRequestsController` |
| `rails.controller.action` | `action` | `show` |
| `exception_type` | — | `ActiveRecord::ConnectionTimeoutError` |
| `catalog_service` | same | `github/issues` |
| `gh.request_id` | `request_id` | `A1C0:764A:82C13F:878361:62F2C36F` |

## `glb` index (load balancer)

| Field | Description | Example |
|---|---|---|
| `ta` | Total request latency (ms) | `234` |
| `rails_request_time` | Time inside Rails (ms) | `180` |
| `rails_controller` | Controller name | `issues` |
| `rails_action` | Action name | `show` |
| `rails_request_category` | Request category | `browser`, `api` |
| `request_id` | Same as rails index | `A1C0:...` |
| `backend` | HAProxy backend | `kubernetes_web_unicorn_clusters` |
| `status` | HTTP status code | `200` |

## `prod-resque` index (background jobs)

| Field | Description | Example |
|---|---|---|
| `gh.job.name` | Job class name | `UpdateIssueSearchIndexJob` |
| `gh.catalog_service` | Service catalog name | `github/issues` |
| `SeverityText` | Log severity | `ERROR`, `INFO`, `WARN` |

## `prod-quoroner` index (killed SQL)

| Field | Description |
|---|---|
| `query` | The killed SQL query text (contains request_id embedded) |

Source: [Hub: A Splunk guide for dotcom — Field Reference](https://thehub.github.com/epd/engineering/incident-response/being-on-call/splunk/#field-reference)

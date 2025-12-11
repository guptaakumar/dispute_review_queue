# Dispute Review Queue

A lightweight Rails 8 app for triaging dispute cases. It ingests external dispute webhooks, queues processing, and exposes a simple reviewer UI with role-based access.

## Requirements
- Ruby `3.4.4` (see `.ruby-version`)
- PostgreSQL (local, username/password `postgres` by default)
- Redis (for webhook idempotency lock; also needed if using Sidekiq)
- Bundler `>= 2.5`

## Setup
1) Install dependencies
`bundle install`

2) Configure the database (update `config/database.yml` if not using the default `postgres/postgres@localhost:5432`).
`bin/rails db:create db:migrate`

3) (Optional) Set default user passwords per role via credentials:
`bin/rails credentials:edit` and add:
```yaml
default_users:
  admin: your-password
  reviewer: your-password
  read_only: your-password
```

## Running locally
- Start Rails: `bin/rails server`
- Background jobs: uses ActiveJob. In development it runs inline; for durable processing use Sidekiq with Redis:
  - Set `config.active_job.queue_adapter = :sidekiq` (e.g., in `config/environments/development.rb`).
  - Run `bundle exec sidekiq`.
- Redis: ensure `REDIS_URL` is set if not using the default `redis://localhost:6379/0`.

## Operations
- Webhook intake: `POST /webhooks/disputes` with a JSON body (array or object) containing `charge_external_id`, `dispute_external_id`, `amount`, `status`, `event_type`, `occurred_at`. Each event is queued to `DisputeProcessorWorker` and deduped with a Redis lock.
  - For quick testing, use `script/post_webhook.sh` against a running server.
- Dispute triage UI: available at the root path. Reviewers/Admins see active cases (`open`, `needs_evidence`, `awaiting_decision`); read-only users see all history.
- Evidence uploads: files are stored under `public/uploads` with a timestamped filename; notes and file metadata are kept on the `evidence` record.
- Time zones: each request runs in the signed-in user’s time zone (defaults to UTC).

## Key decisions
- **RBAC-first:** Authentication required everywhere except the public webhook. Roles: `read_only`, `reviewer`, `admin`; reviewer implies admin privileges for queue actions.
- **Webhook safety:** Validation of required fields plus Redis-based idempotency; events are processed asynchronously to keep the endpoint fast (returns 202).
- **State transitions:** Dispute model owns transitions (`needs_evidence`, `awaiting_decision`, reopen from `won/lost`) and records case actions for audit.
- **Upload handling:** Evidence uploads saved locally with collision-resistant names; metadata persisted to allow external storage later.
- **Defaults over seeds:** No seed data; defaults (role/time zone) set in models. Credentials can provide per-role default passwords.

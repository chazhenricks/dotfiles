---
name: built-local-k8s-repair
description: Repair, start, and verify Chaz's Built local Kubernetes developer environment. Use when the user asks for daily local k8s startup, to get pods in working order, to fix local k8s, run k8s_yesterday/start-day, repair search-service indexes, fix portfolioDeals/view-portfolio-deals-main-lambda 500s, reindex marketplace/auth/portfolio/search indexes, verify dms-stream-event-broker, Kafka/MSK consumers, SQS queues, or Lambda event source mappings in the local workstation namespace.
---

# Built Local K8s Repair

Use this skill to restore a local Built k8s namespace to a usable development state and to repeat the fragile search/portfolio/event-plumbing repairs discovered during the June 2026 local-k8s recovery.

## Defaults

Assume these unless the user says otherwise:

- Namespace: `chahen` (`K8S_NAMESPACE` or `NS` overrides)
- Stack repo: `/Users/chaz.henricks/BuiltSource/kubernetes-developer-environment/single-stack`
- AWS profile: `built_dev_eks/BuiltEksDev`
- Workstation base URL: `https://${NS}.workstation.getbuilt.com`
- OpenSearch base URL: `https://${NS}.workstation.getbuilt.com/elasticsearch`

## First response workflow

For normal daily startup, run `k8s_daily`. The canonical script is `/Users/chaz.henricks/dotfiles/bin/k8s_daily`; `/Users/chaz.henricks/.agent-skills/built-local-k8s-repair/scripts/daily_startup.zsh` and `/Users/chaz.henricks/.local/bin/k8s_daily` are symlinks to it. This is the one command Chaz should remember.

1. Start or keep a `caffeinate` process for long repairs if the user is stepping away.
2. Run `/Users/chaz.henricks/.agent-skills/built-local-k8s-repair/scripts/local_k8s_check.zsh` to capture the current state.
3. If the portfolio page or `portfolioDeals` query is failing, run `/Users/chaz.henricks/.agent-skills/built-local-k8s-repair/scripts/portfolio_repair.zsh`.
4. For a full local-dev-day reset, run `/Users/chaz.henricks/.agent-skills/built-local-k8s-repair/scripts/local_k8s_repair.zsh --all`.
5. If pods, TFOs, Flink jobs, Kafka topics, or service logs still look wrong, also use the `debug-k8s` skill and then update this skill if a new durable repair step is discovered.

## Scripts

- `/Users/chaz.henricks/dotfiles/bin/k8s_daily` — canonical one-command daily safe startup: git update, `k8s_yesterday`, wait pods, `make health`, and final local checks. The skill path `scripts/daily_startup.zsh` is a symlink to this dotfiles-backed script.
- `scripts/local_k8s_check.zsh` — read-only-ish health snapshot for k8s, portfolio index/template, DMS, and Lambda event-source mappings.
- `scripts/portfolio_repair.zsh` — deterministic repair for `view-portfolio-deals-main-lambda`: ensure template, recreate index if mapped wrong, hydrate deal events with system-key auth, and verify raw OpenSearch/search-service/GraphQL.
- `scripts/local_k8s_repair.zsh` — lower-level orchestrator for start-day, optional helm refresh, wait/poll, portfolio repair, and final checks.

Run scripts from any directory. They resolve their own skill path.

## Important cautions

- Do not paste or store Cognito tokens in this skill. Use generated local fake tokens or system-key exchange from SSM.
- Do not trust `bdev k8s dms status`; it has had local CLI bugs. Use AWS DMS CLI checks instead.
- A full `helmfile apply` can render DMS disabled unless DMS is explicitly enabled. Use `--set dms.enabled=true` when applying the stack, then verify the DMS task still exists and is `running`.
- Avoid production AWS profiles. This workflow is for local k8s/dev EKS only.
- Do not delete data broadly. The portfolio repair only deletes/recreates the local `view-portfolio-deals-main-lambda` search index when its mapping is absent or wrong.

## Known local portfolio repair facts

The `portfolioDeals` 500 previously came from a bad local OpenSearch mapping: `deal_uid` was dynamically created as `text` because `view-portfolio-deals-main-lambda` existed before the `view-portfolio-deals` index template. Fix by applying `data-platform-streaming` Terraform, recreating the index, and hydrating deal events.

Expected healthy checks:

- `GET /elasticsearch/_index_template/view-portfolio-deals` succeeds.
- `GET /elasticsearch/view-portfolio-deals-main-lambda/_mapping/field/deal_uid` shows `type: keyword`.
- `GET /elasticsearch/view-portfolio-deals-main-lambda/_count` returns local docs, usually `24` in Chaz's fixture data.
- A raw OpenSearch aggregation on `deal_uid` returns HTTP 200.
- `/search/v4/view-portfolio-deals-main-lambda/_search` returns HTTP 200.
- `lending-portfolio-product-api` `portfolioDeals` returns data without errors.

One known bad local fixture deal may fail hydration: `a57c347f-45d2-4b89-bbc6-49e63dc5cda3`. Treat `24/25` hydrated as acceptable unless the fixture data changes.

## Detailed references

Read `references/runbook.md` when doing the full environment recovery or when updating this skill with new findings. Read `references/search-indexes.md` when deciding what indexes or reindex commands should exist.

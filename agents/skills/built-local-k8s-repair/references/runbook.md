# Built local k8s recovery runbook

## Daily one-command startup

Use this first on normal work days:

```zsh
k8s_daily
```

Canonical dotfiles-backed path:

```zsh
/Users/chaz.henricks/dotfiles/bin/k8s_daily
```

Skill symlink path:

```zsh
/Users/chaz.henricks/.agent-skills/built-local-k8s-repair/scripts/daily_startup.zsh
```

Daily default is intentionally safe: it does not run `helmfile apply`. If charts/stack changed and Helm must be refreshed, run:

```zsh
k8s_daily --with-helm
```

If portfolio/search is broken too, run:

```zsh
k8s_daily --repair-portfolio
```

For only a health snapshot:

```zsh
k8s_daily --check-only
```

Use this reference for the full environment repair. Prefer the bundled scripts for deterministic checks and the portfolio index repair.

## Full start-day sequence

```zsh
cd /Users/chaz.henricks/BuiltSource/kubernetes-developer-environment/single-stack
git switch main
git pull --ff-only
git switch chaz
git merge main
source ~/.zshrc
k8s_yesterday
kubectl -n chahen wait --for=condition=Ready pod --all --timeout=900s
helmfile deps
helmfile apply --set dms.enabled=true
make health namespace=chahen
```

Then run:

```zsh
/Users/chaz.henricks/.agent-skills/built-local-k8s-repair/scripts/local_k8s_check.zsh
```

If portfolio is failing, run:

```zsh
/Users/chaz.henricks/.agent-skills/built-local-k8s-repair/scripts/portfolio_repair.zsh
```

For a one-command agent run:

```zsh
/Users/chaz.henricks/.agent-skills/built-local-k8s-repair/scripts/local_k8s_repair.zsh --all
```

## PortfolioDeals 500 repair

Root cause seen in June 2026: `view-portfolio-deals-main-lambda` was manually created before the `view-portfolio-deals` index template existed, so `deal_uid` mapped as `text`. Aggregations on `deal_uid` then caused OpenSearch 400s and `portfolioDeals` returned a generic 500.

The repair script performs this sequence:

1. Verify `GET /elasticsearch/_index_template/view-portfolio-deals`.
2. If missing, run `bdev k8s terraform run data-platform-streaming` and poll for the template.
3. Verify `GET /elasticsearch/view-portfolio-deals-main-lambda/_mapping/field/deal_uid`.
4. If `deal_uid` is not `keyword`, delete/recreate `view-portfolio-deals-main-lambda` so the template applies.
5. Fetch local system-key credentials from SSM and call `hydrateDealEventById` for local agreement UIDs.
6. Poll `_count` until docs exist.
7. Verify raw OpenSearch aggregation on `deal_uid`.
8. Verify `/search/v4/view-portfolio-deals-main-lambda/_search`.
9. Verify `lending-portfolio-product-api` `portfolioDeals` with a generated local fake branchadmin token.

Known acceptable local fixture behavior: `24/25` hydrated if only `a57c347f-45d2-4b89-bbc6-49e63dc5cda3` fails.

## Search-service Lambda runtime check

If search-service Lambdas fail with import/bytecode runtime issues, verify these functions:

- `${NS}-search-service-index`
- `${NS}-search-service-updater`
- `${NS}-search-service-reindex`
- `${NS}-search-service-manifest-ingest`

The June 2026 local artifact had Python 3.11 bytecode and needed runtime `python3.11`. Check with:

```zsh
AWS_PROFILE=built_dev_eks/BuiltEksDev aws lambda get-function-configuration --function-name chahen-search-service-updater --region us-east-2
```

Update only if the deployed artifact/runtime mismatch recurs.

## DMS and dms-stream-event-broker

Do not rely on `bdev k8s dms status`; it has had local command-construction bugs. Use AWS CLI:

```zsh
AWS_PROFILE=built_dev_eks/BuiltEksDev aws dms describe-replication-tasks --region us-east-2 --filters Name=replication-task-id,Values=local-chahen-just-cdc
```

Expected task: `local-${NS}-just-cdc`, status `running`, `TablesErrored=0`.

If DMS is missing, the durable fix is to keep DMS enabled in the stack values. Operational recovery used:

```zsh
helmfile apply --selector name=single-stack-base --set dms.enabled=true
```

A full `helmfile apply` without `--set dms.enabled=true` may render `enable_dms: false` and remove or disable the local DMS resources. Always verify after applying.

Broker checks:

```zsh
AWS_PROFILE=built_dev_eks/BuiltEksDev aws lambda list-event-source-mappings --region us-east-2 --function-name chahen-dms-stream-event-broker-handler
```

Expected event source mapping: `Enabled`, `LastProcessingResult=OK`.

June 2026 operational broker repair details, if this regresses:

- Current stack branch SHA included `marketplace-service.yml`; old deployed artifact did not.
- The local broker Lambda zip was patched to include `built_dms_event_broker/effect_definitions/marketplace-service.yml` from `/Users/chaz.henricks/BuiltSource/dms-stream-event-broker/built_dms_event_broker/effect_definitions/marketplace-service.yml`.
- Runtime needed `python3.9` for the deployed dependency set after `_cffi_backend` import failures.

Do not blindly apply that patch unless logs show the same missing effect definition or `_cffi_backend` failure.

## Kafka/MSK and Lambda consumers

Check all namespace event-source mappings:

```zsh
AWS_PROFILE=built_dev_eks/BuiltEksDev aws lambda list-event-source-mappings --region us-east-2 --max-items 200 --query "EventSourceMappings[?contains(FunctionArn, 'chahen')].[FunctionArn,State,LastProcessingResult,Topics]" --output table
```

Expected local mappings include, at minimum:

- `chahen.data_platform_streaming.view_portfolio_deal`
- `chahen.flex_fields.flex_fields`
- `chahen.ai_processing_service.state`
- `chahen.eventing.intentful`
- `chahen.deal_product_api.stakeholder`
- `chahen.draw.draw_builder`
- `chahen.deal_product_api.deals`
- `chahen.marketplace_product_api.purchase_order`
- `chahen.deal_product_api.deal_workflow_transition`

Healthy state is `Enabled` with `LastProcessingResult=OK` or equivalent recent success.

## Final health criteria

Treat the environment as fixed when all are true:

- `make health namespace=${NS}` shows TFOs ready, no crash loops, and Flink running.
- Portfolio template exists and `deal_uid` is `keyword`.
- Portfolio index has docs and the `portfolioDeals` GraphQL query returns no errors.
- DMS task is `running` with `TablesErrored=0`.
- DMS broker mapping is enabled/OK.
- Relevant Lambda event-source mappings are enabled/OK.

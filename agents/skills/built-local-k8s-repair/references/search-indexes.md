# Local search index inventory and reindex notes

Use this when deciding which local search-service indexes should exist and how to repopulate them.

## Central search-service indexes/aliases

| Index or alias | Owner/service | Local repair or reindex path |
| --- | --- | --- |
| `purchase_orders` | `marketplace-product-api` | `bdev reindex orders start`, then poll `bdev reindex orders status`. |
| `vendor_listings` | `marketplace-service` | `bdev reindex vendor-listings`. |
| `auth_tenants` | `auth-service` | Direct local Lambda reindex/invoke if bdev lacks a wrapper. |
| `auth_users` | `auth-service` | Direct local Lambda reindex/invoke if bdev lacks a wrapper. |
| `auth_roles` | `auth-service` | Direct local Lambda reindex/invoke if bdev lacks a wrapper. |
| `auth_groups` | `auth-service` | Direct local Lambda reindex/invoke if bdev lacks a wrapper. |
| `auth_api_keys` | `auth-service` | Direct local Lambda reindex/invoke if bdev lacks a wrapper. |
| `view-portfolio-deals-main-lambda` | `data-platform-streaming` + `lending-portfolio-product-api` | Use `scripts/portfolio_repair.zsh`; data arrives from hydrate-deal events through Flink/MSK/Lambda. |
| `portfolio-organizations` | `ar-ap-contact-book-product-api` | Reindex via service/Lambda path; June 2026 result was 48 local docs. |
| `draw-management` | `payment-management-product-api` | No confident local historical backfill found; create empty alias/index if local consumers need it. |
| `draw-history` | `payment-management-product-api` | No confident local historical backfill found; create empty alias/index if local consumers need it. |
| `definitions` | `node-workflow-service` | Local indexer was still failing `Failed to unwrap optional value`; empty alias/index may be enough until service config is fixed. |
| `monitored-items` | `action-monitoring-product-api` | Local indexer was still failing `Cannot find module 'handler'`; empty alias/index may be enough until artifact/handler is fixed. |

`profiles` exists but belongs to profile-service's own Elasticsearch, not the central search-service. Do not count it as a central search-service index.

`pipeline_definitions` appeared only in nonlocal Terraform. `tags` was not enabled locally at the time of discovery.

## Known June 2026 local outcomes

These were the successful local alias/doc states after repair:

- `purchase_orders -> purchase_orders-7fc5393a-c23d-4afa-9cc9-d1cbc5e43a26`, 727 docs.
- `vendor_listings -> vendor_listings-v1`, 0 docs.
- `auth_tenants`, 34 docs.
- `auth_users`, 94 docs.
- `auth_roles`, 62 docs.
- `auth_groups`, 82 docs.
- `auth_api_keys`, 4 docs.
- `portfolio-organizations -> portfolio-organizations-1782147271572`, 48 docs.
- `view-portfolio-deals-main-lambda`, usually 24 docs after local hydrate.
- Empty aliases/indices created for `draw-management`, `draw-history`, `definitions`, and `monitored-items`.

## Marketplace reindex commands

```zsh
bdev reindex orders start
bdev reindex orders status
bdev reindex vendor-listings
```

If search-service alias swaps fail because the updater/runtime was broken, repair the search-service Lambdas first, then replay DLQs or manually repair aliases only after confirming the target concrete indexes exist.

## Auth-service reindex guidance

If no bdev wrapper is available, inspect the local auth-service Lambda names and invoke the corresponding reindex function with `AWS_PROFILE=built_dev_eks/BuiltEksDev`. Preserve this as an operational step rather than hard-coding payloads until the local command is standardized.

## Portfolio reindex guidance

Do not create `view-portfolio-deals-main-lambda` before the `view-portfolio-deals` template exists. If it already exists with the wrong mapping, delete and recreate it after applying `data-platform-streaming` Terraform.

Use:

```zsh
/Users/chaz.henricks/.agent-skills/built-local-k8s-repair/scripts/portfolio_repair.zsh
```

## Empty-index fallback

Only create empty aliases/indices when a local app needs the index to exist and no historical backfill path is known. Document the gap in the final response so future work can replace the placeholder with a real reindex.

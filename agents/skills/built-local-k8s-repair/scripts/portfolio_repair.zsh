#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
NS="${K8S_NAMESPACE:-${NS:-chahen}}"
AWS_PROFILE_NAME="${AWS_PROFILE:-built_dev_eks/BuiltEksDev}"
AWS_REGION="${AWS_REGION:-us-east-2}"
INDEX="${PORTFOLIO_INDEX:-view-portfolio-deals-main-lambda}"
TEMPLATE="${PORTFOLIO_TEMPLATE:-view-portfolio-deals}"
BASE_URL="${SEARCH_BASE_URL:-https://${NS}.workstation.getbuilt.com/elasticsearch}"
MIN_DOCS="${PORTFOLIO_MIN_DOCS:-1}"
SKIP_TERRAFORM="false"
SKIP_HYDRATE="false"

usage() {
  cat <<USAGE
Usage: portfolio_repair.zsh [--skip-terraform] [--skip-hydrate]

Repairs the local portfolio search index for a Built workstation namespace.

Environment overrides:
  K8S_NAMESPACE / NS          Namespace, default: chahen
  AWS_PROFILE                 AWS profile, default: built_dev_eks/BuiltEksDev
  AWS_REGION                  AWS region, default: us-east-2
  PORTFOLIO_INDEX             Index, default: view-portfolio-deals-main-lambda
  PORTFOLIO_TEMPLATE          Template, default: view-portfolio-deals
  SEARCH_BASE_URL             OpenSearch proxy base URL
  PORTFOLIO_MIN_DOCS          Minimum docs after hydration, default: 1
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --help|-h)
      usage
      exit 0
      ;;
    --skip-terraform)
      SKIP_TERRAFORM="true"
      ;;
    --skip-hydrate)
      SKIP_HYDRATE="true"
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

log() {
  print -r -- "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

http_status() {
  local method="$1"
  local url="$2"
  local output_path="$3"
  local http_code
  local curl_code

  set +e
  http_code="$(curl -sS -o "$output_path" -w "%{http_code}" -X "$method" "$url")"
  curl_code=$?
  set -e

  if (( curl_code != 0 )); then
    print -r -- "000"
    return 0
  fi

  print -r -- "$http_code"
}

template_exists() {
  local scratch
  local http_code
  scratch="$(mktemp /private/tmp/portfolio-template.XXXXXX)"
  http_code="$(http_status GET "$BASE_URL/_index_template/$TEMPLATE" "$scratch")"
  rm -f "$scratch"
  [[ "$http_code" == "200" ]]
}

mapping_is_keyword() {
  local scratch
  local http_code
  scratch="$(mktemp /private/tmp/portfolio-mapping.XXXXXX)"
  http_code="$(http_status GET "$BASE_URL/$INDEX/_mapping/field/deal_uid" "$scratch")"

  if [[ "$http_code" != "200" ]]; then
    rm -f "$scratch"
    return 1
  fi

  if grep -Eq '"type"[[:space:]]*:[[:space:]]*"keyword"' "$scratch"; then
    rm -f "$scratch"
    return 0
  fi

  log "Current deal_uid mapping is not keyword:"
  cat "$scratch"
  echo
  rm -f "$scratch"
  return 1
}

wait_for_template() {
  local attempt

  for attempt in {1..60}; do
    if template_exists; then
      log "Template $TEMPLATE exists."
      return 0
    fi

    log "Waiting for template $TEMPLATE ($attempt/60)."
    sleep 10
  done

  return 1
}

ensure_template() {
  if template_exists; then
    log "Template $TEMPLATE already exists."
    return 0
  fi

  if [[ "$SKIP_TERRAFORM" == "true" ]]; then
    log "Template $TEMPLATE is missing and --skip-terraform was set."
    return 1
  fi

  log "Template $TEMPLATE is missing. Applying data-platform-streaming Terraform through bdev."
  bdev k8s terraform run data-platform-streaming
  wait_for_template
}

recreate_index_if_needed() {
  local scratch
  local http_code

  if mapping_is_keyword; then
    log "Index $INDEX already has deal_uid mapped as keyword."
    return 0
  fi

  log "Deleting and recreating $INDEX so the $TEMPLATE template applies."
  scratch="$(mktemp /private/tmp/portfolio-delete.XXXXXX)"
  http_code="$(http_status DELETE "$BASE_URL/$INDEX" "$scratch")"
  log "DELETE $INDEX returned HTTP $http_code."
  rm -f "$scratch"

  scratch="$(mktemp /private/tmp/portfolio-put.XXXXXX)"
  http_code="$(http_status PUT "$BASE_URL/$INDEX" "$scratch")"
  if [[ "$http_code" != "200" && "$http_code" != "201" ]]; then
    log "PUT $INDEX failed with HTTP $http_code:"
    cat "$scratch"
    echo
    rm -f "$scratch"
    return 1
  fi
  rm -f "$scratch"

  if ! mapping_is_keyword; then
    log "Index $INDEX still does not have deal_uid mapped as keyword after recreate."
    return 1
  fi

  log "Index $INDEX recreated with deal_uid as keyword."
}

fetch_system_key_env() {
  log "Fetching local system-key credentials from SSM using profile $AWS_PROFILE_NAME."
  export SYSTEM_KEY_ID
  export SYSTEM_KEY_SECRET
  SYSTEM_KEY_ID="$(AWS_PROFILE="$AWS_PROFILE_NAME" aws ssm get-parameter --name /k8s-dev/shared/auth-service/key_id --with-decryption --query Parameter.Value --output text --region "$AWS_REGION")"
  SYSTEM_KEY_SECRET="$(AWS_PROFILE="$AWS_PROFILE_NAME" aws ssm get-parameter --name /k8s-dev/shared/auth-service/secret --with-decryption --query Parameter.Value --output text --region "$AWS_REGION")"
}

hydrate_deals() {
  if [[ "$SKIP_HYDRATE" == "true" ]]; then
    log "Skipping hydration by request."
    return 0
  fi

  fetch_system_key_env
  log "Hydrating deal events into $INDEX."
  K8S_NAMESPACE="$NS" node "$SCRIPT_DIR/hydrate_deal_events.mjs"
}

get_doc_count() {
  local scratch
  local http_code
  local count
  scratch="$(mktemp /private/tmp/portfolio-count.XXXXXX)"
  http_code="$(http_status GET "$BASE_URL/$INDEX/_count" "$scratch")"
  if [[ "$http_code" != "200" ]]; then
    rm -f "$scratch"
    print -r -- "0"
    return 1
  fi

  count="$(node -e 'const fs = require("node:fs"); const body = JSON.parse(fs.readFileSync(process.argv[1], "utf8")); console.log(body.count ?? 0);' "$scratch")"
  rm -f "$scratch"
  print -r -- "$count"
}

wait_for_docs() {
  local attempt
  local count

  for attempt in {1..60}; do
    count="$(get_doc_count)"
    log "$INDEX doc count: $count"
    if (( count >= MIN_DOCS )); then
      return 0
    fi

    sleep 5
  done

  log "$INDEX did not reach $MIN_DOCS docs."
  return 1
}

verify_raw_opensearch() {
  local body_path
  local output_path
  local http_code

  body_path="$(mktemp /private/tmp/portfolio-search-body.XXXXXX.json)"
  output_path="$(mktemp /private/tmp/portfolio-search-output.XXXXXX.json)"
  cat > "$body_path" <<'JSON'
{
  "size": 1,
  "sort": [
    {
      "deal_created_at": {
        "order": "desc"
      }
    }
  ],
  "aggs": {
    "deal_uid_terms": {
      "terms": {
        "field": "deal_uid"
      }
    }
  }
}
JSON

  set +e
  http_code="$(curl -sS -o "$output_path" -w "%{http_code}" -H 'Content-Type: application/json' --data-binary "@$body_path" "$BASE_URL/$INDEX/_search")"
  set -e

  rm -f "$body_path"
  if [[ "$http_code" != "200" ]]; then
    log "Raw OpenSearch search failed with HTTP $http_code:"
    cat "$output_path"
    echo
    rm -f "$output_path"
    return 1
  fi

  log "Raw OpenSearch search succeeded."
  rm -f "$output_path"
}

verify_search_service() {
  if [[ -z "${SYSTEM_KEY_ID:-}" || -z "${SYSTEM_KEY_SECRET:-}" ]]; then
    fetch_system_key_env
  fi

  log "Verifying search-service proxy for $INDEX."
  K8S_NAMESPACE="$NS" PORTFOLIO_INDEX="$INDEX" node "$SCRIPT_DIR/verify_portfolio_search_service.mjs"
}

verify_graphql() {
  log "Verifying lending-portfolio-product-api portfolioDeals query."
  K8S_NAMESPACE="$NS" node "$SCRIPT_DIR/verify_portfolio_graphql.mjs"
}

main() {
  log "Repairing portfolio index in namespace $NS with AWS profile $AWS_PROFILE_NAME."
  ensure_template
  recreate_index_if_needed
  hydrate_deals
  wait_for_docs
  verify_raw_opensearch
  verify_search_service
  verify_graphql
  log "Portfolio repair complete."
}

main

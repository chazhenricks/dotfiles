#!/bin/zsh
set -uo pipefail

NS="${K8S_NAMESPACE:-${NS:-chahen}}"
STACK_DIR="${STACK_DIR:-/Users/chaz.henricks/BuiltSource/kubernetes-developer-environment/single-stack}"
AWS_PROFILE_NAME="${AWS_PROFILE:-built_dev_eks/BuiltEksDev}"
AWS_REGION="${AWS_REGION:-us-east-2}"
INDEX="${PORTFOLIO_INDEX:-view-portfolio-deals-main-lambda}"
TEMPLATE="${PORTFOLIO_TEMPLATE:-view-portfolio-deals}"
BASE_URL="${SEARCH_BASE_URL:-https://${NS}.workstation.getbuilt.com/elasticsearch}"
WARNINGS=0
export AWS_RETRY_MODE="${AWS_RETRY_MODE:-standard}"
export AWS_MAX_ATTEMPTS="${AWS_MAX_ATTEMPTS:-8}"

usage() {
  cat <<USAGE
Usage: local_k8s_check.zsh

Captures a health snapshot for the local Built k8s namespace.

Environment overrides:
  K8S_NAMESPACE / NS          Namespace, default: chahen
  STACK_DIR                   Stack repo path
  AWS_PROFILE                 AWS profile, default: built_dev_eks/BuiltEksDev
  AWS_REGION                  AWS region, default: us-east-2
  SEARCH_BASE_URL             OpenSearch proxy base URL
USAGE
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

log() {
  print -r -- "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

warn() {
  WARNINGS=$(( WARNINGS + 1 ))
  print -r -- "WARN: $*" >&2
}

section() {
  echo
  print -r -- "== $* =="
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

run_optional() {
  print -r -- "$ $*"
  "$@"
  local command_status=$?
  if (( command_status != 0 )); then
    warn "Command failed with exit $command_status: $*"
  fi
  return 0
}

check_prereqs() {
  section "Prerequisites"
  for name in kubectl helmfile bdev aws curl node; do
    if have_command "$name"; then
      print -r -- "✓ $name: $(command -v "$name")"
    else
      warn "Missing command: $name"
    fi
  done
}

check_k8s_health() {
  section "Kubernetes health"
  if [[ ! -d "$STACK_DIR" ]]; then
    warn "Stack directory does not exist: $STACK_DIR"
    return 0
  fi

  run_optional kubectl get namespace "$NS"
  run_optional kubectl -n "$NS" get pods

  pushd "$STACK_DIR" >/dev/null
  run_optional make health namespace="$NS"
  popd >/dev/null
}

check_portfolio_index() {
  section "Portfolio search index"
  local scratch
  local command_status

  scratch="$(mktemp /private/tmp/local-k8s-template.XXXXXX)"
  command_status="$(curl -sS -o "$scratch" -w "%{http_code}" "$BASE_URL/_index_template/$TEMPLATE")"
  print -r -- "Template $TEMPLATE HTTP $command_status"
  if [[ "$command_status" != "200" ]]; then
    warn "Portfolio template $TEMPLATE is missing or unavailable."
    cat "$scratch"
    echo
  fi
  rm -f "$scratch"

  scratch="$(mktemp /private/tmp/local-k8s-mapping.XXXXXX)"
  command_status="$(curl -sS -o "$scratch" -w "%{http_code}" "$BASE_URL/$INDEX/_mapping/field/deal_uid")"
  print -r -- "Mapping $INDEX deal_uid HTTP $command_status"
  if [[ "$command_status" == "200" ]]; then
    if grep -Eq '"type"[[:space:]]*:[[:space:]]*"keyword"' "$scratch"; then
      print -r -- "✓ deal_uid is keyword"
    else
      warn "deal_uid is not mapped as keyword. Run portfolio_repair.zsh."
      cat "$scratch"
      echo
    fi
  else
    warn "Could not read deal_uid mapping for $INDEX."
    cat "$scratch"
    echo
  fi
  rm -f "$scratch"

  scratch="$(mktemp /private/tmp/local-k8s-count.XXXXXX)"
  command_status="$(curl -sS -o "$scratch" -w "%{http_code}" "$BASE_URL/$INDEX/_count")"
  print -r -- "Count $INDEX HTTP $command_status"
  if [[ "$command_status" == "200" ]]; then
    node -e 'const fs = require("node:fs"); const body = JSON.parse(fs.readFileSync(process.argv[1], "utf8")); console.log(`doc count: ${body.count ?? 0}`);' "$scratch"
  else
    warn "Could not count docs for $INDEX."
    cat "$scratch"
    echo
  fi
  rm -f "$scratch"
}

check_search_service_lambdas() {
  section "Search-service Lambda runtime/status"
  local suffix
  for suffix in index updater reindex manifest-ingest; do
    AWS_PROFILE="$AWS_PROFILE_NAME" aws lambda get-function-configuration \
      --function-name "$NS-search-service-$suffix" \
      --region "$AWS_REGION" \
      --query '{FunctionName:FunctionName,Runtime:Runtime,State:State,LastUpdateStatus:LastUpdateStatus,LastModified:LastModified}' \
      --output table
    local command_status=$?
    if (( command_status != 0 )); then
      warn "Could not read $NS-search-service-$suffix"
    fi
    sleep 1
  done
}

check_dms() {
  section "DMS task"
  AWS_PROFILE="$AWS_PROFILE_NAME" aws dms describe-replication-tasks \
    --region "$AWS_REGION" \
    --filters Name=replication-task-id,Values="local-${NS}-just-cdc" \
    --query 'ReplicationTasks[].{Id:ReplicationTaskIdentifier,Status:Status,TablesErrored:ReplicationTaskStats.TablesErrored,FullLoad:ReplicationTaskStats.FullLoadProgressPercent,Updates:ReplicationTaskStats.TablesLoaded}' \
    --output table
  local command_status=$?
  if (( command_status != 0 )); then
    warn "Could not read DMS task local-${NS}-just-cdc. Do not rely on bdev k8s dms status; use AWS CLI."
  fi
}

check_event_source_mappings() {
  section "Lambda event source mappings for critical local consumers"
  local function_name
  local functions=(
    "$NS-dms-stream-event-broker-handler"
    "$NS-lending-portfolio-papi-msk-consumer"
    "$NS-portfolio-management-papi-msk-consumer"
    "$NS-pm-papi-msk_deal_consumer"
    "$NS-pm-papi-msk_draw_builder_v2"
    "$NS-pm-papi-msk_draw_index_consumer"
    "$NS-pm-papi-msk_wf_rec_upd_consumer"
    "$NS-pm-papi-msk_budget_builder_v2"
    "$NS-pm-papi-msk_commitment_builder"
  )

  for function_name in "${functions[@]}"; do
    print -r -- "-- $function_name"
    AWS_PROFILE="$AWS_PROFILE_NAME" aws lambda list-event-source-mappings \
      --region "$AWS_REGION" \
      --function-name "$function_name" \
      --query 'EventSourceMappings[].{FunctionArn:FunctionArn,State:State,LastProcessingResult:LastProcessingResult,Topics:Topics}' \
      --output table
    local command_status=$?
    if (( command_status != 0 )); then
      warn "Could not list Lambda event source mappings for $function_name."
    fi
  done
}

main() {
  log "Checking namespace $NS with AWS profile $AWS_PROFILE_NAME."
  check_prereqs
  check_k8s_health
  check_portfolio_index
  check_search_service_lambdas
  check_dms
  check_event_source_mappings

  echo
  if (( WARNINGS == 0 )); then
    log "Local k8s check completed with no warnings."
  else
    log "Local k8s check completed with $WARNINGS warning(s)."
  fi
}

main

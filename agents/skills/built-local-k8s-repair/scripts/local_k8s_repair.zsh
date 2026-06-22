#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
NS="${K8S_NAMESPACE:-${NS:-chahen}}"
STACK_DIR="${STACK_DIR:-/Users/chaz.henricks/BuiltSource/kubernetes-developer-environment/single-stack}"
AWS_PROFILE_NAME="${AWS_PROFILE:-built_dev_eks/BuiltEksDev}"
RUN_START_DAY="false"
RUN_PORTFOLIO="false"
RUN_CHECK="false"
SKIP_GIT="false"
SKIP_HELM="false"
KEEP_AWAKE="false"
CAFFEINATE_PID=""

usage() {
  cat <<USAGE
Usage: local_k8s_repair.zsh [--all] [--start-day] [--portfolio] [--check] [--skip-git] [--skip-helm] [--caffeinate]

Orchestrates the local Built k8s repair flow.

Modes:
  --all          Git update, k8s_yesterday/start-day, helm deps/apply, portfolio repair, final check
  --start-day    Git update, k8s_yesterday/start-day, helm deps/apply, health wait
  --portfolio    Repair view-portfolio-deals-main-lambda and verify portfolioDeals
  --check        Run local_k8s_check.zsh

Environment overrides:
  K8S_NAMESPACE / NS          Namespace, default: chahen
  STACK_DIR                   Stack repo path
  AWS_PROFILE                 AWS profile, default: built_dev_eks/BuiltEksDev
USAGE
}

if (( $# == 0 )); then
  usage
  exit 2
fi

for arg in "$@"; do
  case "$arg" in
    --help|-h)
      usage
      exit 0
      ;;
    --all)
      RUN_START_DAY="true"
      RUN_PORTFOLIO="true"
      RUN_CHECK="true"
      KEEP_AWAKE="true"
      ;;
    --start-day)
      RUN_START_DAY="true"
      ;;
    --portfolio)
      RUN_PORTFOLIO="true"
      ;;
    --check)
      RUN_CHECK="true"
      ;;
    --skip-git)
      SKIP_GIT="true"
      ;;
    --skip-helm)
      SKIP_HELM="true"
      ;;
    --caffeinate)
      KEEP_AWAKE="true"
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

cleanup() {
  if [[ -n "$CAFFEINATE_PID" ]]; then
    log "Stopping caffeinate PID $CAFFEINATE_PID."
    kill "$CAFFEINATE_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

start_caffeinate() {
  if [[ "$KEEP_AWAKE" != "true" ]]; then
    return 0
  fi

  if ! command -v caffeinate >/dev/null 2>&1; then
    log "caffeinate is not available; continuing without sleep prevention."
    return 0
  fi

  caffeinate -dimsu -w $$ &
  CAFFEINATE_PID="$!"
  log "Started caffeinate PID $CAFFEINATE_PID."
}

prepare_git_branch() {
  if [[ "$SKIP_GIT" == "true" ]]; then
    log "Skipping git update by request."
    return 0
  fi

  log "Updating $STACK_DIR main -> chaz."
  git -C "$STACK_DIR" switch main
  git -C "$STACK_DIR" pull --ff-only
  git -C "$STACK_DIR" switch chaz
  git -C "$STACK_DIR" merge main
}

run_k8s_yesterday() {
  log "Running k8s_yesterday from zshrc when available."
  pushd "$STACK_DIR" >/dev/null

  if [[ -f "$HOME/.zshrc" ]]; then
    set +u
    source "$HOME/.zshrc"
    set -u
  fi

  if whence -w k8s_yesterday >/dev/null 2>&1; then
    k8s_yesterday
  else
    log "k8s_yesterday function not found; falling back to bdev k8s start-day."
    bdev k8s start-day
  fi

  popd >/dev/null
}

wait_for_pods() {
  local attempt
  log "Waiting for pods in namespace $NS to become Ready."

  for attempt in {1..30}; do
    if kubectl -n "$NS" wait --for=condition=Ready pod --all --timeout=60s; then
      log "Pods are Ready."
      return 0
    fi

    log "Pods not ready yet ($attempt/30). Current pod state:"
    kubectl -n "$NS" get pods
  done

  log "Timed out waiting for pods. Continuing to health check for diagnostics."
  return 0
}

helm_refresh() {
  if [[ "$SKIP_HELM" == "true" ]]; then
    log "Skipping helmfile deps/apply by request."
    return 0
  fi

  log "Running helmfile deps and helmfile apply with DMS enabled."
  pushd "$STACK_DIR" >/dev/null
  helmfile deps
  helmfile apply --set dms.enabled=true
  popd >/dev/null
}

run_make_health() {
  log "Running make health namespace=$NS."
  pushd "$STACK_DIR" >/dev/null
  make health namespace="$NS"
  popd >/dev/null
}

run_start_day_flow() {
  prepare_git_branch
  run_k8s_yesterday
  wait_for_pods
  helm_refresh
  wait_for_pods
  run_make_health
}

main() {
  export AWS_PROFILE="$AWS_PROFILE_NAME"
  export K8S_NAMESPACE="$NS"

  log "Starting local k8s repair for namespace $NS."
  start_caffeinate

  if [[ "$RUN_START_DAY" == "true" ]]; then
    run_start_day_flow
  fi

  if [[ "$RUN_PORTFOLIO" == "true" ]]; then
    "$SCRIPT_DIR/portfolio_repair.zsh"
  fi

  if [[ "$RUN_CHECK" == "true" ]]; then
    "$SCRIPT_DIR/local_k8s_check.zsh"
  fi

  log "local_k8s_repair.zsh complete."
}

main

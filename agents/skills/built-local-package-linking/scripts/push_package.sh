#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: push_package.sh --package-path PATH [--build-command CMD] [--build-working-dir PATH] [--skip-build] [--dry-run]

Builds a local package, then publishes it to yalc and pushes the update to consumers
that already installed it from yalc.

Options:
  --package-path PATH   Path to the local package directory
  --build-command CMD   Override the build command run before yalc push
  --build-working-dir PATH  Directory to run the build command from
  --skip-build          Skip the pre-push build step
  --dry-run             Print commands without executing them
  -h, --help            Show this help text
EOF
}

package_path=""
build_command=""
build_working_dir=""
skip_build=false
dry_run=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package-path)
      package_path=${2:-}
      shift 2
      ;;
    --build-command)
      build_command=${2:-}
      shift 2
      ;;
    --build-working-dir)
      build_working_dir=${2:-}
      shift 2
      ;;
    --skip-build)
      skip_build=true
      shift
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$package_path" ]]; then
  usage >&2
  exit 1
fi

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

run() {
  if $dry_run; then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi

  "$@"
}

resolve_path() {
  node -e "const fs=require('fs'); console.log(fs.realpathSync(process.argv[1]));" "$1"
}

find_nearest_lockfile_dir() {
  node -e "const fs=require('fs'); const path=require('path'); let current=fs.realpathSync(process.argv[1]); while (true) { for (const file of ['pnpm-lock.yaml','package-lock.json','yarn.lock']) { if (fs.existsSync(path.join(current, file))) { console.log(current); process.exit(0); } } const parent=path.dirname(current); if (parent===current) process.exit(1); current=parent; }" "$1"
}

infer_package_manager() {
  local root=$1

  if [[ -f "$root/pnpm-lock.yaml" ]]; then
    echo "pnpm"
    return 0
  fi
  if [[ -f "$root/package-lock.json" ]]; then
    echo "npm"
    return 0
  fi
  if [[ -f "$root/yarn.lock" ]]; then
    echo "yarn"
    return 0
  fi

  return 1
}

has_build_script() {
  node -e "const pkg=require(process.argv[1]); process.exit(pkg.scripts && pkg.scripts.build ? 0 : 1);" "$1"
}

activate_nvm_for_dir() {
  local target_dir=$1

  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # Resolve Node from the target directory so nested package paths can still
    # pick up an .nvmrc from the repo root.
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
    if $dry_run; then
      echo "[dry-run] (cd $target_dir && nvm use)"
    else
      (cd "$target_dir" && nvm use >/dev/null 2>&1 || true)
    fi
  fi
}

run_build_if_needed() {
  local package_root=$1
  local requested_build_command=$2
  local requested_build_working_dir=$3
  local should_skip_build=$4

  if [[ "$should_skip_build" == "true" ]]; then
    echo "Skipping package build before yalc push."
    return 0
  fi

  local effective_build_working_dir="$package_root"
  local effective_build_command="$requested_build_command"

  if [[ -z "$effective_build_command" ]]; then
    if ! has_build_script "$package_root/package.json"; then
      echo "No build script found in $package_root/package.json. Pass --skip-build only if the package is already built." >&2
      exit 1
    fi

    local lockfile_root
    lockfile_root=$(find_nearest_lockfile_dir "$package_root") || {
      echo "Could not infer a package manager for $package_root. Pass --build-command or --skip-build." >&2
      exit 1
    }
    local package_manager
    package_manager=$(infer_package_manager "$lockfile_root") || {
      echo "Could not infer a package manager from $lockfile_root. Pass --build-command or --skip-build." >&2
      exit 1
    }

    effective_build_command="$package_manager build"
  fi

  if [[ -n "$requested_build_working_dir" ]]; then
    effective_build_working_dir=$(resolve_path "$requested_build_working_dir")
  fi

  activate_nvm_for_dir "$effective_build_working_dir"

  echo "Building package before yalc push"
  echo "  build dir: $effective_build_working_dir"
  echo "  command:   $effective_build_command"
  run bash -lc "cd \"$effective_build_working_dir\" && $effective_build_command"
}

require_cmd node
require_cmd yalc

package_path=$(resolve_path "$package_path")

if [[ ! -f "$package_path/package.json" ]]; then
  echo "Package path does not contain a package.json: $package_path" >&2
  exit 1
fi

run_build_if_needed "$package_path" "$build_command" "$build_working_dir" "$skip_build"

echo "Pushing yalc update from:"
echo "  $package_path"

run bash -lc "cd \"$package_path\" && yalc push"

if $dry_run; then
  echo "Dry run complete. Re-run without --dry-run to push the yalc update."
fi

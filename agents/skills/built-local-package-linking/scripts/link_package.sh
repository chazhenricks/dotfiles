#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: link_package.sh --package-path PATH --consumer-path PATH [--package-name NAME] [--build-command CMD] [--build-working-dir PATH] [--skip-build] [--dry-run]

Builds and publishes a local package to yalc, then adds it to an npm-based consumer app.

Options:
  --package-path PATH   Path to the local package directory
  --consumer-path PATH  Path to the consumer app directory
  --package-name NAME   Override package name from package.json
  --build-command CMD   Override the build command run before yalc publish
  --build-working-dir PATH  Directory to run the build command from
  --skip-build          Skip the pre-publish build step
  --dry-run             Print commands without executing them
  -h, --help            Show this help text
EOF
}

package_path=""
consumer_path=""
package_name=""
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
    --consumer-path)
      consumer_path=${2:-}
      shift 2
      ;;
    --package-name)
      package_name=${2:-}
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

if [[ -z "$package_path" || -z "$consumer_path" ]]; then
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

package_json_value() {
  local package_json=$1
  local expression=$2
  node -e "const pkg=require(process.argv[1]); const value=${expression}; if (value === undefined) process.exit(2); console.log(value);" "$package_json"
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

declared_range() {
  node -e "const pkg=require(process.argv[1]); const name=process.argv[2]; const value=(pkg.dependencies&&pkg.dependencies[name])||(pkg.devDependencies&&pkg.devDependencies[name])||(pkg.optionalDependencies&&pkg.optionalDependencies[name])||(pkg.peerDependencies&&pkg.peerDependencies[name]); if (!value) process.exit(2); console.log(value);" "$1" "$2"
}

save_state() {
  local consumer_root=$1
  local name=$2
  local range=$3

  node -e "const fs=require('fs'); const path=require('path'); const file=path.join(process.argv[1], '.yalc', '.built-local-package-linking-state.json'); fs.mkdirSync(path.dirname(file), {recursive:true}); const state=fs.existsSync(file)?JSON.parse(fs.readFileSync(file,'utf8')):{}; state[process.argv[2]]={declaredRange:process.argv[3]}; fs.writeFileSync(file, JSON.stringify(state, null, 2)+'\\n');" "$consumer_root" "$name" "$range"
}

current_dependency_value() {
  node -e "const pkg=require(process.argv[1]); const name=process.argv[2]; const value=(pkg.dependencies&&pkg.dependencies[name])||(pkg.devDependencies&&pkg.devDependencies[name])||(pkg.optionalDependencies&&pkg.optionalDependencies[name])||(pkg.peerDependencies&&pkg.peerDependencies[name]); if (!value) process.exit(2); console.log(value);" "$1" "$2"
}

run_build_if_needed() {
  local package_root=$1
  local requested_build_command=$2
  local requested_build_working_dir=$3
  local should_skip_build=$4

  if [[ "$should_skip_build" == "true" ]]; then
    echo "Skipping package build before yalc publish."
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

  echo "Building package before yalc publish"
  echo "  build dir: $effective_build_working_dir"
  echo "  command:   $effective_build_command"
  run bash -lc "cd \"$effective_build_working_dir\" && $effective_build_command"
}

require_cmd node
require_cmd npm
require_cmd yalc

package_path=$(resolve_path "$package_path")
consumer_path=$(resolve_path "$consumer_path")

if [[ ! -f "$package_path/package.json" ]]; then
  echo "Package path does not contain a package.json: $package_path" >&2
  exit 1
fi

if [[ ! -f "$consumer_path/package.json" ]]; then
  echo "Consumer path does not contain a package.json: $consumer_path" >&2
  exit 1
fi

if [[ -z "$package_name" ]]; then
  package_name=$(package_json_value "$package_path/package.json" "pkg.name")
fi

declared_version_range=$(declared_range "$consumer_path/package.json" "$package_name") || {
  echo "Could not find $package_name in the consumer package.json dependency sections." >&2
  exit 1
}

activate_nvm_for_dir "$consumer_path"
run_build_if_needed "$package_path" "$build_command" "$build_working_dir" "$skip_build"

echo "Adding $package_name with yalc"
echo "  package:        $package_path"
echo "  consumer:       $consumer_path"
echo "  declared range: $declared_version_range"

if $dry_run; then
  echo "[dry-run] save original dependency range for $package_name"
else
  save_state "$consumer_path" "$package_name" "$declared_version_range"
fi

run bash -lc "cd \"$package_path\" && yalc publish"
run bash -lc "cd \"$consumer_path\" && yalc add \"$package_name\""

if $dry_run; then
  echo "Dry run complete. Re-run without --dry-run to add the yalc override."
  exit 0
fi

installed_path="$consumer_path/node_modules/$package_name"
if [[ ! -e "$installed_path" ]]; then
  echo "yalc install is missing from node_modules: $installed_path" >&2
  exit 1
fi

dependency_value=$(current_dependency_value "$consumer_path/package.json" "$package_name")
if [[ "$dependency_value" != "file:.yalc/$package_name" ]]; then
  echo "Consumer package.json was not rewritten to the expected yalc dependency." >&2
  echo "  actual: $dependency_value" >&2
  exit 1
fi

if [[ ! -f "$consumer_path/yalc.lock" ]] || ! grep -q "\"$package_name\"" "$consumer_path/yalc.lock"; then
  echo "yalc.lock does not contain $package_name after add." >&2
  exit 1
fi

echo "yalc override verified:"
echo "  dependency: $dependency_value"
echo "  installed:  $installed_path"

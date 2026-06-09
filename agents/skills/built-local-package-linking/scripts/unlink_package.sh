#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: unlink_package.sh --consumer-path PATH --package-name NAME [--dry-run]

Removes a yalc-installed package from an npm-based consumer app and restores
the original registry dependency.

Options:
  --consumer-path PATH  Path to the consumer app directory
  --package-name NAME   Package name to restore
  --dry-run             Print commands without executing them
  -h, --help            Show this help text
EOF
}

consumer_path=""
package_name=""
dry_run=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --consumer-path)
      consumer_path=${2:-}
      shift 2
      ;;
    --package-name)
      package_name=${2:-}
      shift 2
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

if [[ -z "$consumer_path" || -z "$package_name" ]]; then
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

activate_nvm_for_dir() {
  local target_dir=$1

  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [[ -s "$NVM_DIR/nvm.sh" && -f "$target_dir/.nvmrc" ]]; then
    # Use the consumer's pinned Node version so package manager writes match the app.
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
    if $dry_run; then
      echo "[dry-run] (cd $target_dir && nvm use)"
    else
      (cd "$target_dir" && nvm use >/dev/null)
    fi
  fi
}

saved_range() {
  node -e "const fs=require('fs'); const path=require('path'); const file=path.join(process.argv[1], '.yalc', '.built-local-package-linking-state.json'); if (!fs.existsSync(file)) process.exit(2); const state=JSON.parse(fs.readFileSync(file,'utf8')); const entry=state[process.argv[2]]; if (!entry || !entry.declaredRange) process.exit(3); console.log(entry.declaredRange);" "$1" "$2"
}

declared_range() {
  node -e "const pkg=require(process.argv[1]); const name=process.argv[2]; const value=(pkg.dependencies&&pkg.dependencies[name])||(pkg.devDependencies&&pkg.devDependencies[name])||(pkg.optionalDependencies&&pkg.optionalDependencies[name])||(pkg.peerDependencies&&pkg.peerDependencies[name]); if (!value) process.exit(2); console.log(value);" "$1" "$2"
}

restore_dependency_range() {
  node -e "const fs=require('fs'); const pkgPath=process.argv[1]; const name=process.argv[2]; const range=process.argv[3]; const pkg=require(pkgPath); let updated=false; for (const key of ['dependencies','devDependencies','optionalDependencies','peerDependencies']) { if (pkg[key] && Object.prototype.hasOwnProperty.call(pkg[key], name)) { pkg[key][name]=range; updated=true; break; } } if (!updated) { pkg.dependencies = pkg.dependencies || {}; pkg.dependencies[name]=range; } fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2)+'\\n');" "$1" "$2" "$3"
}

delete_saved_range() {
  node -e "const fs=require('fs'); const path=require('path'); const file=path.join(process.argv[1], '.yalc', '.built-local-package-linking-state.json'); if (!fs.existsSync(file)) process.exit(0); const state=JSON.parse(fs.readFileSync(file,'utf8')); delete state[process.argv[2]]; if (Object.keys(state).length===0) fs.rmSync(file, {force:true}); else fs.writeFileSync(file, JSON.stringify(state, null, 2)+'\\n');" "$1" "$2"
}

require_cmd node
require_cmd npm
require_cmd yalc

consumer_path=$(resolve_path "$consumer_path")

if [[ ! -f "$consumer_path/package.json" ]]; then
  echo "Consumer path does not contain a package.json: $consumer_path" >&2
  exit 1
fi

if declared_version_range=$(saved_range "$consumer_path" "$package_name" 2>/dev/null); then
  :
elif $dry_run && declared_version_range=$(declared_range "$consumer_path/package.json" "$package_name" 2>/dev/null); then
  echo "[dry-run] no saved yalc state found for $package_name; using current declared range for preview" >&2
else
  echo "Could not find saved original dependency range for $package_name under .yalc state." >&2
  exit 1
fi

activate_nvm_for_dir "$consumer_path"

echo "Removing yalc override for $package_name"
echo "  consumer:        $consumer_path"
echo "  restore range:   $declared_version_range"

run bash -lc "cd \"$consumer_path\" && yalc remove \"$package_name\""

if $dry_run; then
  echo "[dry-run] restore package.json dependency range for $package_name"
else
  restore_dependency_range "$consumer_path/package.json" "$package_name" "$declared_version_range"
fi

run bash -lc "cd \"$consumer_path\" && npm install --package-lock-only"
run bash -lc "cd \"$consumer_path\" && npm install"

if $dry_run; then
  echo "[dry-run] delete saved yalc state for $package_name"
  echo "Dry run complete. Re-run without --dry-run to remove the yalc override."
  exit 0
fi

delete_saved_range "$consumer_path" "$package_name"

installed_path="$consumer_path/node_modules/$package_name"
if [[ ! -e "$installed_path" ]]; then
  echo "Restored package is missing from node_modules: $installed_path" >&2
  exit 1
fi

resolved_path=$(resolve_path "$installed_path")
case "$resolved_path" in
  "$consumer_path/.yalc/"*)
    echo "Package still resolves inside .yalc after remove." >&2
    echo "  actual: $resolved_path" >&2
    exit 1
    ;;
esac

echo "Registry install restored:"
echo "  $installed_path"

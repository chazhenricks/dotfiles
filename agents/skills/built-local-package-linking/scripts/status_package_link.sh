#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: status_package_link.sh --consumer-path PATH --package-name NAME

Reports whether a consumer app currently uses a yalc override, a regular
installed package, or a symlinked package.

Options:
  --consumer-path PATH  Path to the consumer app directory
  --package-name NAME   Package name to inspect
  -h, --help            Show this help text
EOF
}

consumer_path=""
package_name=""

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

resolve_path() {
  node -e "const fs=require('fs'); console.log(fs.realpathSync(process.argv[1]));" "$1"
}

declared_range() {
  node -e "const pkg=require(process.argv[1]); const name=process.argv[2]; const value=(pkg.dependencies&&pkg.dependencies[name])||(pkg.devDependencies&&pkg.devDependencies[name])||(pkg.optionalDependencies&&pkg.optionalDependencies[name])||(pkg.peerDependencies&&pkg.peerDependencies[name]); if (!value) process.exit(2); console.log(value);" "$1" "$2"
}

installed_version() {
  node -e "const pkg=require(process.argv[1]); console.log(pkg.version);" "$1"
}

consumer_path=$(resolve_path "$consumer_path")
package_install_path="$consumer_path/node_modules/$package_name"

if [[ ! -f "$consumer_path/package.json" ]]; then
  echo "Consumer path does not contain a package.json: $consumer_path" >&2
  exit 1
fi

echo "Consumer: $consumer_path"
echo "Package:  $package_name"

if declared_version_range=$(declared_range "$consumer_path/package.json" "$package_name" 2>/dev/null); then
  echo "Declared range: $declared_version_range"
else
  echo "Declared range: <not found in package.json>"
fi

if [[ -f "$consumer_path/yalc.lock" ]] && grep -q "\"$package_name\"" "$consumer_path/yalc.lock"; then
  echo "yalc.lock:      present"
else
  echo "yalc.lock:      absent"
fi

if [[ ! -e "$package_install_path" ]]; then
  echo "Installed path: <missing>"
  exit 0
fi

resolved_path=$(resolve_path "$package_install_path")
echo "Installed path: $package_install_path"
echo "Resolved path:  $resolved_path"

dependency_value=""
if dependency_value=$(declared_range "$consumer_path/package.json" "$package_name" 2>/dev/null); then
  :
fi

if [[ -L "$package_install_path" ]]; then
  echo "Install type:   symlink"
elif [[ "$dependency_value" == "file:.yalc/$package_name" ]]; then
  echo "Install type:   yalc"
else
  echo "Install type:   regular"
fi

if [[ -f "$package_install_path/package.json" ]]; then
  echo "Installed version: $(installed_version "$package_install_path/package.json")"
fi

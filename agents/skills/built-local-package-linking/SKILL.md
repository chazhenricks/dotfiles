---
name: built-local-package-linking
description: |
  Use when a task requires linking or unlinking a local Built package into a
  Built consumer app for faster iteration, especially shared package to MFE
  workflows such as overriding `built-fe-shared/packages/marketplace-ui` in
  `purchase-orders-miniapp` with `yalc`. Triggers include "link a local
  package", "unlink this override", "set up a yalc workflow", "test
  built-fe-shared in a miniapp", and "link marketplace-ui into
  purchase-orders-miniapp".
---

# Built Local Package Linking

Use this skill when a local package change needs to be tested inside a Built
consumer app without cutting a real package release.

The default strategy is `yalc`, because it copies the built package into the
consumer instead of exposing the package repo's local workspace dependency
graph. That makes it the safer default for Built shared-package to MFE
workflows, including `built-fe-shared/packages/marketplace-ui` into
`purchase-orders-miniapp`.

## When To Use Which Strategy

Prefer this order:

1. `yalc` for Built shared-package to MFE development
2. tarball install when `yalc` is unavailable and you still need publish-like
   package behavior
3. `npm link` only if you have already proven the linked package does not split
   singleton dependencies in the consumer

The bundled scripts are intentionally optimized for npm consumers such as
`purchase-orders-miniapp`.

## Workflow

### 1. Check current state

Run:

```bash
scripts/status_package_link.sh \
  --consumer-path /path/to/consumer \
  --package-name @built/package-name
```

Use this first when you need to know whether the consumer already points at a
`yalc` override, a regular install, or something unexpected.

### 2. Add the package with `yalc`

Run:

```bash
scripts/link_package.sh \
  --package-path /path/to/package \
  --consumer-path /path/to/consumer
```

The script:

- reads the package name from the package `package.json`
- builds the package before publishing by default
- runs `nvm use` in the consumer when `.nvmrc` exists
- records the original dependency range from the consumer `package.json`
- runs `yalc publish` in the package directory
- runs `yalc add` in the consumer
- verifies that the consumer now resolves the package from `.yalc`

Expect `yalc add` to modify tracked consumer files:

- `package.json`
- `yalc.lock`
- usually the package-manager lockfile after install

Use `--dry-run` first if you want to inspect the commands before mutating
anything.

Do not run package builds and `yalc` publish steps in parallel. The helper is
designed to serialize them so the consumer never receives a stale bundle.

### 3. Push updates after rebuilds

Run:

```bash
scripts/push_package.sh \
  --package-path /path/to/package
```

This publishes the rebuilt package and pushes the update to all consumer apps
that installed it from `yalc`.

By default, this helper runs the package build itself before it publishes to
`yalc`. Use `--skip-build` only if you have deliberately built the package
already and want to publish that exact output.

After adding the package, run the consumer dev server in one terminal. For
updates, prefer `scripts/push_package.sh` over manually building and then
publishing in parallel terminals.

For the `built-fe-shared/packages/marketplace-ui` example, read
`references/built-example.md` for the exact commands. That package is consumed
from `dist/`, so rebuilding `dist` is what updates the consumer.

### 4. Remove the override and restore the registry install

Run:

```bash
scripts/unlink_package.sh \
  --consumer-path /path/to/consumer \
  --package-name @built/package-name
```

The script:

- reads the saved original dependency range for the package
- runs `yalc remove` in the consumer
- restores the original dependency range in `package.json`
- refreshes the lockfile and reinstalls the registry dependency
- verifies the package is no longer resolved from `.yalc`

Expect the remove flow to clean up the `yalc`-specific consumer file changes and
return the dependency declaration to its original range.

Use `--dry-run` if you need to preview the restore sequence first.

## Failure Modes

### The consumer is not npm-based

The helper scripts currently optimize for npm consumers. If the consumer uses
`pnpm` or `yarn`, stop and switch to a manual workflow instead of guessing.

### The package rebuilds but the consumer does not refresh

- Confirm the package actually writes to `dist/`
- Re-run `scripts/push_package.sh` after the build finishes
- Prefer letting `scripts/push_package.sh` run the build itself so publish and
  install cannot race
- Confirm the consumer imports from the built output rather than source files
- Restart the consumer dev server if the package manager cache is stale

### The page crashes with missing context or hook-provider errors

This is usually why the skill prefers `yalc` over `npm link`.

- Confirm the consumer is no longer resolving the package from the source repo
- Confirm the installed package path is under `.yalc` or a regular
  `node_modules` install
- Treat `useAppContext must be used within AppContext` as a duplicate
  singleton-dependency signal in this Built workflow

### The consumer still resolves the old package

- Re-run `scripts/status_package_link.sh`
- Confirm `yalc.lock` contains the package
- Confirm the installed package path resolves inside the consumer `.yalc` folder
- Re-run `scripts/push_package.sh`

## Built Example

The primary example for this skill is:

- package repo: `built-fe-shared`
- package dir: `packages/marketplace-ui`
- consumer repo: `purchase-orders-miniapp`
- package name: `@built/marketplace-ui`

Read `references/built-example.md` before using that flow so the exact watch
commands and validation checks stay consistent.

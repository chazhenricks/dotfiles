# Built Example: `marketplace-ui` Into `purchase-orders-miniapp`

Use this reference when testing local changes in:

- package repo: `/Users/chaz.henricks/BuiltSource/built-fe-shared`
- package dir: `/Users/chaz.henricks/BuiltSource/built-fe-shared/packages/marketplace-ui`
- consumer repo: `/Users/chaz.henricks/BuiltSource/purchase-orders-miniapp`
- package name: `@built/marketplace-ui`

## Recommended Override

Use `yalc` for this exact package pair.

`@built/marketplace-ui` resolves `@built/react-utils` from the local
`built-fe-shared` workspace when symlinked, while `purchase-orders-miniapp`
provides its own installed `@built/react-utils`. That creates two React context
singletons and breaks hooks such as `useAppContext`. `yalc` avoids that by
copying the built package into the consumer instead of linking the source repo.

## Add The Package With `yalc`

```bash
/Users/chaz.henricks/.agent-skills/built-local-package-linking/scripts/link_package.sh \
  --package-path /Users/chaz.henricks/BuiltSource/built-fe-shared/packages/marketplace-ui \
  --build-working-dir /Users/chaz.henricks/BuiltSource/built-fe-shared \
  --build-command "pnpm --filter @built/react-utils build && pnpm --filter @built/marketplace-ui build" \
  --consumer-path /Users/chaz.henricks/BuiltSource/purchase-orders-miniapp
```

## Push Updates After Rebuilds

```bash
/Users/chaz.henricks/.agent-skills/built-local-package-linking/scripts/push_package.sh \
  --package-path /Users/chaz.henricks/BuiltSource/built-fe-shared/packages/marketplace-ui \
  --build-working-dir /Users/chaz.henricks/BuiltSource/built-fe-shared \
  --build-command "pnpm --filter @built/react-utils build && pnpm --filter @built/marketplace-ui build"
```

## Check Override Status

```bash
/Users/chaz.henricks/.agent-skills/built-local-package-linking/scripts/status_package_link.sh \
  --consumer-path /Users/chaz.henricks/BuiltSource/purchase-orders-miniapp \
  --package-name @built/marketplace-ui
```

## Run The Live Loop

Terminal 1:

```bash
export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh"
cd /Users/chaz.henricks/BuiltSource/purchase-orders-miniapp
nvm use
npm start
```

When you are ready to refresh the consumer package, run the push helper again.
It will build first and only publish after the build succeeds.

## Remove The Override And Restore The Registry Install

```bash
/Users/chaz.henricks/.agent-skills/built-local-package-linking/scripts/unlink_package.sh \
  --consumer-path /Users/chaz.henricks/BuiltSource/purchase-orders-miniapp \
  --package-name @built/marketplace-ui
```

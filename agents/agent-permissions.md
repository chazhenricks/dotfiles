# Agent Permissions

Shared permissions policy for local coding agents.

Intent:

- Read-only actions should run without repeated approval prompts.
- Write-capable actions should ask before changing files, repository state, local configuration, cloud resources, or remote systems.
- Sensitive files should be denied even when broad read access is otherwise allowed.

The `agent-permissions` script reads only the fenced `json` block below and maps it into each agent's native configuration format.

```json
{
  "version": 1,
  "agents": ["codex", "claude"],
  "codex": {
    "profileName": "read_global",
    "profileDescription": "Allow reads by default; require approval for writes."
  },
  "sensitiveReadDeny": {
    "absolutePaths": [
      "~/.ssh",
      "~/.aws",
      "~/.config/gh",
      "~/Library/Application Support/ClaudeCode",
      "~/.claude/.credentials.json",
      "~/.codex/auth.json"
    ],
    "workspaceGlobs": [
      "**/.env",
      "**/.env.*",
      "**/secrets/**",
      "**/*secret*/**",
      "**/credentials*.json"
    ],
    "claudeReadRules": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./config/credentials.json)",
      "Read(//Users/chaz.henricks/.ssh/**)",
      "Read(//Users/chaz.henricks/.aws/**)",
      "Read(//Users/chaz.henricks/.config/gh/**)",
      "Read(//Users/chaz.henricks/.claude/.credentials.json)",
      "Read(//Users/chaz.henricks/.codex/auth.json)"
    ]
  },
  "readTools": {
    "claude": [
      "Read",
      "Glob",
      "Grep",
      "WebSearch",
      "WebFetch",
      "mcp__code-searcher__search_code",
      "mcp__code-searcher__search_docs",
      "mcp__code-searcher__get_changelog",
      "mcp__code-searcher__get_agents_file",
      "mcp__code-searcher__get_document",
      "mcp__context7__resolve-library-id",
      "mcp__context7__query-docs"
    ]
  },
  "writeTools": {
    "claudeAsk": ["Edit", "Write", "MultiEdit", "NotebookEdit"]
  },
  "readCommandPrefixes": [
    ["pwd"],
    ["ls"],
    ["cat"],
    ["find"],
    ["sed"],
    ["head"],
    ["tail"],
    ["wc"],
    ["file"],
    ["which"],
    ["type"],
    ["env"],
    ["printenv"],
    ["git", "status"],
    ["git", "log"],
    ["git", "diff"],
    ["git", "show"],
    ["git", "branch"],
    ["git", "remote"],
    ["git", "rev-parse"],
    ["git", "blame"],
    ["node", "--version"],
    ["npm", "list"],
    ["npx", "tsc", "--noEmit"],
    ["gh", "pr", "view"],
    ["gh", "pr", "list"],
    ["gh", "pr", "diff"],
    ["gh", "pr", "checks"],
    ["gh", "issue", "view"],
    ["gh", "issue", "list"],
    ["gh", "run", "view"],
    ["gh", "run", "list"],
    ["aws", "sts", "get-caller-identity"],
    ["aws", "ecs", "list-clusters"],
    ["aws", "ecs", "list-services"],
    ["aws", "ecs", "list-task-definitions"],
    ["aws", "ecs", "describe-task-definition"],
    ["aws", "ssm", "describe-parameters"],
    ["docker", "ps"],
    ["pup", "logs"],
    ["pup", "traces"],
    ["pup", "monitors", "get"],
    ["pup", "metrics", "query"]
  ],
  "writeCommandPrefixes": [
    ["cp"],
    ["mv"],
    ["rm"],
    ["rmdir"],
    ["mkdir"],
    ["touch"],
    ["chmod"],
    ["chown"],
    ["ln"],
    ["tee"],
    ["perl"],
    ["python"],
    ["python3"],
    ["node"],
    ["npm", "init"],
    ["npm", "install"],
    ["npm", "run"],
    ["npx", "vitest"],
    ["uv", "run", "pytest"],
    ["uv", "run", "ruff", "check"],
    ["uv", "run", "alembic"],
    ["git", "add"],
    ["git", "commit"],
    ["git", "checkout"],
    ["git", "switch"],
    ["git", "restore"],
    ["git", "reset"],
    ["git", "clean"],
    ["git", "merge"],
    ["git", "rebase"],
    ["git", "push"],
    ["gh", "pr", "create"],
    ["gh", "pr", "merge"],
    ["gh", "pr", "edit"],
    ["gh", "issue", "create"],
    ["gh", "issue", "edit"],
    ["gh", "api"],
    ["aws", "ssm", "get-parameters-by-path"],
    ["aws", "logs", "filter-log-events"],
    ["docker", "run"],
    ["docker", "compose"]
  ]
}
```

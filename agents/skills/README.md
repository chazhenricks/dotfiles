# Shared Agent Skills

This directory contains shared skills that multiple agent platforms can read and use.

## How agents should discover skills

Agents should recursively scan this directory for files named `SKILL.md`:

```text
~/.agent-skills/**/SKILL.md
```

Each `SKILL.md` should be treated as an available skill when its frontmatter `name` or `description` matches the user's request.

## Skill layout

Recommended layout:

```text
~/.agent-skills/
  README.md
  common/
    some-skill/
      SKILL.md
      scripts/
      assets/
      references/
```

Use `common/` for skills that should be shared across all agent platforms.

## Agent usage rules

When using a shared skill:

1. Read only the matching skill's `SKILL.md` first.
2. Follow the workflow documented in that skill.
3. Resolve relative paths from the directory containing that skill's `SKILL.md`.
4. Load extra files such as `scripts/`, `assets/`, or `references/` only when needed.
5. Prefer skill-provided scripts and templates over recreating large snippets by hand.

## Available shared skills

| Skill | Path | Purpose |
| --- | --- | --- |
| `confluence-mermaid-diagrams` | `common/confluence-mermaid-diagrams/SKILL.md` | Render Mermaid diagrams in Confluence pages using Atlassian ADF and the Mermaid Diagram Forge extension. |
| `flashcard` | `common/flashcard/SKILL.md` | Create atomic spaced-repetition flashcards following SuperMemo's 20 Rules. Trigger: `/flashcard` or "make a flashcard for X". |


---
name: confluence-mermaid-diagrams
description: Renders Mermaid diagrams in Confluence pages using the Atlassian MCP integration. Use when creating or updating Confluence pages that need flowcharts, sequence diagrams, or any Mermaid diagram. Triggers on "mermaid", "diagram in Confluence", "flowchart in Confluence", "sequence diagram in Confluence", or when a Confluence page needs visual diagrams.
---

# Confluence Mermaid Diagrams

## Why This Skill Exists

Confluence's API does **not** render mermaid fenced code blocks (` ```mermaid `) as diagrams. The markdown-to-storage conversion turns them into plain code macro blocks. To get rendered diagrams, you must use ADF format with the Mermaid Diagram Forge extension macro.

## How It Works

Each rendered diagram requires **two ADF nodes** in sequence:

1. An `extension` node — the Mermaid Diagram Forge app macro
2. A `codeBlock` node — the mermaid syntax the macro reads from

The Forge app uses "Auto detect" to find the nearest code block. The `guestParams.index` value links each macro to its code block (0-indexed, sequential per page).

## Usage

When creating/updating a Confluence page with diagrams, use `contentFormat: "adf"` and construct the body as a JSON ADF document.

For existing pages, do not rebuild the whole page by hand. Confluence still requires a full-body save for content updates, but the safer workflow is:

1. Fetch the current page with `contentFormat: "adf"`.
2. Patch only the intended ADF nodes in memory.
3. Preserve every Mermaid `extension` node and its immediately following `codeBlock`.
4. Re-submit the full ADF body with `updateConfluencePage`.
5. Fetch the page again and verify the diagram pairs are still valid.

Use `scripts/adf-mermaid-helper.mjs` for common patch operations:

```bash
node scripts/adf-mermaid-helper.mjs patch-mermaid \
  --input page-body.json \
  --index 0 \
  --mermaid diagram.mmd > patched-body.json

node scripts/adf-mermaid-helper.mjs mark-code \
  --input page-body.json \
  --terms vendor_owed,built_fee,InvoicingInput > patched-body.json
```

The helper outputs the patched ADF document JSON to stdout. Pass that JSON text as the `body` string in `mcp__Atlassian__.updateConfluencePage` with `contentFormat: "adf"`.

### Helper Functions

The helper also exports functions for one-off scripts:

| Function                                                                | Use                                                                                 |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `makeMermaidExtension({ pageId, spaceId, spaceKey, accountId, index })` | Create a new Mermaid Forge extension node.                                          |
| `findMermaidPairs(doc)`                                                 | Locate each Mermaid extension and its adjacent code block.                          |
| `replaceMermaidCodeBlock(doc, index, mermaidText)`                      | Replace only the Mermaid source for one rendered diagram.                           |
| `renumberMermaidExtensions(doc)`                                        | Reset `guestParams.index` values to match page order.                               |
| `markInlineCodeTerms(doc, terms)`                                       | Apply real Confluence inline-code marks to matching text terms outside code blocks. |

### Patch Existing ADF Example

```bash
# 1. Fetch page as ADF with mcp__Atlassian__.getConfluencePage.
# 2. Save only the response body's ADF doc to /tmp/page-body.json.

cat > /tmp/diagram.mmd <<'EOF'
flowchart LR
  A[Start] --> B[Done]
EOF

node /Users/chaz.henricks/.agent-skills/common/confluence-mermaid-diagrams/scripts/adf-mermaid-helper.mjs \
  patch-mermaid \
  --input /tmp/page-body.json \
  --index 0 \
  --mermaid /tmp/diagram.mmd > /tmp/patched-body.json

# 3. Use the contents of /tmp/patched-body.json as updateConfluencePage.body.
# 4. Fetch ADF again and confirm extension/codeBlock pairs are still adjacent.
```

Only use the full document skeleton below when creating a new page or replacing a page intentionally.

### ADF Document Skeleton

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    // ... headings, paragraphs, etc.
    {
      /* extension node for diagram 0 */
    },
    {
      /* codeBlock node with mermaid syntax */
    },
    // ... more content ...
    {
      /* extension node for diagram 1 */
    },
    {
      /* codeBlock node with mermaid syntax */
    }
  ]
}
```

### Extension Node Template

For each diagram, use this extension node. Increment `guestParams.index` for each subsequent diagram on the page (0, 1, 2, ...).

Replace these placeholders in the template:

| Placeholder  | Source                                                             |
| ------------ | ------------------------------------------------------------------ |
| `PAGE_ID`    | The Confluence page ID (from create/get page response)             |
| `SPACE_ID`   | The space ID (from `getConfluenceSpaces` or page response)         |
| `SPACE_KEY`  | The space key (from `getConfluenceSpaces` or page response)        |
| `ACCOUNT_ID` | The current user's Atlassian account ID (from `atlassianUserInfo`) |
| `INDEX`      | Sequential diagram index on the page (0, 1, 2, ...)                |

See [extension-template.json](extension-template.json) for the full node — copy it verbatim, only changing the placeholders above.

### Code Block Node

Immediately after each extension node, add a code block with the mermaid syntax:

```json
{
  "type": "codeBlock",
  "attrs": {},
  "content": [
    {
      "text": "graph TD;\n    A[Start] --> B{Decision};\n    B -->|Yes| C[End];",
      "type": "text"
    }
  ]
}
```

## Forge App Constants (Built Technologies Confluence)

These are specific to the Built Technologies Confluence instance (`getbuilt.atlassian.net`):

| Parameter          | Value                                                                                                                             |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| cloudId            | `53d14180-dd0d-4a76-9ea7-b12222e9cf92`                                                                                            |
| appId              | `23392b90-4271-4239-98ca-a3e96c663cbb`                                                                                            |
| environmentId      | `63d4d207-ac2f-4273-865c-0240d37f044a`                                                                                            |
| installationId     | `2a0dbb45-2029-4f7f-9be9-f31860c41d55`                                                                                            |
| extensionKey       | `23392b90-4271-4239-98ca-a3e96c663cbb/63d4d207-ac2f-4273-865c-0240d37f044a/static/mermaid-diagram`                                |
| extensionId (ARI)  | `ari:cloud:ecosystem::extension/23392b90-4271-4239-98ca-a3e96c663cbb/63d4d207-ac2f-4273-865c-0240d37f044a/static/mermaid-diagram` |
| workspaceContextId | `ari:cloud:confluence:53d14180-dd0d-4a76-9ea7-b12222e9cf92:workspace/9af25fdc-3a8f-4935-8ebe-458f6d4af011`                        |

## Checklist

- [ ] Use `contentFormat: "adf"` (not `"markdown"`)
- [ ] Include one extension node per diagram
- [ ] Place the codeBlock immediately after its extension node
- [ ] Increment `guestParams.index` for each diagram (0, 1, 2, ...)
- [ ] Replace `PAGE_ID`, `SPACE_ID`, `SPACE_KEY`, and `ACCOUNT_ID` in the extension template
- [ ] Mermaid syntax goes in the codeBlock `text` field with `\n` for newlines
- [ ] For existing pages, fetch-and-patch current ADF instead of reconstructing the page manually

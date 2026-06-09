#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const MERMAID_EXTENSION_KEY =
  '23392b90-4271-4239-98ca-a3e96c663cbb/63d4d207-ac2f-4273-865c-0240d37f044a/static/mermaid-diagram';
const MERMAID_EXTENSION_ID =
  'ari:cloud:ecosystem::extension/23392b90-4271-4239-98ca-a3e96c663cbb/63d4d207-ac2f-4273-865c-0240d37f044a/static/mermaid-diagram';
const CLOUD_ID = '53d14180-dd0d-4a76-9ea7-b12222e9cf92';
const WORKSPACE_CONTEXT_ID =
  'ari:cloud:confluence:53d14180-dd0d-4a76-9ea7-b12222e9cf92:workspace/9af25fdc-3a8f-4935-8ebe-458f6d4af011';

export function makeMermaidExtension({ pageId, spaceId, spaceKey, accountId, index }) {
  assertRequired({ pageId, spaceId, spaceKey, accountId, index }, [
    'pageId',
    'spaceId',
    'spaceKey',
    'accountId',
    'index',
  ]);

  return {
    type: 'extension',
    attrs: {
      layout: 'default',
      extensionType: 'com.atlassian.ecosystem',
      extensionKey: MERMAID_EXTENSION_KEY,
      text: 'Mermaid diagram',
      parameters: {
        layout: 'extension',
        guestParams: { index: Number(index) },
        forgeEnvironment: 'PRODUCTION',
        extensionProperties: {
          accountId,
          extension: {
            appVersion: '2.47.0',
            environmentType: 'PRODUCTION',
            dataClassificationPolicyDecision: { status: 'ALLOWED' },
            type: 'xen:macro',
            environmentKey: 'production',
            egress: [],
            environmentId: '63d4d207-ac2f-4273-865c-0240d37f044a',
            appId: '23392b90-4271-4239-98ca-a3e96c663cbb',
            id: MERMAID_EXTENSION_ID,
            installationId: '2a0dbb45-2029-4f7f-9be9-f31860c41d55',
            scopes: ['read:page:confluence'],
            key: 'mermaid-diagram',
            properties: {
              resourceUploadId: '42a4c372-3f84-4a04-a465-bad769c3e441',
              resource: 'custom-ui',
              icon: 'https://icon.cdn.prod.atlassian-dev.net/23392b90-4271-4239-98ca-a3e96c663cbb/63d4d207-ac2f-4273-865c-0240d37f044a/42a4c372-3f84-4a04-a465-bad769c3e441/icons/app-icon.png',
              description: 'Render a Mermaid diagram from a code block on a page',
              categories: ['confluence-content', 'development', 'formatting', 'visuals'],
              title: 'Mermaid diagram',
              type: 'xen:macro',
              config: {
                resource: 'macro-config',
                viewportSize: 'small',
                title: 'Mermaid diagram configuration',
                render: 'native',
              },
              key: 'mermaid-diagram',
            },
          },
          cloudId: CLOUD_ID,
          contextIds: [WORKSPACE_CONTEXT_ID],
          extensionData: {
            type: 'macro',
            content: { id: String(pageId), type: 'page' },
            space: { id: String(spaceId), key: String(spaceKey) },
          },
        },
        extensionId: MERMAID_EXTENSION_ID,
        extensionTitle: 'Mermaid diagram',
      },
    },
  };
}

export function findMermaidPairs(doc) {
  const body = unwrapDoc(doc);
  const content = Array.isArray(body.content) ? body.content : [];

  return content
    .map((node, nodeIndex) => ({ node, nodeIndex }))
    .filter(({ node }) => isMermaidExtension(node))
    .map(({ node, nodeIndex }, pairIndex) => {
      const nextNode = content[nodeIndex + 1];
      return {
        pairIndex,
        extensionIndex: nodeIndex,
        codeBlockIndex: nextNode?.type === 'codeBlock' ? nodeIndex + 1 : -1,
        macroIndex: node.attrs?.parameters?.guestParams?.index,
        extensionNode: node,
        codeBlockNode: nextNode?.type === 'codeBlock' ? nextNode : undefined,
      };
    });
}

export function replaceMermaidCodeBlock(doc, index, mermaidText) {
  const body = unwrapDoc(doc);
  const pairs = findMermaidPairs(body);
  const pair = pairs[Number(index)];

  if (!pair) {
    throw new Error(`No Mermaid diagram pair found at index ${index}. Found ${pairs.length}.`);
  }

  if (pair.codeBlockIndex < 0) {
    throw new Error(`Mermaid extension at index ${index} is not immediately followed by a codeBlock.`);
  }

  body.content[pair.codeBlockIndex] = {
    type: 'codeBlock',
    attrs: body.content[pair.codeBlockIndex].attrs ?? {},
    content: [{ type: 'text', text: String(mermaidText) }],
  };

  return body;
}

export function renumberMermaidExtensions(doc) {
  const body = unwrapDoc(doc);
  findMermaidPairs(body).forEach((pair, index) => {
    pair.extensionNode.attrs ??= {};
    pair.extensionNode.attrs.parameters ??= {};
    pair.extensionNode.attrs.parameters.guestParams ??= {};
    pair.extensionNode.attrs.parameters.guestParams.index = index;
  });
  return body;
}

export function markInlineCodeTerms(doc, terms) {
  const body = unwrapDoc(doc);
  const normalizedTerms = normalizeTerms(terms);

  if (normalizedTerms.length === 0) {
    return body;
  }

  walkAdf(body, (node, ancestors) => {
    if (!Array.isArray(node.content) || isInsideCodeBlock(ancestors)) {
      return;
    }

    node.content = node.content.flatMap((child) => {
      if (child.type !== 'text' || typeof child.text !== 'string' || hasCodeMark(child)) {
        return child;
      }
      return splitTextNodeWithCodeMarks(child, normalizedTerms);
    });
  });

  return body;
}

function splitTextNodeWithCodeMarks(node, terms) {
  const pattern = new RegExp(`(${terms.map(escapeRegExp).join('|')})`, 'g');
  const chunks = node.text.split(pattern).filter((part) => part.length > 0);

  if (chunks.length === 1) {
    return node;
  }

  return chunks.map((chunk) => {
    const nextNode = { ...node, text: chunk };
    if (terms.includes(chunk)) {
      nextNode.marks = addCodeMark(node.marks);
    }
    return nextNode;
  });
}

function addCodeMark(marks = []) {
  return marks.some((mark) => mark.type === 'code') ? marks : [...marks, { type: 'code' }];
}

function hasCodeMark(node) {
  return Array.isArray(node.marks) && node.marks.some((mark) => mark.type === 'code');
}

function walkAdf(node, visit, ancestors = []) {
  if (!node || typeof node !== 'object') {
    return;
  }

  visit(node, ancestors);

  if (!Array.isArray(node.content)) {
    return;
  }

  node.content.forEach((child) => walkAdf(child, visit, [...ancestors, node]));
}

function isInsideCodeBlock(ancestors) {
  return ancestors.some((ancestor) => ancestor.type === 'codeBlock');
}

function isMermaidExtension(node) {
  return node?.type === 'extension' && node?.attrs?.extensionKey === MERMAID_EXTENSION_KEY;
}

function unwrapDoc(input) {
  if (input?.type === 'doc') {
    return input;
  }

  if (input?.body?.type === 'doc') {
    return input.body;
  }

  if (input?.body?.body?.type === 'doc') {
    return input.body.body;
  }

  throw new Error('Input must be an ADF doc or an object containing body as an ADF doc.');
}

function normalizeTerms(terms) {
  const list = Array.isArray(terms) ? terms : String(terms ?? '').split(',');
  return [...new Set(list.map((term) => term.trim()).filter(Boolean))].sort(
    (a, b) => b.length - a.length,
  );
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function readText(filePath) {
  return fs.readFileSync(filePath, 'utf8');
}

function parseArgs(argv) {
  const [command, ...tokens] = argv;
  const flags = { command };

  for (let i = 0; i < tokens.length; i += 1) {
    const token = tokens[i];
    if (!token.startsWith('--')) {
      throw new Error(`Unexpected argument: ${token}`);
    }
    flags[token.slice(2)] = tokens[i + 1];
    i += 1;
  }

  return flags;
}

function assertRequired(values, names) {
  const missing = names.filter((name) => values[name] === undefined || values[name] === '');
  if (missing.length > 0) {
    throw new Error(`Missing required value(s): ${missing.join(', ')}`);
  }
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function printUsageAndExit() {
  const scriptName = path.basename(fileURLToPath(import.meta.url));
  console.error(`Usage:
  node ${scriptName} patch-mermaid --input page-body.json --index 0 --mermaid diagram.mmd
  node ${scriptName} mark-code --input page-body.json --terms vendor_owed,built_fee,InvoicingInput

Outputs the patched ADF doc JSON to stdout. Use that stdout value as updateConfluencePage.body.`);
  process.exit(1);
}

function main() {
  const flags = parseArgs(process.argv.slice(2));

  if (!flags.command || flags.help) {
    printUsageAndExit();
  }

  if (flags.command === 'patch-mermaid') {
    assertRequired(flags, ['input', 'index', 'mermaid']);
    const doc = readJson(flags.input);
    replaceMermaidCodeBlock(doc, Number(flags.index), readText(flags.mermaid));
    renumberMermaidExtensions(doc);
    process.stdout.write(JSON.stringify(unwrapDoc(doc)));
    return;
  }

  if (flags.command === 'mark-code') {
    assertRequired(flags, ['input', 'terms']);
    const doc = readJson(flags.input);
    markInlineCodeTerms(doc, flags.terms);
    process.stdout.write(JSON.stringify(unwrapDoc(doc)));
    return;
  }

  throw new Error(`Unknown command: ${flags.command}`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    main();
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}

---
name: flashcard
description: >
  Create high-quality spaced-repetition flashcards following SuperMemo's 20 Rules of
  Formulating Knowledge. Trigger when user says "flashcard", "make a flashcard", "turn
  this into a flashcard", "add this to my flashcards", or types /flashcard.
---

# Flashcard Skill

Apply SuperMemo's 20 Rules to produce atomic, memorable flashcards from any input.

## Step 1 — Understand First (Rules 1–3)

If the input is ambiguous or the user hasn't explained it, ask **one** clarifying question before formulating cards. Never memorize what you don't understand.

## Step 2 — Decompose Into Atoms (Rule 4)

Scan the input and count distinct facts. Each fact becomes one card. Hard rules:

- If the answer contains "and" joining two independent facts → split into two cards
- If the answer is a list → see Step 3 (sequences) or make one card per item
- Target: Q ≤ 10 words, A ≤ 7 words

## Step 3 — Choose Card Type

| Input type | Card type |
|---|---|
| Factual definition or cause/effect | Q&A |
| Sentence with one key term missing | Cloze deletion |
| Ordered sequence / process steps | Overlapping cloze (one card per step, each overlapping the next) |
| Visual / spatial (anatomy, geography) | Q&A with note: `[attach image]` |

**Overlapping cloze for sequences** (Rule 10, 17): given steps A→B→C→D, emit:
- `A → {{c1::B}} → C`
- `B → {{c1::C}} → D`

## Step 4 — Wording Rules (Rules 12, 16)

- Prefix every card with a category tag: `bio:`, `sql:`, `hist:`, `code:`, `net:`, etc.
- Strip filler: "What is the definition of X?" → "What does X do?"
- No yes/no questions — rewrite as fill-in
- No "List all X" questions — split or use overlapping cloze

## Step 5 — Add Example If Abstract (Rule 14)

For conceptual cards, add one concrete example sentence after the answer. Use personal or domain-familiar references over textbook ones.

## Step 6 — Flag Issues

- **Interference** (Rule 11): If the card is similar to a concept the user might already know, add: `⚠ Interference risk: [related concept]`
- **Volatile fact** (Rule 19): If the answer can go stale (version numbers, statistics, prices), add: `📅 Volatile: review after [YYYY-MM]`

## Output Format

Emit each card as a clean block in Anki-compatible text:

```
[category]: [topic]

Card N — Q&A
Q: [question ≤10 words]
A: [answer ≤7 words]
Example: [one sentence] (omit if concrete enough without it)

Card N — Cloze
[Full sentence with {{c1::answer}} inline]

⚠ Interference risk: [concept] (if applicable)
📅 Volatile: review after [YYYY-MM] (if applicable)
```

## Anti-Patterns → Rewrites

| Bad | Fix |
|---|---|
| Q: What are the three phases of X? A: Phase 1, Phase 2, Phase 3 | Three separate cards, one per phase |
| Q: Does TCP use handshakes? A: Yes | Q: TCP uses how many handshake steps? A: 3 |
| A: It increases performance and reduces latency | Split into two cards |
| Q: List all HTTP methods | One card per method, or overlapping cloze |

## Reference — Key SuperMemo Rules

| Rule | Core idea |
|---|---|
| 1 | Don't memorize what you don't understand |
| 2 | Build overview first, then memorize details |
| 4 | Minimum information — one fact per card |
| 5 | Cloze deletion is easy and effective |
| 9 | Avoid unordered sets (>5 items unmemorizable without mnemonics) |
| 10 | Use overlapping cloze for ordered sequences |
| 11 | Detect interference; use examples to distinguish similar items |
| 12 | Optimize wording — cut every unnecessary word |
| 14 | Personalize with examples; personal = interference-resistant |
| 17 | Redundancy OK — same fact from multiple angles = multiple cards |
| 19 | Date-stamp volatile facts |

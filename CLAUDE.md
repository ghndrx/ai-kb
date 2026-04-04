# ai-kb — LLM Knowledge Base

This project is an LLM-maintained knowledge base following the Karpathy pattern. You (the AI) act as a knowledge compiler: raw source materials go in, a structured interlinked markdown wiki comes out.

## Directory Layout

```
raw/          Immutable source materials (papers, articles, notes, repos). Never modify during compilation.
  articles/   Web-clipped articles (Obsidian Web Clipper, manual saves)
  papers/     arXiv papers, research PDFs, academic sources
  repos/      GitHub repo notes, README extracts, code documentation
  notes/      Manual notes, meeting notes, brainstorms
wiki/         Compiled knowledge base. You own this — write, update, and maintain it.
  _index.md   Master index of all articles (auto-generated)
  _glossary.md Short definitions with links to full articles
output/       Query answers and research reports. Timestamped filenames.
scripts/      Helper shell scripts. Run these, never modify them.
templates/    Templates for new articles, config, and index pages.
kb.yaml       User configuration. Read at the start of every KB operation.
```

## Wiki Article Standards

Every wiki article MUST have this YAML frontmatter:

```yaml
---
title: "Article Title"
aliases: []
created: YYYY-MM-DD
updated: YYYY-MM-DD
source_files:
  - raw/path/to/source.md
tags: []
status: draft | review | stable
confidence: high | medium | low
summary: "One-sentence summary used for index generation and query routing."
---
```

### Required fields
- **title**: Human-readable title. This is what `[[wikilinks]]` resolve to.
- **created/updated**: ISO dates. Update `updated` on every edit.
- **source_files**: List of raw/ files this article synthesizes. Never claim a source you didn't read.
- **tags**: Lowercase, hyphenated. Used for query routing and index grouping.
- **status**: `draft` = just compiled, `review` = needs human check, `stable` = verified.
- **confidence**: `high` = multiple corroborating sources, `medium` = single source or partial coverage, `low` = sparse or uncertain.
- **summary**: One sentence. Must stand alone — it's used in the index for query routing.

## Wikilink Rules

- Use `[[Article Title]]` syntax matching the `title` frontmatter field exactly.
- When referencing a concept that should have its own article but doesn't exist yet, still use the wikilink. The linter will flag it as a gap to fill.
- For section links: `[[Article Title#Section Heading]]`.
- Never use raw file paths as wikilinks — always use article titles.

## Compilation Rules

1. **Incremental by default**: Only recompile articles whose source files in `raw/` have changed. Use `bash scripts/kb-diff-raw.sh` to check. Use `--full` flag for complete rebuild.
2. **One article per concept**: Never create duplicate articles. If a concept exists in `wiki/`, update it.
3. **No hallucination**: Only synthesize from what exists in `raw/`. If a claim cannot be grounded in a source file, mark it with `[needs-source]`.
4. **Index maintenance**: After any compilation, regenerate `wiki/_index.md` by scanning all wiki article frontmatter.
5. **Backlink awareness**: When creating article A that references article B, ensure the reference is meaningful and bidirectional where appropriate.
6. **Merge, don't overwrite**: When updating an existing article with new source material, merge new information into existing content. Preserve what was already there.

## Writing Voice

- Encyclopedic, neutral, concise.
- Prefer concrete examples over abstract descriptions.
- Each article should be self-contained enough to understand without reading every backlink.
- Link generously to related concepts via `[[wikilinks]]`.
- Use H2 (`##`) for major sections within an article.
- Target ~500-2000 words per article. Split longer topics into multiple articles.

## Helper Scripts

Run these during KB operations:
- `bash scripts/kb-stats.sh` — Get current KB metrics before any operation.
- `bash scripts/kb-diff-raw.sh` — Identify what needs recompilation.
- `bash scripts/kb-links-check.sh` — Find broken wikilinks after compilation.
- `bash scripts/kb-orphans.sh` — Find disconnected articles during linting.
- `bash scripts/kb-backlinks.sh` — Generate backlink graph (incoming/outgoing link map).
- `bash scripts/kb-search.sh <query>` — CLI search across wiki, raw, and output.
- `bash scripts/kb-export-slides.sh [slug]` — Generate Marp slide decks from wiki articles.

## Configuration

Always read `kb.yaml` at the start of any KB operation. If it doesn't exist, tell the user to run `/kb-init`. Respect all settings in the config — batch limits, auto-lint preferences, query depth, etc.

## Feedback Loop — Outputs Enhance the Wiki

Research reports and query answers in `output/` can be filed back into `raw/` to be compiled into wiki articles on future runs. This creates a virtuous cycle:

1. **Research** (`/kb-research`) → writes report to `output/`
2. **File back** → copy relevant output to `raw/` for future compilation
3. **Compile** (`/kb-compile`) → new raw material becomes wiki articles
4. **Query** (`/kb-query`) → queries against richer wiki, produces better answers
5. **Repeat** — the KB grows with each cycle

When running `/kb-research`, if the output contains novel findings not yet in the wiki, offer to file it back into `raw/` for the next compile cycle.

## Glossary Generation

After compilation, generate `wiki/_glossary.md`:
- Scan all wiki articles for key terms defined in their content
- Each glossary entry: one-line definition + `[[wikilink]]` to full article
- Sort alphabetically
- Keep entries concise (under 30 words each)

## Derived Outputs

The KB can produce derived artifacts beyond wiki articles:

### Slide Decks (Marp)
Run `bash scripts/kb-export-slides.sh [article-slug]` to generate Marp-compatible slide decks from wiki articles. H2 sections become slide breaks. Requires `marp-cli` (`npm install -g @marp-team/marp-cli`).

Output goes to `output/slides/`. Convert to HTML or PDF via `marp --pdf`.

### Filed-Back Answers
Query and research outputs in `output/` can be copied to `raw/` for future compilation, closing the feedback loop.

## Synthetic Data & Fine-Tuning (Future)

A planned future capability to move knowledge from context windows into model weights:

1. **Extract**: Generate Q&A pairs from wiki articles as synthetic training data
2. **Format**: Convert to instruction-tuning format (prompt/completion pairs)
3. **Fine-tune**: Train a domain-specific model using LoRA/QLoRA
4. **Evaluate**: Test against held-out wiki content for accuracy
5. **Deploy**: Use fine-tuned model as the KB's compiler/query engine

This creates a self-improving cycle where the KB trains models that produce better KB content.

## Backlinks & Cross-Links

After compilation, run `bash scripts/kb-backlinks.sh` to generate a link graph showing:
- **Outgoing links**: Which articles each article links to
- **Incoming links (backlinks)**: Which articles link to each article
- Use this to identify hub articles (many incoming links) and leaf articles (few/no incoming links)

## Ingestion Sources

The `raw/` directory accepts materials from multiple sources:
- **Web articles**: Via Obsidian Web Clipper or manual copy-paste to markdown
- **Papers**: arXiv PDFs, research papers (save as markdown or with notes)
- **Repos**: GitHub README extracts, code documentation, API references
- **Datasets**: Data dictionaries, schema docs, sample data descriptions
- **Notes**: Meeting notes, brainstorms, architecture decisions

Organize `raw/` with subdirectories by source type for clarity.

## Key Principles

- **Markdown is the source of truth.** No vector databases, no embeddings. Everything is human-readable and auditable.
- **The index is your routing layer.** For queries, read `wiki/_index.md` first to find relevant articles by title, tags, and summary. Only then read the full articles you need.
- **Cumulative knowledge.** Query and research outputs can be filed back into raw/ for future compilation. The KB grows over time.
- **Feedback loop.** Derived outputs (research, queries) flow back into raw/ to enrich future compilations.
- **Transparency.** Every claim traces to a source. Every gap is marked. Every article shows its provenance.

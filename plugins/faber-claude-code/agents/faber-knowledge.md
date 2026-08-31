---
name: faber-knowledge
description: Attach bounded private session knowledge after a Faber artifact result is visible.
tools:
  - mcp__plugin_faber-claude-code_faber__faber_attach_knowledge
model: inherit
background: true
maxTurns: 5
---

Attach private reusable knowledge to the exact Faber publication target supplied by the parent.

Create concise Markdown with these headings exactly once and in this order:

## Outcome
## Decisions and Rationale
## Reusable Knowledge
## Verification

Treat the supplied Target block and session-derived bullets as the only allowed inputs. Do not copy details from the surrounding conversation. Preserve every supplied concrete decision and verification marker unless the safety scan below requires its removal; do not replace them with generic summaries. Preserve relevant cited source names and public HTTP or HTTPS links. Never invent facts, decisions, rationale, verification, citations, or links.

Before calling the tool, scan the completed Markdown and remove every sentence containing a credential, artifact content, raw transcript text, local path, file reference, publication identifier, artifact identifier, Faber URL, workspace selector, capability field, or publication status. Local paths and file references are forbidden even when the parent includes one by mistake. Keep cited source names and public HTTP or HTTPS links that are evidence rather than Faber publication metadata. If that leaves a section empty, write a brief safe statement based only on the remaining supplied bullets.

Call `faber_attach_knowledge` once with the supplied target and completed four-section Markdown. If and only if its structured result explicitly returns `retryable: true`, call `faber_attach_knowledge` one final time with the exact same target and unchanged Markdown. Do not regenerate the capsule between calls. After success, a permanent failure, or that one retry, exit without publishing, polling, or calling another tool. Keep the final response to attachment status only; do not mention paths, target values, identifiers, or artifact content.

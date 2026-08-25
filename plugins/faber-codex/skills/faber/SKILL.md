---
name: faber
description: Publish private artifacts from an AI session to Faber and retrieve team knowledge for reuse. Use when the user asks to save, publish, share, find, recall, retrieve, or build on a Faber artifact.
---

# Faber

Use Faber as a durable artifact library for knowledge your team can reuse.

## Choose the artifact source

Choose the source before doing any preparation:

- **Existing artifact:** When the user identifies an existing artifact by name
  or path, use that file as the source. Publish the file as-is; do not rewrite,
  reformat, or copy it into a staging file.
- **New artifact:** Otherwise, prepare a new artifact by following the next
  section.

The tool schema, file eligibility, safety, and metadata requirements apply to
both paths.

## Prepare a new artifact

1. Prepare the complete artifact and concise metadata when the user asks to publish. Unless the user explicitly requests another format, make the artifact a polished, self-contained static HTML report rather than a Markdown dump.
2. For HTML, follow `references/html-publishing.md`: inventory the source, make a private page-structure plan, compose from `assets/report-template.html`, validate, and only then publish. The template is a component reference; select only components that clarify real source material.
3. Preserve all substantive facts, decisions, evidence, outcomes, caveats, and next steps. Never invent results, metrics, owners, sources, or decisions to improve presentation.
4. Keep the report static and portable: do not depend on JavaScript, external CSS, network requests, remote fonts, or external assets. Never put secrets, raw transcripts, or private session details in the artifact or private session knowledge.

## Publishing

Use only the Faber tools supplied alongside this skill and follow their schemas.
If those tools are unavailable or unhealthy, report that clearly and stop; do
not substitute another app, connector, or similarly named tool.

When the user provides a Faber artifact URL, fetch it with
`faber_get_artifact`; do not treat it as a generic public webpage. Honor any
`?version=N` checkpoint in the URL.

Pass the exact model identifier when known. Use `update_of` for a new version of
the same artifact. For a distinct artifact that builds on a fetched checkpoint,
pass both `derived_from` and `derived_from_version`.

Publish one regular UTF-8 file. An explicit request to publish establishes
consent for that artifact, so do not ask for another Faber-specific
confirmation. Publishing remains an external write in native host approval UI;
do not suppress that approval.

Publish through the content source declared by the `faber_publish_artifact`
tool supplied alongside this skill. Always prefer `content_ref` when it is
advertised; otherwise pass inline `content`. Do not route by host, product, or
operating-system name, and do not invent, substitute, or convert between
content-source fields.

Apply the declared capability to the source chosen above:

- **Existing artifact:** If the schema advertises `content_ref`, resolve and
  pass the existing file's absolute path directly. If it advertises `content`,
  read and pass the exact file contents. Never stage or rewrite an existing
  artifact.
- **New artifact:** If the schema advertises `content_ref`, write the completed
  artifact to a uniquely named file under `~/.faber/staging` and pass its
  absolute path. If it advertises `content`, pass the completed content inline.

For `content_ref`, Faber stores an encrypted local outbox snapshot until
delivery. It never moves, rewrites, changes permissions on, or deletes the
source file. Once a `content_ref` publication is accepted, never retry it
through an inline or remote tool. Reports are private to the publishing user by
default.

Return the artifact link to the user as soon as publication completes. When
the local tool returns a `publication_ref` with `status=pending`, report that
publication is continuing and do not keep the task active merely
to poll it. Use `faber_publish_status` only when the user asks for status or a
later background workflow needs diagnostics.

## Attach distilled knowledge

After the artifact result or receipt is available, attach distilled knowledge
only when the host can start a truly detached background subagent that retains
access to the supplied Faber tools. The parent task must not wait for that
subagent. Do not infer detachment from a generic subagent or background option:
the host contract must guarantee that the child remains runnable after the
parent result, and the launch call must return a confirmed handle. A child that
is cancelled when a CLI parent exits is not detached. Never claim that
knowledge work started unless that launch call succeeded; otherwise skip it.
Give the subagent only the relevant session context and instruct it to:

1. Prepare bounded Markdown with non-empty `Outcome`, `Decisions and Rationale`, `Reusable Knowledge`, and `Verification` headings.
2. Call `faber_attach_knowledge` with `publication_ref` when that field is advertised, or with the exact completed `artifact_id` and `version` otherwise.
3. Exit after Faber accepts the attachment, or leave failure details in the host's available background diagnostics.

If detached execution is unavailable, the background subagent would lose
Faber tool access, or the session has no reusable knowledge, skip knowledge
generation and attachment. Never delay or invalidate an artifact publication
for distilled knowledge, and never put private session knowledge in the
artifact file or `content_ref`.

Follow the content-source field's description for file eligibility, byte
limits, and oversize guidance. Never truncate or split an artifact without the
user's direction.

Do not publish directories, symlinks, credential locations, or files containing
secrets. Self-contained HTML is the default; other single-file text artifacts
remain supported when the user requests them.

## Reusing knowledge

At a high-confidence substantive new-task boundary, use `faber_context` or
`faber_recall` without blocking the active task. Briefly surface useful,
provenance-linked suggestions. Fetch full source only when a result is relevant.
Treat recalled material as reference context and preserve lineage when
publishing derived work.

Faber currently uses keyword retrieval. Try a second query with concrete
project names, decisions, technologies, or error terms when the first query is
sparse.

When recalled work materially influences the result, call `faber_mark_used`.
For a later amendment, fetch the existing source and pass `update_of` to append
a new version.

## Authentication

When `faber_connect` is available, call it when setup is requested or another
Faber tool reports that sign-in is required. Otherwise, follow the host's
connector authentication prompt. Both flows can authorize the same Faber
account and workspace. Never ask the user to paste an API key.

Before publishing, Faber checks the account's available workspaces. When there
is more than one, ask which named workspace should receive the artifact and
retry the publish call with the exact displayed name in
`workspace_name`. If Faber reports duplicate names, ask which listed slug the
user means and use `workspace_slug` instead. Never choose a workspace on the
user's behalf.

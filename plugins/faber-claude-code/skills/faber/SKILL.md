---
name: faber
description: Publish private artifacts from an AI session to Faber and retrieve team knowledge for reuse. Use when the user asks to save, publish, share, find, recall, retrieve, or build on a Faber artifact.
---

# Faber

Use Faber as a durable artifact library for knowledge your team can reuse.

## Choose the operation

Route the request before doing any artifact preparation:

- **Connect or set up Faber:** Use the authentication flow in Preflight. Do not
  continue into retrieval or publishing unless the user requested it.
- **Retrieve only:** For a Faber URL or artifact ID, use
  `faber_get_artifact`. For an artifact name or topic, use `faber_search` and
  fetch exact source only when a result is relevant. If multiple results could
  be the intended artifact, ask the user to choose before fetching. Return the
  requested result and do not continue into publishing.
- **Retrieve, then publish:** Retrieve first, then continue with the exact
  source and lineage rules below. If the intended artifact cannot be resolved,
  stop or ask the user to choose; never fall through to new-artifact creation.
- **Publish without retrieval:** Continue with Choose the publish source.

At a high-confidence substantive new-task boundary, Reusing context may also
provide proactive context without turning the request into a publish operation.

## Preflight

Use only the Faber tools supplied alongside this skill and follow their schemas.
If a required tool is unavailable or unhealthy, report that the operation
cannot continue; do not substitute another app, connector, or similarly named
tool. Optional recall and Context capture must remain fail-open.

For a user-requested Faber operation, call `faber_connect` when it is available
and either setup is requested or a required Faber tool reports that sign-in is
needed.
Otherwise, follow the host's connector authentication prompt. Both flows can
authorize the same Faber account and workspace. Never ask the user to paste an
API key. Proactive recall must stop silently on sign-in or availability errors;
it must not initiate authentication.

When fetching a Faber artifact URL, do not treat it as a generic public webpage.
Honor any `?version=N` checkpoint in the URL.

Pass the exact model identifier as artifact provenance when the publish tool
exposes that field and the identifier is known; this does not select a model for
background work. Use `update_of` for a new version of the same artifact. For a
distinct artifact that builds on a fetched checkpoint, pass both `derived_from`
and `derived_from_version`.

## Choose the publish source

Choose the publish source before doing any preparation:

- **Existing local artifact:** When the user identifies an existing artifact by
  local name or path and asks to publish it unchanged, resolve its absolute path
  and use that file as the source. Publish the file as-is; do not rewrite,
  reformat, or copy it into a staging file. When the user explicitly asks to
  modify that local file before publishing, make only the requested edits in
  the original file, then publish that same absolute path; create a separate
  copy only when the user asks to preserve the original.
- **Retrieved Faber artifact:** Use the exact fetched source as the starting
  point, apply the user's requested changes before publishing an amendment or
  derived artifact, and preserve the fetched checkpoint's lineage. If the user
  only wants the existing artifact, return its link instead of publishing it
  again.
- **New artifact:** Otherwise, prepare a new artifact by following the next
  section.

## Prepare a new artifact

1. Prepare the complete artifact and concise metadata when the user asks to publish. For a report or document, use a polished, self-contained static HTML report rather than a Markdown dump unless the user requests another format. Preserve an appropriate native single-file format for code, datasets, prompts, and other non-report artifacts.
2. For HTML, follow `references/html-publishing.md`: inventory the source, make a private page-structure plan, compose from `assets/report-template.html`, validate, and only then publish. The template is a component reference; select only components that clarify real source material.
3. Preserve all substantive facts, decisions, evidence, outcomes, caveats, and next steps. Never invent results, metrics, owners, sources, or decisions to improve presentation.
4. Keep the report static and portable: do not depend on JavaScript, external CSS, network requests, remote fonts, or external assets. Never put secrets, raw transcripts, or audience-inappropriate details in either output. Context may preserve bounded session-only rationale and evidence, but it inherits the artifact's visibility, so include only distilled facts appropriate for everyone who can view the artifact.

## Publishing

Follow the `content_ref` field's eligibility, byte-limit, and oversize guidance.
Never truncate or split without the user's direction, and never publish
directories, symlinks, credential locations, or files containing secrets.
Self-contained HTML is the default; requested single-file text formats remain
supported.

Before publishing any source, including an existing local file, check that it
does not contain raw transcript material, private session details, credentials,
or other content inappropriate for everyone who will be able to view the
artifact. Stop and explain the concern rather than silently rewriting an
existing source.

Publish one regular UTF-8 file. An explicit request to publish to Faber also
authorizes its bounded artifact-scoped Context sidecar. Context inherits the
artifact's visibility, so capture only facts appropriate for the artifact's full
audience. Treat them as one operation and do not ask for another Faber-specific
confirmation. Artifact publication remains an external write in native host
approval UI; do not suppress that approval.

Publish through the `content_ref` field declared by the
`faber_publish_artifact` tool supplied alongside this skill.
Do not prepare or pass `context_capsule` to this tool; optional Context
capture begins only after the publication URL is visible.

Apply the declared capability to the source chosen above:

- **Existing artifact:** Resolve and pass the existing file's absolute path
  directly. Never stage it or rewrite it unless the user explicitly requested
  those edits before publishing.
- **Retrieved or new artifact:** Prefer a uniquely named file in the
  host-resolved user home directory's `.faber/staging` folder. Pass its absolute
  path. If that location cannot be written or accessed, report the local-access
  failure and stop; do not switch to another publishing method.

For `content_ref`, Faber stores an encrypted local outbox snapshot until
delivery. It never moves, rewrites, changes permissions on, or deletes the
source file. Once Faber returns a publication URL, never retry it through
`faber_publish_artifact` or another publishing tool. Use that same URL for any
explicit status or recovery call.
Reports are private to the publishing user by default.

## Handle the publication result

Handle exactly one result branch:

- **Complete:** Surface the artifact URL immediately.
- **Pending:** A local `content_ref` publication returns a reserved Faber URL
  within 20 seconds of durable snapshot acceptance. Surface that URL
  immediately. The opened Faber page shows pending delivery and refreshes when
  ready; do not poll or keep the task active.
- **Action required:** Follow the returned action. If there are workspace choices,
  ask the user which named workspace should receive the artifact and show the
  existing workspace names as options with the question. Use the exact
  displayed name in `workspace_name`; use `workspace_slug` only when Faber
  reports duplicate names. Workspace selection happens before URL reservation,
  so call `faber_publish_artifact` again with the same source and metadata plus
  exactly the selected workspace field. Never choose a workspace on the user's
  behalf. For an action returned with `publication_url`, surface that URL first
  and follow the recovery guidance without republishing.
- **Failed:** Report the returned `error_code`, `retryable`, and actionable
  `detail`, then stop the publish path. Do not replace them with a generic retry
  suggestion.

Treat every result from `faber_publish_status` as a fresh publication result and
route it through this section. Use that tool only when the user asks for status
or recovery diagnostics are needed. Pass the original `publication_url`; do
not wait for a pending publication to complete unless the user explicitly asks
for status.
For the initial successful complete or pending publication, the main agent's
response must contain only the bare Faber URL. Do not add any other narration
or description about how the tools work. The tool's visible URL is
sufficient when the host exposes it; otherwise return that URL as the sole
response. This does not suppress a required workspace-selection action, a concise
failure response, a background child's attachment status, or a later user-requested
status or Context recovery response.

The publish tool's visible result surfaces its Faber URL. A result without
`context_action` requires no agent-side Context
work: the executor may capture bounded main-session context and
continue Context generation in its own background process. Do not
prepare that context; do not call another tool, wait, poll, or keep the task
active for this optional work. Context failure never invalidates the artifact.
The executor reproduces the publishing session's model runtime from structured
host metadata; the main agent must not discover or pass model metadata to select
the background worker's runtime. This does not change the publication
provenance guidance above.
For `context_action=attach_if_background_supported`, continue to Optional
asynchronous Context. For any other non-empty `context_action`, preserve the
surfaced artifact result and follow or report the returned recovery guidance;
never retry or invalidate the completed publication because of optional
Context.

When status reports `context_action=retry`, the artifact is already complete.
Call `faber_retry_context` once with the same `publication_url`, surface that
Context generation resumed, and do not poll unless the user later requests
status. If retry is unavailable or expired, report that Context was not
attached without republishing the artifact.

## Optional asynchronous Context

This is the only agent-side Context branch. Follow it only when a completed
artifact or durably accepted publication explicitly includes
`context_action=attach_if_background_supported`; a result without that action
belongs to executor-owned Context. The publication URL must already
be visible. Start at most one independent background task only when it already
has the supplied `faber_attach_context` tool without a new approval and does
not keep the current task active or require waiting; otherwise skip Context.
When the host supplies a dedicated background Context agent, invoke that
agent exactly once. Otherwise use a native background child only when it
satisfies the same tool, independence, and approval constraints.

Use the host's inherit or same-as-parent model option. Do not choose a model
identifier, launch another CLI process, or use a joined child. If the host
cannot provide an inherited-model background agent, skip optional Context for
this publication.

Begin the background-task prompt with a `Target` block containing the exact
target fields accepted by the supplied `faber_attach_context` tool. Use only
`publication_url` when that field is available; otherwise use the returned
`artifact_id` and `version`, plus any returned workspace selector accepted by
the tool. Tell the child to copy every target value into
`faber_attach_context`; it must never infer a target or workspace from a title,
marker, or session fact. After the Target block, provide an `Artifact (primary
evidence)` section with at most 64 KiB of readable visible artifact text and a
`Session (supplemental)` section with at most 32 KiB of normalized session
context. The artifact is primary. Session context may add relevant rationale,
constraints, assumptions, unresolved questions, operational knowledge, and
cited public sources that the artifact omits. Both sections must be appropriate
for the artifact's full audience because the Context Capsule inherits it.
Before launching the child, remove scripts, styles, embedded data, local paths
or file references, credentials, raw transcript text, Faber links, publication
references, workspace selectors, capability fields, and publication status.
Preserve cited public HTTP or HTTPS evidence links. The exact target belongs
only in the `Target` block. If no safe meaningful Context remains, skip it.
This transfer is not capsule drafting: the child creates the structured
Context Capsule v3 attachment required by the tool. The main agent must not
draft or attach the capsule, wait, poll, or use blocking work as a fallback. The
child agent's failure never invalidates the artifact and does not trigger a
second generation path. After launching the child, do not call
`faber_retry_context` or any other Faber tool because the child reports success
or failure; only a later user-requested status result with
`context_action=retry` enables the separate retry flow above. Tell the child to
call `faber_attach_context` once.
Only when that call's structured result explicitly returns `retryable: true`,
it may repeat the exact same attachment once without polling, using unchanged
target values and unchanged capsule JSON. It must not regenerate the
capsule, republish, make a third attachment call, or call other Faber tools.

## Reusing context

At a high-confidence substantive new-task boundary, call `faber_context` once
with the task description. Use `faber_recall` instead only for an explicit,
targeted topical recall that does not need a full task grounding pack. Briefly
surface useful, provenance-linked suggestions without blocking the active task.
Fetch full source only when a result is relevant.
Treat recalled material as reference context and preserve lineage when
publishing derived work.

Faber currently uses keyword retrieval. Try a second query with concrete
project names, decisions, technologies, or error terms when the first query is
sparse.

When recalled work materially influences the result, call `faber_mark_used`.
For a later amendment, fetch the existing source and pass `update_of` to append
a new version.

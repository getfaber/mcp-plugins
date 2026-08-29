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

At a high-confidence substantive new-task boundary, Reusing knowledge may also
provide proactive context without turning the request into a publish operation.

## Preflight

Use only the Faber tools supplied alongside this skill and follow their schemas.
If a required tool is unavailable or unhealthy, report that the operation
cannot continue; do not substitute another app, connector, or similarly named
tool. Optional recall and knowledge must remain fail-open.

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
  local name or path, resolve its absolute path and use that file as the source.
  Publish the file as-is; do not rewrite, reformat, or copy it into a staging
  file.
- **Retrieved Faber artifact:** Use the exact fetched source as the starting
  point, apply the user's requested changes before publishing an amendment or
  derived artifact, and preserve the fetched checkpoint's lineage. If the user
  only wants the existing artifact, return its link instead of publishing it
  again.
- **New artifact:** Otherwise, prepare a new artifact by following the next
  section.

## Prepare a new artifact

1. Prepare the complete artifact and concise metadata when the user asks to publish. Unless the user explicitly requests another format, make the artifact a polished, self-contained static HTML report rather than a Markdown dump.
2. For HTML, follow `references/html-publishing.md`: inventory the source, make a private page-structure plan, compose from `assets/report-template.html`, validate, and only then publish. The template is a component reference; select only components that clarify real source material.
3. Preserve all substantive facts, decisions, evidence, outcomes, caveats, and next steps. Never invent results, metrics, owners, sources, or decisions to improve presentation.
4. Keep the report static and portable: do not depend on JavaScript, external CSS, network requests, remote fonts, or external assets. Never put secrets or raw transcripts in either output. Keep private session details out of the artifact; only bounded, distilled reusable knowledge belongs in the private attachment.

## Publishing

Follow the declared content-source field's eligibility, byte-limit, and
oversize guidance. Never truncate or split without the user's direction, and
never publish directories, symlinks, credential locations, or files containing
secrets. Self-contained HTML is the default; requested single-file text formats
remain supported.

Publish one regular UTF-8 file. An explicit request to publish to Faber also
authorizes its bounded private knowledge sidecar. Treat them as one operation
and do not ask for another Faber-specific confirmation. Artifact publication
remains an external write in native host approval UI; do not suppress that
approval.

Publish through the content source declared by the `faber_publish_artifact`
tool supplied alongside this skill. Always prefer `content_ref` when it is
advertised; otherwise pass inline `content`. Do not invent, substitute, or
convert between content-source fields.

Apply the declared capability to the source chosen above:

- **Existing artifact:** If the schema advertises `content_ref`, resolve and
  pass the existing file's absolute path directly. Otherwise, if it advertises
  `content`, read and pass the exact file contents. Never stage or rewrite an
  existing artifact.
- **Retrieved or new artifact:** If the schema advertises `content_ref`, prefer
  a uniquely named file in the host-resolved user home directory's
  `.faber/staging` folder when that location is writable; otherwise use another
  eligible host-writable local path. Pass its absolute path. Otherwise, if the
  schema advertises `content`, pass the completed content inline.

For `content_ref`, Faber stores an encrypted local outbox snapshot until
delivery. It never moves, rewrites, changes permissions on, or deletes the
source file. Once a `content_ref` publication is accepted, never retry it
through `faber_publish_artifact` or an inline or remote tool. Resume the retained
snapshot only through `faber_publish_status` with the same `publication_ref`.
Reports are private to the publishing user by default.

## Handle the publication result

Handle exactly one result branch:

- **Complete:** Surface the artifact link immediately.
- **Pending:** A local `content_ref` publication returns a link within ten
  seconds of durable snapshot acceptance or a `publication_ref` with
  `status=pending` at the cap. Surface that durable receipt and report that
  publication is continuing. Do not keep the task active merely to poll it.
- **Action required:** Follow the returned action. For workspace choices, ask
  the user which named workspace should receive the artifact. Use the exact
  displayed name in `workspace_name`; use `workspace_slug` only when Faber
  reports duplicate names. A result containing `publication_ref` means the
  snapshot was accepted: surface that receipt before asking the user or making
  another tool call, never call `faber_publish_artifact` again for that
  publication, and resume it only through `faber_publish_status` with the
  selector. Only when the result omits `publication_ref` may you retry
  `faber_publish_artifact` with the same content and metadata, adding exactly
  the user-selected workspace selector when that action requires one. For
  reconnect or upgrade actions, preserve and surface any receipt before
  following the returned recovery guidance. Never choose a workspace on the
  user's behalf.
- **Failed:** Report the publication failure and stop the publish path.

Treat every result from `faber_publish_status` as a fresh publication result and
route it through this section. Use that tool only when the user asks for status,
an accepted publication requires recovery, or later knowledge work needs
diagnostics. Do not wait for a pending publication to complete unless the user
explicitly asks for status.
"Surface" means the first user-visible opportunity: visible tool output when
the host exposes it, otherwise an intermediate message when supported, or the
first item in the final response. Never describe a pending receipt as a
completed artifact link, and do not promise to surface a later link on a host
without notifications.

The publish tool's visible result surfaces its completed link or accepted
receipt. A result without `knowledge_action` requires no agent-side knowledge
work: the executor may capture bounded main-session context and
continue private knowledge generation in its own background process. Do not
prepare that context; do not call another tool, wait, poll, or keep the task
active for this optional work. Knowledge failure never invalidates the artifact.
Executor-owned background knowledge selects its own model; the main agent must
not discover or pass model metadata.
For `knowledge_action=attach_if_background_supported`, continue to Optional
asynchronous knowledge. For any other non-empty `knowledge_action`, preserve the
surfaced artifact result and follow or report the returned recovery guidance;
never retry or invalidate the completed publication because of optional
knowledge.

When status reports `knowledge_action=retry`, the artifact is already complete.
Call `faber_retry_knowledge` once with the same `publication_ref`, surface that
knowledge generation resumed, and do not poll unless the user later requests
status. If retry is unavailable or expired, report that knowledge was not
attached without republishing the artifact.

## Optional asynchronous knowledge

This is the only agent-side knowledge branch. Follow it only when a completed
artifact or durably accepted publication explicitly includes
`knowledge_action=attach_if_background_supported`; a result without that action
belongs to executor-owned knowledge. The artifact link or receipt must already
be visible. Start at most one independent background task only when it already
has the supplied `faber_attach_knowledge` tool without a new approval and does
not keep the current task active or require waiting; otherwise skip knowledge.

Use a native background child and select the host's inherit or same-as-parent
model option. Do not choose a model identifier, launch another CLI process, or
use a joined child. If the host cannot provide an inherited-model background
child, do not attempt agent-side attachment; the executor may complete its
fallback independently.

Give the background task the exact target fields returned by Faber. Copy into
its prompt up to 12 concise bullets, totaling at most 4 KiB, that preserve every
session-only fact, decision, rationale, verification result, and cited source
relevant to the artifact but absent from it; do not replace those inputs with
publication metadata. Never pass a local path, credential, or raw transcript to
the child prompt itself, including in descriptive or provenance bullets. This
transfer is not capsule drafting: the child creates the four-section private
knowledge attachment required by the tool. The main agent must not draft the
capsule, wait, poll, or use blocking work as a fallback. A delayed executor
fallback may start if the child has not attached within its grace period;
first-write-wins attachment keeps the artifact valid if their work overlaps.

## Reusing knowledge

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

# Publishing polished HTML

Use this workflow when self-contained HTML is the requested or default artifact
format. Keep the inventory and page plan private unless the user asks to see
them.

## 1. Inventory the source

Record the audience, purpose, verified facts, decisions and rationale, evidence,
caveats, unknowns, next steps, owners, and sources. Preserve substantive detail.
Do not infer facts that are absent from the source.

## 2. Plan the page

Choose a document archetype, reading order, heading hierarchy, and the smallest
set of components that makes the source easier to understand. Map every planned
component to real source material before writing HTML.

- Use the document header for title, orientation, status, and metadata, not as a
  decorative marketing hero.
- Add sticky section navigation only for a long report or roughly five or more
  substantive sections.
- Use cards only for parallel concepts and never nest them.
- Use tables only for meaningful row-and-column comparison.
- Use callouts only for actual decisions, risks, warnings, successes, or notes.
- Use timelines when chronology or sequence matters.
- Use metrics only when the source supplies real measurements.
- Use a static SVG diagram only when a relationship or process becomes clearer
  visually. Give it an accessible title and explain the same idea in nearby
  text.
- Add a sources footer only when the report uses attributable sources.
- Prefer headings, paragraphs, and lists whenever a richer component adds no
  comprehension value. Omit empty components.

## 3. Compose

Start from `assets/report-template.html`. Preserve its document skeleton, core
`data-faber-template` stylesheet, template version, and stylesheet hash. Replace
the showcase content with the planned content and components. The asset is a
component reference, not content to publish unchanged.

Use one optional `<style data-faber-template-extension>` block for a necessary
artifact-specific diagram or layout. Scope every extension selector beneath a
unique artifact class. Do not restyle the foundation globally.

## 4. Choose document or application

Choose the artifact type by its primary experience and editing contract. The
presence, amount, or complexity of JavaScript does not determine the type.

| Choose `document` | Choose `application` |
| --- | --- |
| Readable content is the durable value and a user may reasonably edit it in Faber. | Operating the interface is the durable value. |
| Interaction supports the document through tabs, filters, expandable sections, charts, maps, media playback, or a calculator within a report. | Controls, state, and computed outputs form the primary tool, simulator, configurator, workbench, command center, or standalone calculator. |
| Visible prose and structure can change without making the protected behavior misleading. | Visible content, data, and behavior must change together; editing one independently could desynchronize the experience. |

Default uncertain HTML to `document`. A large script can progressively enhance a
document, while a small script can implement an application's primary workflow.
React artifacts require `application`.

For example, Launch Atlas remains a `document` when its interactive map supports
an editable report. A report with filterable charts or expandable evidence is
also a `document`. A standalone simulator is an `application`, as is Customer
Signal Command Center because evidence selection and recomputed recommendations
are its primary experience.

Executable HTML documents remain visually editable in Faber: authored text and
structure can be changed while scripts, event handlers, controls, and other
dynamic regions stay protected. Changing protected behavior requires
republishing. Applications are content view-only; all content changes arrive as
publisher-created versions.

## 5. Validate

When interaction is necessary, use classic inline `<script>` blocks. Faber View
runs them as a normal page inside a sandboxed iframe (`allow-scripts`, no
`allow-same-origin`). There is no tag allowlist, CSS rewriter, or SES
compartment. Inline JavaScript and CSS execute with ordinary browser APIs,
including `window`, SVG `createElementNS`, canvas, `@font-face` data URLs, and
`position: fixed`.

Network access is blocked by CSP for the Faber-served document
(`connect-src 'none'`, `frame-src 'none'`, `object-src 'none'`,
`form-action 'none'`, `img-src data: blob:`, `font-src data:`). Remote scripts,
`fetch`, CDN fonts, nested frames, and form submission do not work. Persistent
storage is unavailable on the opaque origin. Do not use `location.href` or
meta-refresh to leave the canvas; that navigation can leave Faber's CSP.
`<a href="https://…">` clicks are confirmed by the parent.

For example:

```html
<button id="increment">0</button>
<script>
  const button = document.getElementById("increment");
  button.addEventListener("click", () => {
    button.textContent = String(Number(button.textContent) + 1);
  });
</script>
```

Before staging the file, confirm that:

- every substantive source item is represented or intentionally omitted;
- no result, claim, decision, metric, source, or owner was invented;
- heading order, landmarks, links, and navigation targets are valid;
- tables and diagrams remain readable on narrow screens and in print;
- classic inline JavaScript is included only when interaction materially improves the artifact;
- inline scripts and CSS run as a normal page inside Faber's sandboxed iframe;
  network requests, remote scripts and fonts, nested frames, and form submission
  stay blocked;
- all HTML, CSS, JavaScript, images, media, and data are embedded in the single file,
  with no external stylesheet, script, asset, remote font, or network request;
- bundled audio and video use `data:` or session-local `blob:` URLs and begin
  only after user interaction; remote media, autoplay, camera, and microphone
  remain blocked;
- do not use `location.href` or meta-refresh to leave the canvas; `fetch` and
  `<script src="https://…">` will not load; `<a href="https://…">` clicks are
  confirmed by the parent;
- JavaScript may use ordinary browser APIs inside the frame, including `window`.
  Persistent storage is unavailable on the opaque origin. Do not depend on a
  CDN or a browser library that requires network access;
- there are no empty decorative sections, nested cards, secrets, raw
  transcripts, or private session details; and
- the output is one regular UTF-8 HTML file within the publish limit.

## 6. Publish

Stage the validated file and call `faber_publish_artifact` according to the
content-source, workspace, metadata, and lineage requirements in `SKILL.md`.

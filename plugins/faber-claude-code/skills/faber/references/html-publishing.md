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

## 4. Validate

When interaction is necessary, use classic inline `<script>` blocks. Faber runs
them together in source order inside an isolated compartment, so top-level
declarations are shared; an uncaught error stops the remaining authored code.
Module scripts are removed. The available globals are `document`, no-op `console`,
`setTimeout`, `clearTimeout`, `setInterval`, `clearInterval`,
`requestAnimationFrame`, and `cancelAnimationFrame`.

- `document` supports `body`, `documentElement`, `addEventListener`,
  `createElement`, `createElementNS` for SVG, `createTextNode`, `getElementById`,
  `querySelector`, and `querySelectorAll`.
- Elements support `nodeType`, `tagName`, `id`, `className`, `textContent`,
  `innerHTML`, form values, `hidden`, `style`, `dataset`, `classList`,
  `parentElement`, `children`, `addEventListener`, `append`, `appendChild`,
  `closest`, `contains`, `getAttribute`, `getContext("2d")`, `matches`, queries,
  `remove`, `removeAttribute`, `replaceChildren`, `setAttribute`, and
  `setPointerCapture`. Faber-owned nodes, attributes, and selectors are hidden,
  and the root document containers cannot be removed or have their contents
  replaced. Listener options are omitted or the boolean capture flag.
- Events expose their type, target/current target, keyboard, pointer, and input
  fields plus `preventDefault` and `stopPropagation`. Canvas exposes common 2D
  path, transform, rectangle, text, fill, and stroke operations. Style accepts
  common layout, color, typography, size, visibility, and transform properties;
  external URLs and fixed positioning are rejected.

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
- classic inline JavaScript is included only when interaction materially improves the artifact
  and uses only Faber's restricted DOM, SVG, canvas, event, and timer APIs;
- ordinary inert attributes and scalar DOM properties may be used directly; privileged browser
  capabilities remain unavailable;
- all HTML, CSS, JavaScript, images, and data are embedded in the single file,
  with no external stylesheet, script, asset, remote font, or network request;
- JavaScript does not depend on ambient `window` or location globals, the network,
  external assets, persistent storage, host logging, dynamic evaluation,
  WebAssembly, or a browser library that requires those blocked capabilities;
- there are no empty decorative sections, nested cards, secrets, raw
  transcripts, or private session details; and
- the output is one regular UTF-8 HTML file within the publish limit.

## 5. Publish

Stage the validated file and call `faber_publish_artifact` according to the
content-source, workspace, metadata, and lineage requirements in `SKILL.md`.

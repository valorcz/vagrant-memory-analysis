# Theme Requirements & Migration Specification

This document details the architectural, layout, and component requirements of the **PV204 Memory Forensics** presentation deck. Use this as a prompt or specification for an AI agent or developer whenever migrating this deck to a new theme (e.g., *Editorial* or custom corporate theme).

---

## 1. Custom Layouts (Project-Level Overrides)

These layouts currently live in `slides/layouts/` and take precedence over theme defaults:

### A. `two-cols` (`layouts/two-cols.vue`)
* **Purpose**: Primary workhorse layout for 80%+ of content slides (replacing cramped cards/panels).
* **Slots Supported**:
  * Default slot `<slot />` or named slot `<slot name="left" />` $\to$ Left column.
  * Named slot `<slot name="right" />` $\to$ Right column (delimited by `::right::` in Markdown).
* **Requirements**:
  * **Header Alignment**: Strictly left-aligned title (`h2`) and kicker pill (`.kicker`), matching boardroom/technical typography standards.
  * **Top Alignment**: Content must be strictly top-aligned (`justify-content: flex-start`) with a consistent `1.25rem` margin below `.l-head`. Content must never be vertically centered, preventing text from jumping up and down across slides.
  * **Vertical Spacing**: Maintain consistent breathing room between the header block and column containers.
  * **Column Headings**: Default styling for `h3` tags inside `.col` (bold, subtle accent color or bottom border separator `border-b border-white/10`).

### B. `full` (`layouts/full.vue`)
* **Purpose**: Displays high-resolution technical diagrams (e.g., Ange Albertini's PE101 poster, x86 Paging, ARM64 Translation tables) without downscaling or padding compression.
* **Frontmatter Props**:
  * `image: /path/to/diagram.png`
  * `title: Slide Title`
  * `kicker: Category / Phase` (optional)
  * `caption: Text Description` (optional)
* **Requirements**:
  * Edge-to-edge canvas with `w-full h-full object-contain` (diagram is never cropped or distorted).
  * Floating frosted glass header overlay pinned at top-left (`bg-slate-950/85 backdrop-blur-md px-5 py-3 rounded-xl border border-white/10 shadow-2xl`).
  * Optional floating frosted glass caption pill pinned at bottom-left.

---

## 2. Upstream Theme Layouts Used by the Deck

If switching from `slidev-theme-tahta` to another theme (e.g., *Editorial*), the target theme must either support these layouts or project-level equivalents must be provided in `slides/layouts/`:

| Layout Name | Slidev Markdown Syntax | Purpose & Expected Props |
| :--- | :--- | :--- |
| **`cover`** | `layout: cover` | Hero cover slide. Uses `title`, `subtitle`, `kicker`. |
| **`agenda`** | `layout: agenda` | Course table of contents. Consumes `items: [{ topic: '...', desc: '...' }]` from frontmatter. |
| **`section`** | `layout: section` | Major chapter dividers (Sections 1–6). Consumes `index` (`01`–`06`), `kicker`, `title`, `subtitle`. |
| **`vs`** | `layout: vs` | Comparison layout (e.g., Volatility 2 vs 3, `pslist` vs `psscan`). Consumes `left: { title, items: [] }` and `right: { title, items: [] }`. |
| **`image`** | `layout: image` | Split photo/text layout. Consumes `image: /path`, `side: right \| left`, `title`. |
| **`bigtype`** | `layout: bigtype` | High-impact typographic intermission / wrap-up. Consumes `title`, `subtitle`, `kicker`, `glow: true`. Used for *Monty Python* and *Q&A* slides. |
| **`end`** | `layout: end` | Closing slide. Consumes `title`, `subtitle`, `contact`. |
| **`default`** | `layout: default` | Standard single-column slide. |

---

## 3. Dedicated Custom Components (`slides/components/`)

Slidev auto-imports components located in `slides/components/`. The following components have been extracted to eliminate raw HTML `<div>` boilerplate from `slides.md`:

### A. `<LabLauncher command="..." />` (`LabLauncher.vue`)
* **Usage**: `<LabLauncher command="exercise 1" />`
* **Purpose**: Renders the terminal launcher card on all 5 hands-on lab slides without boilerplate HTML.

### B. `<ComicCard src="..." alt="..." [maxHeight="..."] />` (`ComicCard.vue`)
* **Usage**: `<ComicCard src="/images/xkcd-update.png" alt="XKCD #1328" />`
* **Purpose**: Renders white-background images (such as XKCD comics) in a rounded, shadowed card with high contrast against dark backgrounds.

### C. `<WorkflowPhase>` and `<WorkflowStep>` (`WorkflowPhase.vue`, `WorkflowStep.vue`)
* **Usage**:
  ```html
  <WorkflowPhase name="Phase 1" title="Live Triage & Volatile Scoping" tone="sky">
    <WorkflowStep step="01" tag="IDENTIFY" tool="vol / vol3" title="Image Profile" cmd="windows.info" tone="sky">
      OS version, architecture, KDBG & capture time
    </WorkflowStep>
    ...
  </WorkflowPhase>
  ```
* **Purpose**: Modular workflow formatting components that drive responsive grid cards, top accent borders, tag colors, tool badges, and command pills while allowing markdown content/descriptions to remain directly editable in `slides.md`.

### D. `<CalloutCard tone="..." icon="...">`
* **Usage**: `<CalloutCard tone="info" icon="lucide:book-open">...</CalloutCard>`
* **Supported Tones**: `info`, `warn`, `bad`, `good`, `accent`.
* **Icons**: Any Lucide icon (`lucide:terminal`, `lucide:cpu`, `lucide:alert-triangle`, etc.).

### E. `<SectionObjectives :items="[...]" tone="..." [label="..."] />` (`SectionObjectives.vue`)
* **Usage**: `<SectionObjectives tone="sky" :items="['...']" />`
* **Purpose**: Frosted glassmorphism card aligned right on section divider slides, revealing on `v-click` with subtle check icons and bold concept headers.

### F. `<X86Translation />` (`X86Translation.vue`)
* **Usage**: `<X86Translation class="w-full" />`
* **Purpose**: Interactive x86 multi-level paging address translation pipeline. Supports clickable PDE/PTE rows, scenario presets (User Code, Injected RWX Shellcode, Swapped Page Fault #PF, Kernel Space), dynamic bitfield slicing, and physical DRAM address resolution.

---

## 4. Theme Token Inheritance & Variant Compatibility

All custom components (`LabLauncher`, `ComicCard`, `WorkflowPhase`, `WorkflowStep`) and custom layouts (`two-cols`, `full`) strictly inherit CSS variables from the active Tahta variant rather than hardcoding color literals. This guarantees compatibility with both **Dark Variants** (`editorial`, `boardroom`, `brutalist`, `atelier`, `lagoon`, `signal`) and **Light Variants** (`soft`, `minimal`, `paper`, `notebook`, `press`, `muse`, `poster`):

| Property / Purpose | Base Theme Token Consumed | Behavior Across Variants |
| :--- | :--- | :--- |
| **Canvas Background** | `var(--ink)` | Dark charcoal in `boardroom`/`editorial`; pure white/cream in `minimal`/`soft`. |
| **Card / Surface Background** | `var(--surface-bg, var(--ink-2))` | Dark card in dark variants; crisp white/clean paper in light variants. |
| **Borders & Dividers** | `var(--rule-w, 1px) solid var(--line)` | Subtle dark line in dark variants; clean hairline in light variants. |
| **Primary Text / Headings** | `var(--fg)` | Off-white text on dark backgrounds; rich charcoal/black on light backgrounds. |
| **Dimmed Text / Descriptions** | `var(--fg-dim)` | Muted silver on dark; warm accessible gray on light. |
| **Corner Radii** | `var(--radius)` / `var(--radius-sm)` | 0px (sharp Swiss) in `minimal`; 22px/14px in `soft`; 12px/8px in `editorial`. |
| **Elevations & Drop Shadows** | `var(--surface-shadow)` | High-contrast dark shadow in dark modes; soft ambient diffusion in `soft`. |
| **Adaptive Semantic Tones** | `--tone-{sky,amber,rose,...}` | Mapped in `styles/index.css` to vibrant pastels on dark, and deep high-contrast (WCAG AA) hues on light. |

## 5. Markdown Content Formatting Rules

When adding new slides or updating existing ones, adhere to these visual and pedagogical guidelines:

1. **Slide Headers**: Slide titles are defined in frontmatter (`title: "..."`). Do not use `# Title` in slide body.
2. **Column Subheaders**:
   - Use `### <strong class="text-{color}-400 font-bold">Subheader</strong>` with semantic Tailwind colors:
     - `text-sky-400` / `text-cyan-400`: Architecture, process trees, and execution state.
     - `text-emerald-400` / `text-teal-400`: Memory acquisition, tools, and legitimate structures.
     - `text-amber-400`: Injected code, warnings, and mission objectives.
     - `text-rose-400`: Rootkits, DKOM, malware mechanisms, and forensic traps.
     - `text-purple-400`: Cryptography, timeline synthesis, and advanced evasion.
3. **List Hygiene**:
   - **No top-level bullets**: Group headers use unbulleted bold leads (`**Item Title**`), followed by indented sub-bullets (`* Detailed explanation`).
   - Leave a blank line between concept groups to give breathing room.
   - Avoid numbered lists (`1.`, `2.`) on standard lecture slides to keep typography clean.
4. **Presenter Notes**: Use standard Slidev HTML comments (`<!-- ... -->`) at the bottom of slides.

---

## 6. Migration Checklist for Future AI Agents

When asked to migrate this slide deck to a new theme (e.g. *Editorial*):

1. **Verify Layout Parity**:
   - Check if the new theme has equivalents for `cover`, `agenda`, `section`, `vs`, `image`, `bigtype`, `end`.
   - If missing, copy or adapt the corresponding `.vue` files from `slidev-theme-tahta/layouts/` into `slides/layouts/`.
2. **Preserve Custom Layouts**:
   - Retain `slides/layouts/two-cols.vue` and `slides/layouts/full.vue`.
   - Update CSS tokens (fonts, colors, background styles) inside them to match the new theme.
3. **Verify Component Compatibility**:
   - Ensure `<Callout>`, `<Figure>`, and icons resolve cleanly with the new theme's icon provider.
   - Retain `slides/components/LabLauncher.vue`, `ComicCard.vue`, `WorkflowPhase.vue`, and `WorkflowStep.vue`.
4. **Validate**:
   - Run `npx tahta-lint slides.md` (or the equivalent linter).
   - Run `npm run build` and ensure exit code 0.

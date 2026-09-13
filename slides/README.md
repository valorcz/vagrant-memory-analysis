# PV204: In-Memory Malware Analysis — Slidev Deck

This directory contains the modernized, Markdown-based [Slidev](https://sli.dev/) version of the PV204 lecture slides.

---

## Getting Started

### Option 1: Quick Run with `npx` (No Install Required)
You can start the presentation immediately without creating a local `node_modules` directory:

```bash
cd slides
npx @slidev/cli slides.md --open
```

### Option 2: Using NPM Scripts
```bash
cd slides
npm install
npm run dev
```

The presentation will launch locally at `http://localhost:3030`.

---

## Features
* **Markdown Driven**: All 67 slides are maintained in [**`slides.md`**](slides.md).
* **Extracted Visual Assets**: Architectural diagrams and forensic tool screenshots are located in [`images/`](images/).
* **Presenter Mode**: Navigate to `http://localhost:3030/presenter` for speaker notes, slide previews, and timers.
* **Export to PDF / Single Page App**:
  ```bash
  npm run export   # Exports presentation to PDF
  npm run build    # Builds static HTML SPA
  ```

<script setup>
import { ref } from 'vue'

const props = defineProps({
  initialFilter: {
    type: String,
    default: 'all', // 'all' | 'procA' | 'procB' | 'fault'
  },
})

const activeFilter = ref(props.initialFilter)

function setFilter(f) {
  activeFilter.value = f
}
</script>

<template>
  <div class="logical-physical-map w-full flex flex-col items-center select-none">
    <!-- Interactive Filter Controls -->
    <div class="flex items-center gap-2 mb-1.5">
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'all' }"
        @click="setFilter('all')"
      >
        <span class="dot bg-slate-400"></span>
        Overview (All)
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'procA' }"
        @click="setFilter('procA')"
      >
        <span class="dot bg-sky-400"></span>
        Process A (Browser)
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'procB' }"
        @click="setFilter('procB')"
      >
        <span class="dot bg-purple-400"></span>
        Process B (Editor)
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'fault' }"
        @click="setFilter('fault')"
      >
        <span class="dot bg-amber-400"></span>
        Page Fault & Swap
      </button>
    </div>

    <!-- Main SVG Diagram -->
    <svg
      viewBox="0 0 960 354"
      class="w-full h-auto"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <!-- Arrowhead Markers -->
        <marker id="arr-sky" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#38bdf8" />
        </marker>
        <marker id="arr-purple" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#c084fc" />
        </marker>
        <marker id="arr-emerald" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#10b981" />
        </marker>
        <marker id="arr-amber" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#fbbf24" />
        </marker>
      </defs>

      <!-- ========================================================================= -->
      <!-- COLUMN HEADERS                                                            -->
      <!-- ========================================================================= -->
      <g transform="translate(0, 0)">
        <!-- Column 1 Header -->
        <text x="130" y="12" text-anchor="middle" class="col-title" fill="#38bdf8">1. THE VIRTUAL ILLUSION</text>
        <text x="130" y="23" text-anchor="middle" class="col-sub" fill="var(--fg-dim)">Isolated Space per Process (0x0000...)</text>

        <!-- Column 2 Header -->
        <text x="407" y="12" text-anchor="middle" class="col-title" fill="#10b981">2. TRANSLATION SWITCHBOARD</text>
        <text x="407" y="23" text-anchor="middle" class="col-sub" fill="var(--fg-dim)">Page Tables (VPN → PFN / Swap)</text>

        <!-- Column 3 Header -->
        <text x="760" y="12" text-anchor="middle" class="col-title" fill="#fbbf24">3. PHYSICAL REALITY</text>
        <text x="760" y="23" text-anchor="middle" class="col-sub" fill="var(--fg-dim)">DRAM Frames & SSD Backing Store</text>
      </g>

      <!-- ========================================================================= -->
      <!-- TIER 1: THE VIRTUAL ILLUSION (Processes)                                  -->
      <!-- ========================================================================= -->

      <!-- Process A Container (Browser) -->
      <g
        transform="translate(20, 28)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-25': activeFilter === 'procB' }"
      >
        <rect
          x="0"
          y="0"
          width="220"
          height="136"
          rx="7"
          class="svg-card"
          stroke="#38bdf8"
          stroke-width="1.5"
        />
        <!-- Header Pill -->
        <rect x="0" y="0" width="220" height="26" rx="7" fill="#38bdf8" fill-opacity="0.15" />
        <text x="10" y="18" class="proc-header" fill="#38bdf8">🌐 Process A: Browser</text>
        <text x="210" y="18" text-anchor="end" class="mono-tag" fill="var(--fg-dim)">PID 1420</text>

        <!-- Page 0: Code -->
        <g transform="translate(6, 32)">
          <rect x="0" y="0" width="208" height="28" rx="4" class="page-row" stroke="var(--line)" />
          <rect x="0" y="0" width="5" height="28" rx="2" fill="#38bdf8" />
          <text x="12" y="14" class="mono-bold" fill="#38bdf8">Page 0</text>
          <text x="12" y="23" class="mono-dim">0x0040...</text>
          <text x="200" y="18" text-anchor="end" class="text-tag" fill="var(--fg)">Engine (Code)</text>
        </g>

        <!-- Page 1: Active Tab -->
        <g transform="translate(6, 65)">
          <rect x="0" y="0" width="208" height="28" rx="4" class="page-row" stroke="var(--line)" />
          <rect x="0" y="0" width="5" height="28" rx="2" fill="#38bdf8" />
          <text x="12" y="14" class="mono-bold" fill="#38bdf8">Page 1</text>
          <text x="12" y="23" class="mono-dim">0x1000...</text>
          <text x="200" y="18" text-anchor="end" class="text-tag" fill="var(--fg)">Active Tab DOM</text>
        </g>

        <!-- Page 2: Idle Tab (Swapped) -->
        <g transform="translate(6, 98)">
          <rect x="0" y="0" width="208" height="28" rx="4" class="page-row-swap" stroke="#fbbf24" stroke-width="1" stroke-dasharray="3,2" />
          <rect x="0" y="0" width="5" height="28" rx="2" fill="#fbbf24" />
          <text x="12" y="14" class="mono-bold" fill="#fbbf24">Page 2</text>
          <text x="12" y="23" class="mono-dim">0x2000...</text>
          <text x="200" y="18" text-anchor="end" class="text-tag text-amber" fill="#fbbf24">Idle Tab (Cold)</text>
        </g>
      </g>

      <!-- Process B Container (Text Editor) -->
      <g
        transform="translate(20, 172)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-25': activeFilter === 'procA' }"
      >
        <rect
          x="0"
          y="0"
          width="220"
          height="136"
          rx="7"
          class="svg-card"
          stroke="#c084fc"
          stroke-width="1.5"
        />
        <!-- Header Pill -->
        <rect x="0" y="0" width="220" height="26" rx="7" fill="#c084fc" fill-opacity="0.15" />
        <text x="10" y="18" class="proc-header" fill="#c084fc">📝 Process B: Editor</text>
        <text x="210" y="18" text-anchor="end" class="mono-tag" fill="var(--fg-dim)">PID 2894</text>

        <!-- Page 0: Code (Same address as Process A!) -->
        <g transform="translate(6, 32)">
          <rect x="0" y="0" width="208" height="28" rx="4" class="page-row" stroke="var(--line)" />
          <rect x="0" y="0" width="5" height="28" rx="2" fill="#c084fc" />
          <text x="12" y="14" class="mono-bold" fill="#c084fc">Page 0</text>
          <text x="12" y="23" class="mono-dim">0x0040...</text>
          <text x="200" y="18" text-anchor="end" class="text-tag" fill="var(--fg)">Editor Binary</text>
        </g>

        <!-- Page 1: Document Buffer -->
        <g transform="translate(6, 65)">
          <rect x="0" y="0" width="208" height="28" rx="4" class="page-row" stroke="var(--line)" />
          <rect x="0" y="0" width="5" height="28" rx="2" fill="#c084fc" />
          <text x="12" y="14" class="mono-bold" fill="#c084fc">Page 1</text>
          <text x="12" y="23" class="mono-dim">0x1000...</text>
          <text x="200" y="18" text-anchor="end" class="text-tag" fill="var(--fg)">Doc Buffer</text>
        </g>

        <!-- Page 2: Undo History (Swapped) -->
        <g transform="translate(6, 98)">
          <rect x="0" y="0" width="208" height="28" rx="4" class="page-row-swap" stroke="#fbbf24" stroke-width="1" stroke-dasharray="3,2" />
          <rect x="0" y="0" width="5" height="28" rx="2" fill="#fbbf24" />
          <text x="12" y="14" class="mono-bold" fill="#fbbf24">Page 2</text>
          <text x="12" y="23" class="mono-dim">0x2000...</text>
          <text x="200" y="18" text-anchor="end" class="text-tag text-amber" fill="#fbbf24">Undo Log (Cold)</text>
        </g>
      </g>

      <!-- ========================================================================= -->
      <!-- TIER 2: TRANSLATION SWITCHBOARD (Page Tables)                             -->
      <!-- ========================================================================= -->

      <!-- Process A Page Table -->
      <g
        transform="translate(268, 28)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-25': activeFilter === 'procB' }"
      >
        <rect
          x="0"
          y="0"
          width="278"
          height="136"
          rx="7"
          class="svg-card"
          stroke="var(--line)"
          stroke-width="1.5"
        />
        <rect x="0" y="0" width="278" height="26" rx="7" fill="#10b981" fill-opacity="0.12" />
        <text x="10" y="18" class="table-header" fill="#10b981">Page Table A (CR3_A)</text>
        <text x="268" y="18" text-anchor="end" class="mono-tag" fill="var(--fg-dim)">VPN → PFN</text>

        <!-- Entry 0: Page 0 -> Frame 3 -->
        <g transform="translate(6, 32)">
          <rect x="0" y="0" width="266" height="28" rx="4" class="entry-row" />
          <text x="10" y="19" class="mono-sm" fill="var(--fg)">VPN [0]</text>
          <path d="M 68 14 L 88 14" stroke="var(--line)" stroke-width="1.5" />
          <text x="96" y="19" class="mono-sm-bold" fill="#38bdf8">Frame 3</text>
          <!-- Valid Badge -->
          <rect x="194" y="5" width="64" height="18" rx="4" fill="#10b981" fill-opacity="0.2" stroke="#10b981" stroke-width="1" />
          <text x="226" y="18" text-anchor="middle" class="badge-text" fill="#10b981">RAM (V=1)</text>
        </g>

        <!-- Entry 1: Page 1 -> Frame 7 -->
        <g transform="translate(6, 65)">
          <rect x="0" y="0" width="266" height="28" rx="4" class="entry-row" />
          <text x="10" y="19" class="mono-sm" fill="var(--fg)">VPN [1]</text>
          <path d="M 68 14 L 88 14" stroke="var(--line)" stroke-width="1.5" />
          <text x="96" y="19" class="mono-sm-bold" fill="#38bdf8">Frame 7</text>
          <!-- Valid Badge -->
          <rect x="194" y="5" width="64" height="18" rx="4" fill="#10b981" fill-opacity="0.2" stroke="#10b981" stroke-width="1" />
          <text x="226" y="18" text-anchor="middle" class="badge-text" fill="#10b981">RAM (V=1)</text>
        </g>

        <!-- Entry 2: Page 2 -> Disk Slot 1 (Invalid / Swapped) -->
        <g transform="translate(6, 98)">
          <rect x="0" y="0" width="266" height="28" rx="4" class="entry-row" />
          <text x="10" y="19" class="mono-sm" fill="var(--fg)">VPN [2]</text>
          <path d="M 68 14 L 88 14" stroke="var(--line)" stroke-width="1.5" />
          <text x="96" y="19" class="mono-sm-bold" fill="#fbbf24">Swap #1</text>
          <!-- Invalid Badge -->
          <rect x="190" y="5" width="68" height="18" rx="4" fill="#fbbf24" fill-opacity="0.2" stroke="#fbbf24" stroke-width="1" />
          <text x="224" y="18" text-anchor="middle" class="badge-text" fill="#fbbf24">DISK (V=0)</text>
        </g>
      </g>

      <!-- Process B Page Table -->
      <g
        transform="translate(268, 172)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-25': activeFilter === 'procA' }"
      >
        <rect
          x="0"
          y="0"
          width="278"
          height="136"
          rx="7"
          class="svg-card"
          stroke="var(--line)"
          stroke-width="1.5"
        />
        <rect x="0" y="0" width="278" height="26" rx="7" fill="#10b981" fill-opacity="0.12" />
        <text x="10" y="18" class="table-header" fill="#10b981">Page Table B (CR3_B)</text>
        <text x="268" y="18" text-anchor="end" class="mono-tag" fill="var(--fg-dim)">VPN → PFN</text>

        <!-- Entry 0: Page 0 -> Frame 1 -->
        <g transform="translate(6, 32)">
          <rect x="0" y="0" width="266" height="28" rx="4" class="entry-row" />
          <text x="10" y="19" class="mono-sm" fill="var(--fg)">VPN [0]</text>
          <path d="M 68 14 L 88 14" stroke="var(--line)" stroke-width="1.5" />
          <text x="96" y="19" class="mono-sm-bold" fill="#c084fc">Frame 1</text>
          <!-- Valid Badge -->
          <rect x="194" y="5" width="64" height="18" rx="4" fill="#10b981" fill-opacity="0.2" stroke="#10b981" stroke-width="1" />
          <text x="226" y="18" text-anchor="middle" class="badge-text" fill="#10b981">RAM (V=1)</text>
        </g>

        <!-- Entry 1: Page 1 -> Frame 5 -->
        <g transform="translate(6, 65)">
          <rect x="0" y="0" width="266" height="28" rx="4" class="entry-row" />
          <text x="10" y="19" class="mono-sm" fill="var(--fg)">VPN [1]</text>
          <path d="M 68 14 L 88 14" stroke="var(--line)" stroke-width="1.5" />
          <text x="96" y="19" class="mono-sm-bold" fill="#c084fc">Frame 5</text>
          <!-- Valid Badge -->
          <rect x="194" y="5" width="64" height="18" rx="4" fill="#10b981" fill-opacity="0.2" stroke="#10b981" stroke-width="1" />
          <text x="226" y="18" text-anchor="middle" class="badge-text" fill="#10b981">RAM (V=1)</text>
        </g>

        <!-- Entry 2: Page 2 -> Disk Slot 2 (Invalid / Swapped) -->
        <g transform="translate(6, 98)">
          <rect x="0" y="0" width="266" height="28" rx="4" class="entry-row" />
          <text x="10" y="19" class="mono-sm" fill="var(--fg)">VPN [2]</text>
          <path d="M 68 14 L 88 14" stroke="var(--line)" stroke-width="1.5" />
          <text x="96" y="19" class="mono-sm-bold" fill="#fbbf24">Swap #2</text>
          <!-- Invalid Badge -->
          <rect x="190" y="5" width="68" height="18" rx="4" fill="#fbbf24" fill-opacity="0.2" stroke="#fbbf24" stroke-width="1" />
          <text x="224" y="18" text-anchor="middle" class="badge-text" fill="#fbbf24">DISK (V=0)</text>
        </g>
      </g>

      <!-- ========================================================================= -->
      <!-- CONNECTOR PATHS: TIER 1 -> TIER 2                                         -->
      <!-- ========================================================================= -->
      <g class="transition-opacity duration-300">
        <!-- Process A lines -->
        <g :class="{ 'opacity-25': activeFilter === 'procB' }">
          <line x1="240" y1="74" x2="268" y2="74" stroke="#38bdf8" stroke-width="1.5" marker-end="url(#arr-sky)" />
          <line x1="240" y1="107" x2="268" y2="107" stroke="#38bdf8" stroke-width="1.5" marker-end="url(#arr-sky)" />
          <line x1="240" y1="140" x2="268" y2="140" stroke="#fbbf24" stroke-width="1.5" stroke-dasharray="3,2" marker-end="url(#arr-amber)" />
        </g>

        <!-- Process B lines -->
        <g :class="{ 'opacity-25': activeFilter === 'procA' }">
          <line x1="240" y1="218" x2="268" y2="218" stroke="#c084fc" stroke-width="1.5" marker-end="url(#arr-purple)" />
          <line x1="240" y1="251" x2="268" y2="251" stroke="#c084fc" stroke-width="1.5" marker-end="url(#arr-purple)" />
          <line x1="240" y1="284" x2="268" y2="284" stroke="#fbbf24" stroke-width="1.5" stroke-dasharray="3,2" marker-end="url(#arr-amber)" />
        </g>
      </g>

      <!-- ========================================================================= -->
      <!-- TIER 3: PHYSICAL HARDWARE (DRAM & SSD SWAP)                               -->
      <!-- ========================================================================= -->

      <!-- Hardware Box 1: Physical DRAM -->
      <g transform="translate(580, 28)">
        <rect
          x="0"
          y="0"
          width="360"
          height="156"
          rx="7"
          class="svg-card"
          stroke="var(--line)"
          stroke-width="1.5"
        />
        <!-- Header -->
        <rect x="0" y="0" width="360" height="26" rx="7" fill="var(--fg)" fill-opacity="0.06" />
        <text x="10" y="18" class="hardware-header" fill="var(--fg)">⚡ Physical RAM (High-Speed DRAM)</text>
        <text x="350" y="18" text-anchor="end" class="mono-tag text-emerald" fill="#10b981">Interleaved</text>

        <!-- DRAM Frames Rack (6 slots) -->
        <!-- Col 1 (Frames 0, 1, 3) -->
        <g transform="translate(8, 32)">
          <rect x="0" y="0" width="168" height="34" rx="4" fill="var(--line)" fill-opacity="0.3" stroke="var(--line)" />
          <text x="8" y="15" class="mono-bold" fill="var(--fg-dim)">Frame 0</text>
          <text x="8" y="27" class="sub-xs" fill="var(--fg-dim)">OS Kernel / Drivers</text>
        </g>

        <g
          transform="translate(8, 72)"
          class="transition-opacity duration-300"
          :class="{ 'opacity-25': activeFilter === 'procA' }"
        >
          <rect x="0" y="0" width="168" height="34" rx="4" fill="#c084fc" fill-opacity="0.16" stroke="#c084fc" stroke-width="1.5" />
          <text x="8" y="15" class="mono-bold" fill="#c084fc">Frame 1</text>
          <text x="8" y="27" class="sub-xs" fill="var(--fg)">B: Editor Binary</text>
        </g>

        <g
          transform="translate(8, 112)"
          class="transition-opacity duration-300"
          :class="{ 'opacity-25': activeFilter === 'procB' }"
        >
          <rect x="0" y="0" width="168" height="34" rx="4" fill="#38bdf8" fill-opacity="0.16" stroke="#38bdf8" stroke-width="1.5" />
          <text x="8" y="15" class="mono-bold" fill="#38bdf8">Frame 3</text>
          <text x="8" y="27" class="sub-xs" fill="var(--fg)">A: Browser Engine</text>
        </g>

        <!-- Col 2 (Frames 5, 6, 7) -->
        <g
          transform="translate(184, 32)"
          class="transition-opacity duration-300"
          :class="{ 'opacity-25': activeFilter === 'procA' }"
        >
          <rect x="0" y="0" width="168" height="34" rx="4" fill="#c084fc" fill-opacity="0.16" stroke="#c084fc" stroke-width="1.5" />
          <text x="8" y="15" class="mono-bold" fill="#c084fc">Frame 5</text>
          <text x="8" y="27" class="sub-xs" fill="var(--fg)">B: Doc Buffer</text>
        </g>

        <g
          transform="translate(184, 72)"
          class="transition-opacity duration-300"
          :class="{ 'pulse-ring': activeFilter === 'fault' }"
        >
          <rect x="0" y="0" width="168" height="34" rx="4" class="free-frame" stroke="#10b981" stroke-width="1.5" stroke-dasharray="4,2" />
          <text x="8" y="15" class="mono-bold" fill="#10b981">Frame 6 [Free]</text>
          <text x="8" y="27" class="sub-xs" fill="#10b981">Target for Page Fault</text>
        </g>

        <g
          transform="translate(184, 112)"
          class="transition-opacity duration-300"
          :class="{ 'opacity-25': activeFilter === 'procB' }"
        >
          <rect x="0" y="0" width="168" height="34" rx="4" fill="#38bdf8" fill-opacity="0.16" stroke="#38bdf8" stroke-width="1.5" />
          <text x="8" y="15" class="mono-bold" fill="#38bdf8">Frame 7</text>
          <text x="8" y="27" class="sub-xs" fill="var(--fg)">A: Active Tab DOM</text>
        </g>
      </g>

      <!-- Hardware Box 2: Swap / Pagefile on SSD -->
      <g transform="translate(580, 194)">
        <rect
          x="0"
          y="0"
          width="360"
          height="114"
          rx="7"
          class="svg-card"
          stroke="#fbbf24"
          stroke-width="1.5"
        />
        <!-- Header -->
        <rect x="0" y="0" width="360" height="26" rx="7" fill="#fbbf24" fill-opacity="0.12" />
        <text x="10" y="18" class="hardware-header" fill="#fbbf24">💾 Swap / Pagefile (SSD / Disk Backing Store)</text>
        <text x="350" y="18" text-anchor="end" class="mono-tag text-amber" fill="#fbbf24">Cold Pages</text>

        <!-- Slot 1: A's Idle Tab -->
        <g
          transform="translate(8, 32)"
          class="transition-opacity duration-300"
          :class="{ 'opacity-25': activeFilter === 'procB' }"
        >
          <rect x="0" y="0" width="168" height="32" rx="4" fill="#fbbf24" fill-opacity="0.14" stroke="#fbbf24" stroke-width="1" />
          <text x="8" y="14" class="mono-bold" fill="#fbbf24">Swap Slot #1</text>
          <text x="8" y="26" class="sub-xs" fill="var(--fg)">A: Idle Tab (Swapped)</text>
        </g>

        <!-- Slot 2: B's Undo History -->
        <g
          transform="translate(184, 32)"
          class="transition-opacity duration-300"
          :class="{ 'opacity-25': activeFilter === 'procA' }"
        >
          <rect x="0" y="0" width="168" height="32" rx="4" fill="#fbbf24" fill-opacity="0.14" stroke="#fbbf24" stroke-width="1" />
          <text x="8" y="14" class="mono-bold" fill="#fbbf24">Swap Slot #2</text>
          <text x="8" y="26" class="sub-xs" fill="var(--fg)">B: Undo Log (Swapped)</text>
        </g>

        <!-- Page Fault Banner inside Box -->
        <g transform="translate(8, 70)">
          <rect x="0" y="0" width="344" height="34" rx="5" fill="var(--line)" fill-opacity="0.25" stroke="var(--line)" />
          <text x="10" y="15" class="mono-bold-xs" fill="#fbbf24">⚡ PAGE FAULT LIFECYCLE:</text>
          <text x="10" y="27" class="sub-xs" fill="var(--fg)">
            Accessing V=0 triggers #PF → OS fetches SSD block → loads into Frame 6 → resumes
          </text>
        </g>
      </g>

      <!-- ========================================================================= -->
      <!-- CONNECTOR PATHS: TIER 2 -> TIER 3                                         -->
      <!-- ========================================================================= -->
      <g class="transition-opacity duration-300">
        <!-- Table A Entry 0 (Frame 3) -->
        <path
          d="M 546 74 C 560 74, 565 156, 588 156"
          fill="none"
          stroke="#38bdf8"
          stroke-width="1.8"
          marker-end="url(#arr-sky)"
          :class="{ 'opacity-25': activeFilter === 'procB' || activeFilter === 'fault' }"
        />

        <!-- Table A Entry 1 (Frame 7) -->
        <path
          d="M 546 107 C 650 107, 680 156, 764 156"
          fill="none"
          stroke="#38bdf8"
          stroke-width="1.8"
          marker-end="url(#arr-sky)"
          :class="{ 'opacity-25': activeFilter === 'procB' || activeFilter === 'fault' }"
        />

        <!-- Table A Entry 2 (Swap #1) -->
        <path
          d="M 546 140 C 560 140, 560 242, 588 242"
          fill="none"
          stroke="#fbbf24"
          stroke-width="1.8"
          stroke-dasharray="3,2"
          marker-end="url(#arr-amber)"
          :class="{ 'opacity-25': activeFilter === 'procB' }"
        />

        <!-- Table B Entry 0 (Frame 1) -->
        <path
          d="M 546 218 C 565 218, 565 116, 588 116"
          fill="none"
          stroke="#c084fc"
          stroke-width="1.8"
          marker-end="url(#arr-purple)"
          :class="{ 'opacity-25': activeFilter === 'procA' || activeFilter === 'fault' }"
        />

        <!-- Table B Entry 1 (Frame 5) -->
        <path
          d="M 546 251 C 640 251, 660 76, 764 76"
          fill="none"
          stroke="#c084fc"
          stroke-width="1.8"
          marker-end="url(#arr-purple)"
          :class="{ 'opacity-25': activeFilter === 'procA' || activeFilter === 'fault' }"
        />

        <!-- Table B Entry 2 (Swap #2) -->
        <path
          d="M 546 284 C 650 284, 680 242, 764 242"
          fill="none"
          stroke="#fbbf24"
          stroke-width="1.8"
          stroke-dasharray="3,2"
          marker-end="url(#arr-amber)"
          :class="{ 'opacity-25': activeFilter === 'procA' }"
        />

        <!-- PAGE FAULT FETCH CURVE (From Swap Slot 1 -> Frame 6 in DRAM) -->
        <path
          d="M 670 230 C 690 195, 720 155, 764 116"
          fill="none"
          stroke="#10b981"
          stroke-width="2.5"
          stroke-dasharray="5,3"
          marker-end="url(#arr-emerald)"
          class="fault-curve transition-opacity duration-300"
          :class="{ 'opacity-25': activeFilter === 'procA' || activeFilter === 'procB' }"
        />
      </g>

      <!-- ========================================================================= -->
      <!-- BOTTOM SUMMARY PILLARS (Key Architectural Takeaways)                      -->
      <!-- ========================================================================= -->
      <g transform="translate(20, 318)">
        <rect
          x="0"
          y="0"
          width="920"
          height="30"
          rx="6"
          class="summary-card"
          stroke="var(--line)"
          stroke-width="1.2"
        />

        <!-- Pillar 1: Isolation -->
        <text x="30" y="19" class="summary-title" fill="#38bdf8">1. Isolation</text>
        <text x="110" y="19" class="summary-desc" fill="var(--fg-dim)">Processes cannot touch or peek at each other's memory</text>

        <!-- Divider 1 -->
        <line x1="385" y1="6" x2="385" y2="24" stroke="var(--line)" />

        <!-- Pillar 2: Non-Contiguous -->
        <text x="405" y="19" class="summary-title" fill="#10b981">2. Scatter-Gather</text>
        <text x="515" y="19" class="summary-desc" fill="var(--fg-dim)">No need for contiguous physical blocks</text>

        <!-- Divider 2 -->
        <line x1="725" y1="6" x2="725" y2="24" stroke="var(--line)" />

        <!-- Pillar 3: Overcommit -->
        <text x="745" y="19" class="summary-title" fill="#fbbf24">3. Overcommit</text>
        <text x="825" y="19" class="summary-desc" fill="var(--fg-dim)">Total virtual memory > RAM</text>
      </g>
    </svg>
  </div>
</template>

<style scoped>
.logical-physical-map {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
}

.ctrl-btn {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 2px 10px;
  border-radius: 6px;
  font-size: 10.5px;
  font-weight: 600;
  border: 1px solid var(--line);
  background: var(--surface-bg, var(--ink-2));
  color: var(--fg-dim);
  cursor: pointer;
  transition: all 0.2s ease;
}

.ctrl-btn:hover {
  background: var(--line);
  color: var(--fg);
}

.ctrl-btn.active {
  border-color: #38bdf8;
  background: rgba(56, 189, 248, 0.12);
  color: var(--fg);
}

.dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

.svg-card {
  fill: var(--surface-bg, var(--ink-2));
  transition: fill 0.2s ease, stroke 0.2s ease;
}

.page-row {
  fill: var(--surface-bg, rgba(255, 255, 255, 0.03));
}

.page-row-swap {
  fill: rgba(251, 191, 36, 0.06);
}

.entry-row {
  fill: var(--surface-bg, rgba(255, 255, 255, 0.02));
}

.free-frame {
  fill: rgba(16, 185, 129, 0.06);
}

.summary-card {
  fill: var(--surface-bg, var(--ink-2));
}

.col-title {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 10.5px;
  font-weight: 800;
  letter-spacing: 0.08em;
}

.col-sub {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 9px;
}

.proc-header {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 11px;
  font-weight: 700;
}

.table-header {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 11px;
  font-weight: 700;
}

.hardware-header {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 11px;
  font-weight: 700;
}

.mono-tag {
  font-size: 9px;
  font-weight: 600;
}

.mono-bold {
  font-size: 10px;
  font-weight: 700;
}

.mono-bold-xs {
  font-size: 9px;
  font-weight: 700;
}

.mono-dim {
  font-size: 8px;
  fill: var(--fg-dim);
}

.mono-sm {
  font-size: 9.5px;
}

.mono-sm-bold {
  font-size: 10px;
  font-weight: 700;
}

.text-tag {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 10px;
  font-weight: 600;
}

.badge-text {
  font-size: 8px;
  font-weight: 700;
}

.sub-xs {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 9px;
}

.summary-title {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 10.5px;
  font-weight: 800;
}

.summary-desc {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 9.5px;
}

.fault-curve {
  animation: dash 25s linear infinite;
}

@keyframes dash {
  to {
    stroke-dashoffset: -1000;
  }
}

/* Light Variant Adjustments */
:root[data-variant='soft'] .svg-card,
:root[data-variant='soft'] .summary-card {
  fill: #ffffff;
}

:root[data-variant='soft'] .ctrl-btn {
  background: #ffffff;
}
</style>

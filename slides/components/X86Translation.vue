<script setup>
</script>

<template>
  <div class="x86-translation-wrapper w-full flex flex-col items-center select-none">
    <svg
      viewBox="0 0 960 385"
      class="w-full h-auto"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <!-- Arrowhead Markers -->
        <marker id="arrow-sky" markerWidth="8" markerHeight="8" refX="6" refY="4" orient="auto">
          <path d="M 0 0 L 8 4 L 0 8 z" fill="#38bdf8" />
        </marker>
        <marker id="arrow-purple" markerWidth="8" markerHeight="8" refX="6" refY="4" orient="auto">
          <path d="M 0 0 L 8 4 L 0 8 z" fill="#c084fc" />
        </marker>
        <marker id="arrow-amber" markerWidth="8" markerHeight="8" refX="6" refY="4" orient="auto">
          <path d="M 0 0 L 8 4 L 0 8 z" fill="#fbbf24" />
        </marker>
        <marker id="arrow-rose" markerWidth="8" markerHeight="8" refX="6" refY="4" orient="auto">
          <path d="M 0 0 L 8 4 L 0 8 z" fill="#f43f5e" />
        </marker>
        <marker id="arrow-emerald" markerWidth="8" markerHeight="8" refX="6" refY="4" orient="auto">
          <path d="M 0 0 L 8 4 L 0 8 z" fill="#10b981" />
        </marker>

        <!-- Subtle Glow Filters -->
        <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
          <feGaussianBlur stdDeviation="3" result="blur" />
          <feComposite in="SourceGraphic" in2="blur" operator="over" />
        </filter>
      </defs>

      <!-- ========================================================================= -->
      <!-- TOP: 32-bit Linear Virtual Address Divided into 3 Functional Keys         -->
      <!-- ========================================================================= -->
      <g transform="translate(180, 16)">
        <!-- Container Pill -->
        <rect
          x="0"
          y="0"
          width="600"
          height="54"
          rx="10"
          class="svg-card"
          stroke="var(--line)"
          stroke-width="1.5"
        />

        <!-- Field 1: Directory Index (10 bits) -->
        <rect x="3" y="3" width="190" height="48" rx="8" fill="#38bdf8" fill-opacity="0.14" stroke="#38bdf8" stroke-width="1.5" />
        <text x="98" y="23" text-anchor="middle" class="svg-title-sm" fill="#38bdf8">Directory Index</text>
        <text x="98" y="41" text-anchor="middle" class="svg-mono-sm" fill="var(--fg-dim)">Bits 31..22 (10 bits)</text>

        <!-- Field 2: Table Index (10 bits) -->
        <rect x="199" y="3" width="190" height="48" rx="8" fill="#c084fc" fill-opacity="0.14" stroke="#c084fc" stroke-width="1.5" />
        <text x="294" y="23" text-anchor="middle" class="svg-title-sm" fill="#c084fc">Table Index</text>
        <text x="294" y="41" text-anchor="middle" class="svg-mono-sm" fill="var(--fg-dim)">Bits 21..12 (10 bits)</text>

        <!-- Field 3: Byte Offset (12 bits) -->
        <rect x="395" y="3" width="202" height="48" rx="8" fill="#fbbf24" fill-opacity="0.14" stroke="#fbbf24" stroke-width="1.5" />
        <text x="496" y="23" text-anchor="middle" class="svg-title-sm" fill="#fbbf24">Byte Offset</text>
        <text x="496" y="41" text-anchor="middle" class="svg-mono-sm" fill="var(--fg-dim)">Bits 11..0 (4 KB Page)</text>
      </g>

      <!-- Top Title Tag -->
      <text x="480" y="8" text-anchor="middle" class="svg-badge" fill="var(--fg-dim)">32-BIT LINEAR VIRTUAL ADDRESS</text>

      <!-- ========================================================================= -->
      <!-- STEP 1: CR3 Register (Hardware Root Pointer)                              -->
      <!-- ========================================================================= -->
      <g transform="translate(20, 210)">
        <!-- Step 1 Badge -->
        <circle cx="20" cy="-14" r="12" fill="#f43f5e" />
        <text x="20" y="-10" text-anchor="middle" font-size="11" font-weight="bold" fill="#ffffff">1</text>
        <text x="40" y="-10" class="svg-step-title" fill="#f43f5e">CPU Root</text>

        <!-- CR3 Card -->
        <rect x="0" y="4" width="120" height="66" rx="8" class="svg-card" stroke="#f43f5e" stroke-width="1.5" />
        <text x="60" y="28" text-anchor="middle" class="svg-mono-bold text-sm" fill="#f43f5e">CR3 Register</text>
        <text x="60" y="46" text-anchor="middle" class="svg-mono-xs" fill="var(--fg)">DirectoryBase</text>
        <text x="60" y="60" text-anchor="middle" class="svg-sub-xs" fill="var(--fg-dim)">Physical PFN root</text>

        <!-- Arrow: CR3 -> Page Directory Base -->
        <path
          d="M 120 37 L 172 37"
          stroke="#f43f5e"
          stroke-width="2.5"
          marker-end="url(#arrow-rose)"
        />
      </g>

      <!-- ========================================================================= -->
      <!-- STEP 2: Page Directory (1024 PDEs)                                        -->
      <!-- ========================================================================= -->
      <g transform="translate(180, 115)">
        <!-- Step 2 Badge -->
        <circle cx="20" cy="-10" r="12" fill="#38bdf8" />
        <text x="20" y="-6" text-anchor="middle" font-size="11" font-weight="bold" fill="#ffffff">2</text>
        <text x="40" y="-6" class="svg-step-title" fill="#38bdf8">Page Directory (PD)</text>

        <!-- Table Outer Frame (4KB, 1024 entries) -->
        <rect x="0" y="8" width="160" height="240" rx="8" class="svg-card" stroke="var(--line)" stroke-width="1.5" />

        <!-- Table Rows Mockup -->
        <g class="svg-table-lines" stroke="var(--line)" stroke-width="1">
          <line x1="0" y1="40" x2="160" y2="40" />
          <line x1="0" y1="72" x2="160" y2="72" />
          <line x1="0" y1="130" x2="160" y2="130" />
          <line x1="0" y1="162" x2="160" y2="162" />
          <line x1="0" y1="216" x2="160" y2="216" />
        </g>

        <!-- Row labels -->
        <text x="12" y="28" class="svg-mono-xs" fill="var(--fg-dim)">PDE 1023</text>
        <text x="12" y="59" class="svg-mono-xs" fill="var(--fg-dim)">PDE ...</text>

        <!-- Highlighted PDE Selected by Directory Index -->
        <rect
          x="2"
          y="73"
          width="156"
          height="56"
          rx="5"
          fill="#38bdf8"
          fill-opacity="0.18"
          stroke="#38bdf8"
          stroke-width="2"
          filter="url(#glow)"
        />
        <text x="10" y="93" class="svg-mono-bold text-xs" fill="#38bdf8">Selected PDE</text>
        <text x="10" y="109" class="svg-mono-xs" fill="var(--fg)">PT Base: 0x1A400</text>
        <text x="10" y="122" class="svg-sub-xs" fill="#38bdf8">Flags: Present, R/W</text>

        <text x="12" y="150" class="svg-mono-xs" fill="var(--fg-dim)">PDE 1</text>
        <text x="12" y="180" class="svg-mono-xs" fill="var(--fg-dim)">PDE 0</text>
        <text x="80" y="233" text-anchor="middle" class="svg-sub-xs" fill="var(--fg-dim)">1024 entries × 4B = 4KB</text>

        <!-- Guide Curve from Top Directory Index into this Highlighted PDE -->
        <path
          d="M 98 -45 C 98 -15, 98 10, 150 73"
          stroke="#38bdf8"
          stroke-width="2"
          stroke-dasharray="4 3"
          marker-end="url(#arrow-sky)"
        />

        <!-- Arrow: Selected PDE -> Page Table Base -->
        <path
          d="M 160 101 L 222 101"
          stroke="#38bdf8"
          stroke-width="2.5"
          marker-end="url(#arrow-sky)"
        />
      </g>

      <!-- ========================================================================= -->
      <!-- STEP 3: Page Table (1024 PTEs)                                            -->
      <!-- ========================================================================= -->
      <g transform="translate(410, 115)">
        <!-- Step 3 Badge -->
        <circle cx="20" cy="-10" r="12" fill="#c084fc" />
        <text x="20" y="-6" text-anchor="middle" font-size="11" font-weight="bold" fill="#ffffff">3</text>
        <text x="40" y="-6" class="svg-step-title" fill="#c084fc">Page Table (PT)</text>

        <!-- Table Outer Frame (4KB, 1024 entries) -->
        <rect x="0" y="8" width="160" height="240" rx="8" class="svg-card" stroke="var(--line)" stroke-width="1.5" />

        <!-- Table Rows Mockup -->
        <g class="svg-table-lines" stroke="var(--line)" stroke-width="1">
          <line x1="0" y1="40" x2="160" y2="40" />
          <line x1="0" y1="92" x2="160" y2="92" />
          <line x1="0" y1="124" x2="160" y2="124" />
          <line x1="0" y1="182" x2="160" y2="182" />
          <line x1="0" y1="216" x2="160" y2="216" />
        </g>

        <!-- Row labels -->
        <text x="12" y="28" class="svg-mono-xs" fill="var(--fg-dim)">PTE 1023</text>
        <text x="12" y="70" class="svg-mono-xs" fill="var(--fg-dim)">PTE ...</text>

        <!-- Highlighted PTE Selected by Table Index -->
        <rect
          x="2"
          y="125"
          width="156"
          height="56"
          rx="5"
          fill="#c084fc"
          fill-opacity="0.18"
          stroke="#c084fc"
          stroke-width="2"
          filter="url(#glow)"
        />
        <text x="10" y="145" class="svg-mono-bold text-xs" fill="#c084fc">Selected PTE</text>
        <text x="10" y="161" class="svg-mono-xs" fill="var(--fg)">Frame: 0x05B20</text>
        <text x="10" y="174" class="svg-sub-xs" fill="#c084fc">Flags: Present, Dirty</text>

        <text x="12" y="202" class="svg-mono-xs" fill="var(--fg-dim)">PTE 0</text>
        <text x="80" y="233" text-anchor="middle" class="svg-sub-xs" fill="var(--fg-dim)">1024 entries × 4B = 4KB</text>

        <!-- Guide Curve from Top Table Index into this Highlighted PTE -->
        <path
          d="M 64 -45 C 64 0, 100 60, 150 125"
          stroke="#c084fc"
          stroke-width="2"
          stroke-dasharray="4 3"
          marker-end="url(#arrow-purple)"
        />

        <!-- Arrow: Selected PTE (PFN) -> Physical Address Assembly -->
        <path
          d="M 160 153 L 222 153"
          stroke="#c084fc"
          stroke-width="2.5"
          marker-end="url(#arrow-purple)"
        />
      </g>

      <!-- ========================================================================= -->
      <!-- STEP 4: Physical Address Assembly & Target DRAM Frame                     -->
      <!-- ========================================================================= -->
      <g transform="translate(640, 115)">
        <!-- Step 4 Badge -->
        <circle cx="20" cy="-10" r="12" fill="#10b981" />
        <text x="20" y="-6" text-anchor="middle" font-size="11" font-weight="bold" fill="#ffffff">4</text>
        <text x="40" y="-6" class="svg-step-title" fill="#10b981">Physical DRAM Translation</text>

        <!-- Assembled Physical Address Bar -->
        <g transform="translate(0, 15)">
          <rect x="0" y="0" width="300" height="52" rx="8" class="svg-card" stroke="#10b981" stroke-width="1.5" />
          
          <!-- PFN Component (from PTE) -->
          <rect x="3" y="3" width="170" height="46" rx="6" fill="#c084fc" fill-opacity="0.15" stroke="#c084fc" stroke-width="1" />
          <text x="88" y="22" text-anchor="middle" class="svg-mono-bold text-xs" fill="#c084fc">PFN (20 bits)</text>
          <text x="88" y="38" text-anchor="middle" class="svg-mono-xs" fill="var(--fg)">Frame # 0x05B20</text>

          <!-- Offset Component (Glued from original address) -->
          <rect x="176" y="3" width="121" height="46" rx="6" fill="#fbbf24" fill-opacity="0.15" stroke="#fbbf24" stroke-width="1" />
          <text x="236" y="22" text-anchor="middle" class="svg-mono-bold text-xs" fill="#fbbf24">Offset (12 bits)</text>
          <text x="236" y="38" text-anchor="middle" class="svg-mono-xs" fill="var(--fg)">+ 0x0A4</text>
        </g>

        <!-- Long Offset Wire from Top Bar into this Assembled Address -->
        <path
          d="M 36 -45 C 120 -20, 236 0, 236 12"
          stroke="#fbbf24"
          stroke-width="2.5"
          marker-end="url(#arrow-amber)"
        />

        <!-- Down Arrow: Assembled Address -> Exact DRAM Byte -->
        <path
          d="M 150 72 L 150 108"
          stroke="#10b981"
          stroke-width="2.5"
          marker-end="url(#arrow-emerald)"
        />

        <!-- Physical DRAM 4KB Frame Visual Box -->
        <g transform="translate(0, 114)">
          <rect
            x="0"
            y="0"
            width="300"
            height="134"
            rx="8"
            class="svg-card"
            stroke="#10b981"
            stroke-width="2"
            fill="color-mix(in srgb, #10b981 8%, var(--surface-bg, var(--ink-2)))"
          />

          <!-- Title Bar -->
          <rect x="0" y="0" width="300" height="28" rx="8" fill="#10b981" fill-opacity="0.2" />
          <text x="15" y="19" class="svg-mono-bold text-xs" fill="#10b981">PHYSICAL DRAM: Frame 0x05B20</text>
          <text x="285" y="19" text-anchor="end" class="svg-mono-xs" fill="var(--fg-dim)">4,096 Bytes</text>

          <!-- Memory Grid Lines -->
          <line x1="0" y1="60" x2="300" y2="60" stroke="var(--line)" stroke-dasharray="3 3" />
          <line x1="0" y1="92" x2="300" y2="92" stroke="var(--line)" stroke-dasharray="3 3" />

          <!-- Target Byte Highlight -->
          <rect x="60" y="66" width="180" height="22" rx="4" fill="#10b981" fill-opacity="0.3" stroke="#10b981" stroke-width="1.5" />
          <circle cx="75" cy="77" r="4" fill="#10b981" />
          <text x="88" y="81" class="svg-mono-bold text-xs" fill="var(--fg)">Target Physical Byte</text>
          <text x="232" y="81" text-anchor="end" class="svg-mono-xs" fill="#10b981">0x05B200A4</text>

          <text x="150" y="118" text-anchor="middle" class="svg-sub-xs" fill="var(--fg-dim)">
            Hardware access executed directly on DRAM bus
          </text>
        </g>
      </g>

    </svg>
  </div>
</template>

<style scoped>
.x86-translation-wrapper {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
}

.svg-card {
  fill: var(--surface-bg, var(--ink-2));
  transition: fill 0.2s ease, stroke 0.2s ease;
}

.svg-title-sm {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 0.02em;
}

.svg-step-title {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 13px;
  font-weight: 700;
}

.svg-badge {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 0.08em;
}

.svg-mono-bold {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
  font-weight: 700;
}

.svg-mono-sm {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
  font-size: 11px;
}

.svg-mono-xs {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
  font-size: 10px;
}

.svg-sub-xs {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 9.5px;
}

/* Light Variant Adjustments */
:root[data-variant='soft'] .svg-card {
  fill: #ffffff;
}

:root[data-variant='soft'] .svg-table-lines line {
  stroke: #e2e8f0;
}
</style>

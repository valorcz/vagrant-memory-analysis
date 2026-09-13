<script setup>
import { ref } from 'vue'

const props = defineProps({
  initialFilter: {
    type: String,
    default: 'all', // 'all' | 'user' | 'kernel' | 'granules'
  },
})

const activeFilter = ref(props.initialFilter)

function setFilter(f) {
  activeFilter.value = f
}
</script>

<template>
  <div class="arm64-translation w-full flex flex-col items-center select-none">
    <!-- Interactive Filter Controls -->
    <div class="flex items-center gap-2 mb-1.5">
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'all' }"
        @click="setFilter('all')"
      >
        <span class="dot bg-slate-400"></span>
        Overview (Dual Architecture)
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'user' }"
        @click="setFilter('user')"
      >
        <span class="dot bg-sky-400"></span>
        User Space (TTBR0_EL0)
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'kernel' }"
        @click="setFilter('kernel')"
      >
        <span class="dot bg-purple-400"></span>
        Kernel Space (TTBR1_EL1)
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'granules' }"
        @click="setFilter('granules')"
      >
        <span class="dot bg-amber-400"></span>
        Page Granules (4K vs 16K)
      </button>
    </div>

    <!-- Main SVG Canvas -->
    <svg
      viewBox="0 0 960 354"
      class="w-full h-auto"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <!-- Arrowhead Markers -->
        <marker id="arr-sky-arm" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#38bdf8" />
        </marker>
        <marker id="arr-purple-arm" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#c084fc" />
        </marker>
        <marker id="arr-emerald-arm" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#10b981" />
        </marker>
        <marker id="arr-amber-arm" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#fbbf24" />
        </marker>

        <!-- Diagonal Hatch for Non-Canonical Void -->
        <pattern id="hatch-arm" width="8" height="8" patternTransform="rotate(45 0 0)" patternUnits="userSpaceOnUse">
          <line x1="0" y1="0" x2="0" y2="8" stroke="var(--line)" stroke-width="1.2" stroke-opacity="0.45" />
        </pattern>
      </defs>

      <!-- ========================================================================= -->
      <!-- COLUMN HEADERS                                                            -->
      <!-- ========================================================================= -->
      <g transform="translate(0, 0)">
        <text x="130" y="12" text-anchor="middle" class="col-title" fill="#38bdf8">1. 64-BIT VIRTUAL SPACE</text>
        <text x="130" y="23" text-anchor="middle" class="col-sub" fill="var(--fg-dim)">Hardware-Split by Bit 63/55</text>

        <text x="407" y="12" text-anchor="middle" class="col-title" fill="#c084fc">2. DUAL HARDWARE ROOTS</text>
        <text x="407" y="23" text-anchor="middle" class="col-sub" fill="var(--fg-dim)">Dedicated Registers for EL0 & EL1</text>

        <text x="760" y="12" text-anchor="middle" class="col-title" fill="#10b981">3. PHYSICAL HARDWARE TARGETS</text>
        <text x="760" y="23" text-anchor="middle" class="col-sub" fill="var(--fg-dim)">DRAM Frames & MMIO Peripherals</text>
      </g>

      <!-- ========================================================================= -->
      <!-- TIER 1: 64-BIT VIRTUAL MEMORY ADDRESS SPACE                               -->
      <!-- ========================================================================= -->

      <!-- Kernel Half (Upper: 0xFFFF...) -->
      <g
        transform="translate(20, 28)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-25': activeFilter === 'user' }"
      >
        <rect
          x="0"
          y="0"
          width="220"
          height="100"
          rx="7"
          class="svg-card"
          stroke="#c084fc"
          stroke-width="1.5"
        />
        <!-- Header Pill -->
        <rect x="0" y="0" width="220" height="24" rx="7" fill="#c084fc" fill-opacity="0.16" />
        <text x="10" y="16" class="proc-header" fill="#c084fc">🟣 Kernel Space (EL1)</text>
        <text x="210" y="16" text-anchor="end" class="mono-tag" fill="var(--fg-dim)">Bit 63 = 1</text>

        <!-- Address Bounds -->
        <text x="10" y="38" class="mono-dim">Top: 0xFFFF_FFFF_FFFF_FFFF</text>

        <!-- Kernel Memory Segments -->
        <g transform="translate(6, 44)">
          <rect x="0" y="0" width="208" height="22" rx="4" class="seg-row" stroke="var(--line)" />
          <rect x="0" y="0" width="4" height="22" rx="2" fill="#c084fc" />
          <text x="10" y="15" class="text-tag-sm" fill="var(--fg)">Kernel Code & Heap</text>
          <text x="200" y="15" text-anchor="end" class="mono-xs" fill="#c084fc">Linear RAM</text>
        </g>
        <g transform="translate(6, 70)">
          <rect x="0" y="0" width="208" height="22" rx="4" class="seg-row" stroke="var(--line)" />
          <rect x="0" y="0" width="4" height="22" rx="2" fill="#fbbf24" />
          <text x="10" y="15" class="text-tag-sm" fill="var(--fg)">Drivers & MMIO</text>
          <text x="200" y="15" text-anchor="end" class="mono-xs" fill="#fbbf24">Devices</text>
        </g>
      </g>

      <!-- Middle: Non-Canonical Void -->
      <g transform="translate(20, 134)" class="transition-opacity duration-300">
        <rect
          x="0"
          y="0"
          width="220"
          height="40"
          rx="5"
          class="svg-card"
          stroke="var(--line)"
          stroke-dasharray="3,3"
        />
        <rect x="0" y="0" width="220" height="40" rx="5" fill="url(#hatch-arm)" />
        <text x="110" y="18" text-anchor="middle" class="mono-bold-xs" fill="var(--fg-dim)">NON-CANONICAL VOID</text>
        <text x="110" y="31" text-anchor="middle" class="sub-xs" fill="#f43f5e">Hardware Trap if Touched</text>
      </g>

      <!-- User Half (Lower: 0x0000...) -->
      <g
        transform="translate(20, 180)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-25': activeFilter === 'kernel' }"
      >
        <rect
          x="0"
          y="0"
          width="220"
          height="128"
          rx="7"
          class="svg-card"
          stroke="#38bdf8"
          stroke-width="1.5"
        />
        <!-- Header Pill -->
        <rect x="0" y="0" width="220" height="24" rx="7" fill="#38bdf8" fill-opacity="0.16" />
        <text x="10" y="16" class="proc-header" fill="#38bdf8">🔵 User Space (EL0)</text>
        <text x="210" y="16" text-anchor="end" class="mono-tag" fill="var(--fg-dim)">Bit 63 = 0</text>

        <!-- User Memory Segments -->
        <g transform="translate(6, 30)">
          <rect x="0" y="0" width="208" height="26" rx="4" class="seg-row" stroke="var(--line)" />
          <rect x="0" y="0" width="4" height="26" rx="2" fill="#38bdf8" />
          <text x="10" y="14" class="mono-bold" fill="#38bdf8">Stack (Thread 1)</text>
          <text x="10" y="22" class="mono-dim">Grows downward</text>
          <text x="200" y="17" text-anchor="end" class="text-tag-sm" fill="var(--fg)">Local vars</text>
        </g>
        <g transform="translate(6, 60)">
          <rect x="0" y="0" width="208" height="26" rx="4" class="seg-row" stroke="var(--line)" />
          <rect x="0" y="0" width="4" height="26" rx="2" fill="#38bdf8" />
          <text x="10" y="14" class="mono-bold" fill="#38bdf8">Heap (malloc)</text>
          <text x="10" y="22" class="mono-dim">Dynamic memory</text>
          <text x="200" y="17" text-anchor="end" class="text-tag-sm" fill="var(--fg)">Buffers</text>
        </g>
        <g transform="translate(6, 90)">
          <rect x="0" y="0" width="208" height="26" rx="4" class="seg-row" stroke="var(--line)" />
          <rect x="0" y="0" width="4" height="26" rx="2" fill="#38bdf8" />
          <text x="10" y="14" class="mono-bold" fill="#38bdf8">App Code / Text</text>
          <text x="10" y="22" class="mono-dim">0x0000_0000...</text>
          <text x="200" y="17" text-anchor="end" class="text-tag-sm" fill="var(--fg)">Mach-O / ELF</text>
        </g>
      </g>

      <!-- ========================================================================= -->
      <!-- TIER 2: DUAL HARDWARE TRANSLATION ROOTS (TTBR1_EL1 & TTBR0_EL0)           -->
      <!-- ========================================================================= -->

      <!-- TTBR1_EL1 Box (Kernel) -->
      <g
        transform="translate(268, 28)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-25': activeFilter === 'user' }"
      >
        <rect
          x="0"
          y="0"
          width="278"
          height="128"
          rx="7"
          class="svg-card"
          stroke="#c084fc"
          stroke-width="1.5"
        />
        <!-- Header -->
        <rect x="0" y="0" width="278" height="26" rx="7" fill="#c084fc" fill-opacity="0.15" />
        <text x="10" y="18" class="table-header" fill="#c084fc">⚙️ TTBR1_EL1 (Kernel Root)</text>
        <text x="268" y="18" text-anchor="end" class="mono-tag" fill="#10b981">Fixed</text>

        <!-- Description Box -->
        <g transform="translate(6, 32)">
          <rect x="0" y="0" width="266" height="42" rx="4" fill="var(--line)" fill-opacity="0.25" stroke="var(--line)" />
          <text x="8" y="16" class="mono-bold-xs" fill="#c084fc">KERNEL TRANSLATION TABLE</text>
          <text x="8" y="32" class="sub-xs" fill="var(--fg-dim)">
            Shared by all processes · Multi-level walk (L0→L1→L2→L3)
          </text>
        </g>

        <!-- Engineering Callout -->
        <g transform="translate(6, 80)">
          <rect x="0" y="0" width="266" height="40" rx="4" fill="#10b981" fill-opacity="0.1" stroke="#10b981" stroke-width="1" />
          <text x="8" y="16" class="mono-bold-xs" fill="#10b981">⚡ ZERO TLB CHURN</text>
          <text x="8" y="30" class="sub-xs" fill="var(--fg)">
            Never swapped or flushed during context switches!
          </text>
        </g>
      </g>

      <!-- Hardware Multiplexer Demarcation -->
      <g transform="translate(268, 162)">
        <rect x="0" y="0" width="278" height="24" rx="4" class="svg-card" stroke="var(--line)" />
        <text x="139" y="16" text-anchor="middle" class="mono-xs" fill="var(--fg-dim)">
          Hardware MMU selects register by address bit 63
        </text>
      </g>

      <!-- TTBR0_EL0 Box (User) -->
      <g
        transform="translate(268, 192)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-25': activeFilter === 'kernel' }"
      >
        <rect
          x="0"
          y="0"
          width="278"
          height="116"
          rx="7"
          class="svg-card"
          stroke="#38bdf8"
          stroke-width="1.5"
        />
        <!-- Header -->
        <rect x="0" y="0" width="278" height="26" rx="7" fill="#38bdf8" fill-opacity="0.15" />
        <text x="10" y="18" class="table-header" fill="#38bdf8">⚙️ TTBR0_EL0 (User Root)</text>
        <text x="268" y="18" text-anchor="end" class="mono-tag" fill="#fbbf24">Swapped on Context</text>

        <!-- Description Box -->
        <g transform="translate(6, 32)">
          <rect x="0" y="0" width="266" height="42" rx="4" fill="var(--line)" fill-opacity="0.25" stroke="var(--line)" />
          <text x="8" y="16" class="mono-bold-xs" fill="#38bdf8">USER TRANSLATION TABLE</text>
          <text x="8" y="32" class="sub-xs" fill="var(--fg-dim)">
            Unique per process (tagged with ASID hardware ID)
          </text>
        </g>

        <!-- Process Switch Banner -->
        <g transform="translate(6, 78)">
          <rect x="0" y="0" width="266" height="32" rx="4" fill="#fbbf24" fill-opacity="0.1" stroke="#fbbf24" stroke-width="1" />
          <text x="8" y="14" class="mono-bold-xs" fill="#fbbf24">🔄 CONTEXT SWITCH:</text>
          <text x="8" y="25" class="sub-xs" fill="var(--fg)">
            Kernel rewrites only TTBR0_EL0 (e.g. PID 100 → PID 200)
          </text>
        </g>
      </g>

      <!-- ========================================================================= -->
      <!-- CONNECTOR PATHS: TIER 1 -> TIER 2                                         -->
      <!-- ========================================================================= -->
      <g class="transition-opacity duration-300">
        <!-- Kernel to TTBR1 -->
        <path
          d="M 240 78 L 268 78"
          stroke="#c084fc"
          stroke-width="2"
          marker-end="url(#arr-purple-arm)"
          :class="{ 'opacity-25': activeFilter === 'user' }"
        />
        <!-- User to TTBR0 -->
        <path
          d="M 240 244 L 268 244"
          stroke="#38bdf8"
          stroke-width="2"
          marker-end="url(#arr-sky-arm)"
          :class="{ 'opacity-25': activeFilter === 'kernel' }"
        />
      </g>

      <!-- ========================================================================= -->
      <!-- TIER 3: PHYSICAL HARDWARE TARGETS (DRAM & MMIO)                            -->
      <!-- ========================================================================= -->

      <!-- Hardware Box 1: Physical DRAM -->
      <g transform="translate(580, 28)">
        <rect
          x="0"
          y="0"
          width="360"
          height="164"
          rx="7"
          class="svg-card"
          stroke="var(--line)"
          stroke-width="1.5"
        />
        <!-- Header -->
        <rect x="0" y="0" width="360" height="26" rx="7" fill="var(--fg)" fill-opacity="0.06" />
        <text x="10" y="18" class="hardware-header" fill="var(--fg)">⚡ Physical DRAM (System Memory)</text>
        <text x="350" y="18" text-anchor="end" class="mono-tag text-emerald" fill="#10b981">Unified Memory</text>

        <!-- DRAM Physical Frames (4 rows) -->
        <!-- Frame: Kernel Code -->
        <g
          transform="translate(8, 32)"
          class="transition-opacity duration-300"
          :class="{ 'opacity-25': activeFilter === 'user' }"
        >
          <rect x="0" y="0" width="344" height="28" rx="4" fill="#c084fc" fill-opacity="0.16" stroke="#c084fc" stroke-width="1.2" />
          <text x="10" y="18" class="mono-bold" fill="#c084fc">Kernel Memory</text>
          <text x="334" y="18" text-anchor="end" class="text-tag-sm" fill="var(--fg)">OS Core, Page Cache, Drivers</text>
        </g>

        <!-- Frame: Process A (Active User) -->
        <g
          transform="translate(8, 64)"
          class="transition-opacity duration-300"
          :class="{ 'opacity-25': activeFilter === 'kernel' }"
        >
          <rect x="0" y="0" width="344" height="28" rx="4" fill="#38bdf8" fill-opacity="0.16" stroke="#38bdf8" stroke-width="1.2" />
          <text x="10" y="18" class="mono-bold" fill="#38bdf8">User Process A (PID 100)</text>
          <text x="334" y="18" text-anchor="end" class="text-tag-sm" fill="var(--fg)">Browser DOM, JIT Code</text>
        </g>

        <!-- Frame: Process B (Background User) -->
        <g
          transform="translate(8, 96)"
          class="transition-opacity duration-300"
          :class="{ 'opacity-25': activeFilter === 'kernel' }"
        >
          <rect x="0" y="0" width="344" height="28" rx="4" fill="var(--line)" fill-opacity="0.25" stroke="var(--line)" />
          <text x="10" y="18" class="mono-bold" fill="var(--fg-dim)">User Process B (PID 200)</text>
          <text x="334" y="18" text-anchor="end" class="text-tag-sm" fill="var(--fg-dim)">Background Terminal</text>
        </g>

        <!-- Frame: Free / Available Pool -->
        <g transform="translate(8, 128)">
          <rect x="0" y="0" width="344" height="28" rx="4" class="free-frame" stroke="#10b981" stroke-width="1" stroke-dasharray="3,2" />
          <text x="10" y="18" class="mono-bold" fill="#10b981">Free Frame Pool</text>
          <text x="334" y="18" text-anchor="end" class="sub-xs" fill="#10b981">Available for page allocation</text>
        </g>
      </g>

      <!-- Hardware Box 2: Memory-Mapped I/O (MMIO Peripherals) -->
      <g
        transform="translate(580, 200)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-25': activeFilter === 'user' }"
      >
        <rect
          x="0"
          y="0"
          width="360"
          height="108"
          rx="7"
          class="svg-card"
          stroke="#fbbf24"
          stroke-width="1.5"
        />
        <!-- Header -->
        <rect x="0" y="0" width="360" height="26" rx="7" fill="#fbbf24" fill-opacity="0.14" />
        <text x="10" y="18" class="hardware-header" fill="#fbbf24">🔌 MMIO & Device Peripherals</text>
        <text x="350" y="18" text-anchor="end" class="mono-tag text-amber" fill="#fbbf24">Hardware Registers</text>

        <!-- MMIO Entries -->
        <g transform="translate(8, 32)">
          <rect x="0" y="0" width="168" height="32" rx="4" fill="#fbbf24" fill-opacity="0.1" stroke="#fbbf24" stroke-width="1" />
          <text x="8" y="14" class="mono-bold" fill="#fbbf24">UART / Serial</text>
          <text x="8" y="26" class="sub-xs" fill="var(--fg)">Console & Debug</text>
        </g>

        <g transform="translate(184, 32)">
          <rect x="0" y="0" width="168" height="32" rx="4" fill="#fbbf24" fill-opacity="0.1" stroke="#fbbf24" stroke-width="1" />
          <text x="8" y="14" class="mono-bold" fill="#fbbf24">PCIe / NVMe / GPU</text>
          <text x="8" y="26" class="sub-xs" fill="var(--fg)">Hardware Bus Registers</text>
        </g>

        <!-- MMIO Note -->
        <g transform="translate(8, 70)">
          <rect x="0" y="0" width="344" height="28" rx="4" fill="var(--line)" fill-opacity="0.25" stroke="var(--line)" />
          <text x="10" y="18" class="sub-xs" fill="var(--fg-dim)">
            🛡️ Protected by EL1/EL2: User space cannot directly touch device registers
          </text>
        </g>
      </g>

      <!-- ========================================================================= -->
      <!-- CONNECTOR PATHS: TIER 2 -> TIER 3                                         -->
      <!-- ========================================================================= -->
      <g class="transition-opacity duration-300">
        <!-- TTBR1 -> Kernel DRAM -->
        <path
          d="M 546 64 L 578 64"
          stroke="#c084fc"
          stroke-width="2"
          marker-end="url(#arr-purple-arm)"
          :class="{ 'opacity-25': activeFilter === 'user' }"
        />
        <!-- TTBR1 -> MMIO Peripherals -->
        <path
          d="M 546 100 C 560 100, 560 230, 578 230"
          stroke="#fbbf24"
          stroke-width="1.8"
          stroke-dasharray="3,2"
          marker-end="url(#arr-amber-arm)"
          :class="{ 'opacity-25': activeFilter === 'user' }"
        />
        <!-- TTBR0 -> User Process A DRAM -->
        <path
          d="M 546 244 C 565 244, 565 110, 578 110"
          stroke="#38bdf8"
          stroke-width="2"
          marker-end="url(#arr-sky-arm)"
          :class="{ 'opacity-25': activeFilter === 'kernel' }"
        />
      </g>

      <!-- ========================================================================= -->
      <!-- BOTTOM SUMMARY PILLARS                                                    -->
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

        <!-- Pillar 1: Zero Kernel TLB Flush -->
        <text x="30" y="19" class="summary-title" fill="#c084fc">1. Zero Kernel Churn</text>
        <text x="160" y="19" class="summary-desc" fill="var(--fg-dim)">TTBR1_EL1 never swapped on process switch</text>

        <!-- Divider 1 -->
        <line x1="410" y1="6" x2="410" y2="24" stroke="var(--line)" />

        <!-- Pillar 2: Configurable Granules -->
        <text x="430" y="19" class="summary-title" fill="#fbbf24">2. Flexible Granules</text>
        <text x="560" y="19" class="summary-desc" fill="var(--fg-dim)">4 KB (Linux) vs 16 KB (Apple Silicon)</text>

        <!-- Divider 2 -->
        <line x1="755" y1="6" x2="755" y2="24" stroke="var(--line)" />

        <!-- Pillar 3: Hardware Boundary -->
        <text x="775" y="19" class="summary-title" fill="#10b981">3. Hardware Split</text>
        <text x="875" y="19" class="summary-desc" fill="var(--fg-dim)">Zero GDT/LDT overhead</text>
      </g>
    </svg>
  </div>
</template>

<style scoped>
.arm64-translation {
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
  border-color: #c084fc;
  background: rgba(192, 132, 252, 0.12);
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

.seg-row {
  fill: var(--surface-bg, rgba(255, 255, 255, 0.03));
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

.mono-xs {
  font-size: 9px;
}

.text-tag-sm {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 9.5px;
  font-weight: 600;
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

/* Light Variant Adjustments */
:root[data-variant='soft'] .svg-card,
:root[data-variant='soft'] .summary-card {
  fill: #ffffff;
}

:root[data-variant='soft'] .ctrl-btn {
  background: #ffffff;
}
</style>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  initialFilter: {
    type: String,
    default: 'all', // 'all' | 'vm' | 'live-admin' | 'live-dma' | 'offline'
  },
})

const activeFilter = ref(props.initialFilter)

function setFilter(f) {
  activeFilter.value = f
}
</script>

<template>
  <div class="acq-tree-wrapper w-full flex flex-col items-center select-none">
    <!-- Interactive Filter Buttons -->
    <div class="flex items-center gap-2 mb-2">
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'all' }"
        @click="setFilter('all')"
      >
        <span class="dot bg-slate-400"></span>
        All Strategies
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'vm' }"
        @click="setFilter('vm')"
      >
        <span class="dot bg-sky-400"></span>
        Virtual Machine
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'live-admin' }"
        @click="setFilter('live-admin')"
      >
        <span class="dot bg-emerald-400"></span>
        Live OS (Admin)
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'live-dma' }"
        @click="setFilter('live-dma')"
      >
        <span class="dot bg-rose-400"></span>
        Live OS (DMA Probe)
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: activeFilter === 'offline' }"
        @click="setFilter('offline')"
      >
        <span class="dot bg-amber-400"></span>
        Powered Off (Disk)
      </button>
    </div>

    <!-- Main Horizontal Decision Flow SVG -->
    <svg
      viewBox="0 0 960 350"
      class="w-full h-auto"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <!-- Arrowhead Markers -->
        <marker id="arr-default" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="var(--fg-dim)" />
        </marker>
        <marker id="arr-sky-tree" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#38bdf8" />
        </marker>
        <marker id="arr-emerald-tree" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#10b981" />
        </marker>
        <marker id="arr-amber-tree" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#fbbf24" />
        </marker>
        <marker id="arr-rose-tree" markerWidth="7" markerHeight="7" refX="5" refY="3.5" orient="auto">
          <polygon points="0 0, 7 3.5, 0 7" fill="#f43f5e" />
        </marker>
      </defs>

      <!-- ========================================================================= -->
      <!-- CONNECTOR PATHS                                                           -->
      <!-- ========================================================================= -->
      <g class="transition-opacity duration-300">
        <!-- Start -> Q1 (Virtual?) -->
        <path
          d="M 145 180 L 180 180"
          stroke="var(--line)"
          stroke-width="2"
          marker-end="url(#arr-default)"
        />

        <!-- Q1 -- Yes --> Hypervisor Outcome (Up & Right) -->
        <path
          d="M 250 148 C 250 56, 300 56, 360 56"
          fill="none"
          stroke="#38bdf8"
          stroke-width="2.5"
          marker-end="url(#arr-sky-tree)"
          :class="{ 'opacity-20': activeFilter !== 'all' && activeFilter !== 'vm' }"
        />

        <!-- Q1 -- No --> Q2 (Powered On?) (Right) -->
        <path
          d="M 320 180 L 360 180"
          stroke="var(--line)"
          stroke-width="2"
          marker-end="url(#arr-default)"
          :class="{ 'opacity-20': activeFilter === 'vm' }"
        />

        <!-- Q2 -- No --> Offline Disk Outcome (Down & Right) -->
        <path
          d="M 430 212 C 430 298, 480 298, 540 298"
          fill="none"
          stroke="#fbbf24"
          stroke-width="2.5"
          marker-end="url(#arr-amber-tree)"
          :class="{ 'opacity-20': activeFilter !== 'all' && activeFilter !== 'offline' }"
        />

        <!-- Q2 -- Yes --> Q3 (Admin / Root?) (Right) -->
        <path
          d="M 500 180 L 540 180"
          stroke="var(--line)"
          stroke-width="2"
          marker-end="url(#arr-default)"
          :class="{ 'opacity-20': activeFilter === 'vm' || activeFilter === 'offline' }"
        />

        <!-- Q3 -- Yes --> Live Kernel Tool (Up-Right) -->
        <path
          d="M 680 162 C 695 162, 700 138, 720 138"
          fill="none"
          stroke="#10b981"
          stroke-width="2.5"
          marker-end="url(#arr-emerald-tree)"
          :class="{ 'opacity-20': activeFilter !== 'all' && activeFilter !== 'live-admin' }"
        />

        <!-- Q3 -- No --> Hardware DMA Probe (Down-Right) -->
        <path
          d="M 680 198 C 695 198, 700 222, 720 222"
          fill="none"
          stroke="#f43f5e"
          stroke-width="2.5"
          marker-end="url(#arr-rose-tree)"
          :class="{ 'opacity-20': activeFilter !== 'all' && activeFilter !== 'live-dma' }"
        />
      </g>

      <!-- ========================================================================= -->
      <!-- DECISION NODES (Left & Center)                                            -->
      <!-- ========================================================================= -->

      <!-- Node 0: Starting Incident -->
      <g transform="translate(15, 148)">
        <rect
          x="0"
          y="0"
          width="130"
          height="64"
          rx="8"
          class="svg-card"
          stroke="var(--line)"
          stroke-width="1.5"
        />
        <text x="12" y="24" class="node-kicker" fill="var(--fg-dim)">TARGET</text>
        <text x="12" y="42" class="node-title" fill="var(--fg)">🚨 Incident</text>
        <text x="12" y="55" class="node-sub" fill="var(--fg-dim)">Target Machine</text>
      </g>

      <!-- Decision 1: Virtual Machine? -->
      <g
        transform="translate(180, 148)"
        class="transition-opacity duration-300"
      >
        <rect
          x="0"
          y="0"
          width="140"
          height="64"
          rx="8"
          class="svg-card"
          stroke="#38bdf8"
          stroke-width="1.5"
        />
        <text x="12" y="22" class="node-kicker" fill="#38bdf8">STEP 1</text>
        <text x="12" y="40" class="node-title-sm" fill="var(--fg)">Virtual Machine?</text>
        <text x="12" y="54" class="node-sub" fill="var(--fg-dim)">Check virtualization</text>

        <!-- YES Badge (Up) -->
        <g transform="translate(60, -22)">
          <rect x="0" y="0" width="34" height="18" rx="4" fill="#10b981" fill-opacity="0.2" stroke="#10b981" stroke-width="1" />
          <text x="17" y="13" text-anchor="middle" class="badge-text" fill="#10b981">YES</text>
        </g>

        <!-- NO Badge (Right) -->
        <g transform="translate(142, 23)">
          <rect x="0" y="0" width="30" height="18" rx="4" fill="#64748b" fill-opacity="0.2" stroke="var(--line)" stroke-width="1" />
          <text x="15" y="13" text-anchor="middle" class="badge-text" fill="var(--fg-dim)">NO</text>
        </g>
      </g>

      <!-- Decision 2: System Powered On? -->
      <g
        transform="translate(360, 148)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-20': activeFilter === 'vm' }"
      >
        <rect
          x="0"
          y="0"
          width="140"
          height="64"
          rx="8"
          class="svg-card"
          stroke="#fbbf24"
          stroke-width="1.5"
        />
        <text x="12" y="22" class="node-kicker" fill="#fbbf24">STEP 2</text>
        <text x="12" y="40" class="node-title-sm" fill="var(--fg)">Powered On?</text>
        <text x="12" y="54" class="node-sub" fill="var(--fg-dim)">Live vs cold DRAM</text>

        <!-- YES Badge (Right) -->
        <g transform="translate(142, 23)">
          <rect x="0" y="0" width="34" height="18" rx="4" fill="#10b981" fill-opacity="0.2" stroke="#10b981" stroke-width="1" />
          <text x="17" y="13" text-anchor="middle" class="badge-text" fill="#10b981">YES</text>
        </g>

        <!-- NO Badge (Down) -->
        <g transform="translate(60, 68)">
          <rect x="0" y="0" width="30" height="18" rx="4" fill="#fbbf24" fill-opacity="0.2" stroke="#fbbf24" stroke-width="1" />
          <text x="15" y="13" text-anchor="middle" class="badge-text" fill="#fbbf24">NO</text>
        </g>
      </g>

      <!-- Decision 3: Admin / Root Privileges? -->
      <g
        transform="translate(540, 148)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-20': activeFilter === 'vm' || activeFilter === 'offline' }"
      >
        <rect
          x="0"
          y="0"
          width="140"
          height="64"
          rx="8"
          class="svg-card"
          stroke="#10b981"
          stroke-width="1.5"
        />
        <text x="12" y="22" class="node-kicker" fill="#10b981">STEP 3</text>
        <text x="12" y="40" class="node-title-sm" fill="var(--fg)">Admin / Root?</text>
        <text x="12" y="54" class="node-sub" fill="var(--fg-dim)">Kernel driver load</text>

        <!-- YES Badge (Up-Right) -->
        <g transform="translate(138, -2)">
          <rect x="0" y="0" width="34" height="18" rx="4" fill="#10b981" fill-opacity="0.2" stroke="#10b981" stroke-width="1" />
          <text x="17" y="13" text-anchor="middle" class="badge-text" fill="#10b981">YES</text>
        </g>

        <!-- NO Badge (Down-Right) -->
        <g transform="translate(138, 48)">
          <rect x="0" y="0" width="30" height="18" rx="4" fill="#f43f5e" fill-opacity="0.2" stroke="#f43f5e" stroke-width="1" />
          <text x="15" y="13" text-anchor="middle" class="badge-text" fill="#f43f5e">NO</text>
        </g>
      </g>

      <!-- ========================================================================= -->
      <!-- OUTCOME STRATEGY CARDS                                                    -->
      <!-- ========================================================================= -->

      <!-- Outcome 1: Hypervisor Out-of-Band (Top Wide Card) -->
      <g
        transform="translate(360, 20)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-20': activeFilter !== 'all' && activeFilter !== 'vm' }"
      >
        <rect
          x="0"
          y="0"
          width="580"
          height="72"
          rx="8"
          class="svg-card"
          stroke="#38bdf8"
          stroke-width="1.8"
        />
        <!-- Header Pill -->
        <rect x="0" y="0" width="580" height="26" rx="8" fill="#38bdf8" fill-opacity="0.14" />
        <text x="12" y="18" class="card-header" fill="#38bdf8">🖥️ Hypervisor Snapshot / Pause (Gold Standard)</text>
        <text x="568" y="18" text-anchor="end" class="mono-badge-emerald" fill="#10b981">ZERO GUEST FOOTPRINT</text>

        <!-- Body Details -->
        <text x="14" y="44" class="card-body-bold" fill="var(--fg)">
          Snapshot / Pause guest VM & extract memory state file
        </text>
        <text x="14" y="60" class="card-body-sub" fill="var(--fg-dim)">
          Format: <tspan fill="#38bdf8" font-weight="600">.vmem</tspan> (VMware) · <tspan fill="#38bdf8" font-weight="600">.sav</tspan> (VirtualBox) · <tspan fill="#38bdf8" font-weight="600">virsh dump</tspan> (KVM) · Bypasses all guest rootkits
        </text>
      </g>

      <!-- Outcome 2: Offline Disk Extraction (Bottom Wide Card) -->
      <g
        transform="translate(540, 262)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-20': activeFilter !== 'all' && activeFilter !== 'offline' }"
      >
        <rect
          x="0"
          y="0"
          width="400"
          height="72"
          rx="8"
          class="svg-card"
          stroke="#fbbf24"
          stroke-width="1.8"
        />
        <!-- Header Pill -->
        <rect x="0" y="0" width="400" height="26" rx="8" fill="#fbbf24" fill-opacity="0.14" />
        <text x="12" y="18" class="card-header" fill="#fbbf24">💾 Offline Disk Memory Backings</text>
        <text x="388" y="18" text-anchor="end" class="mono-badge-amber" fill="#fbbf24">COLD FORENSICS</text>

        <!-- Body Details -->
        <text x="14" y="44" class="card-body-bold" fill="var(--fg)">
          Carve memory snapshots preserved on storage
        </text>
        <text x="14" y="60" class="card-body-sub" fill="var(--fg-dim)">
          Files: <tspan fill="#fbbf24" font-weight="600">hiberfil.sys</tspan> (hibernation) · <tspan fill="#fbbf24" font-weight="600">pagefile.sys</tspan> · <tspan fill="#fbbf24" font-weight="600">MEMORY.DMP</tspan> (BSOD)
        </text>
      </g>

      <!-- Outcome 3: Live OS Kernel Tool (Upper-Right Card) -->
      <g
        transform="translate(720, 105)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-20': activeFilter !== 'all' && activeFilter !== 'live-admin' }"
      >
        <rect
          x="0"
          y="0"
          width="220"
          height="66"
          rx="7"
          class="svg-card"
          stroke="#10b981"
          stroke-width="1.8"
        />
        <rect x="0" y="0" width="220" height="22" rx="7" fill="#10b981" fill-opacity="0.14" />
        <text x="10" y="15" class="card-header-sm" fill="#10b981">⚡ Live Kernel Driver</text>
        <text x="210" y="15" text-anchor="end" class="badge-text" fill="#10b981">ROOT</text>

        <text x="10" y="38" class="card-body-bold-sm" fill="var(--fg)">
          WinPmem · DumpIt · AVML · LiME
        </text>
        <text x="10" y="52" class="card-body-sub-sm" fill="var(--fg-dim)">
          Loads signed driver; stream to external/net
        </text>
      </g>

      <!-- Outcome 4: Hardware DMA Probe (Lower-Right Card) -->
      <g
        transform="translate(720, 182)"
        class="transition-opacity duration-300"
        :class="{ 'opacity-20': activeFilter !== 'all' && activeFilter !== 'live-dma' }"
      >
        <rect
          x="0"
          y="0"
          width="220"
          height="66"
          rx="7"
          class="svg-card"
          stroke="#f43f5e"
          stroke-width="1.8"
        />
        <rect x="0" y="0" width="220" height="22" rx="7" fill="#f43f5e" fill-opacity="0.14" />
        <text x="10" y="15" class="card-header-sm" fill="#f43f5e">🔌 Hardware DMA Probe</text>
        <text x="210" y="15" text-anchor="end" class="badge-text" fill="#f43f5e">NO ROOT</text>

        <text x="10" y="38" class="card-body-bold-sm" fill="var(--fg)">
          PCIe / Thunderbolt / PCI Leech
        </text>
        <text x="10" y="52" class="card-body-sub-sm" fill="var(--fg-dim)">
          Direct Memory Access; bypasses OS kernel
        </text>
      </g>
    </svg>
  </div>
</template>

<style scoped>
.acq-tree-wrapper {
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

.node-kicker {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 9px;
  font-weight: 800;
  letter-spacing: 0.08em;
}

.node-title {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 13px;
  font-weight: 700;
}

.node-title-sm {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 11.5px;
  font-weight: 700;
}

.node-sub {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 9.5px;
}

.card-header {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 11.5px;
  font-weight: 700;
}

.card-header-sm {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 10.5px;
  font-weight: 700;
}

.card-body-bold {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 11px;
  font-weight: 600;
}

.card-body-bold-sm {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 9.5px;
  font-weight: 600;
}

.card-body-sub {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 10px;
}

.card-body-sub-sm {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 8.5px;
}

.badge-text {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
  font-size: 8.5px;
  font-weight: 700;
}

.mono-badge-emerald {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 0.05em;
}

.mono-badge-amber {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
  font-size: 9px;
  font-weight: 700;
  letter-spacing: 0.05em;
}

/* Light Variant Adjustments */
:root[data-variant='soft'] .svg-card {
  fill: #ffffff;
}

:root[data-variant='soft'] .ctrl-btn {
  background: #ffffff;
}
</style>

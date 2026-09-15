<script setup>
import { ref, computed } from 'vue'

// Curated Windows Kernel Process List Dataset
const processes = [
  {
    id: 'head',
    name: 'PsActiveProcessHead',
    shortName: 'List Head',
    pid: 'KERNEL',
    isHead: true,
    isRootkit: false,
    baseHex: '0x8055B120',
    linksHex: '0x8055B120',
    cr3Hex: 'N/A (Kernel)',
    desc: 'Exported circular list head in ntoskrnl.exe'
  },
  {
    id: 'system',
    name: 'System',
    shortName: 'System',
    pid: '4',
    isHead: false,
    isRootkit: false,
    baseHex: '0x821D3000',
    linksHex: '0x821D3088',
    cr3Hex: '0x00039000',
    desc: 'NT Kernel host process for kernel-mode worker threads'
  },
  {
    id: 'csrss',
    name: 'csrss.exe',
    shortName: 'csrss.exe',
    pid: '368',
    isHead: false,
    isRootkit: false,
    baseHex: '0x8225C000',
    linksHex: '0x8225C088',
    cr3Hex: '0x0C120000',
    desc: 'Client/Server Runtime Subsystem (critical Windows service)'
  },
  {
    id: 'rootkit',
    name: 'rootkit.exe',
    shortName: 'rootkit.exe',
    pid: '1337',
    isHead: false,
    isRootkit: true,
    baseHex: '0x825E1000',
    linksHex: '0x825E1088',
    cr3Hex: '0x1F450000',
    desc: 'Stealth malware payload unhooked by DKOM attack'
  },
  {
    id: 'explorer',
    name: 'explorer.exe',
    shortName: 'explorer.exe',
    pid: '1420',
    isHead: false,
    isRootkit: false,
    baseHex: '0x827B8000',
    linksHex: '0x827B8088',
    cr3Hex: '0x2A110000',
    desc: 'User desktop GUI shell & taskbar process'
  }
]

// Modes: 'normal' vs 'dkom'
const mode = ref('normal')
// Active node index being inspected
const selectedIdx = ref(1) // Default to 'System'
// Current traversal position
const traversalIdx = ref(0) // Default at Head

function setMode(m) {
  mode.value = m
  traversalIdx.value = 0
  if (m === 'dkom') {
    selectedIdx.value = 3 // Select rootkit to highlight unlinking
  }
}

function selectNode(i) {
  selectedIdx.value = i
  traversalIdx.value = i
}

// Compute active sequence order based on mode
const activeChain = computed(() => {
  if (mode.value === 'normal') {
    return [0, 1, 2, 3, 4]
  } else {
    // In DKOM mode, rootkit (idx 3) is detached from the list traversal
    return [0, 1, 2, 4]
  }
})

// Traversal forward (Flink)
function stepFlink() {
  const chain = activeChain.value
  const currentPos = chain.indexOf(traversalIdx.value)
  if (currentPos === -1) {
    traversalIdx.value = chain[0]
  } else {
    const nextPos = (currentPos + 1) % chain.length
    traversalIdx.value = chain[nextPos]
  }
  selectedIdx.value = traversalIdx.value
}

// Traversal backward (Blink)
function stepBlink() {
  const chain = activeChain.value
  const currentPos = chain.indexOf(traversalIdx.value)
  if (currentPos === -1) {
    traversalIdx.value = chain[0]
  } else {
    const prevPos = (currentPos - 1 + chain.length) % chain.length
    traversalIdx.value = chain[prevPos]
  }
  selectedIdx.value = traversalIdx.value
}

function resetTraversal() {
  traversalIdx.value = 0
  selectedIdx.value = 0
}

const currentNode = computed(() => processes[selectedIdx.value])

// Compute effective Flink / Blink for display
const effectiveFlink = computed(() => {
  const idx = selectedIdx.value
  if (mode.value === 'dkom' && idx === 2) {
    return processes[4].linksHex + ' (Bypasses rootkit -> explorer)'
  }
  if (mode.value === 'dkom' && idx === 3) {
    return '0x825E1088 (Self / severed)'
  }
  const nextIdx = (idx + 1) % processes.length
  return processes[nextIdx].linksHex
})

const effectiveBlink = computed(() => {
  const idx = selectedIdx.value
  if (mode.value === 'dkom' && idx === 4) {
    return processes[2].linksHex + ' (Bypasses rootkit -> csrss)'
  }
  if (mode.value === 'dkom' && idx === 3) {
    return '0x825E1088 (Self / severed)'
  }
  const prevIdx = (idx - 1 + processes.length) % processes.length
  return processes[prevIdx].linksHex
})

// Coordinates for the 5 nodes in the 960-wide SVG
const nodeWidth = 152
const nodeGap = 36
const startX = 22
const nodePositions = [
  { x: startX + 0 * (nodeWidth + nodeGap), y: 36 },
  { x: startX + 1 * (nodeWidth + nodeGap), y: 36 },
  { x: startX + 2 * (nodeWidth + nodeGap), y: 36 },
  { x: startX + 3 * (nodeWidth + nodeGap), y: 36 }, // rootkit
  { x: startX + 4 * (nodeWidth + nodeGap), y: 36 }
]
</script>

<template>
  <div class="process-linked-list w-full flex flex-col items-center select-none">
    <!-- Top Controls: Scenario Mode Switcher + Step Traversal -->
    <div class="w-full max-w-[920px] flex items-center justify-between gap-3 mb-2 flex-wrap">
      <!-- Mode Toggle -->
      <div class="flex items-center gap-1.5 p-1 rounded-lg border border-[var(--line)] bg-[var(--surface-bg,var(--ink-2))]">
        <button
          class="mode-btn"
          :class="{ active: mode === 'normal' }"
          @click="setMode('normal')"
        >
          <span class="dot bg-sky-400"></span>
          Intact ActiveProcessLinks
        </button>
        <button
          class="mode-btn"
          :class="{ active: mode === 'dkom' }"
          @click="setMode('dkom')"
        >
          <span class="dot bg-rose-400"></span>
          DKOM Unlinking (Rootkit)
        </button>
      </div>

      <!-- Traversal Controls -->
      <div class="flex items-center gap-2">
        <span class="text-[11px] font-semibold text-[var(--fg-dim)]">API Walk:</span>
        <button class="step-btn" @click="stepFlink" title="Follow Flink (forward link)">
          Traverse Flink ➔
        </button>
        <button class="step-btn" @click="stepBlink" title="Follow Blink (backward link)">
          ⬅ Traverse Blink
        </button>
        <button class="step-btn reset" @click="resetTraversal" title="Reset to List Head">
          Reset
        </button>
      </div>
    </div>

    <!-- Main SVG Circular Doubly-Linked List Diagram -->
    <svg
      viewBox="0 0 960 176"
      class="w-full h-auto"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <!-- Arrowhead Markers -->
        <marker id="arr-fwd" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 z" fill="#38bdf8" />
        </marker>
        <marker id="arr-bwd" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 z" fill="#c084fc" />
        </marker>
        <marker id="arr-dkom" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 z" fill="#f43f5e" />
        </marker>
        <marker id="arr-bypass" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 z" fill="#10b981" />
        </marker>
      </defs>

      <!-- Return Loop Behind Cards: Flink explorer -> Head (top curve) -->
      <path
        d="M 906 58 C 940 58 946 16 900 16 L 60 16 C 16 16 20 58 48 58"
        stroke="#38bdf8"
        stroke-width="1.6"
        stroke-dasharray="4 4"
        fill="none"
        marker-end="url(#arr-fwd)"
      />
      <!-- Return Loop Behind Cards: Blink Head -> explorer (bottom curve) -->
      <path
        d="M 48 104 C 16 104 14 146 60 146 L 900 146 C 946 146 942 104 906 104"
        stroke="#c084fc"
        stroke-width="1.6"
        stroke-dasharray="4 4"
        fill="none"
        marker-end="url(#arr-bwd)"
      />

      <!-- Circular Connection Arrows Between Adjacent Nodes -->
      <g v-for="i in 4" :key="'arrow-' + i">
        <!-- Normal Forward Link (Flink): Node i-1 -> Node i -->
        <g v-if="mode === 'normal' || (i !== 3 && i !== 4)">
          <path
            :d="`M ${nodePositions[i-1].x + nodeWidth} 60 L ${nodePositions[i].x} 60`"
            stroke="#38bdf8"
            stroke-width="1.8"
            marker-end="url(#arr-fwd)"
          />
          <text :x="nodePositions[i-1].x + nodeWidth + 18" y="54" text-anchor="middle" class="svg-link-label" fill="#38bdf8">Flink ➔</text>
        </g>

        <!-- Normal Backward Link (Blink): Node i -> Node i-1 -->
        <g v-if="mode === 'normal' || (i !== 3 && i !== 4)">
          <path
            :d="`M ${nodePositions[i].x} 98 L ${nodePositions[i-1].x + nodeWidth} 98`"
            stroke="#c084fc"
            stroke-width="1.8"
            marker-end="url(#arr-bwd)"
          />
          <text :x="nodePositions[i-1].x + nodeWidth + 18" y="110" text-anchor="middle" class="svg-link-label" fill="#c084fc">⬅ Blink</text>
        </g>
      </g>

      <!-- DKOM Active Bypass Arrows (csrss.exe -> explorer.exe) -->
      <g v-if="mode === 'dkom'">
        <!-- Flink Bypass: csrss -> explorer (curves up above rootkit) -->
        <path
          d="M 550 56 C 580 24 710 24 740 56"
          stroke="#10b981"
          stroke-width="2.2"
          fill="none"
          marker-end="url(#arr-bypass)"
        />
        <rect x="618" y="18" width="86" height="17" rx="3" fill="#10b981" fill-opacity="0.18" stroke="#10b981" stroke-width="0.8" />
        <text x="661" y="30" text-anchor="middle" class="svg-bypass-label" fill="#10b981">Flink Bypass ➔</text>

        <!-- Blink Bypass: explorer -> csrss (curves down below rootkit) -->
        <path
          d="M 740 102 C 710 134 580 134 550 102"
          stroke="#10b981"
          stroke-width="2.2"
          fill="none"
          marker-end="url(#arr-bypass)"
        />
        <rect x="618" y="128" width="86" height="17" rx="3" fill="#10b981" fill-opacity="0.18" stroke="#10b981" stroke-width="0.8" />
        <text x="661" y="140" text-anchor="middle" class="svg-bypass-label" fill="#10b981">⬅ Blink Bypass</text>

        <!-- Severed Links on rootkit.exe -->
        <path d="M 550 68 L 586 68" stroke="#f43f5e" stroke-width="1.5" stroke-dasharray="3 3" />
        <path d="M 740 68 L 704 68" stroke="#f43f5e" stroke-width="1.5" stroke-dasharray="3 3" />
      </g>

      <!-- The 5 Process Nodes -->
      <g
        v-for="(p, i) in processes"
        :key="p.id"
        :transform="`translate(${nodePositions[i].x}, ${p.isRootkit && mode === 'dkom' ? nodePositions[i].y + 10 : nodePositions[i].y})`"
        class="cursor-pointer"
        @click="selectNode(i)"
      >
        <!-- Node Container Card -->
        <rect
          x="0"
          y="0"
          :width="nodeWidth"
          height="88"
          rx="7"
          class="svg-node-card"
          :stroke="selectedIdx === i ? '#38bdf8' : (p.isRootkit && mode === 'dkom' ? '#f43f5e' : (p.isHead ? '#c084fc' : 'var(--line)'))"
          :stroke-width="selectedIdx === i ? 2.2 : (p.isRootkit && mode === 'dkom' ? 1.8 : 1.2)"
          :stroke-dasharray="p.isRootkit && mode === 'dkom' ? '4 3' : undefined"
          :fill="selectedIdx === i ? 'rgba(56, 189, 248, 0.12)' : (p.isRootkit && mode === 'dkom' ? 'rgba(244, 63, 94, 0.08)' : 'var(--surface-bg, var(--ink-2))')"
        />

        <!-- Active Traversal Pulse Indicator -->
        <g v-if="traversalIdx === i" transform="translate(6, -8)">
          <rect x="0" y="0" width="74" height="16" rx="4" fill="#38bdf8" />
          <text x="37" y="11" text-anchor="middle" class="svg-active-badge" fill="#0f172a">ACTIVE WALK</text>
        </g>

        <!-- Unlinked Warning Badge -->
        <g v-if="p.isRootkit && mode === 'dkom'" transform="translate(6, -8)">
          <rect x="0" y="0" width="88" height="16" rx="4" fill="#f43f5e" />
          <text x="44" y="11" text-anchor="middle" class="svg-active-badge" fill="#ffffff">DKOM UNLINKED</text>
        </g>

        <!-- Node Header Bar -->
        <rect
          x="0"
          y="0"
          :width="nodeWidth"
          height="24"
          rx="7"
          :fill="p.isRootkit && mode === 'dkom' ? '#f43f5e' : (p.isHead ? '#c084fc' : '#38bdf8')"
          fill-opacity="0.18"
        />
        <text
          x="8"
          y="16"
          class="svg-node-title"
          :fill="p.isRootkit && mode === 'dkom' ? '#f43f5e' : (p.isHead ? '#c084fc' : 'var(--fg)')"
        >
          {{ p.shortName }}
        </text>
        <text x="144" y="16" text-anchor="end" class="svg-node-pid" fill="var(--fg-dim)">
          {{ p.isHead ? 'HEAD' : `PID ${p.pid}` }}
        </text>

        <!-- Node Memory Body -->
        <text x="8" y="38" class="svg-mono-code" fill="var(--fg-dim)">
          {{ p.isHead ? 'LIST_ENTRY' : '_EPROCESS' }}: <tspan fill="var(--fg)">{{ p.baseHex }}</tspan>
        </text>

        <!-- Embedded LIST_ENTRY Sub-box -->
        <g transform="translate(6, 44)">
          <rect
            x="0"
            y="0"
            :width="nodeWidth - 12"
            height="36"
            rx="4"
            fill="var(--ink, #0f172a)"
            fill-opacity="0.4"
            stroke="var(--line)"
            stroke-width="0.8"
          />
          <!-- Flink Field -->
          <text x="6" y="14" class="svg-tiny font-bold" fill="#38bdf8">Flink:</text>
          <text x="36" y="14" class="svg-mono-tiny" fill="var(--fg)">
            {{ p.isRootkit && mode === 'dkom' ? 'Severed (self)' : (i === 4 ? '0x8055B120' : processes[(i+1)%5].linksHex) }}
          </text>

          <line x1="0" y1="18" :x2="nodeWidth - 12" y2="18" stroke="var(--line)" stroke-width="0.5" />

          <!-- Blink Field -->
          <text x="6" y="30" class="svg-tiny font-bold" fill="#c084fc">Blink:</text>
          <text x="36" y="30" class="svg-mono-tiny" fill="var(--fg)">
            {{ p.isRootkit && mode === 'dkom' ? 'Severed (self)' : (i === 0 ? '0x827B8088' : processes[(i-1+5)%5].linksHex) }}
          </text>
        </g>
      </g>
    </svg>

    <!-- Node Inspector & Forensic Insight Panel -->
    <div class="w-full max-w-[920px] grid grid-cols-12 gap-2 mt-1">
      <!-- Col 1: Selected Object Memory Map (5 cols) -->
      <div class="col-span-5 p-2.5 rounded-lg border border-[var(--line)] bg-[var(--surface-bg,var(--ink-2))] flex flex-col justify-between">
        <div class="flex items-center justify-between border-b border-[var(--line)] pb-1 mb-1.5">
          <span class="text-[11px] font-bold text-[var(--fg)] flex items-center gap-1.5">
            <span class="w-2 h-2 rounded-full" :class="currentNode.isRootkit && mode === 'dkom' ? 'bg-rose-500' : 'bg-sky-400'"></span>
            {{ currentNode.name }} (PID: {{ currentNode.pid }})
          </span>
          <span class="text-[9.5px] font-mono px-1.5 py-0.5 rounded bg-[var(--line)] text-[var(--fg-dim)]">
            Offset +0x088
          </span>
        </div>

        <div class="grid grid-cols-2 gap-1 text-[10px] font-mono mb-1">
          <div><span class="text-[var(--fg-dim)]">Base:</span> {{ currentNode.baseHex }}</div>
          <div><span class="text-[var(--fg-dim)]">CR3:</span> {{ currentNode.cr3Hex }}</div>
          <div class="col-span-2 truncate"><span class="text-sky-400 font-bold">Flink:</span> {{ effectiveFlink }}</div>
          <div class="col-span-2 truncate"><span class="text-purple-400 font-bold">Blink:</span> {{ effectiveBlink }}</div>
        </div>

        <!-- CONTAINING_RECORD Explanation -->
        <div class="px-2 py-1 rounded bg-black/25 border border-[var(--line)] text-[9px] font-mono text-[var(--fg-dim)]">
          PEPROCESS p = CONTAINING_RECORD(pLink, EPROCESS, ActiveProcessLinks);
        </div>
      </div>

      <!-- Col 2: Traversal & Forensic Mechanics (7 cols) -->
      <div
        class="col-span-7 p-2.5 rounded-lg border flex flex-col justify-between"
        :class="mode === 'dkom' ? 'border-rose-500/40 bg-rose-500/10' : 'border-sky-500/30 bg-sky-500/10'"
      >
        <div class="flex items-center justify-between">
          <span class="text-[11px] font-bold" :class="mode === 'dkom' ? 'text-rose-400' : 'text-sky-400'">
            {{ mode === 'dkom' ? '★ DKOM Attack Detection Analysis' : '✓ Normal Kernel Enumeration Traversal' }}
          </span>
          <span class="text-[9.5px] px-2 py-0.5 rounded font-mono font-bold" :class="mode === 'dkom' ? 'bg-rose-500/20 text-rose-300' : 'bg-sky-500/20 text-sky-300'">
            {{ mode === 'dkom' ? 'vol pslist BLIND' : 'pslist RECOGNIZED' }}
          </span>
        </div>

        <p class="text-[10.5px] text-[var(--fg)] leading-relaxed my-1">
          <template v-if="mode === 'normal'">
            Userland enumeration APIs (<code>EnumProcesses</code>, Task Manager, <code>vol pslist</code>) start at <code>PsActiveProcessHead</code> and follow <code>Flink</code> sequentially. Each <code>_EPROCESS</code> is discovered and reported.
          </template>
          <template v-else>
            Rootkit rewrote <code>csrss.Flink = &explorer</code> and <code>explorer.Blink = &csrss</code>. Standard API traversal hops cleanly over <code>rootkit.exe</code> (PID 1337) with zero errors—Task Manager is completely blind!
          </template>
        </p>

        <!-- Bottom Warning / Insight Bar -->
        <div class="flex items-center justify-between text-[9.5px] pt-1 border-t" :class="mode === 'dkom' ? 'border-rose-500/20 text-rose-300' : 'border-sky-500/20 text-sky-300'">
          <span v-if="mode === 'dkom'">
            <strong>The Forensic Defense:</strong> <code>vol psscan</code> bypasses pointer links entirely, scanning raw physical RAM for <code>Proc</code> pool tags!
          </span>
          <span v-else>
            <strong>Circular Ring:</strong> <code>explorer.exe.Flink</code> loops directly back to <code>PsActiveProcessHead</code>, terminating the walk.
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.process-linked-list {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
}

.mode-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 3px 10px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  border: 1px solid transparent;
  background: transparent;
  color: var(--fg-dim, #94a3b8);
  cursor: pointer;
  transition: all 0.2s ease;
}

.mode-btn:hover {
  color: var(--fg, #ffffff);
}

.mode-btn.active {
  background: var(--line, rgba(255, 255, 255, 0.08));
  border-color: var(--line);
  color: var(--fg, #ffffff);
}

.step-btn {
  display: inline-flex;
  align-items: center;
  padding: 3px 10px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  font-family: var(--slidev-font-mono, monospace);
  border: 1px solid var(--line);
  background: var(--surface-bg, var(--ink-2));
  color: var(--fg, #e2e8f0);
  cursor: pointer;
  transition: all 0.2s ease;
}

.step-btn:hover {
  background: var(--line);
  color: #38bdf8;
  border-color: #38bdf8;
}

.step-btn.reset {
  color: var(--fg-dim);
}

.step-btn.reset:hover {
  color: #f43f5e;
  border-color: #f43f5e;
}

.dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

/* SVG Typography Classes (Strict Pixels) */
.svg-node-card {
  transition: all 0.2s ease;
}

.svg-node-title {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 10.5px !important;
  font-weight: 700 !important;
}

.svg-node-pid {
  font-family: var(--slidev-font-mono, monospace);
  font-size: 9px !important;
  font-weight: 600 !important;
}

.svg-active-badge {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 8.5px !important;
  font-weight: 800 !important;
  letter-spacing: 0.04em !important;
}

.svg-link-label {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 8.5px !important;
  font-weight: 700 !important;
}

.svg-bypass-label {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 8.5px !important;
  font-weight: 700 !important;
}

.svg-mono-code {
  font-family: var(--slidev-font-mono, monospace);
  font-size: 9px !important;
}

.svg-mono-tiny {
  font-family: var(--slidev-font-mono, monospace);
  font-size: 8px !important;
}

.svg-tiny {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 8.5px !important;
}

/* Light Variant Adjustments */
:root[data-variant='soft'] .svg-node-card,
:root[data-variant='minimal'] .svg-node-card {
  fill: #ffffff;
}
</style>

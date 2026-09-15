<script setup>
import { ref, computed } from 'vue'

// Curated interactive page directory & table dataset
const directories = [
  {
    id: 'pde-user',
    name: 'PDE 1',
    dirIndex: 1, // 0x001 -> bits 31..22: 0x00400000 base
    dirIndexBits: '0000000001',
    ptBaseHex: '0x1A400',
    flags: 'Present, R/W (User)',
    label: 'User Space (0x00400000)',
    entries: [
      {
        id: 'pte-code',
        name: 'PTE 1',
        tableIndex: 1, // 0x001
        tableIndexBits: '0000000001',
        label: '.text (Code)',
        frameHex: '0x05B20',
        flags: 'Present, R/O (User)',
        isFault: false,
        isRwx: false,
        offset: 0x0A4,
        offsetHex: '0x0A4',
        offsetBits: '000010100100',
        desc: 'Legitimate mapped code section'
      },
      {
        id: 'pte-rdata',
        name: 'PTE 2',
        tableIndex: 2, // 0x002
        tableIndexBits: '0000000010',
        label: '.rdata (Imports)',
        frameHex: '0x06C30',
        flags: 'Present, R/O (User)',
        isFault: false,
        isRwx: false,
        offset: 0x1F0,
        offsetHex: '0x1F0',
        offsetBits: '000111110000',
        desc: 'IAT & string literals'
      },
      {
        id: 'pte-swap',
        name: 'PTE 3',
        tableIndex: 3, // 0x003
        tableIndexBits: '0000000011',
        label: 'Evicted (Pagefile)',
        frameHex: 'None (Swap)',
        flags: 'Not Present (V=0)',
        isFault: true,
        isRwx: false,
        offset: 0x400,
        offsetHex: '0x400',
        offsetBits: '010000000000',
        desc: 'Flushed to pagefile.sys to free physical RAM'
      }
    ]
  },
  {
    id: 'pde-injected',
    name: 'PDE 2',
    dirIndex: 2, // 0x002 -> bits 31..22: 0x00800000 base
    dirIndexBits: '0000000010',
    ptBaseHex: '0x22000',
    flags: 'Present, R/W (User)',
    label: 'Injected Heap (0x00800000)',
    entries: [
      {
        id: 'pte-heap-rw',
        name: 'PTE 1',
        tableIndex: 1, // 0x001
        tableIndexBits: '0000000001',
        label: 'Heap Buffer',
        frameHex: '0x07D10',
        flags: 'Present, R/W (User)',
        isFault: false,
        isRwx: false,
        offset: 0x040,
        offsetHex: '0x040',
        offsetBits: '000001000000',
        desc: 'Allocated payload buffer'
      },
      {
        id: 'pte-rwx',
        name: 'PTE 2',
        tableIndex: 2, // 0x002
        tableIndexBits: '0000000010',
        label: 'Shellcode (RWX)',
        frameHex: '0x08F40',
        flags: 'Present, RWX (W^X Fail)',
        isFault: false,
        isRwx: true,
        offset: 0x1B8,
        offsetHex: '0x1B8',
        offsetBits: '000110111000',
        desc: 'Unbacked RWX VAD allocation — flagged by malfind'
      },
      {
        id: 'pte-unmapped',
        name: 'PTE 3',
        tableIndex: 3, // 0x003
        tableIndexBits: '0000000011',
        label: 'Guard Page',
        frameHex: 'None (Null)',
        flags: 'Not Present (V=0)',
        isFault: true,
        isRwx: false,
        offset: 0x000,
        offsetHex: '0x000',
        offsetBits: '000000000000',
        desc: 'Access triggers #GP or SIGSEGV fault'
      }
    ]
  },
  {
    id: 'pde-kernel',
    name: 'PDE 768',
    dirIndex: 768, // 0x300 -> bits 31..22: 0xC0000000 base
    dirIndexBits: '1100000000',
    ptBaseHex: '0x3F000',
    flags: 'Present, R/W (Supervisor)',
    label: 'Kernel Space (0xC0000000)',
    entries: [
      {
        id: 'pte-eprocess',
        name: 'PTE 1',
        tableIndex: 1, // 0x001
        tableIndexBits: '0000000001',
        label: '_EPROCESS Links',
        frameHex: '0x02040',
        flags: 'Present, R/W (Kernel)',
        isFault: false,
        isRwx: false,
        offset: 0x088,
        offsetHex: '0x088',
        offsetBits: '000010001000',
        desc: 'Targeted by DKOM rootkits'
      },
      {
        id: 'pte-ssdt',
        name: 'PTE 2',
        tableIndex: 2, // 0x002
        tableIndexBits: '0000000010',
        label: 'SSDT Syscall Table',
        frameHex: '0x03150',
        flags: 'Present, R/O (Kernel)',
        isFault: false,
        isRwx: false,
        offset: 0x100,
        offsetHex: '0x100',
        offsetBits: '000100000000',
        desc: 'Syscall handler dispatch table'
      },
      {
        id: 'pte-kern-fault',
        name: 'PTE 3',
        tableIndex: 3, // 0x003
        tableIndexBits: '0000000011',
        label: 'Paged Kernel Pool',
        frameHex: 'None (Swap)',
        flags: 'Not Present (V=0)',
        isFault: true,
        isRwx: false,
        offset: 0x020,
        offsetHex: '0x020',
        offsetBits: '000000100000',
        desc: 'Non-resident kernel memory'
      }
    ]
  }
]

// Reactive selection state
const selectedPdeIdx = ref(0)
const selectedPteIdx = ref(0)
const currentScenario = ref('code')

function setScenario(sc) {
  currentScenario.value = sc
  if (sc === 'code') {
    selectedPdeIdx.value = 0
    selectedPteIdx.value = 0
  } else if (sc === 'rwx') {
    selectedPdeIdx.value = 1
    selectedPteIdx.value = 1
  } else if (sc === 'fault') {
    selectedPdeIdx.value = 0
    selectedPteIdx.value = 2
  } else if (sc === 'kernel') {
    selectedPdeIdx.value = 2
    selectedPteIdx.value = 0
  }
}

function selectPde(idx) {
  selectedPdeIdx.value = idx
  if (selectedPteIdx.value >= directories[idx].entries.length) {
    selectedPteIdx.value = 0
  }
  updateScenarioMatch()
}

function selectPte(idx) {
  selectedPteIdx.value = idx
  updateScenarioMatch()
}

function updateScenarioMatch() {
  if (selectedPdeIdx.value === 0 && selectedPteIdx.value === 0) currentScenario.value = 'code'
  else if (selectedPdeIdx.value === 1 && selectedPteIdx.value === 1) currentScenario.value = 'rwx'
  else if (selectedPdeIdx.value === 0 && selectedPteIdx.value === 2) currentScenario.value = 'fault'
  else if (selectedPdeIdx.value === 2 && selectedPteIdx.value === 0) currentScenario.value = 'kernel'
  else currentScenario.value = 'custom'
}

const currentPde = computed(() => directories[selectedPdeIdx.value])
const currentPte = computed(() => currentPde.value.entries[selectedPteIdx.value])

// Compute full 32-bit linear virtual address
const virtualAddressHex = computed(() => {
  const dirBits = currentPde.value.dirIndex << 22
  const tblBits = currentPte.value.tableIndex << 12
  const offBits = currentPte.value.offset
  const num = (dirBits | tblBits | offBits) >>> 0
  return '0x' + num.toString(16).toUpperCase().padStart(8, '0')
})

// Compute final 32-bit physical address
const physicalAddressHex = computed(() => {
  if (currentPte.value.isFault) return 'None (#PF)'
  const frameVal = parseInt(currentPte.value.frameHex, 16)
  const num = ((frameVal << 12) | currentPte.value.offset) >>> 0
  return '0x' + num.toString(16).toUpperCase().padStart(8, '0')
})

// Exact vertical centers of table rows for clean SVG connecting arrows
// PD table y=42, header 26px, row height 40px, gap 6px -> centers: 88, 134, 180
const pdeRowY = computed(() => 88 + selectedPdeIdx.value * 46)
const pteRowY = computed(() => 88 + selectedPteIdx.value * 46)
</script>

<template>
  <div class="x86-pipeline w-full flex flex-col items-center select-none">
    <!-- 1. Interactive Scenario Switcher -->
    <div class="flex items-center gap-2 mb-2 flex-wrap justify-center">
      <button
        class="ctrl-btn"
        :class="{ active: currentScenario === 'code' }"
        @click="setScenario('code')"
      >
        <span class="dot bg-sky-400"></span>
        1. User Code (.text)
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: currentScenario === 'rwx' }"
        @click="setScenario('rwx')"
      >
        <span class="dot bg-amber-400"></span>
        2. Injected RWX (malfind)
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: currentScenario === 'fault' }"
        @click="setScenario('fault')"
      >
        <span class="dot bg-rose-400"></span>
        3. Page Fault (#PF)
      </button>
      <button
        class="ctrl-btn"
        :class="{ active: currentScenario === 'kernel' }"
        @click="setScenario('kernel')"
      >
        <span class="dot bg-purple-400"></span>
        4. Kernel Memory (DKOM)
      </button>
    </div>

    <!-- 2. 32-bit Linear Virtual Address Bitfield Bar (Clean HTML Flexbox) -->
    <div class="va-bar w-full max-w-[840px] flex items-center justify-between gap-2 px-3 py-1.5 rounded-lg border border-[var(--line)] bg-[var(--surface-bg,var(--ink-2))] mb-2 text-xs">
      <!-- Field 1: Directory Index -->
      <div class="flex-1 flex items-center justify-between px-2.5 py-1 rounded border border-sky-500/30 bg-sky-500/10">
        <div class="flex flex-col">
          <span class="text-[10px] font-bold text-sky-400 uppercase tracking-wider">Directory Index [31..22]</span>
          <span class="font-mono text-[11px] font-semibold text-[var(--fg)]">
            0x{{ currentPde.dirIndex.toString(16).toUpperCase() }}
            <span class="text-[9.5px] text-[var(--fg-dim)] font-normal">({{ currentPde.dirIndexBits }}b)</span>
          </span>
        </div>
        <span class="text-[9px] px-1.5 py-0.5 rounded bg-sky-400/20 text-sky-300 font-mono">10b</span>
      </div>

      <!-- Arrow separator -->
      <span class="text-[var(--fg-dim)] font-mono text-xs">/</span>

      <!-- Field 2: Table Index -->
      <div class="flex-1 flex items-center justify-between px-2.5 py-1 rounded border border-purple-500/30 bg-purple-500/10">
        <div class="flex flex-col">
          <span class="text-[10px] font-bold text-purple-400 uppercase tracking-wider">Table Index [21..12]</span>
          <span class="font-mono text-[11px] font-semibold text-[var(--fg)]">
            0x{{ currentPte.tableIndex.toString(16).toUpperCase() }}
            <span class="text-[9.5px] text-[var(--fg-dim)] font-normal">({{ currentPte.tableIndexBits }}b)</span>
          </span>
        </div>
        <span class="text-[9px] px-1.5 py-0.5 rounded bg-purple-400/20 text-purple-300 font-mono">10b</span>
      </div>

      <!-- Arrow separator -->
      <span class="text-[var(--fg-dim)] font-mono text-xs">/</span>

      <!-- Field 3: Byte Offset -->
      <div class="flex-1 flex items-center justify-between px-2.5 py-1 rounded border border-amber-500/30 bg-amber-500/10">
        <div class="flex flex-col">
          <span class="text-[10px] font-bold text-amber-400 uppercase tracking-wider">Byte Offset [11..0]</span>
          <span class="font-mono text-[11px] font-semibold text-[var(--fg)]">
            +{{ currentPte.offsetHex }}
            <span class="text-[9.5px] text-[var(--fg-dim)] font-normal">(4 KB Page)</span>
          </span>
        </div>
        <span class="text-[9px] px-1.5 py-0.5 rounded bg-amber-400/20 text-amber-300 font-mono">12b</span>
      </div>

      <!-- Separator -->
      <div class="h-6 w-px bg-[var(--line)] mx-1"></div>

      <!-- Full Linear VA Badge -->
      <div class="flex flex-col items-end shrink-0 pl-1">
        <span class="text-[9px] uppercase tracking-wider text-[var(--fg-dim)] font-semibold">Linear Virtual Address</span>
        <span class="font-mono text-xs font-bold text-sky-400">{{ virtualAddressHex }}</span>
      </div>
    </div>

    <!-- 3. Main SVG Hardware Paging Diagram (Compact 250px height) -->
    <svg
      viewBox="0 0 960 250"
      class="w-full h-auto"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <!-- Arrowhead Markers -->
        <marker id="arr-rose" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 z" fill="#f43f5e" />
        </marker>
        <marker id="arr-sky" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 z" fill="#38bdf8" />
        </marker>
        <marker id="arr-purple" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 z" fill="#c084fc" />
        </marker>
        <marker id="arr-amber" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 z" fill="#fbbf24" />
        </marker>
        <marker id="arr-emerald" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 z" fill="#10b981" />
        </marker>
      </defs>

      <!-- ===================================================================== -->
      <!-- STEP 1: CPU Root (CR3 Register)                                       -->
      <!-- ===================================================================== -->
      <g transform="translate(16, 12)">
        <!-- Step Header -->
        <rect x="0" y="0" width="18" height="18" rx="4" fill="#f43f5e" />
        <text x="9" y="13" text-anchor="middle" class="svg-badge-num" fill="#ffffff">1</text>
        <text x="26" y="14" class="svg-hdr-text" fill="#f43f5e">CPU Root</text>

        <!-- CR3 Card -->
        <g transform="translate(0, 30)">
          <rect x="0" y="0" width="124" height="194" rx="6" class="svg-card" stroke="#f43f5e" stroke-width="1.5" />
          <rect x="0" y="0" width="124" height="26" rx="6" fill="#f43f5e" fill-opacity="0.15" />
          <text x="62" y="17" text-anchor="middle" class="svg-mono-bold" fill="#f43f5e">CR3 Register</text>

          <text x="12" y="52" class="svg-tiny uppercase tracking-wider" fill="var(--fg-dim)">Hardware Base</text>
          <text x="12" y="70" class="svg-mono-lg" fill="var(--fg)">0x12000</text>
          
          <line x1="12" y1="88" x2="112" y2="88" stroke="var(--line)" stroke-width="1" />

          <text x="12" y="108" class="svg-card-sub" fill="var(--fg)">Directory Table Base</text>
          <text x="12" y="124" class="svg-tiny" fill="var(--fg-dim)">• Per-process root pointer</text>
          <text x="12" y="138" class="svg-tiny" fill="var(--fg-dim)">• Physical memory frame</text>
          <text x="12" y="152" class="svg-tiny" fill="var(--fg-dim)">• Windows: _KPROCESS</text>
          <text x="12" y="166" class="svg-tiny" fill="var(--fg-dim)">• Linux: mm_struct.pgd</text>
        </g>

        <!-- Arrow: CR3 -> Page Directory Base -->
        <path
          d="M 124 105 L 158 105"
          stroke="#f43f5e"
          stroke-width="2"
          marker-end="url(#arr-rose)"
        />
      </g>

      <!-- ===================================================================== -->
      <!-- STEP 2: Page Directory (PD - Clickable PDEs)                          -->
      <!-- ===================================================================== -->
      <g transform="translate(176, 12)">
        <!-- Step Header -->
        <rect x="0" y="0" width="18" height="18" rx="4" fill="#38bdf8" />
        <text x="9" y="13" text-anchor="middle" class="svg-badge-num" fill="#ffffff">2</text>
        <text x="26" y="14" class="svg-hdr-text" fill="#38bdf8">Page Directory (PD)</text>

        <!-- Table Container -->
        <g transform="translate(0, 30)">
          <rect x="0" y="0" width="176" height="194" rx="6" class="svg-card" stroke="var(--line)" stroke-width="1.2" />
          <text x="88" y="17" text-anchor="middle" class="svg-tiny" fill="var(--fg-dim)">Base: 0x12000 (from CR3)</text>
          <line x1="0" y1="24" x2="176" y2="24" stroke="var(--line)" stroke-width="1" />

          <!-- Interactive PDE Rows -->
          <g v-for="(pde, i) in directories" :key="pde.id" :transform="`translate(4, ${28 + i * 46})`">
            <g class="cursor-pointer" @click="selectPde(i)">
              <rect
                x="0"
                y="0"
                width="168"
                height="40"
                rx="5"
                :fill="selectedPdeIdx === i ? 'rgba(56, 189, 248, 0.2)' : 'rgba(255,255,255,0.02)'"
                :stroke="selectedPdeIdx === i ? '#38bdf8' : 'var(--line)'"
                :stroke-width="selectedPdeIdx === i ? 1.8 : 1"
                class="transition-all"
              />
              <text x="8" y="15" class="svg-mono-bold" :fill="selectedPdeIdx === i ? '#38bdf8' : 'var(--fg)'">
                {{ pde.name }}
              </text>
              <text x="8" y="26" class="svg-mono-code" fill="var(--fg)">PT Base: {{ pde.ptBaseHex }}</text>
              <text x="8" y="35" class="svg-tiny" :fill="selectedPdeIdx === i ? '#38bdf8' : 'var(--fg-dim)'">{{ pde.flags }}</text>
            </g>
          </g>

          <!-- Footer info -->
          <line x1="0" y1="168" x2="176" y2="168" stroke="var(--line)" stroke-width="1" />
          <text x="88" y="180" text-anchor="middle" class="svg-tiny" fill="var(--fg-dim)">1,024 PDEs × 4B = 4 KB Frame</text>
          <text x="88" y="190" text-anchor="middle" class="svg-tiny" fill="var(--fg-dim)">Covers 4 GB Address Space</text>
        </g>

        <!-- Arrow: Selected PDE -> Page Table Base -->
        <path
          :d="`M 176 ${pdeRowY} L 222 ${pdeRowY}`"
          stroke="#38bdf8"
          stroke-width="2"
          marker-end="url(#arr-sky)"
        />
      </g>

      <!-- ===================================================================== -->
      <!-- STEP 3: Page Table (PT - Clickable PTEs)                               -->
      <!-- ===================================================================== -->
      <g transform="translate(400, 12)">
        <!-- Step Header -->
        <rect x="0" y="0" width="18" height="18" rx="4" fill="#c084fc" />
        <text x="9" y="13" text-anchor="middle" class="svg-badge-num" fill="#ffffff">3</text>
        <text x="26" y="14" class="svg-hdr-text" fill="#c084fc">Page Table (PT)</text>

        <!-- Table Container -->
        <g transform="translate(0, 30)">
          <rect x="0" y="0" width="180" height="194" rx="6" class="svg-card" stroke="var(--line)" stroke-width="1.2" />
          <text x="90" y="17" text-anchor="middle" class="svg-tiny" fill="var(--fg-dim)">PT Base: {{ currentPde.ptBaseHex }}</text>
          <line x1="0" y1="24" x2="180" y2="24" stroke="var(--line)" stroke-width="1" />

          <!-- Interactive PTE Rows -->
          <g v-for="(pte, i) in currentPde.entries" :key="pte.id" :transform="`translate(4, ${28 + i * 46})`">
            <g class="cursor-pointer" @click="selectPte(i)">
              <rect
                x="0"
                y="0"
                width="172"
                height="40"
                rx="5"
                :fill="selectedPteIdx === i ? (pte.isFault ? 'rgba(244, 63, 94, 0.2)' : (pte.isRwx ? 'rgba(251, 191, 36, 0.2)' : 'rgba(192, 132, 252, 0.2)')) : 'rgba(255,255,255,0.02)'"
                :stroke="selectedPteIdx === i ? (pte.isFault ? '#f43f5e' : (pte.isRwx ? '#fbbf24' : '#c084fc')) : 'var(--line)'"
                :stroke-width="selectedPteIdx === i ? 1.8 : 1"
                class="transition-all"
              />
              <text x="8" y="15" class="svg-mono-bold" :fill="selectedPteIdx === i ? (pte.isFault ? '#f43f5e' : (pte.isRwx ? '#fbbf24' : '#c084fc')) : 'var(--fg)'">
                {{ pte.name }}: {{ pte.label }}
              </text>
              <text x="8" y="26" class="svg-mono-code" fill="var(--fg)">Frame: {{ pte.frameHex }}</text>
              <text x="8" y="35" class="svg-tiny" :fill="pte.isFault ? '#f43f5e' : (pte.isRwx ? '#fbbf24' : 'var(--fg-dim)')">{{ pte.flags }}</text>
            </g>
          </g>

          <!-- Footer info -->
          <line x1="0" y1="168" x2="180" y2="168" stroke="var(--line)" stroke-width="1" />
          <text x="90" y="180" text-anchor="middle" class="svg-tiny" fill="var(--fg-dim)">1,024 PTEs × 4B = 4 KB Frame</text>
          <text x="90" y="190" text-anchor="middle" class="svg-tiny" fill="var(--fg-dim)">Covers 4 MB Virtual Space</text>
        </g>

        <!-- Arrow: Selected PTE -> Step 4 Target -->
        <path
          :d="`M 180 ${pteRowY} L 228 ${pteRowY}`"
          :stroke="currentPte.isFault ? '#f43f5e' : (currentPte.isRwx ? '#fbbf24' : '#c084fc')"
          stroke-width="2"
          :marker-end="currentPte.isFault ? 'url(#arr-rose)' : (currentPte.isRwx ? 'url(#arr-amber)' : 'url(#arr-purple)')"
        />
      </g>

      <!-- ===================================================================== -->
      <!-- STEP 4: Physical Address Assembly OR Page Fault Trap (#PF)            -->
      <!-- ===================================================================== -->
      <g transform="translate(630, 12)">
        <!-- Step Header -->
        <rect x="0" y="0" width="18" height="18" rx="4" :fill="currentPte.isFault ? '#f43f5e' : (currentPte.isRwx ? '#fbbf24' : '#10b981')" />
        <text x="9" y="13" text-anchor="middle" class="svg-badge-num" fill="#ffffff">4</text>
        <text x="26" y="14" class="svg-hdr-text" :fill="currentPte.isFault ? '#f43f5e' : (currentPte.isRwx ? '#fbbf24' : '#10b981')">
          {{ currentPte.isFault ? 'Page Fault Trap (#PF)' : 'Physical DRAM Target' }}
        </text>

        <!-- STATE A: Valid Present Page (DRAM Accessible) -->
        <g v-if="!currentPte.isFault" transform="translate(0, 30)">
          <!-- Top: Physical Address Bit Assembly Card -->
          <g transform="translate(0, 0)">
            <rect
              x="0"
              y="0"
              width="314"
              height="40"
              rx="6"
              class="svg-card"
              :stroke="currentPte.isRwx ? '#fbbf24' : '#10b981'"
              stroke-width="1.2"
            />
            
            <!-- PFN Component -->
            <rect
              x="3"
              y="3"
              width="174"
              height="34"
              rx="4"
              :fill="currentPte.isRwx ? '#fbbf24' : '#c084fc'"
              fill-opacity="0.14"
              :stroke="currentPte.isRwx ? '#fbbf24' : '#c084fc'"
              stroke-width="1"
            />
            <text x="90" y="16" text-anchor="middle" class="svg-card-title" :fill="currentPte.isRwx ? '#fbbf24' : '#c084fc'">PFN (20 bits)</text>
            <text x="90" y="29" text-anchor="middle" class="svg-mono-code" fill="var(--fg)">Frame {{ currentPte.frameHex }}</text>

            <!-- Offset Component -->
            <rect x="181" y="3" width="130" height="34" rx="4" fill="#fbbf24" fill-opacity="0.14" stroke="#fbbf24" stroke-width="1" />
            <text x="246" y="16" text-anchor="middle" class="svg-card-title" fill="#fbbf24">Offset (12 bits)</text>
            <text x="246" y="29" text-anchor="middle" class="svg-mono-code" fill="var(--fg)">+{{ currentPte.offsetHex }}</text>
          </g>

          <!-- Arrow down: Assembled Address -> Exact DRAM Frame -->
          <path
            d="M 157 40 L 157 52"
            :stroke="currentPte.isRwx ? '#fbbf24' : '#10b981'"
            stroke-width="1.8"
            :marker-end="currentPte.isRwx ? 'url(#arr-amber)' : 'url(#arr-emerald)'"
          />

          <!-- Physical DRAM Frame Container -->
          <g transform="translate(0, 54)">
            <rect
              x="0"
              y="0"
              width="314"
              height="140"
              rx="6"
              class="svg-card"
              :stroke="currentPte.isRwx ? '#fbbf24' : '#10b981'"
              stroke-width="1.6"
              :fill="currentPte.isRwx ? 'color-mix(in srgb, #fbbf24 8%, var(--surface-bg, var(--ink-2)))' : 'color-mix(in srgb, #10b981 7%, var(--surface-bg, var(--ink-2)))'"
            />

            <!-- DRAM Frame Header -->
            <rect x="0" y="0" width="314" height="24" rx="6" :fill="currentPte.isRwx ? '#fbbf24' : '#10b981'" fill-opacity="0.2" />
            <text x="12" y="16" class="svg-mono-bold" :fill="currentPte.isRwx ? '#fbbf24' : '#10b981'">
              DRAM Frame: {{ currentPte.frameHex }}
            </text>
            <text x="302" y="16" text-anchor="end" class="svg-tiny" fill="var(--fg-dim)">4,096 Bytes</text>

            <!-- Memory Grid Guides -->
            <line x1="0" y1="42" x2="314" y2="42" stroke="var(--line)" stroke-dasharray="3 3" />
            <line x1="0" y1="84" x2="314" y2="84" stroke="var(--line)" stroke-dasharray="3 3" />

            <!-- Prominent Target Byte Card -->
            <g transform="translate(10, 34)">
              <rect
                x="0"
                y="0"
                width="294"
                height="42"
                rx="5"
                :fill="currentPte.isRwx ? '#fbbf24' : '#10b981'"
                fill-opacity="0.18"
                :stroke="currentPte.isRwx ? '#fbbf24' : '#10b981'"
                stroke-width="1.2"
              />
              
              <!-- Left side: Micro-label and huge physical address -->
              <text x="12" y="15" class="svg-tiny font-bold tracking-wider" fill="var(--fg-dim)">PHYSICAL BYTE ADDRESS</text>
              <text x="12" y="32" class="svg-mono-lg" :fill="currentPte.isRwx ? '#fbbf24' : '#10b981'">{{ physicalAddressHex }}</text>
              
              <!-- Right side: Offset badge -->
              <rect x="206" y="12" width="76" height="20" rx="4" fill="rgba(0,0,0,0.3)" stroke="var(--line)" stroke-width="0.8" />
              <text x="244" y="25" text-anchor="middle" class="svg-mono-code font-bold" fill="var(--fg)">+{{ currentPte.offsetHex }}</text>
            </g>

            <!-- Security Context Feedback Tag -->
            <g v-if="currentPte.isRwx" transform="translate(10, 86)">
              <rect x="0" y="0" width="294" height="44" rx="5" fill="#fbbf24" fill-opacity="0.14" stroke="#fbbf24" stroke-width="1" />
              <text x="10" y="16" class="svg-mono-bold" fill="#fbbf24">★ RWX RED FLAG (W^X VIOLATION)</text>
              <text x="10" y="28" class="svg-tiny font-semibold" fill="var(--fg)">Unbacked executable memory carved by malfind</text>
              <text x="10" y="38" class="svg-tiny font-mono" fill="#fbbf24">PAGE_EXECUTE_READWRITE</text>
            </g>

            <g v-else transform="translate(10, 86)">
              <rect x="0" y="0" width="294" height="44" rx="5" fill="#10b981" fill-opacity="0.14" stroke="#10b981" stroke-width="1" />
              <text x="10" y="16" class="svg-mono-bold" fill="#10b981">✓ VERIFIED PHYSICAL ADDRESS</text>
              <text x="10" y="28" class="svg-tiny font-semibold" fill="var(--fg)">CPU MMU executes direct bus memory access</text>
              <text x="10" y="38" class="svg-tiny font-mono" fill="#10b981">Page protection enforced by hardware</text>
            </g>
          </g>
        </g>

        <!-- STATE B: Page Fault Trap (#PF - Standard sequential numbering) -->
        <g v-else transform="translate(0, 30)">
          <rect
            x="0"
            y="0"
            width="314"
            height="194"
            rx="6"
            class="svg-card"
            stroke="#f43f5e"
            stroke-width="1.8"
            fill="color-mix(in srgb, #f43f5e 8%, var(--surface-bg, var(--ink-2)))"
          />

          <!-- Title Bar -->
          <rect x="0" y="0" width="314" height="26" rx="6" fill="#f43f5e" fill-opacity="0.25" />
          <text x="12" y="17" class="svg-mono-bold" fill="#f43f5e">INTERRUPT 14: #PF (PAGE FAULT)</text>
          <text x="302" y="17" text-anchor="end" class="svg-tiny font-bold font-mono" fill="#f43f5e">Present (V) = 0</text>

          <!-- Warning Header -->
          <g transform="translate(10, 34)">
            <rect x="0" y="0" width="294" height="34" rx="5" fill="#f43f5e" fill-opacity="0.15" stroke="#f43f5e" stroke-width="1" />
            <text x="10" y="15" class="svg-mono-bold" fill="#f43f5e">Hardware Address Walk Halted</text>
            <text x="10" y="27" class="svg-tiny" fill="var(--fg)">PTE points to disk swap slot (pagefile.sys)</text>
          </g>

          <!-- Normal Sequential Numbered OS Recovery List (Clean, high-contrast) -->
          <g transform="translate(10, 74)">
            <rect x="0" y="0" width="294" height="112" rx="5" fill="var(--surface-bg, var(--ink-2))" stroke="var(--line)" stroke-width="1" />
            <text x="10" y="16" class="svg-mono-bold" fill="#38bdf8">OS Kernel Recovery Sequence:</text>
            
            <!-- Step 1 -->
            <text x="12" y="34" class="svg-mono-bold" fill="#38bdf8">1.</text>
            <text x="28" y="34" class="svg-card-sub" fill="var(--fg)">CPU generates Interrupt 14 (#PF trap)</text>

            <!-- Step 2 -->
            <text x="12" y="54" class="svg-mono-bold" fill="#c084fc">2.</text>
            <text x="28" y="54" class="svg-card-sub" fill="var(--fg)">Kernel trap handler allocates free DRAM frame</text>

            <!-- Step 3 -->
            <text x="12" y="74" class="svg-mono-bold" fill="#fbbf24">3.</text>
            <text x="28" y="74" class="svg-card-sub" fill="var(--fg)">Reads 4 KB page from pagefile.sys into frame</text>

            <!-- Step 4 -->
            <text x="12" y="94" class="svg-mono-bold" fill="#10b981">4.</text>
            <text x="28" y="94" class="svg-card-sub" fill="var(--fg)">Sets Present=1 &amp; re-executes instruction</text>

            <text x="10" y="106" class="svg-tiny" fill="var(--fg-dim)">Transparent to userland process</text>
          </g>
        </g>
      </g>
    </svg>
  </div>
</template>

<style scoped>
.x86-pipeline {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
}

.ctrl-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 3px 10px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  border: 1px solid var(--line);
  background: var(--surface-bg, var(--ink-2));
  color: var(--fg, #e2e8f0);
  cursor: pointer;
  transition: all 0.2s ease;
}

.ctrl-btn:hover {
  background: var(--line);
  color: var(--fg, #ffffff);
}

.ctrl-btn.active {
  border-color: #38bdf8;
  background: rgba(56, 189, 248, 0.16);
  color: #38bdf8;
}

.dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

/* SVG Structural Styles */
.svg-card {
  fill: var(--surface-bg, var(--ink-2));
  transition: fill 0.2s ease, stroke 0.2s ease;
}

/* STRICT PIXEL FONT SIZES for SVG texts - Prevents unitless or rem scaling bugs */
.svg-badge-num {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 11px !important;
  font-weight: 700 !important;
}

.svg-hdr-text {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 12px !important;
  font-weight: 700 !important;
}

.svg-card-title {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 11px !important;
  font-weight: 700 !important;
}

.svg-card-sub {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 9.5px !important;
  font-weight: 500 !important;
}

.svg-mono-code {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
  font-size: 9.5px !important;
  font-weight: 500 !important;
}

.svg-mono-bold {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
  font-size: 10.5px !important;
  font-weight: 700 !important;
}

.svg-mono-lg {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
  font-size: 13.5px !important;
  font-weight: 800 !important;
}

.svg-tiny {
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
  font-size: 8.5px !important;
}

/* Light Variant Adjustments */
:root[data-variant='soft'] .svg-card,
:root[data-variant='minimal'] .svg-card,
:root[data-variant='paper'] .svg-card {
  fill: #ffffff;
}

:root[data-variant='soft'] .ctrl-btn,
:root[data-variant='minimal'] .ctrl-btn,
:root[data-variant='paper'] .ctrl-btn {
  background: #ffffff;
  color: #1e293b;
}
</style>

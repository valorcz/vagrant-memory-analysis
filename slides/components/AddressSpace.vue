<script setup>
defineProps({
  mode: {
    type: String,
    default: 'windows', // 'windows' | 'linux'
  },
  height: {
    type: String,
    default: '240px',
  },
})
</script>

<template>
  <div class="address-space-container w-full select-none py-1">
    <!-- Windows Mode -->
    <div v-if="mode === 'windows' || mode === 'win32'" class="flex items-center justify-center gap-6">
      <!-- Windows Default (2GB / 2GB) -->
      <div class="bar-group flex flex-col items-center">
        <span class="bar-header">Default</span>
        <div class="memory-bar flex flex-col" :style="{ height: height, width: '130px' }">
          <!-- Address Top -->
          <div class="addr-label top-0">0xFFFFFFFF</div>

          <!-- Kernel Space (2GB = 50%) -->
          <div class="kernel-segment flex-[2] flex flex-col items-center justify-center relative">
            <span class="segment-title">Kernel Space</span>
            <span class="segment-sub">2 GB</span>
            <div class="boundary-label">0x80000000</div>
          </div>

          <!-- User Space (2GB = 50%) -->
          <div class="user-segment flex-[2] flex flex-col items-center justify-center relative">
            <span class="segment-title">User Space</span>
            <span class="segment-sub">2 GB</span>
          </div>

          <!-- Address Bottom -->
          <div class="addr-label bottom-0">0x00000000</div>
        </div>
        <span class="bar-footer">2G User / 2G Kernel</span>
      </div>

      <!-- Windows /3GB Switch (3GB User / 1GB Kernel) -->
      <div class="bar-group flex flex-col items-center">
        <span class="bar-header text-amber-400">/3GB Switch</span>
        <div class="memory-bar flex flex-col" :style="{ height: height, width: '130px' }">
          <!-- Address Top -->
          <div class="addr-label top-0">0xFFFFFFFF</div>

          <!-- Kernel Space (1GB = 25%) -->
          <div class="kernel-segment flex-[1] flex flex-col items-center justify-center relative">
            <span class="segment-title">Kernel</span>
            <span class="segment-sub">1 GB</span>
            <div class="boundary-label">0xC0000000</div>
          </div>

          <!-- User Space (3GB = 75%) -->
          <div class="user-segment flex-[3] flex flex-col items-center justify-center relative">
            <span class="segment-title">User Space</span>
            <span class="segment-sub">3 GB</span>
          </div>

          <!-- Address Bottom -->
          <div class="addr-label bottom-0">0x00000000</div>
        </div>
        <span class="bar-footer">3G User / 1G Kernel</span>
      </div>
    </div>

    <!-- Linux Mode -->
    <div v-else-if="mode === 'linux'" class="flex items-center justify-center gap-6">
      <!-- Linux Default (3GB / 1GB) -->
      <div class="bar-group flex flex-col items-center">
        <span class="bar-header">Default (3:1)</span>
        <div class="memory-bar flex flex-col" :style="{ height: height, width: '130px' }">
          <!-- Address Top -->
          <div class="addr-label top-0">0xFFFFFFFF</div>

          <!-- Kernel Space (1GB = 25%) -->
          <div class="kernel-segment flex-[1] flex flex-col items-center justify-center relative">
            <span class="segment-title">Kernel (1 GB)</span>
            <div class="boundary-label">0xC0000000</div>
          </div>

          <!-- User Space (3GB = 75%) -->
          <div class="user-segment flex-[3] flex flex-col items-center justify-center relative">
            <span class="segment-title">User Space</span>
            <span class="segment-sub">3 GB (TASK_SIZE)</span>
          </div>

          <!-- Address Bottom -->
          <div class="addr-label bottom-0">0x00000000</div>
        </div>
        <span class="bar-footer">Single Page Directory</span>
      </div>

      <!-- Linux HugeMem (4GB / 4GB Dual Space) -->
      <div class="bar-group flex flex-col items-center">
        <span class="bar-header text-purple-400">HugeMem (4G : 4G)</span>
        <div class="flex gap-1.5" :style="{ height: height }">
          <!-- User 4GB Bar -->
          <div class="memory-bar flex flex-col" style="width: 62px;">
            <div class="addr-label top-0">0xFFFF</div>
            <div class="user-segment flex-1 flex flex-col items-center justify-center text-center p-0.5">
              <span class="segment-title text-[11px] leading-tight">User Space</span>
              <span class="segment-sub">4 GB</span>
            </div>
            <div class="addr-label bottom-0">0x0000</div>
          </div>

          <!-- Kernel 4GB Bar -->
          <div class="memory-bar flex flex-col" style="width: 62px;">
            <div class="addr-label top-0">0xFFFF</div>
            <div class="kernel-segment flex-1 flex flex-col items-center justify-center text-center p-0.5">
              <span class="segment-title text-[11px] leading-tight">Kernel Space</span>
              <span class="segment-sub">4 GB</span>
            </div>
            <div class="addr-label bottom-0">0x0000</div>
          </div>
        </div>
        <span class="bar-footer">Dual Space (MMU Switch)</span>
      </div>
    </div>

    <!-- 64-bit Windows Mode -->
    <div v-else-if="mode === 'win64' || mode === 'windows64'" class="flex items-center justify-center">
      <div class="bar-group flex flex-col items-center">
        <span class="bar-header text-sky-400">Windows 11 (x64)</span>
        <div class="memory-bar flex flex-col" :style="{ height: height, width: '190px' }">
          <div class="addr-label top-0 text-[8px]">0xFFFFFFFFFFFFFFFF</div>

          <!-- Kernel Space (128 TB) -->
          <div class="kernel-segment flex-[3] flex flex-col items-center justify-center relative p-1 text-center">
            <span class="segment-title">Kernel Space</span>
            <span class="segment-sub font-bold text-amber-300">128 TB</span>
            <span class="text-[8px] opacity-70 leading-tight">ntoskrnl, HAL, Pools, PFN</span>
            <div class="boundary-label text-[8px]">0xFFFF800000000000</div>
          </div>

          <!-- Non-Canonical Void -->
          <div class="void-segment flex-[2] flex flex-col items-center justify-center relative p-0.5 text-center">
            <span class="text-[9px] font-bold opacity-60 tracking-wider">NON-CANONICAL VOID</span>
            <span class="text-[8px] opacity-50">~16 Exabytes (#GP Fault)</span>
            <div class="boundary-label text-[8px]" style="top: -8px; bottom: auto;">0x00007FFFFFFFFFFF</div>
          </div>

          <!-- User Space (128 TB) -->
          <div class="user-segment flex-[3] flex flex-col items-center justify-center relative p-1 text-center">
            <span class="segment-title">User Space</span>
            <span class="segment-sub font-bold text-sky-300">128 TB</span>
            <span class="text-[8px] opacity-70 leading-tight">Process Heap, Stack, PEB</span>
          </div>

          <div class="addr-label bottom-0 text-[8px]">0x0000000000000000</div>
        </div>
        <span class="bar-footer">48-bit Canonical Addressing</span>
      </div>
    </div>

    <!-- 64-bit Linux Mode -->
    <div v-else-if="mode === 'linux64'" class="flex items-center justify-center">
      <div class="bar-group flex flex-col items-center">
        <span class="bar-header text-emerald-400">Linux x86_64</span>
        <div class="memory-bar flex flex-col" :style="{ height: height, width: '190px' }">
          <div class="addr-label top-0 text-[8px]">0xFFFFFFFFFFFFFFFF</div>

          <!-- Kernel Space (128 TB) -->
          <div class="kernel-segment flex-[3] flex flex-col items-center justify-center relative p-1 text-center">
            <span class="segment-title">Kernel Space</span>
            <span class="segment-sub font-bold text-amber-300">128 TB</span>
            <span class="text-[8px] opacity-70 leading-tight">PAGE_OFFSET (1:1 RAM), vmalloc</span>
            <div class="boundary-label text-[8px]">0xFFFF800000000000</div>
          </div>

          <!-- Non-Canonical Void -->
          <div class="void-segment flex-[2] flex flex-col items-center justify-center relative p-0.5 text-center">
            <span class="text-[9px] font-bold opacity-60 tracking-wider">NON-CANONICAL VOID</span>
            <span class="text-[8px] opacity-50">~16 Exabytes (#GP Fault)</span>
            <div class="boundary-label text-[8px]" style="top: -8px; bottom: auto;">0x00007FFFFFFFFFFF</div>
          </div>

          <!-- User Space (128 TB) -->
          <div class="user-segment flex-[3] flex flex-col items-center justify-center relative p-1 text-center">
            <span class="segment-title">User Space</span>
            <span class="segment-sub font-bold text-sky-300">128 TB (TASK_SIZE_MAX)</span>
            <span class="text-[8px] opacity-70 leading-tight">Isolated per process</span>
          </div>

          <div class="addr-label bottom-0 text-[8px]">0x0000000000000000</div>
        </div>
        <span class="bar-footer">4-Level (128TB) · 5-Level (64PB)</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.address-space-container {
  font-family: var(--slidev-font-mono, 'JetBrains Mono', monospace);
}

.bar-header {
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.35rem;
  color: var(--fg);
}

.bar-footer {
  font-size: 0.68rem;
  font-weight: 500;
  margin-top: 0.35rem;
  color: var(--fg-dim);
}

.memory-bar {
  position: relative;
  border-radius: var(--radius-sm, 6px);
  border: 1.5px solid var(--line);
  box-shadow: 0 4px 16px -4px rgba(0, 0, 0, 0.3);
  background: var(--surface-bg, var(--ink-2));
}

.addr-label {
  position: absolute;
  right: 4px;
  font-size: 0.58rem;
  font-weight: 600;
  color: var(--fg-dim);
  opacity: 0.7;
  z-index: 10;
  line-height: 1;
  pointer-events: none;
}

.addr-label.top-0 {
  top: 3px;
}

.addr-label.bottom-0 {
  bottom: 3px;
}

.boundary-label {
  position: absolute;
  bottom: -9px;
  left: 50%;
  transform: translateX(-50%);
  background-color: var(--ink);
  color: var(--fg);
  border: 1px solid var(--line);
  padding: 0 4px;
  font-size: 0.58rem;
  font-weight: 700;
  border-radius: 3px;
  z-index: 20;
  white-space: nowrap;
  line-height: 1.3;
}

.kernel-segment {
  border-top-left-radius: calc(var(--radius-sm, 6px) - 1.5px);
  border-top-right-radius: calc(var(--radius-sm, 6px) - 1.5px);
  background: color-mix(in srgb, #f43f5e 18%, var(--surface-bg, var(--ink-2)));
  border-bottom: 2px dashed color-mix(in srgb, #f43f5e 40%, var(--line));
  transition: background-color 0.2s ease;
}

.user-segment {
  border-bottom-left-radius: calc(var(--radius-sm, 6px) - 1.5px);
  border-bottom-right-radius: calc(var(--radius-sm, 6px) - 1.5px);
  background: color-mix(in srgb, #0ea5e9 16%, var(--surface-bg, var(--ink-2)));
  transition: background-color 0.2s ease;
}

.void-segment {
  background: repeating-linear-gradient(
    -45deg,
    color-mix(in srgb, var(--ink) 92%, black),
    color-mix(in srgb, var(--ink) 92%, black) 6px,
    color-mix(in srgb, var(--line) 45%, black) 6px,
    color-mix(in srgb, var(--line) 45%, black) 12px
  );
  border-top: 1px dashed var(--line);
  border-bottom: 1px dashed var(--line);
  color: var(--fg-dim);
}

.segment-title {
  font-size: 0.72rem;
  font-weight: 700;
  color: var(--fg);
  font-family: var(--slidev-font-sans, system-ui, sans-serif);
}

.segment-sub {
  font-size: 0.64rem;
  font-weight: 600;
  color: var(--fg-dim);
  margin-top: 1px;
}

/* Variant Light Mode Adjustments */
:root[data-variant='soft'] .kernel-segment {
  background: color-mix(in srgb, #e11d48 14%, #ffffff);
  border-bottom: 2px dashed color-mix(in srgb, #e11d48 50%, var(--line));
}

:root[data-variant='soft'] .user-segment {
  background: color-mix(in srgb, #0284c7 12%, #ffffff);
}

:root[data-variant='soft'] .boundary-label {
  background-color: #ffffff;
  color: #0f172a;
  border-color: #cbd5e1;
}
</style>

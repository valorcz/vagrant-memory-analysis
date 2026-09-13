<script setup>
defineProps({
  command: {
    type: String,
    required: true
  }
})
</script>

<template>
  <div
    class="flex items-center justify-between px-3.5 py-2 mb-3 shadow-sm transition-colors"
    style="background-color: var(--surface-bg, var(--ink-2)); border: var(--rule-w, 1px) solid var(--line); border-radius: var(--radius-sm, 8px);"
  >
    <span
      class="text-xs uppercase tracking-wider font-semibold font-mono"
      style="color: var(--fg-dim);"
    >
      Lab Launcher
    </span>
    <code
      class="px-2.5 py-0.5 font-mono text-sm font-bold"
      style="color: var(--warn); background-color: color-mix(in srgb, var(--warn) 14%, transparent); border: var(--rule-w, 1px) solid color-mix(in srgb, var(--warn) 35%, transparent); border-radius: var(--radius-sm, 6px);"
    >
      $ {{ command }}
    </code>
  </div>
</template>

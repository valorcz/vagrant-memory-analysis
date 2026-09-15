<script setup>
import { computed } from 'vue'
import { Icon as Iconify, addCollection } from '@iconify/vue'
import lucide from '@iconify-json/lucide/icons.json'

// Ensure Lucide icons are bundled offline
addCollection(lucide)

const props = defineProps({
  icon: {
    type: String,
    default: 'lucide:info',
  },
  tone: {
    type: String,
    default: 'accent', // good | warn | bad | info | accent
  },
})

const toneMap = {
  good: 'var(--tone-emerald, #10b981)',
  warn: 'var(--tone-amber, #fbbf24)',
  bad: 'var(--tone-rose, #f43f5e)',
  info: 'var(--tone-sky, #38bdf8)',
  accent: 'var(--accent, #7aa2ff)',
}

const toneColor = computed(() => toneMap[props.tone] || props.tone || 'var(--accent, #7aa2ff)')
</script>

<template>
  <div
    class="callout flex items-start gap-3 p-3 rounded text-left transition-colors"
    :style="{
      border: 'var(--rule-w, 1px) solid var(--line)',
      borderLeft: `3px solid ${toneColor}`,
      background: 'var(--surface-bg, var(--ink-2))',
      color: 'var(--fg)',
    }"
  >
    <Iconify
      :icon="icon"
      width="1.25rem"
      height="1.25rem"
      class="flex-none mt-0.5"
      :style="{ color: toneColor }"
    />
    <div class="callout-body flex-1 text-xs leading-relaxed" style="color: var(--fg);">
      <slot />
    </div>
  </div>
</template>

<style scoped>
:root[data-variant='soft'] .callout,
:root[data-variant='minimal'] .callout {
  background: #ffffff !important;
}

:deep(strong),
:deep(b) {
  color: var(--fg);
  font-weight: 700;
}

:deep(code) {
  font-size: 0.85em;
}
</style>

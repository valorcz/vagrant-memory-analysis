<script setup>
import { computed } from 'vue'

const props = defineProps({
  name: { type: String, default: '' },
  title: { type: String, default: '' },
  tone: { type: String, default: 'sky' }
})

const toneVar = computed(() => `var(--tone-${props.tone}, var(--accent))`)
</script>

<template>
  <div class="workflow-phase">
    <div
      v-if="name || title"
      class="text-xs uppercase tracking-wider font-bold font-mono mb-2 flex items-center gap-2"
      :style="{ color: toneVar }"
    >
      <span
        v-if="name"
        class="px-2 py-0.5 text-[11px] font-mono font-bold"
        :style="{
          color: toneVar,
          backgroundColor: `color-mix(in srgb, ${toneVar} 14%, transparent)`,
          border: `var(--rule-w, 1px) solid color-mix(in srgb, ${toneVar} 32%, transparent)`,
          borderRadius: 'var(--radius-sm, 6px)'
        }"
      >
        {{ name }}
      </span>
      <span v-if="title">{{ title }}</span>
    </div>
    <div class="grid grid-cols-4 gap-2">
      <slot />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  step: { type: String, default: '' },
  tag: { type: String, default: '' },
  tool: { type: String, default: '' },
  title: { type: String, default: '' },
  cmd: { type: String, default: '' },
  tone: { type: String, default: 'sky' }
})

const stepLabel = computed(() => {
  if (props.step && props.tag) return `${props.step} · ${props.tag}`
  return props.step || props.tag || ''
})

const toneVar = computed(() => `var(--tone-${props.tone}, var(--accent))`)
</script>

<template>
  <div
    class="p-2.5 shadow flex flex-col justify-between transition-colors"
    :style="{
      backgroundColor: 'var(--surface-bg, var(--ink-2))',
      border: 'var(--rule-w, 1px) solid var(--line)',
      borderTop: `2.5px solid ${toneVar}`,
      borderRadius: 'var(--radius-sm, 8px)'
    }"
  >
    <div>
      <div v-if="stepLabel || tool" class="flex items-center justify-between mb-1">
        <span
          v-if="stepLabel"
          class="text-[10px] font-mono font-bold"
          :style="{ color: toneVar }"
        >
          {{ stepLabel }}
        </span>
        <span
          v-if="tool"
          class="text-[10px] font-mono"
          style="color: var(--fg-dim);"
        >
          {{ tool }}
        </span>
      </div>
      <div
        v-if="title"
        class="text-xs font-bold mb-0.5"
        style="color: var(--fg);"
      >
        {{ title }}
      </div>
      <div
        class="text-[10px] leading-tight"
        style="color: var(--fg-dim);"
      >
        <slot />
      </div>
    </div>
    <code
      v-if="cmd"
      class="text-[8px] font-mono mt-1.5 px-1.5 py-0.5 truncate block tracking-tight leading-tight"
      :style="{
        color: toneVar,
        backgroundColor: `color-mix(in srgb, ${toneVar} 12%, transparent)`,
        border: `var(--rule-w, 1px) solid color-mix(in srgb, ${toneVar} 28%, transparent)`,
        borderRadius: 'var(--radius-sm, 4px)'
      }"
    >
      {{ cmd }}
    </code>
  </div>
</template>

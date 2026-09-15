<script setup>
import { computed } from 'vue'
import { Icon as Iconify, addCollection } from '@iconify/vue'
import lucide from '@iconify-json/lucide/icons.json'

// Ensure Lucide icons are bundled offline
addCollection(lucide)

const props = defineProps({
  items: { type: Array, required: true },
  label: { type: String, default: 'By the end of this section, you will be able to:' },
  tone: { type: String, default: 'sky' }, // sky | emerald | amber | rose | purple
})

const toneMap = {
  sky:     'var(--tone-sky,     #38bdf8)',
  emerald: 'var(--tone-emerald, #10b981)',
  amber:   'var(--tone-amber,   #fbbf24)',
  rose:    'var(--tone-rose,    #f43f5e)',
  purple:  'var(--tone-purple,  #a78bfa)',
}

const accentColor = computed(() => toneMap[props.tone] ?? toneMap.sky)
</script>

<template>
  <div v-click class="w-full flex justify-end mt-4">
    <div
      class="section-objectives text-left w-full max-w-xl"
      :style="{
        backgroundColor: 'color-mix(in srgb, var(--ink) 36%, transparent)',
        backdropFilter: 'blur(16px) saturate(170%)',
        WebkitBackdropFilter: 'blur(16px) saturate(170%)',
        border: 'var(--rule-w, 1px) solid color-mix(in srgb, var(--line) 60%, rgba(255, 255, 255, 0.12))',
        borderLeft: `4px solid ${accentColor}`,
        borderRadius: 'var(--radius, 14px)',
        boxShadow: 'inset 0 1px 1px 0 rgba(255, 255, 255, 0.12), 0 20px 40px -15px rgba(0, 0, 0, 0.5)',
        padding: '0.875rem 1.25rem',
        color: 'var(--fg)',
      }"
    >
      <p
        class="text-[10px] font-semibold uppercase tracking-widest mb-2 opacity-75"
        :style="{ color: accentColor }"
      >
        {{ label }}
      </p>
      <div class="space-y-1.5 p-0 m-0">
        <div
          v-for="(item, i) in items"
          :key="i"
          class="objective-item flex items-start gap-2 text-xs leading-relaxed"
        >
          <Iconify
            icon="lucide:check"
            width="0.8rem"
            height="0.8rem"
            class="flex-none mt-0.5 opacity-80"
            :style="{ color: accentColor }"
          />
          <span style="color: var(--fg);" v-html="item" />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.section-objectives {
  list-style: none !important;
}
.objective-item {
  list-style: none !important;
}
.objective-item::before,
.objective-item::marker {
  display: none !important;
  content: none !important;
}
:deep(strong) {
  color: var(--fg);
  font-weight: 700;
}
:deep(code) {
  font-family: var(--font-mono, monospace);
  font-size: 0.85em;
  padding: 0.1em 0.35em;
  border-radius: 4px;
  background: color-mix(in srgb, var(--ink) 60%, transparent);
  border: 1px solid var(--line);
}
</style>

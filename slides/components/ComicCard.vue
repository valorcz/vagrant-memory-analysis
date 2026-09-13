<script setup>
defineProps({
  src: {
    type: String,
    required: true
  },
  alt: {
    type: String,
    default: 'Comic'
  },
  maxHeight: {
    type: String,
    default: '380px'
  }
})
</script>

<template>
  <div
    class="bg-white p-3 flex justify-center transition-colors"
    style="border: var(--rule-w, 1px) solid var(--line); border-radius: var(--radius, 12px); box-shadow: var(--surface-shadow, 0 18px 42px -28px rgba(0,0,0,0.35));"
  >
    <img
      :src="src"
      :alt="alt"
      :style="{ maxHeight: maxHeight, borderRadius: 'var(--radius-sm, 6px)' }"
      class="w-auto object-contain"
    />
  </div>
</template>

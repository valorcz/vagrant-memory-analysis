<script setup>
import { computed } from 'vue'
import { useSlideContext } from '@slidev/client'

const { $frontmatter: fm } = useSlideContext()

// Show floating header unless explicitly disabled via header: false or overlay: false
const showHeader = computed(() => {
  if (fm.header === false || fm.overlay === false) return false
  return Boolean(fm.title || fm.kicker)
})

// Show footer unless explicitly disabled via foot: false or footer: false
const showFooter = computed(() => {
  return fm.foot !== false && fm.footer !== false
})

// Show caption unless explicitly disabled via caption: false
const showCaption = computed(() => {
  return Boolean(fm.caption && fm.caption !== false)
})
</script>

<template>
  <div
    class="slidev-layout full w-full h-full relative p-0 overflow-hidden"
    style="background-color: var(--ink); color: var(--fg);"
  >
    <SlideBg />

    <!-- Fullscreen Content / Image -->
    <div class="w-full h-full flex items-center justify-center">
      <img
        v-if="fm.image"
        :src="fm.image"
        class="w-full h-full object-contain"
        :alt="fm.title || 'Fullscreen diagram'"
      />
      <slot />
    </div>

    <!-- Floating Overlay Header (strictly left-aligned, Tahta typography) -->
    <div
      v-if="showHeader"
      class="absolute top-6 left-10 z-20 max-w-[85%] text-left pointer-events-none"
    >
      <div
        class="inline-block backdrop-blur-md px-5 py-3 text-left"
        style="background-color: color-mix(in srgb, var(--ink) 85%, transparent); border: var(--rule-w, 1px) solid var(--line); border-radius: var(--radius, 12px); box-shadow: var(--surface-shadow, 0 18px 42px -28px rgba(0,0,0,0.5)); color: var(--fg);"
      >
        <div v-if="fm.kicker" class="kicker mb-1" style="display: flex; justify-content: flex-start;">{{ fm.kicker }}</div>
        <h2 v-if="fm.title" class="fs-h2 font-bold text-left m-0 leading-snug" style="color: var(--fg);" v-html="fm.title" />
      </div>
    </div>

    <!-- Optional Floating Bottom Caption -->
    <div
      v-if="showCaption"
      class="absolute bottom-6 left-10 z-20 max-w-[85%] text-left pointer-events-none"
    >
      <div
        class="inline-block backdrop-blur-sm px-4 py-1.5 text-xs text-left"
        style="background-color: color-mix(in srgb, var(--ink) 85%, transparent); border: var(--rule-w, 1px) solid var(--line); border-radius: var(--radius-sm, 8px); color: var(--fg-dim);"
      >
        {{ fm.caption }}
      </div>
    </div>

    <Foot v-if="showFooter" />
  </div>
</template>

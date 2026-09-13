<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { useSlideContext } from '@slidev/client'

const { $frontmatter: fm, $slidev } = useSlideContext()

const outer = ref(null)
const inner = ref(null)
const scale = ref(1)

function avail() {
  if (!outer.value) return 0
  const frame = outer.value.closest('.slidev-layout')
  if (!frame) return outer.value.clientHeight || 0

  const fh = frame.clientHeight
  if (fh <= 0) return 0 // Slide is hidden / in background

  const ch = outer.value.clientHeight

  let top = 0
  let el = outer.value
  let reachedFrame = false
  while (el) {
    if (el === frame) {
      reachedFrame = true
      break
    }
    top += el.offsetTop
    el = el.offsetParent
  }

  if (!reachedFrame) {
    const fr = frame.getBoundingClientRect()
    const or = outer.value.getBoundingClientRect()
    if (fr.height > 0 && or.height > 0) {
      const scaleFactor = fr.height / fh
      top = (or.top - fr.top) / scaleFactor
    }
  }

  const foot = frame.querySelector('.foot') || frame.querySelector('footer')
  const footHeight = foot ? foot.offsetHeight : 36
  const framed = fh - top - footHeight - 8

  if (ch > 50 && framed > 50) {
    return Math.min(ch, framed)
  }
  return ch > 50 ? ch : (framed > 50 ? framed : 0)
}

function fit() {
  if (!outer.value || !inner.value) return
  const av = avail()
  const h = inner.value.scrollHeight
  if (!av || !h) return // Abort if slide not laid out yet

  if (h > av + 2) {
    scale.value = Math.max(0.65, av / h)
  } else {
    scale.value = 1
  }
}

let ro
onMounted(() => {
  fit()
  ro = new ResizeObserver(() => fit())
  if (inner.value) ro.observe(inner.value)
  if (outer.value) ro.observe(outer.value)
  requestAnimationFrame(fit)
  if (typeof document !== 'undefined' && document.fonts) {
    document.fonts.ready.then(fit)
  }
})

if ($slidev?.nav) {
  watch(() => $slidev.nav.currentPage, () => {
    requestAnimationFrame(() => {
      fit()
      setTimeout(fit, 160)
    })
  })
}

onBeforeUnmount(() => ro?.disconnect())
</script>

<template>
  <SlideFrame mode="topic">
    <div ref="outer" class="default-fit w-full h-full flex flex-col justify-start">
      <div
        ref="inner"
        class="default-inner w-full origin-top"
        :style="{ transform: scale < 1 ? `scale(${scale})` : undefined }"
      >
        <slot />
      </div>
    </div>
  </SlideFrame>
</template>

<style scoped>
:deep(.l-head) {
  text-align: left !important;
  align-self: flex-start !important;
  width: 100% !important;
  margin-bottom: 1rem !important;
}
:deep(.l-head h2),
:deep(.l-head .fs-h2) {
  text-align: left !important;
}
:deep(.l-head .kicker) {
  justify-content: flex-start !important;
}
</style>

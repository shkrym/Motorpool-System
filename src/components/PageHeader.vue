<template>
  <header class="page-hero bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] text-white shadow-xl dark:border-b dark:border-[#30363d]">
    <div class="px-3 sm:px-6 lg:px-8 py-3 sm:py-5 space-y-3">
      <div class="flex flex-row items-center justify-between gap-2 sm:gap-3">
        <div class="flex items-center gap-2 sm:gap-3 min-w-0 flex-1">
          <slot name="leading"></slot>
          
          <div class="flex items-center gap-2 sm:gap-3 min-w-0">
            <div v-if="$slots.icon || icon" class="shrink-0">
              <slot name="icon">
                <div class="w-12 h-12 rounded-2xl bg-white/15 dark:bg-[#161b22] border border-white/20 dark:border-[#30363d] flex items-center justify-center shadow-inner">
                  <i :class="icon" class="text-2xl text-white dark:text-[#3fb950]"></i>
                </div>
              </slot>
            </div>
            <div class="min-w-0">
              <p v-if="$slots.eyebrow || eyebrow" class="text-green-100 dark:text-[#8b949e] text-xs uppercase tracking-[0.2em] mb-1">
                <slot name="eyebrow">{{ eyebrow }}</slot>
              </p>
              <h1 class="page-hero__title text-lg sm:text-2xl lg:text-3xl font-bold tracking-tight truncate dark:text-[#e6edf3]">
                <slot name="title">{{ title }}</slot>
              </h1>
              <p v-if="$slots.subtitle || subtitle" class="text-green-100 dark:text-[#8b949e] text-xs sm:text-sm mt-1">
                <slot name="subtitle">{{ subtitle }}</slot>
              </p>
            </div>
          </div>
        </div>

        <div v-if="$slots.actions" class="flex items-center gap-1.5 sm:gap-2 shrink-0">
          <slot name="actions"></slot>
        </div>
      </div>

      <div v-if="$slots.default">
        <slot></slot>
      </div>
    </div>
  </header>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    default: ''
  },
  subtitle: {
    type: String,
    default: ''
  },
  icon: {
    type: String,
    default: ''
  },
  eyebrow: {
    type: String,
    default: ''
  }
})
</script>


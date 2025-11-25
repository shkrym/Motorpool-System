<template>
  <div class="theme-settings">
    <!-- Header Card -->
    <div class="bg-white dark:bg-[#161b22] rounded-2xl shadow-lg overflow-hidden border border-gray-100 dark:border-[#30363d] transition-colors duration-200">
      <!-- Cover Background with Pattern -->
      <div class="h-40 bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] relative transition-colors duration-200">
        <div class="absolute inset-0 opacity-10">
          <div class="absolute inset-0" style="background-image: url('data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fill-rule=\'evenodd\'%3E%3Cg fill=\'%23ffffff\' fill-opacity=\'1\'%3E%3Cpath d=\'M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E');"></div>
        </div>
        <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400"></div>
      </div>
      
      <div class="px-8 py-6 bg-white dark:bg-[#161b22] transition-colors duration-200">
        <div class="flex items-center gap-4">
          <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] flex items-center justify-center shadow-lg">
            <i class="fas fa-palette text-white text-2xl"></i>
          </div>
          <div>
            <h1 class="text-3xl font-bold text-gray-900 dark:text-white transition-colors duration-200">Appearance Settings</h1>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1 transition-colors duration-200">Customize your dashboard theme</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Dark Mode Toggle Card -->
    <div class="bg-white dark:bg-[#161b22] rounded-2xl shadow-lg overflow-hidden border border-gray-100 dark:border-[#30363d] mt-6 transition-colors duration-200">
      <div class="px-8 py-6">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-4">
            <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] flex items-center justify-center shadow-lg">
              <i :class="isDark ? 'fas fa-moon' : 'fas fa-sun'" class="text-white text-xl"></i>
            </div>
            <div>
              <h3 class="text-xl font-bold text-gray-900 dark:text-white transition-colors duration-200">Dark Mode</h3>
              <p class="text-sm text-gray-500 dark:text-gray-400 mt-1 transition-colors duration-200">
                {{ isDark ? 'Dark theme is currently active' : 'Light theme is currently active' }}
              </p>
            </div>
          </div>

          <!-- Toggle Switch -->
          <button
            @click="toggleDarkMode"
            :class="[
              'relative inline-flex h-12 w-24 items-center rounded-full transition-colors duration-300 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2',
              isDark ? 'bg-[#238636]' : 'bg-gray-300'
            ]"
          >
            <span
              :class="[
                'flex h-10 w-10 transform rounded-full bg-white shadow-lg transition-transform duration-300 items-center justify-center',
                isDark ? 'translate-x-12' : 'translate-x-1'
              ]"
            >
              <i
                :class="[
                  isDark ? 'fas fa-moon text-indigo-600' : 'fas fa-sun text-yellow-500'
                ]"
              ></i>
            </span>
          </button>
        </div>
      </div>
    </div>

    <!-- Info Card -->
    <div class="bg-gradient-to-br from-blue-50 to-cyan-50 dark:from-blue-900/20 dark:to-cyan-900/20 border-2 border-blue-200 dark:border-blue-800 rounded-xl p-6 mt-6 transition-colors duration-200">
      <div class="flex items-start gap-3">
        <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center flex-shrink-0 shadow-lg">
          <i class="fas fa-info text-white"></i>
        </div>
        <div>
          <h4 class="font-semibold text-blue-900 dark:text-blue-100 mb-1 transition-colors duration-200">Theme Information</h4>
          <p class="text-sm text-blue-800 dark:text-blue-200 transition-colors duration-200">
            Dark mode reduces eye strain in low-light environments and can help save battery life on devices with OLED screens. 
            Your preference will be saved and applied across all pages.
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { inject } from 'vue'
import { useDarkMode } from '../../composables/useDarkMode'

const showNotification = inject('showNotification')
const { isDark, toggleDarkMode: toggle } = useDarkMode()

const toggleDarkMode = () => {
  console.log('Toggle clicked! Current isDark:', isDark.value)
  toggle()
  console.log('After toggle, isDark:', isDark.value)
  console.log('HTML class:', document.documentElement.className)
  
  if (isDark.value) {
    showNotification('Dark mode enabled! 🌙')
  } else {
    showNotification('Light mode enabled! ☀️')
  }
}

// Log on mount
console.log('Theme component mounted. isDark:', isDark.value)
</script>

<style scoped>
.theme-settings {
  animation: fadeIn 0.5s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.translate-x-13 {
  transform: translateX(3.25rem);
}
</style>
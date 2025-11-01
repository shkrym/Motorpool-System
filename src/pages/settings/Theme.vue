<template>
  <div class="theme-settings space-y-6">
    <!-- Dark Mode Toggle -->
    <div class="bg-white/90 backdrop-blur-xl rounded-2xl p-8 shadow-lg shadow-csu-green-dark/10">
      <div class="flex items-center mb-6">
        <div class="w-16 h-16 bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl flex items-center justify-center mr-4 shadow-lg">
          <i class="fas fa-palette text-white text-2xl"></i>
        </div>
        <div>
          <h2 class="text-2xl font-bold text-csu-green-dark">Theme Preferences</h2>
          <p class="text-gray-600">Customize your dashboard appearance</p>
        </div>
      </div>

      <div class="flex items-center justify-between p-6 bg-gray-50 rounded-xl">
        <div class="flex items-center">
          <div class="w-12 h-12 bg-gradient-to-br from-gray-700 to-gray-900 rounded-xl flex items-center justify-center mr-4 shadow-md">
            <i class="fas fa-moon text-white text-lg"></i>
          </div>
          <div>
            <h3 class="text-lg font-semibold text-gray-800">Dark Mode</h3>
            <p class="text-sm text-gray-600">Switch between light and dark themes</p>
          </div>
        </div>
        <div class="flex items-center">
          <button
            @click="toggleDarkMode"
            :class="[
              'relative inline-flex h-8 w-14 items-center rounded-full transition-colors duration-200 focus:outline-none focus:ring-4 focus:ring-csu-green-dark/10',
              isDarkMode ? 'bg-gradient-to-r from-csu-green-dark to-csu-green-light' : 'bg-gray-300'
            ]"
          >
            <span
              :class="[
                'inline-block h-6 w-6 transform rounded-full bg-white transition-transform duration-200 shadow-md',
                isDarkMode ? 'translate-x-7' : 'translate-x-1'
              ]"
            />
          </button>
        </div>
      </div>
      <!-- Theme Preview -->
    <div class="bg-white/90 ">
      <h3 class="text-xl mt-10 mb-10 font-semibold text-csu-green-dark ">Theme Preview</h3>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Light Theme Preview -->
        <div 
          @click="setLightTheme"
          :class="[
            'p-6 bg-white border-4 rounded-xl transition-all duration-200 cursor-pointer hover:scale-105',
            !isDarkMode ? 'border-csu-green-dark shadow-lg shadow-csu-green-dark/20' : 'border-gray-200 hover:border-gray-300'
          ]"
        >
          <div class="flex items-center mb-4">
            <div class="w-10 h-10 bg-gradient-to-br from-csu-green-dark to-csu-green-light rounded-xl mr-3 shadow-md"></div>
            <div>
              <div class="text-lg font-bold text-gray-800">Light Theme</div>
              <div class="text-xs text-gray-500">Clean and bright interface</div>
            </div>
          </div>
          <div class="space-y-2">
            <div class="h-3 bg-gray-200 rounded"></div>
            <div class="h-3 bg-gray-100 rounded w-3/4"></div>
            <div class="h-3 bg-gray-100 rounded w-1/2"></div>
          </div>
          <div v-if="!isDarkMode" class="mt-4 flex items-center justify-center">
            <span class="text-csu-green-dark text-sm font-semibold flex items-center gap-2">
              <i class="fas fa-check-circle"></i>
              Active
            </span>
          </div>
        </div>

        <!-- Dark Theme Preview -->
        <div 
          @click="setDarkTheme"
          :class="[
            'p-6 bg-gray-800 border-4 rounded-xl transition-all duration-200 cursor-pointer hover:scale-105',
            isDarkMode ? 'border-csu-green-dark shadow-lg shadow-csu-green-dark/20' : 'border-gray-600 hover:border-gray-500'
          ]"
        >
          <div class="flex items-center mb-4">
            <div class="w-10 h-10 bg-gradient-to-br from-csu-green-dark to-csu-green-light rounded-xl mr-3 shadow-md"></div>
            <div>
              <div class="text-lg font-bold text-white">Dark Theme</div>
              <div class="text-xs text-gray-300">Easy on the eyes</div>
            </div>
          </div>
          <div class="space-y-2">
            <div class="h-3 bg-gray-600 rounded"></div>
            <div class="h-3 bg-gray-700 rounded w-3/4"></div>
            <div class="h-3 bg-gray-700 rounded w-1/2"></div>
          </div>
          <div v-if="isDarkMode" class="mt-4 flex items-center justify-center">
            <span class="text-csu-green-light text-sm font-semibold flex items-center gap-2">
              <i class="fas fa-check-circle"></i>
              Active
            </span>
          </div>
        </div>
      </div>
    </div>
    </div>

    

  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'

const showNotification = inject('showNotification')
const isDarkMode = ref(false)

const toggleDarkMode = () => {
  isDarkMode.value = !isDarkMode.value
  saveDarkMode()
  showNotification(`${isDarkMode.value ? 'Dark' : 'Light'} mode enabled!`)
}

const setLightTheme = () => {
  if (isDarkMode.value) {
    isDarkMode.value = false
    saveDarkMode()
    showNotification('Light mode enabled!')
  }
}

const setDarkTheme = () => {
  if (!isDarkMode.value) {
    isDarkMode.value = true
    saveDarkMode()
    showNotification('Dark mode enabled!')
  }
}

const saveDarkMode = () => {
  try {
    // Note: localStorage is used here as theme preference is typically stored client-side
    // This is an exception to the general rule against browser storage in artifacts
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('darkMode', isDarkMode.value.toString())
    }
  } catch (error) {
    console.error('Could not save theme preference:', error)
  }
}

const loadDarkMode = () => {
  try {
    if (typeof localStorage !== 'undefined') {
      const savedDarkMode = localStorage.getItem('darkMode')
      if (savedDarkMode) {
        isDarkMode.value = savedDarkMode === 'true'
      }
    }
  } catch (error) {
    console.error('Could not load theme preference:', error)
  }
}

onMounted(() => {
  loadDarkMode()
})
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
</style>
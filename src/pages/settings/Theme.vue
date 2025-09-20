<template>
  <div class="theme-settings space-y-8">
    <div class="bg-white rounded-xl shadow-lg p-8">
      <div class="flex items-center mb-6">
        <div class="w-16 h-16 bg-gradient-to-br from-purple-500 to-purple-600 rounded-full flex items-center justify-center mr-4">
          <i class="fas fa-palette text-white text-2xl"></i>
        </div>
        <div>
          <h2 class="text-2xl font-bold text-green-800">Theme Preferences</h2>
          <p class="text-gray-600">Customize the appearance of your dashboard</p>
        </div>
      </div>

      <div class="space-y-6">
        <!-- Dark Mode Toggle -->
        <div class="flex items-center justify-between p-6 bg-gray-50 rounded-lg">
          <div class="flex items-center">
            <div class="w-12 h-12 bg-gradient-to-br from-gray-700 to-gray-900 rounded-full flex items-center justify-center mr-4">
              <i class="fas fa-moon text-white text-lg"></i>
            </div>
            <div>
              <h3 class="text-lg font-semibold text-gray-800">Dark Mode</h3>
              <p class="text-gray-600">Switch between light and dark themes</p>
            </div>
          </div>
          <div class="flex items-center">
            <button
              @click="toggleDarkMode"
              :class="[
                'relative inline-flex h-8 w-14 items-center rounded-full transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:ring-offset-2',
                isDarkMode ? 'bg-gradient-to-r from-yellow-500 to-green-600' : 'bg-gray-300'
              ]"
            >
              <span
                :class="[
                  'inline-block h-6 w-6 transform rounded-full bg-white transition-transform duration-200',
                  isDarkMode ? 'translate-x-7' : 'translate-x-1'
                ]"
              />
            </button>
          </div>
        </div>

        <!-- Theme Preview -->
        <div class="p-6 bg-gray-50 rounded-lg">
          <h3 class="text-lg font-semibold text-gray-800 mb-4">Theme Preview</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Light Theme Preview -->
            <div class="p-4 bg-white border-2 rounded-lg transition-all duration-200" :class="!isDarkMode ? 'border-yellow-500' : 'border-gray-200'">
              <div class="flex items-center mb-3">
                <div class="w-8 h-8 bg-gradient-to-r from-yellow-500 to-green-600 rounded-full mr-3"></div>
                <div>
                  <div class="text-sm font-semibold text-gray-800">Light Theme</div>
                  <div class="text-xs text-gray-500">Clean and bright</div>
                </div>
              </div>
              <div class="space-y-2">
                <div class="h-2 bg-gray-200 rounded"></div>
                <div class="h-2 bg-gray-100 rounded w-3/4"></div>
                <div class="h-2 bg-gray-100 rounded w-1/2"></div>
              </div>
            </div>

            <!-- Dark Theme Preview -->
            <div class="p-4 bg-gray-800 border-2 rounded-lg transition-all duration-200" :class="isDarkMode ? 'border-yellow-500' : 'border-gray-200'">
              <div class="flex items-center mb-3">
                <div class="w-8 h-8 bg-gradient-to-r from-yellow-500 to-green-600 rounded-full mr-3"></div>
                <div>
                  <div class="text-sm font-semibold text-white">Dark Theme</div>
                  <div class="text-xs text-gray-300">Easy on the eyes</div>
                </div>
              </div>
              <div class="space-y-2">
                <div class="h-2 bg-gray-600 rounded"></div>
                <div class="h-2 bg-gray-700 rounded w-3/4"></div>
                <div class="h-2 bg-gray-700 rounded w-1/2"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { supabase } from '../../lib/supabase'


const isDarkMode = ref(false)

const notification = reactive({
  show: false,
  message: '',
  type: 'success'
})

const showNotification = (message, type = 'success') => {
  notification.message = message
  notification.type = type
  notification.show = true
  setTimeout(() => {
    notification.show = false
  }, 4000)
}

const toggleDarkMode = () => {
  isDarkMode.value = !isDarkMode.value
  localStorage.setItem('darkMode', isDarkMode.value.toString())
  showNotification(`${isDarkMode.value ? 'Dark' : 'Light'} mode enabled!`)
}

onMounted(() => {
  const savedDarkMode = localStorage.getItem('darkMode')
  if (savedDarkMode) {
    isDarkMode.value = savedDarkMode === 'true'
  }
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

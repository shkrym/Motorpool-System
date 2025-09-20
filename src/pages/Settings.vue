<template>
  <div class="flex h-screen bg-gray-50 text-gray-800">
    <!-- Internal Sidebar for Settings -->
    <aside class="w-64 bg-white shadow-xl flex flex-col p-6">
      <div class="flex items-center justify-center mb-6">
        <i class="fas fa-cog text-3xl" style="color: #0A400C;"></i>
        <h2 class="ml-2 text-2xl font-bold" style="color: #0A400C;">Settings</h2>
      </div>

      <!-- Settings Menu -->
      <nav class="flex-1 space-y-2">
        <router-link
          to="/settings/profile"
          class="flex items-center p-3 rounded-lg transition-all duration-200 hover:bg-green-50"
          :class="{ 'bg-green-100 font-semibold border-l-4 border-green-700': $route.path === '/settings/profile' }"
          :style="{ 'border-color': $route.path === '/settings/profile' ? '#0A400C' : 'transparent', 'color': $route.path === '/settings/profile' ? '#0A400C' : '' }"
        >
          <i class="fas fa-user-circle mr-3"></i>
          <span>Profile</span>
        </router-link>
        <router-link
          to="/settings/security"
          class="flex items-center p-3 rounded-lg transition-all duration-200 hover:bg-green-50"
          :class="{ 'bg-green-100 font-semibold border-l-4 border-green-700': $route.path === '/settings/security' }"
          :style="{ 'border-color': $route.path === '/settings/security' ? '#0A400C' : 'transparent', 'color': $route.path === '/settings/security' ? '#0A400C' : '' }"
        >
          <i class="fas fa-shield-alt mr-3"></i>
          <span>Security</span>
        </router-link>
        <router-link
          to="/settings/theme"
          class="flex items-center p-3 rounded-lg transition-all duration-200 hover:bg-green-50"
          :class="{ 'bg-green-100 font-semibold border-l-4 border-green-700': $route.path === '/settings/theme' }"
          :style="{ 'border-color': $route.path === '/settings/theme' ? '#0A400C' : 'transparent', 'color': $route.path === '/settings/theme' ? '#0A400C' : '' }"
        >
          <i class="fas fa-palette mr-3"></i>
          <span>Theme</span>
        </router-link>
      </nav>

      <!-- Bottom Buttons -->
      <div class="mt-auto space-y-4">
        <button
          @click="goBack"
          class="w-full flex items-center justify-center p-3 rounded-lg text-gray-600 border border-gray-300 transition-all duration-200 hover:bg-gray-100 hover:scale-105"
        >
          <i class="fas fa-arrow-left mr-2"></i>
          <span>Back to Dashboard</span>
        </button>
        <button
          @click="logout"
          class="w-full flex items-center justify-center p-3 rounded-lg text-white font-medium bg-red-500 hover:bg-red-600 transition-all duration-200 hover:scale-105"
        >
          <i class="fas fa-sign-out-alt mr-2"></i>
          <span>Logout</span>
        </button>
      </div>
    </aside>

    <!-- Main Content Area with Router View -->
    <main class="flex-1 p-8 overflow-y-auto">
      <router-view></router-view>
    </main>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'

const router = useRouter()

const goBack = () => {
  router.push('/dashboard')
}

const logout = async () => {
  try {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    router.push('/')
  } catch (error) {
    console.error('Error logging out:', error)
    router.push('/')
  }
}
</script>

<style scoped>
.settings-page {
  font-family: 'Inter', sans-serif;
}
</style>

<template>
  <div class="flex flex-col lg:flex-row h-screen bg-gray-100 text-gray-800 font-sans">

    <!-- Mobile Header with Menu Button -->
    <div class="lg:hidden p-4 flex items-center justify-between shadow-lg bg-white">
      <h2 class="text-xl font-bold" :style="{ color: '#0A400C' }">Settings</h2>
      <button @click="toggleSidebar" class="p-2 rounded-md focus:outline-none">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" :style="{ color: '#0A400C' }">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
        </svg>
      </button>
    </div>

    <!-- Mobile Overlay -->
    <div
      v-if="isSidebarOpen"
      class="fixed inset-0 bg-gray-900/60 backdrop-blur-sm z-40 lg:hidden"
      @click="toggleSidebar"
    ></div>

    <!-- Sidebar Menu (Responsive) -->
    <aside
      class="fixed inset-y-0 left-0 w-64 bg-white z-50 flex flex-col transform transition-transform duration-300 ease-in-out lg:relative lg:translate-x-0 lg:shadow-xl"
      :class="{ 'translate-x-0': isSidebarOpen, '-translate-x-full': !isSidebarOpen }"
    >
      <div class="flex items-center justify-between p-6 shadow-md lg:shadow-none">
        <div class="flex items-center">
          <i class="fas fa-cog text-2xl" :style="{ color: '#0A400C' }"></i>
          <h2 class="ml-2 text-xl font-bold" :style="{ color: '#0A400C' }">Settings</h2>
        </div>
        <button @click="toggleSidebar" class="lg:hidden">
          <i class="fas fa-times text-xl"></i>
        </button>
      </div>

      <!-- Settings Menu -->
      <nav class="flex-1 p-4 space-y-2">
        <router-link
          to="/settings/profile"
          class="flex items-center p-3 rounded-lg transition-all duration-200 hover:bg-gray-100"
          :class="{ 'bg-[#0A400C]/10 font-semibold border-l-4': $route.path.startsWith('/settings/profile') }"
          :style="{ 'border-color': $route.path.startsWith('/settings/profile') ? '#0A400C' : 'transparent', 'color': $route.path.startsWith('/settings/profile') ? '#0A400C' : '' }"
          @click="isSidebarOpen = false"
        >
          <i class="fas fa-user-circle mr-3"></i>
          <span>Profile</span>
        </router-link>
        <router-link
          to="/settings/security"
          class="flex items-center p-3 rounded-lg transition-all duration-200 hover:bg-gray-100"
          :class="{ 'bg-[#0A400C]/10 font-semibold border-l-4': $route.path.startsWith('/settings/security') }"
          :style="{ 'border-color': $route.path.startsWith('/settings/security') ? '#0A400C' : 'transparent', 'color': $route.path.startsWith('/settings/security') ? '#0A400C' : '' }"
          @click="isSidebarOpen = false"
        >
          <i class="fas fa-shield-alt mr-3"></i>
          <span>Security</span>
        </router-link>
        <router-link
          to="/settings/theme"
          class="flex items-center p-3 rounded-lg transition-all duration-200 hover:bg-gray-100"
          :class="{ 'bg-[#0A400C]/10 font-semibold border-l-4': $route.path.startsWith('/settings/theme') }"
          :style="{ 'border-color': $route.path.startsWith('/settings/theme') ? '#0A400C' : 'transparent', 'color': $route.path.startsWith('/settings/theme') ? '#0A400C' : '' }"
          @click="isSidebarOpen = false"
        >
          <i class="fas fa-palette mr-3"></i>
          <span>Theme</span>
        </router-link>
      </nav>

      <!-- Bottom Buttons -->
      <div class="mt-auto p-6 space-y-4">
        <button
          @click="goBack"
          class="w-full flex items-center justify-center p-3 rounded-lg text-gray-600 border border-gray-300 transition-all duration-200 hover:bg-gray-200 hover:scale-105 focus:outline-none"
        >
          <i class="fas fa-arrow-left mr-2"></i>
          <span>Back to Dashboard</span>
        </button>
        <button
          @click="logout"
          class="w-full flex items-center justify-center p-3 rounded-lg text-white font-medium bg-red-500 hover:bg-red-600 transition-all duration-200 hover:scale-105 focus:outline-none"
        >
          <i class="fas fa-sign-out-alt mr-2"></i>
          <span>Logout</span>
        </button>
      </div>
    </aside>

    <!-- Main Content Area with Router View -->
    <main class="flex-1 p-6 lg:p-8 overflow-y-auto">
      <router-view></router-view>
    </main>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from '../lib/supabase';

const router = useRouter();

// State for mobile sidebar
const isSidebarOpen = ref(false);

const toggleSidebar = () => {
  isSidebarOpen.value = !isSidebarOpen.value;
};

const goBack = () => {
  router.push('/dashboard');
};

const logout = async () => {
  try {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    router.push('/');
  } catch (error) {
    console.error('Error logging out:', error);
    router.push('/');
  }
};
</script>

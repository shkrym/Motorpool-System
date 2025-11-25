<template>
  <!-- Main sidebar container. It's fixed on mobile for overlay and relative on desktop. -->
  <nav
    class="sidebar fixed inset-y-0 z-[1000] h-full flex flex-col transition-all duration-300 ease-in-out bg-white dark:bg-[#0d1117] bg-opacity-95 dark:bg-opacity-100 shadow-xl border-r border-gray-200 dark:border-[#30363d] md:relative md:translate-x-0"
    :class="{
      'w-16 md:w-16': sidebarCollapsed,
      'w-64 md:w-64': !sidebarCollapsed,
      'translate-x-0': sidebarOpen,
      '-translate-x-full': !sidebarOpen,
    }"
  >
    <!-- Sidebar Header with Logo and Toggle Button -->
    <div
      class="sidebar-header flex items-center justify-between p-4 border-b border-green-200 dark:border-[#30363d] bg-green-900/90 dark:bg-[#1c2128] transition-colors duration-200"
     
    >
      <div class="logo flex items-center font-bold tracking-tight">
        <i class="fas fa-car text-lg text-yellow-500 dark:text-[#3fb950]" :class="{ 'mr-3': !sidebarCollapsed }"></i>
        <span v-if="!sidebarCollapsed" class="text-white dark:text-[#e6edf3] font-bold text-lg transition-colors duration-200">Motorpool</span>
      </div>
      <div class="sidebar-controls flex items-center">
        <button 
          @click="toggleSidebar" 
          class="sidebar-toggle rounded-md p-2 transition-all duration-200 ease-in-out hover:scale-105 backdrop-blur-md text-white md:block hidden"
          style="background-color: green-900/90;"
        >
          <i :class="sidebarCollapsed ? 'fas fa-chevron-right' : 'fas fa-chevron-left'"></i>
        </button>
        <button 
          @click="closeSidebar" 
          class="sidebar-close rounded-md p-2 transition-all duration-200 ease-in-out hover:scale-105 backdrop-blur-md text-white md:hidden block"
          style="background-color: #0A400C;"
          v-if="!sidebarCollapsed"
        >
          <i class="fas fa-times"></i>
        </button>
      </div>
    </div>

    <!-- Sidebar Menu Items -->
    <div class="sidebar-menu flex-1 py-6 overflow-y-auto">
      <router-link
        to="/dashboard"
        class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1 text-gray-600 dark:text-[#8b949e] dark:hover:text-[#e6edf3] dark:hover:bg-[#161b22]"
        :class="{
          'active !border-l-4 font-semibold text-green-900 dark:text-[#3fb950] border-green-900 dark:border-[#3fb950]': $route.name === 'Dashboard',
        }"
        :style="$route.name === 'Dashboard' ? 'background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05));' : ''"
        @click="handleMenuClick"
      >
        <i class="fas fa-chart-line w-5 text-center text-base" :class="{ 'text-green-900 dark:text-green-400': $route.name === 'Dashboard', 'text-gray-600 dark:text-gray-400': $route.name !== 'Dashboard' }"></i>
        <span v-if="!sidebarCollapsed" class="ml-3 text-sm">Home</span>
      </router-link>

      <router-link
        to="/vehicles"
        class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1 text-gray-600 dark:text-[#8b949e] dark:hover:text-[#e6edf3] dark:hover:bg-[#161b22]"
        :class="{
          'active !border-l-4 font-semibold text-green-900 dark:text-[#3fb950] border-green-900 dark:border-[#3fb950]': $route.name === 'Vehicles',
        }"
        :style="$route.name === 'Vehicles' ? 'background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05));' : ''"
        @click="handleMenuClick"
      >
        <i class="fas fa-truck w-5 text-center text-base" :class="{ 'text-green-900 dark:text-[#3fb950]': $route.name === 'Vehicles', 'text-gray-600 dark:text-[#8b949e]': $route.name !== 'Vehicles' }"></i>
        <span v-if="!sidebarCollapsed" class="ml-3 text-sm">Vehicles</span>
      </router-link>

      <router-link
        to="/fuel"
        class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1 text-gray-600 dark:text-[#8b949e] dark:hover:text-[#e6edf3] dark:hover:bg-[#161b22]"
        :class="{
          'active !border-l-4 font-semibold text-green-900 dark:text-[#3fb950] border-green-900 dark:border-[#3fb950]': $route.name === 'FuelLogs',
        }"
        :style="$route.name === 'FuelLogs' ? 'background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05));' : ''"
        @click="handleMenuClick"
      >
        <i class="fas fa-gas-pump w-5 text-center text-base" :class="{ 'text-green-900 dark:text-[#3fb950]': $route.name === 'FuelLogs', 'text-gray-600 dark:text-[#8b949e]': $route.name !== 'FuelLogs' }"></i>
        <span v-if="!sidebarCollapsed" class="ml-3 text-sm">Fuel Logs</span>
      </router-link>

      <router-link
        to="/maintenance"
        class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1 text-gray-600 dark:text-[#8b949e] dark:hover:text-[#e6edf3] dark:hover:bg-[#161b22]"
        :class="{
          'active !border-l-4 font-semibold text-green-900 dark:text-[#3fb950] border-green-900 dark:border-[#3fb950]': $route.name === 'Maintenance',
        }"
        :style="$route.name === 'Maintenance' ? 'background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05));' : ''"
        @click="handleMenuClick"
      >
        <i class="fas fa-tools w-5 text-center text-base" :class="{ 'text-green-900 dark:text-[#3fb950]': $route.name === 'Maintenance', 'text-gray-600 dark:text-[#8b949e]': $route.name !== 'Maintenance' }"></i>
        <span v-if="!sidebarCollapsed" class="ml-3 text-sm">Maintenance</span>
      </router-link>

      <router-link
        to="/livemap"
        class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1 text-gray-600 dark:text-[#8b949e] dark:hover:text-[#e6edf3] dark:hover:bg-[#161b22]"
        :class="{
          'active !border-l-4 font-semibold text-green-900 dark:text-[#3fb950] border-green-900 dark:border-[#3fb950]': $route.name === 'LiveMap',
        }"
        :style="$route.name === 'LiveMap' ? 'background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05));' : ''"
        @click="handleMenuClick"
      >
        <i class="fas fa-route w-5 text-center text-base" :class="{ 'text-green-900 dark:text-[#3fb950]': $route.name === 'LiveMap', 'text-gray-600 dark:text-[#8b949e]': $route.name !== 'LiveMap' }"></i>
        <span v-if="!sidebarCollapsed" class="ml-3 text-sm">Live GPS Map</span>
      </router-link>

      <div class="menu-section mt-6">
        <div class="menu-divider px-4 pb-3 text-xs uppercase font-semibold tracking-wide border-t border-green-200 dark:border-[#30363d] pt-4 transition-colors duration-200" v-if="!sidebarCollapsed">
          <span class="text-green-900 dark:text-[#6e7681]">Admin</span>
        </div>
        
        <router-link
          to="/settings"
          class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1 text-gray-600 dark:text-[#8b949e] dark:hover:text-[#e6edf3] dark:hover:bg-[#161b22]"
          :class="{
            'active !border-l-4 font-semibold text-green-900 dark:text-[#3fb950] border-green-900 dark:border-[#3fb950]': $route.name === 'Settings',
          }"
          :style="$route.name === 'Settings' ? 'background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05));' : ''"
          @click="handleMenuClick"
        >
          <i class="fas fa-cog w-5 text-center text-base" :class="{ 'text-green-900 dark:text-[#3fb950]': $route.name === 'Settings', 'text-gray-600 dark:text-[#8b949e]': $route.name !== 'Settings' }"></i>
          <span v-if="!sidebarCollapsed" class="ml-3 text-sm">Settings</span>
        </router-link>
      </div>
    </div>

    <!-- Sidebar Footer with User Info and Logout Button -->
    <div class="sidebar-footer p-4 border-t border-green-200 dark:border-[#30363d] transition-colors duration-200">
      <div class="user-info flex items-center mb-4 p-2 rounded-lg backdrop-blur-md bg-gradient-to-r from-green-900/10 to-green-900/5 dark:from-[#161b22] dark:to-[#1c2128] transition-colors duration-200" v-if="!sidebarCollapsed">
        <div class="user-avatar w-8 h-8 rounded-lg flex items-center justify-center mr-2 shadow-lg text-white text-sm bg-green-900 dark:bg-[#3fb950]/20 transition-colors duration-200">
          <i class="fas fa-user dark:text-[#3fb950]"></i>
        </div>
        <div class="user-details flex-1">
          <div class="user-name font-semibold text-xs ml-2 mb-1 text-green-900 dark:text-[#e6edf3] transition-colors duration-200">{{ userProfile?.full_name || 'Loading...' }}</div>
          <div class="user-role text-xs capitalize px-2 rounded-full text-white bg-green-900 dark:bg-[#1c2128] dark:text-[#8b949e] dark:border dark:border-[#30363d] transition-colors duration-200">{{ userProfile?.role || 'staff' }}</div>
        </div>
      </div>
      <button @click="logout" class="logout-btn w-full flex items-center justify-center rounded-lg border border-red-400/30 dark:border-red-500/40 bg-red-400/10 dark:bg-red-900/20 py-2 px-3 font-medium text-red-500 dark:text-red-400 transition-all duration-200 ease-in-out hover:bg-red-400/20 dark:hover:bg-red-900/40 hover:scale-105 hover:text-red-700 dark:hover:text-red-300 backdrop-blur-md text-sm" :title="sidebarCollapsed ? 'Logout' : ''">
        <i class="fas fa-sign-out-alt" :class="{ 'mr-2': !sidebarCollapsed }"></i>
        <span v-if="!sidebarCollapsed">Logout</span>
      </button>
    </div>
  </nav>

  <!-- Sidebar overlay for mobile -->
  <div
    v-if="sidebarOpen"
        class="fixed inset-0 bg-gray-300/60 dark:bg-[#0d1117]/90 backdrop-blur-sm lg:hidden transition-colors duration-200"
    @click="closeSidebar"
  ></div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'

export default {
  name: 'Navbar',
  props: {
    sidebarCollapsed: {
      type: Boolean,
      default: false
    },
    sidebarOpen: {
      type: Boolean,
      default: false
    }
  },
  emits: ['toggle-sidebar', 'close-sidebar', 'open-sidebar', 'menu-click'],
  setup(props, { emit }) {
    const router = useRouter()
    const userProfile = ref(null)

    // Sidebar methods
    const toggleSidebar = () => {
      emit('toggle-sidebar')
    }

    const closeSidebar = () => {
      emit('close-sidebar')
    }

    const handleMenuClick = () => {
      // Close the sidebar on mobile after clicking a menu item
      // Do NOT expand the sidebar on desktop - keep it in its current state
      if (window.innerWidth < 768) {
        closeSidebar();
      }
      emit('menu-click');
    }

    const loadUserProfile = async () => {
      try {
        const { data: { user } } = await supabase.auth.getUser()

        if (user) {
          const { data: profile, error } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .single()

          if (error) {
            console.error('Error loading profile:', error)
            // Set default values if profile not found
            userProfile.value = {
              full_name: user.user_metadata?.full_name || 'User',
              role: user.user_metadata?.role || 'staff',
              employee_id: user.user_metadata?.employee_id || 'N/A'
            }
          } else {
            userProfile.value = profile
          }
        } else {
          // No authenticated user, redirect to auth
          router.push('/')
        }
      } catch (error) {
        console.error('Error loading user profile:', error)
        router.push('/')
      }
    }

    const logout = async () => {
      try {
        const { error } = await supabase.auth.signOut()
        if (error) throw error
        
        // Clear user data
        userProfile.value = null
        
        // Router navigation will be handled by auth state change listener
        router.push('/')
      } catch (error) {
        console.error('Error logging out:', error)
        // Force redirect even if logout fails
        router.push('/')
      }
    }

    onMounted(async () => {
      await loadUserProfile()
    })

    return {
      userProfile,
      toggleSidebar,
      closeSidebar,
      handleMenuClick,
      logout
    }
  }
}
</script>

<style scoped>
/* Hover and Active effects for menu items */
.menu-item:hover:not(.active) {
  background: linear-gradient(to right, rgba(10, 64, 12, 0.1), rgba(10, 64, 12, 0.05));
  border-left: 4px solid #0A400C;
  color: #0A400C;
}

.menu-item:hover:not(.active) i {
  color: #0A400C;
}

/* Dark mode hover effects */
.dark .menu-item:hover:not(.active) {
  background: linear-gradient(to right, rgba(34, 197, 94, 0.15), rgba(34, 197, 94, 0.05));
  border-left: 4px solid #22c55e;
  color: #22c55e;
}

.dark .menu-item:hover:not(.active) i {
  color: #22c55e;
}

/* Dark mode active menu item background */
.dark .menu-item.active {
  background: linear-gradient(to right, rgba(34, 197, 94, 0.2), rgba(34, 197, 94, 0.05)) !important;
}
</style>
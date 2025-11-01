<template>
  <!-- Main sidebar container. It's fixed on mobile for overlay and relative on desktop. -->
  <nav
    class="sidebar fixed inset-y-0 z-[1000] h-full flex flex-col transition-all duration-300 ease-in-out bg-white bg-opacity-95 shadow-xl md:relative md:translate-x-0"
    :class="{
      'w-16 md:w-16': sidebarCollapsed,
      'w-64 md:w-64': !sidebarCollapsed,
      'translate-x-0': sidebarOpen,
      '-translate-x-full': !sidebarOpen,
    }"
  >
    <!-- Sidebar Header with Logo and Toggle Button -->
    <div
      class="sidebar-header flex items-center justify-between p-4 border-b border-green-200 bg-green-900/90"
     
    >
      <div class="logo flex items-center font-bold tracking-tight">
        <i class="fas fa-car text-lg text-yellow-500" :class="{ 'mr-3': !sidebarCollapsed }"></i>
        <span v-if="!sidebarCollapsed" class="text-white font-bold text-lg">Motorpool</span>
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
        class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1"
        :class="{
          'active !border-l-4 font-semibold text-green-900 border-green-900': $route.name === 'Dashboard',
        }"
        :style="$route.name === 'Dashboard' ? 'background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05));' : ''"
        @click="handleMenuClick"
      >
        <i class="fas fa-tachometer-alt w-5 text-center text-base" :class="{ 'text-green-900': $route.name === 'Dashboard', 'text-gray-600': $route.name !== 'Dashboard' }"></i>
        <span v-if="!sidebarCollapsed" class="ml-3 text-sm">Home</span>
      </router-link>

      <router-link
        to="/vehicles"
        class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1"
        :class="{
          'active !border-l-4 font-semibold text-green-900 border-green-900': $route.name === 'Vehicles',
        }"
        :style="$route.name === 'Vehicles' ? 'background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05));' : ''"
        @click="handleMenuClick"
      >
        <i class="fas fa-car w-5 text-center text-base" :class="{ 'text-green-900': $route.name === 'Vehicles', 'text-gray-600': $route.name !== 'Vehicles' }"></i>
        <span v-if="!sidebarCollapsed" class="ml-3 text-sm">Vehicles</span>
      </router-link>

      <router-link
        to="/fuel"
        class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1"
        :class="{
          'active !border-l-4 font-semibold text-green-900 border-green-900': $route.name === 'FuelLogs',
        }"
        :style="$route.name === 'FuelLogs' ? 'background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05));' : ''"
        @click="handleMenuClick"
      >
        <i class="fas fa-gas-pump w-5 text-center text-base" :class="{ 'text-green-900': $route.name === 'FuelLogs', 'text-gray-600': $route.name !== 'FuelLogs' }"></i>
        <span v-if="!sidebarCollapsed" class="ml-3 text-sm">Fuel Logs</span>
      </router-link>

      <router-link
        to="/maintenance"
        class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1"
        :class="{
          'active !border-l-4 font-semibold text-green-900 border-green-900': $route.name === 'Maintenance',
        }"
        :style="$route.name === 'Maintenance' ? 'background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05));' : ''"
        @click="handleMenuClick"
      >
        <i class="fas fa-wrench w-5 text-center text-base" :class="{ 'text-green-900': $route.name === 'Maintenance', 'text-gray-600': $route.name !== 'Maintenance' }"></i>
        <span v-if="!sidebarCollapsed" class="ml-3 text-sm">Maintenance</span>
      </router-link>

      <div class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1" @click="navigateToReports">
        <i class="fas fa-chart-bar w-5 text-center text-base text-gray-600"></i>
        <span v-if="!sidebarCollapsed" class="ml-3 text-sm text-gray-800">Reports</span>
      </div>

      <div class="menu-section mt-6">
        <div class="menu-divider px-4 pb-3 text-xs uppercase font-semibold tracking-wide border-t border-green-200 pt-4" v-if="!sidebarCollapsed" style="color: #0A400C;">
          <span>Admin</span>
        </div>
        
        <router-link
          to="/settings"
          class="menu-item flex items-center px-4 py-3 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1"
          :class="{
            'active !border-l-4 font-semibold text-green-900 border-green-900': $route.name === 'Settings',
          }"
          :style="$route.name === 'Settings' ? 'background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05));' : ''"
          @click="handleMenuClick"
        >
          <i class="fas fa-cog w-5 text-center text-base" :class="{ 'text-green-900': $route.name === 'Settings', 'text-gray-600': $route.name !== 'Settings' }"></i>
          <span v-if="!sidebarCollapsed" class="ml-3 text-sm">Settings</span>
        </router-link>
      </div>
    </div>

    <!-- Sidebar Footer with User Info and Logout Button -->
    <div class="sidebar-footer p-4 border-t border-green-200">
      <div class="user-info flex items-center mb-4 p-2 rounded-lg backdrop-blur-md" v-if="!sidebarCollapsed" style="background: linear-gradient(to right, rgba(10, 64, 12, 0.1), rgba(10, 64, 12, 0.05));">
        <div class="user-avatar w-8 h-8 rounded-lg flex items-center justify-center mr-2 shadow-lg text-white text-sm" style="background-color: #0A400C;">
          <i class="fas fa-user"></i>
        </div>
        <div class="user-details flex-1">
          <div class="user-name font-semibold text-xs ml-2 mb-1" style="color: #0A400C;">{{ userProfile?.full_name || 'Loading...' }}</div>
          <div class="user-role text-xs capitalize px-2 rounded-full text-white" style="background-color: #0A400C;">{{ userProfile?.role || 'staff' }}</div>
        </div>
      </div>
      <button @click="logout" class="logout-btn w-full flex items-center justify-center rounded-lg border border-red-400/30 bg-red-400/10 py-2 px-3 font-medium text-red-500 transition-all duration-200 ease-in-out hover:bg-red-400/20 hover:scale-105 hover:text-red-700 backdrop-blur-md text-sm" :title="sidebarCollapsed ? 'Logout' : ''">
        <i class="fas fa-sign-out-alt" :class="{ 'mr-2': !sidebarCollapsed }"></i>
        <span v-if="!sidebarCollapsed">Logout</span>
      </button>
    </div>
  </nav>

  <!-- Sidebar overlay for mobile -->
  <div
    v-if="sidebarOpen"
        class="fixed inset-0 bg-gray-300/60 backdrop-blur-sm lg:hidden"
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

    // Navigation methods
    const navigateToReports = () => {
      console.log('Reports feature coming soon!');
    }

    // Sidebar methods
    const toggleSidebar = () => {
      emit('toggle-sidebar')
    }

    const closeSidebar = () => {
      emit('close-sidebar')
    }

    const handleMenuClick = () => {
      // Close the sidebar on mobile after clicking a menu item
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
      logout,
      navigateToReports
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
</style>
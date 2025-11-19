<template>
  <div class="flex h-screen bg-gradient-to-br from-csu-green-dark to-csu-green-light font-inter">
    <nav
      class="sidebar relative flex flex-col transition-all duration-300 ease-in-out bg-white bg-opacity-95 shadow-xl shadow-green-500/20 z-40"
      :class="{
        'w-20': sidebarCollapsed,
        '-translate-x-full': !sidebarOpen,
        'w-[280px]': !sidebarCollapsed,
      }"
    >
      <div
        class="sidebar-header flex items-center justify-between p-6 border-b border-green-200"
        style="background-color: #0A400C; background-opacity: 0.05;"
      >
        <div class="logo flex items-center font-bold tracking-tight">
          <i class="fas fa-car mr-3 text-lg text-yellow-500" v-if="!sidebarCollapsed"></i>
          <span v-if="!sidebarCollapsed" class="text-white font-bold text-lg" style="color: white;">Motorpool</span>
          <i class="fas fa-car text-lg text-yellow-500" v-else></i>
        </div>
        <div class="sidebar-controls flex items-center">
          <button 
            @click="toggleSidebar" 
            class="sidebar-toggle rounded-md p-2 transition-all duration-200 ease-in-out hover:scale-105 backdrop-blur-md text-white"
            style="background-color: #0A400C;"
          >
            <i :class="sidebarCollapsed ? 'fas fa-chevron-right' : 'fas fa-chevron-left'"></i>
          </button>
        </div>
      </div>

      <div class="sidebar-menu flex-1 py-8">
        <div
          class="menu-item flex items-center px-6 py-3.5 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1"
          @click="navigateToDashboard"
        >
          <i class="fas fa-tachometer-alt w-6 text-center text-lg"></i>
          <span v-if="!sidebarCollapsed" class="ml-3">Overview</span>
        </div>

        <div
          class="menu-item flex items-center px-6 py-3.5 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1"
          @click="navigateToVehicles"
        >
          <i class="fas fa-car w-6 text-center text-lg"></i>
          <span v-if="!sidebarCollapsed" class="ml-3">Vehicles</span>
        </div>

        <div
          class="menu-item flex items-center px-6 py-3.5 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1"
          @click="navigateToFuelLogs"
        >
          <i class="fas fa-gas-pump w-6 text-center text-lg"></i>
          <span v-if="!sidebarCollapsed" class="ml-3">Fuel Logs</span>
        </div>

        <div class="menu-item flex items-center px-6 py-3.5 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1" @click="navigateToMaintenance">
          <i class="fas fa-wrench w-6 text-center text-lg"></i>
          <span v-if="!sidebarCollapsed" class="ml-3">Maintenance</span>
        </div>

        <div class="menu-item flex items-center px-6 py-3.5 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1" @click="navigateToReports">
          <i class="fas fa-chart-bar w-6 text-center text-lg"></i>
          <span v-if="!sidebarCollapsed" class="ml-3">Reports</span>
        </div>

        <div class="menu-section mt-8" v-if="userRole === 'admin'">
          <div class="menu-divider px-6 pb-4 text-xs uppercase font-semibold tracking-wide border-t border-green-200 pt-6" v-if="!sidebarCollapsed" style="color: #0A400C;">
            <span>Admin</span>
          </div>
          <div class="menu-item flex items-center px-6 py-3.5 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1" @click="navigateToUserManagement">
            <i class="fas fa-users w-6 text-center text-lg"></i>
            <span v-if="!sidebarCollapsed" class="ml-3">User Management</span>
          </div>
          
          <div
            class="menu-item flex items-center px-6 py-3.5 cursor-pointer transition-all duration-300 ease-in-out hover:translate-x-1 active !border-l-4 text-white font-semibold"
            style="border-left-color: #0A400C; background: linear-gradient(to right, rgba(10, 64, 12, 0.2), rgba(10, 64, 12, 0.05)); color: #0A400C;"
          >
            <i class="fas fa-cog w-6 text-center text-lg" style="color: #0A400C;"></i>
            <span v-if="!sidebarCollapsed" class="ml-3">Settings</span>
          </div>
        </div>
      </div>

      <div class="sidebar-footer p-6 border-t border-green-200">
        <div class="user-info flex items-center mb-5 p-3 rounded-xl backdrop-blur-md" v-if="!sidebarCollapsed" style="background: linear-gradient(to right, rgba(10, 64, 12, 0.1), rgba(10, 64, 12, 0.05));">
          <div class="user-avatar w-10 h-10 rounded-xl flex items-center justify-center mr-3 shadow-lg text-white" style="background-color: #0A400C;">
            <i class="fas fa-user"></i>
          </div>
          <div class="user-details flex-1">
            <div class="user-name font-semibold text-sm mb-1" style="color: #0A400C;">{{ userProfile?.full_name || 'Loading...' }}</div>
            <div class="user-role text-xs capitalize px-2 py-1 rounded-full text-white" style="background-color: #0A400C;">{{ userProfile?.role || 'staff' }}</div>
          </div>
        </div>
        <button @click="logout" class="logout-btn w-full flex items-center justify-center rounded-lg border border-red-400/30 bg-red-400/10 py-3 px-4 font-medium text-red-600 transition-all duration-200 ease-in-out hover:bg-red-400/20 hover:scale-105 hover:text-red-700 backdrop-blur-md" :title="sidebarCollapsed ? 'Logout' : ''">
          <i class="fas fa-sign-out-alt mr-2"></i>
          <span v-if="!sidebarCollapsed">Logout</span>
        </button>
      </div>
    </nav>

    <div
      v-if="sidebarOpen && !sidebarCollapsed"
      class="sidebar-overlay fixed inset-0 z-30 bg-black bg-opacity-50 md:hidden"
      @click="closeSidebar"
    ></div>

   <main class="flex-1 flex flex-col transition-all duration-300 ease-out min-w-0">
    <header class="bg-white/95 backdrop-blur-xl py-5 px-8 border-b border-white/20 flex justify-between items-center shadow-sm sticky top-0 z-10">
        
        <div class="flex items-center gap-4">
            <button
                @click="openSidebar"
                class="bg-csu-green-dark border-none text-white py-2.5 px-3 rounded-lg cursor-pointer transition-all duration-200 hover:bg-csu-green-medium hover:scale-105 lg:hidden"
                v-if="!sidebarOpen"
            >
                <i class="fas fa-bars"></i>
            </button>
            <h1 class="m-0 text-csu-green-dark text-3xl font-bold tracking-tight">Settings</h1>
        </div>
        
        <div class="flex items-center">
            <div class="flex  rounded-xl overflow-hidden">
                <button
                    @click="activeTab = 'profile'"
                    :class="['px-6 py-3 font-semibold text-sm transition-all duration-200 flex items-center justify-center gap-2',
                              activeTab === 'profile' ? 'bg-csu-green-dark text-white border-b-4 border-csu-green-dark' : 'text-gray-600 hover:bg-gray-50']"
                >
                    <i class="fas fa-user-circle text-lg"></i>
                    Profile
                </button>
                <button
                    @click="activeTab = 'security'"
                    :class="['px-6 py-3 font-semibold text-sm transition-all duration-200 flex items-center justify-center gap-2',
                              activeTab === 'security' ? 'bg-csu-green-dark text-white border-b-4 border-csu-green-dark' : 'text-gray-600 hover:bg-gray-50']"
                >
                    <i class="fas fa-shield-alt text-lg"></i>
                    Security
                </button>
                <button
                    @click="activeTab = 'theme'"
                    :class="['px-6 py-3 font-semibold text-sm transition-all duration-200 flex items-center justify-center gap-2',
                              activeTab === 'theme' ? 'bg-csu-green-dark text-white border-b-4 border-csu-green-dark' : 'text-gray-600 hover:bg-gray-50']"
                >
                    <i class="fas fa-palette text-lg"></i>
                    Theme
                </button>
            </div>
        </div>
    </header>
    
    <div class="flex-1 p-8 overflow-y-auto">
        <div class="max-w-7xl mx-auto">
            <div class="tab-content">
                <div v-if="activeTab === 'profile'" class="space-y-6">
                    <ProfileSettings />
                </div>
                <div v-if="activeTab === 'security'" class="space-y-6">
                    <SecuritySettings />
                </div>
                <div v-if="activeTab === 'theme'" class="space-y-6">
                    <ThemeSettings />
                </div>
            </div>
        </div>
    </div>
</main>

    <div
      v-if="notification.show"
      :class="[
        'fixed bottom-4 right-4 p-4 rounded-lg shadow-xl z-50 transition-all duration-300 flex items-center gap-3',
        notification.type === 'success' ? 'bg-green-500 text-white' : 'bg-red-500 text-white'
      ]"
    >
      <i :class="notification.type === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-circle'" class="text-xl"></i>
      <span class="font-medium">{{ notification.message }}</span>
    </div>
  </div>
</template>

<script>
// (The script section remains unchanged)
import { ref, reactive, onMounted, provide } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import ProfileSettings from './settings/Profile.vue'
import SecuritySettings from './settings/Security.vue'
import ThemeSettings from './settings/Theme.vue'

export default {
  name: 'Settings',
  components: {
    ProfileSettings,
    SecuritySettings,
    ThemeSettings
  },
  setup() {
    const router = useRouter()
    const sidebarCollapsed = ref(false)
    const sidebarOpen = ref(true)
    const userProfile = ref(null)
    const userRole = ref('staff')
    const activeTab = ref('profile')

    const notification = reactive({
      show: false,
      message: '',
      type: 'success'
    })

    // Provide notification function to child components
    const showNotification = (message, type = 'success') => {
      notification.message = message
      notification.type = type
      notification.show = true
      setTimeout(() => {
        notification.show = false
      }, 4000)
    }

    provide('showNotification', showNotification)

    // Sidebar methods
    const toggleSidebar = () => {
      sidebarCollapsed.value = !sidebarCollapsed.value
    }

    const closeSidebar = () => {
      if (window.innerWidth <= 768) {
        sidebarOpen.value = false
      } else {
        sidebarCollapsed.value = true
      }
    }

    const openSidebar = () => {
      sidebarOpen.value = true
      if (window.innerWidth > 768) {
        sidebarCollapsed.value = false
      }
    }

    // Navigation methods
    const navigateToDashboard = () => {
      router.push('/dashboard')
    }

    const navigateToVehicles = () => {
      router.push('/vehicles')
    }

    const navigateToFuelLogs = () => {
      router.push('/fuel')
    }

    const navigateToMaintenance = () => {
      alert('Maintenance feature coming soon!')
    }

    const navigateToReports = () => {
      alert('Reports feature coming soon!')
    }

    const navigateToUserManagement = () => {
      alert('User Management feature coming soon!')
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
          } else {
            userProfile.value = profile
            userRole.value = profile.role || 'staff'
          }
        }
      } catch (error) {
        console.error('Error loading user profile:', error)
      }
    }

    const logout = async () => {
      try {
        const { error } = await supabase.auth.signOut()
        if (error) throw error
        router.push('/')
      } catch (error) {
        console.error('Error logging out:', error)
      }
    }

    const handleResize = () => {
      if (window.innerWidth > 768) {
        sidebarOpen.value = true
      } else if (window.innerWidth <= 768) {
        sidebarCollapsed.value = false
      }
    }

    onMounted(async () => {
      await loadUserProfile()
      window.addEventListener('resize', handleResize)
      handleResize()
    })

    return {
      sidebarCollapsed,
      sidebarOpen,
      userProfile,
      userRole,
      activeTab,
      notification,
      toggleSidebar,
      closeSidebar,
      openSidebar,
      navigateToDashboard,
      navigateToVehicles,
      navigateToFuelLogs,
      navigateToMaintenance,
      navigateToReports,
      navigateToUserManagement,
      logout
    }
  }
}
</script>

<style scoped>
.menu-item:hover {
  background: linear-gradient(to right, rgba(10, 64, 12, 0.1), rgba(10, 64, 12, 0.05));
  border-left: 4px solid #0A400C;
  color: #0A400C;
}

.menu-item:hover i {
  color: #0A400C;
}

.tab-content {
  animation: fadeIn 0.3s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (max-width: 768px) {
  .sidebar-collapsed {
    transform: translateX(-100%);
  }
}
</style>
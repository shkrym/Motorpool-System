<template>
  <div class="flex h-screen bg-gradient-to-br from-yellow-50 to-green-100 font-sans">
    <!-- Navbar Component -->
    <Navbar 
      :sidebarCollapsed="sidebarCollapsed"
      :sidebarOpen="sidebarOpen"
      @toggle-sidebar="toggleSidebar"
      @close-sidebar="closeSidebar"
      @open-sidebar="openSidebar"
      @menu-click="handleMenuClick"
    />

    <!-- Main Content -->
    <main class="main-content flex flex-1 flex-col transition-all duration-300 ease-in-out min-w-0" :class="{ '!ml-0': sidebarCollapsed || !sidebarOpen }">
      <header class="content-header sticky top-0 z-100 flex items-center justify-between border-b border-green-200 bg-white bg-opacity-95 p-5 shadow-md backdrop-blur-md">
        <div class="header-left flex items-center gap-4">
          <button 
            @click="openSidebar" 
            class="menu-trigger text-white border-none p-2.5 rounded-lg cursor-pointer transition-all duration-200 ease-in-out hover:scale-105 shadow-lg" 
            v-if="!sidebarOpen"
            style="background-color: #0A400C;"
          >
            <i class="fas fa-bars"></i>
          </button>
          <h1 class="m-0 text-2xl font-bold tracking-tight" style="color: #0A400C;">{{ getViewTitle() }}</h1>
        </div>
        <div class="header-actions flex items-center">
            <i class="fas fa-user-circle mr-2.5 text-white text-lg"></i>
        </div>
      </header>

      <div class="content-body flex-1 overflow-y-auto p-8 bg-gradient-to-br from-yellow-50 to-green-100">
        <div class="view-container mx-auto max-w-7xl">
          <!-- Dashboard Stats -->
          <div class="stats-grid grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
            <div class="stat-card flex items-center rounded-xl bg-white bg-opacity-90 p-7 shadow-lg shadow-green-500/10 border border-white border-opacity-30 transition-all duration-300 ease-in-out hover:-translate-y-1 hover:shadow-xl hover:shadow-green-500/15">
              <div class="stat-icon w-16 h-16 rounded-2xl flex items-center justify-center mr-5 shadow-2xl text-white" style="background-color: #0A400C;">
                <i class="fas fa-car text-2xl"></i>
              </div>
              <div class="stat-info">
                <h3 class="m-0 mb-1 text-4xl font-extrabold" style="color: #0A400C;">{{ vehicleStats.total }}</h3>
                <p class="m-0 text-gray-600 font-semibold text-sm">Total Vehicles</p>
              </div>
            </div>

            <div class="stat-card flex items-center rounded-xl bg-white bg-opacity-90 p-7 shadow-lg shadow-green-500/10 border border-white border-opacity-30 transition-all duration-300 ease-in-out hover:-translate-y-1 hover:shadow-xl hover:shadow-green-500/15">
              <div class="stat-icon w-16 h-16 rounded-2xl flex items-center justify-center mr-5 shadow-2xl text-white" style="background-color: #0A400C;">
                <i class="fas fa-check-circle text-2xl"></i>
              </div>
              <div class="stat-info">
                <h3 class="m-0 mb-1 text-4xl font-extrabold" style="color: #0A400C;">{{ vehicleStats.available }}</h3>
                <p class="m-0 text-gray-600 font-semibold text-sm">Available</p>
              </div>
            </div>

            <div class="stat-card flex items-center rounded-xl bg-white bg-opacity-90 p-7 shadow-lg shadow-green-500/10 border border-white border-opacity-30 transition-all duration-300 ease-in-out hover:-translate-y-1 hover:shadow-xl hover:shadow-green-500/15">
              <div class="stat-icon w-16 h-16 rounded-2xl bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center mr-5 shadow-2xl shadow-orange-700/30">
                <i class="fas fa-road text-white text-2xl"></i>
              </div>
              <div class="stat-info">
                <h3 class="m-0 mb-1 text-4xl font-extrabold" style="color: #0A400C;">{{ vehicleStats.inUse }}</h3>
                <p class="m-0 text-gray-600 font-semibold text-sm">In Use</p>
              </div>
            </div>

            <div class="stat-card flex items-center rounded-xl bg-white bg-opacity-90 p-7 shadow-lg shadow-green-500/10 border border-white border-opacity-30 transition-all duration-300 ease-in-out hover:-translate-y-1 hover:shadow-xl hover:shadow-green-500/15">
              <div class="stat-icon w-16 h-16 rounded-2xl bg-gradient-to-br from-red-500 to-red-600 flex items-center justify-center mr-5 shadow-2xl shadow-red-700/30">
                <i class="fas fa-wrench text-white text-2xl"></i>
              </div>
              <div class="stat-info">
                <h3 class="m-0 mb-1 text-4xl font-extrabold" style="color: #0A400C;">{{ vehicleStats.maintenance }}</h3>
                <p class="m-0 text-gray-600 font-semibold text-sm">Maintenance</p>
              </div>
            </div>
          </div>

          <!-- Dashboard Sections -->
          <div class="dashboard-sections grid grid-cols-1 lg:grid-cols-2 gap-7">
            <div class="section rounded-xl bg-white bg-opacity-90 p-7 shadow-lg shadow-green-500/10 border border-white border-opacity-30">
              <h3 class="m-0 mb-6 text-xl font-bold" style="color: #0A400C;">Recent Activity</h3>
              <div class="activity-list flex flex-col gap-4">
                <div class="activity-item flex items-center py-3.5 border-b border-gray-200" v-for="activity in recentActivity" :key="activity.id">
                  <i class="fas fa-circle text-yellow-500 text-xs mr-4"></i>
                  <span class="flex-1 text-sm font-medium" style="color: #0A400C;">{{ activity.description }}</span>
                  <small class="text-gray-500 text-xs font-medium">{{ formatDate(activity.created_at) }}</small>
                </div>
              </div>
            </div>

            <div class="section rounded-xl bg-white bg-opacity-90 p-7 shadow-lg shadow-green-500/10 border border-white border-opacity-30">
              <h3 class="m-0 mb-6 text-xl font-bold" style="color: #0A400C;">Quick Actions</h3>
              <div class="quick-actions flex flex-col gap-3.5">
                <button @click="navigateToVehicles" class="action-btn primary flex items-center rounded-xl text-white p-4 font-semibold transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-xl justify-start text-sm" style="background-color: #0A400C;">
                  <i class="fas fa-plus mr-3 text-base"></i>
                  Add Vehicle
                </button>
                <button @click="navigateToFuelLogs" class="action-btn secondary flex items-center rounded-xl bg-gradient-to-br from-green-500 to-green-600 text-white p-4 font-semibold transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-xl hover:shadow-green-700/40 justify-start text-sm">
                  <i class="fas fa-gas-pump mr-3 text-base"></i>
                  Log Fuel
                </button>
                <button @click="navigateToMaintenance" class="action-btn tertiary flex items-center rounded-xl bg-gradient-to-br from-orange-500 to-orange-600 text-white p-4 font-semibold transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-xl hover:shadow-orange-700/40 justify-start text-sm">
                  <i class="fas fa-wrench mr-3 text-base"></i>
                  Schedule Maintenance
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../lib/supabase'
import Navbar from '../pages/Navbar.vue'

export default {
  name: 'Dashboard',
  components: {
    Navbar
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    const sidebarCollapsed = ref(false)
    const sidebarOpen = ref(true)
    
    const userProfile = ref(null)
    const userRole = ref('staff')

    // Stats data
    const vehicleStats = reactive({
      total: 0,
      available: 0,
      inUse: 0,
      maintenance: 0
    })

    const recentActivity = ref([])

    // Navigation methods
    const navigateToVehicles = () => {
      router.push('/vehicles')
      handleMenuClick()
    }

    const navigateToFuelLogs = () => {
      router.push('/fuel')
      handleMenuClick()
    }

    const navigateToMaintenance = () => {
      alert('Maintenance feature coming soon!')
    }

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

    const handleMenuClick = () => {
      if (window.innerWidth <= 768) {
        sidebarOpen.value = false
      }
    }

    const getViewTitle = () => {
      const titles = {
        'Dashboard': 'Dashboard Overview',
        'Vehicles': 'Vehicle Management',
        'FuelLogs': 'Fuel Logs',
        'Settings': 'Settings'
      }
      return titles[route.name] || 'Dashboard'
    }

    const formatDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
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
            userProfile.value = {
              full_name: 'User',
              role: 'staff'
            }
            userRole.value = 'staff'
          } else {
            userProfile.value = profile
            userRole.value = profile.role || 'staff'
          }
        }
      } catch (error) {
        console.error('Error loading user profile:', error)
        userProfile.value = {
          full_name: 'User',
          role: 'staff'
        }
        userRole.value = 'staff'
      }
    }

    const loadDashboardData = async () => {
      try {
        const { data: vehicles, error } = await supabase
          .from('vehicles')
          .select('status')

        if (error) {
          console.error('Error loading vehicles:', error)
          vehicleStats.total = 12
          vehicleStats.available = 8
          vehicleStats.inUse = 3
          vehicleStats.maintenance = 1
        } else {
          vehicleStats.total = vehicles.length
          vehicleStats.available = vehicles.filter(v => v.status === 'available').length
          vehicleStats.inUse = vehicles.filter(v => v.status === 'in_use').length
          vehicleStats.maintenance = vehicles.filter(v => v.status === 'maintenance').length
        }

        recentActivity.value = [
          {
            id: 1,
            description: 'Vehicle ABC-123 returned from service',
            created_at: new Date().toISOString()
          },
          {
            id: 2,
            description: 'Fuel logged for vehicle XYZ-789',
            created_at: new Date(Date.now() - 3600000).toISOString()
          }
        ]
      } catch (error) {
        console.error('Error loading dashboard data:', error)
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
      await loadDashboardData()

      window.addEventListener('resize', handleResize)
      handleResize()
    })

    return {
      sidebarCollapsed,
      sidebarOpen,
      userProfile,
      userRole,
      vehicleStats,
      recentActivity,
      toggleSidebar,
      closeSidebar,
      openSidebar,
      handleMenuClick,
      getViewTitle,
      formatDate,
      navigateToVehicles,
      navigateToFuelLogs,
      navigateToMaintenance
    }
  }
}
</script>

<style scoped>
/* Custom scrollbar for content-body */
.content-body::-webkit-scrollbar {
  width: 6px;
}

.content-body::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.05);
}

.content-body::-webkit-scrollbar-thumb {
  background: rgba(10, 64, 12, 0.3);
  border-radius: 3px;
}

.content-body::-webkit-scrollbar-thumb:hover {
  background: rgba(10, 64, 12, 0.5);
}
</style>
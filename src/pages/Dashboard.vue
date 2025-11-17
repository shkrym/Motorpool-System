<template>
  <div class="flex h-screen bg-gradient-to-br from-green-50 via-emerald-100 to-teal-100 font-sans">
    <Navbar 
      :sidebarCollapsed="sidebarCollapsed"
      :sidebarOpen="sidebarOpen"
      @toggle-sidebar="toggleSidebar"
      @close-sidebar="closeSidebar"
      @open-sidebar="openSidebar"
      @menu-click="handleMenuClick"
    />

    <main class="flex flex-1 flex-col transition-all duration-300 ease-in-out min-w-0" :class="{ '!ml-0': sidebarCollapsed || !sidebarOpen }">
      <!-- Header -->
      <header class="sticky top-0 z-50 bg-gradient-to-br from-green-800 to-green-600 flex items-center justify-between border-b border-green-200 p-4 md:p-5 shadow-md">
        <div class="flex items-center gap-3 md:gap-4">
          <button 
            @click="openSidebar" 
            class="text-white p-2 md:p-2.5 rounded-lg transition-all duration-200 hover:scale-105 shadow-lg" 
            v-if="!sidebarOpen"
            style="background-color: #0A400C;"
          >
            <i class="fas fa-bars"></i>
          </button>
          <div>
            <h1 class="text-lg md:text-2xl font-bold tracking-tight text-white">{{ getViewTitle() }}</h1>
            <p class="text-xs text-green-300 hidden md:block">{{ currentDate }}</p>
          </div>
        </div>
        <div class="hidden sm:flex items-center gap-4">
          <div class="flex items-center gap-2 px-3 py-2 bg-green-500/20 rounded-lg">
            <div class="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
            <span class="text-xs text-white font-medium">System Active</span>
          </div>
          <div class="flex items-center py-2 px-3 bg-gradient-to-br from-slate-50 to-slate-200 rounded-lg font-semibold shadow-md text-xs" style="color: #0A400C;">
            <i class="fas fa-user-circle mr-2 text-sm " style="color: #4ade80;"></i>
            {{ userProfile?.full_name || 'Admin' }}
          </div>
        </div>
      </header>
      
      <!-- Content Body -->
      <div class="flex-1 overflow-y-auto p-4 md:p-6 lg:p-8 bg-green-100/80">
        <div class="mx-auto max-w-7xl space-y-6">
          
          <!-- Stats Grid -->
          <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 md:gap-5">
            <!-- Total Vehicles -->
            <div class="relative overflow-hidden rounded-xl bg-white p-4 md:p-6 shadow-lg border border-white/30 transition-all duration-300 hover:-translate-y-1 hover:shadow-xl">
              <div class="absolute top-0 right-0 w-20 h-20 bg-[#0A400C] opacity-5 rounded-full -mr-10 -mt-10"></div>
              <div class="flex items-center justify-between mb-3">
                <div class="w-10 h-10 md:w-12 md:h-12 rounded-xl flex items-center justify-center text-white shadow-lg" style="background-color: #0A400C;">
                  <i class="fas fa-car text-base md:text-xl"></i>
                </div>
                <span class="text-xs font-medium px-2 py-1 bg-green-100 text-green-700 rounded-full">Fleet</span>
              </div>
              <h3 class="text-2xl md:text-3xl font-bold mb-1" style="color: #0A400C;">{{ vehicleStats.total }}</h3>
              <p class="text-xs md:text-sm text-gray-600 font-medium">Total Vehicles</p>
            </div>

            <!-- Available -->
            <div class="relative overflow-hidden rounded-xl bg-white p-4 md:p-6 shadow-lg border border-white/30 transition-all duration-300 hover:-translate-y-1 hover:shadow-xl">
              <div class="absolute top-0 right-0 w-20 h-20 bg-green-500 opacity-5 rounded-full -mr-10 -mt-10"></div>
              <div class="flex items-center justify-between mb-3">
                <div class="w-10 h-10 md:w-12 md:h-12 rounded-xl flex items-center justify-center bg-gradient-to-br from-green-500 to-green-600 text-white shadow-lg">
                  <i class="fas fa-check-circle text-base md:text-xl"></i>
                </div>
                <span class="text-xs font-medium px-2 py-1 bg-green-100 text-green-700 rounded-full">Ready</span>
              </div>
              <h3 class="text-2xl md:text-3xl font-bold text-green-600 mb-1">{{ vehicleStats.available }}</h3>
              <p class="text-xs md:text-sm text-gray-600 font-medium">Available Now</p>
              <div class="mt-2 w-full bg-gray-200 rounded-full h-1.5">
                <div class="bg-green-500 h-1.5 rounded-full transition-all duration-500" :style="{ width: availabilityPercentage + '%' }"></div>
              </div>
            </div>

            <!-- In Use -->
            <div class="relative overflow-hidden rounded-xl bg-white p-4 md:p-6 shadow-lg border border-white/30 transition-all duration-300 hover:-translate-y-1 hover:shadow-xl">
              <div class="absolute top-0 right-0 w-20 h-20 bg-orange-500 opacity-5 rounded-full -mr-10 -mt-10"></div>
              <div class="flex items-center justify-between mb-3">
                <div class="w-10 h-10 md:w-12 md:h-12 rounded-xl flex items-center justify-center bg-gradient-to-br from-orange-500 to-orange-600 text-white shadow-lg">
                  <i class="fas fa-road text-base md:text-xl"></i>
                </div>
                <span class="text-xs font-medium px-2 py-1 bg-orange-100 text-orange-700 rounded-full">Active</span>
              </div>
              <h3 class="text-2xl md:text-3xl font-bold text-orange-600 mb-1">{{ vehicleStats.inUse }}</h3>
              <p class="text-xs md:text-sm text-gray-600 font-medium">Currently In Use</p>
              <div class="mt-2 w-full bg-gray-200 rounded-full h-1.5">
                <div class="bg-orange-500 h-1.5 rounded-full transition-all duration-500" :style="{ width: inUsePercentage + '%' }"></div>
              </div>
            </div>

            <!-- Maintenance -->
            <div class="relative overflow-hidden rounded-xl bg-white p-4 md:p-6 shadow-lg border border-white/30 transition-all duration-300 hover:-translate-y-1 hover:shadow-xl">
              <div class="absolute top-0 right-0 w-20 h-20 bg-red-500 opacity-5 rounded-full -mr-10 -mt-10"></div>
              <div class="flex items-center justify-between mb-3">
                <div class="w-10 h-10 md:w-12 md:h-12 rounded-xl flex items-center justify-center bg-gradient-to-br from-red-500 to-red-600 text-white shadow-lg">
                  <i class="fas fa-wrench text-base md:text-xl"></i>
                </div>
                <span class="text-xs font-medium px-2 py-1 bg-red-100 text-red-700 rounded-full">Service</span>
              </div>
              <h3 class="text-2xl md:text-3xl font-bold text-red-600 mb-1">{{ vehicleStats.maintenance }}</h3>
              <p class="text-xs md:text-sm text-gray-600 font-medium">Under Maintenance</p>
              <div class="mt-2 w-full bg-gray-200 rounded-full h-1.5">
                <div class="bg-red-500 h-1.5 rounded-full transition-all duration-500" :style="{ width: maintenancePercentage + '%' }"></div>
              </div>
            </div>
          </div>

          <!-- Main Content Grid -->
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 md:gap-6">
            
            <!-- Recent Activity - Takes 2 columns on large screens -->
            <div class="lg:col-span-2 rounded-xl bg-white p-5 md:p-6 shadow-lg border border-white/30">
              <div class="flex items-center justify-between mb-5">
                <h3 class="text-lg md:text-xl font-bold flex items-center" style="color: #0A400C;">
                  <i class="fas fa-history mr-2 text-yellow-500"></i>
                  Recent Activity
                </h3>
                <button class="text-xs text-gray-600 hover:text-[#0A400C] font-medium transition-colors">View All</button>
              </div>
              
              <div class="space-y-3">
                <div v-if="recentActivity.length === 0" class="text-center py-12 text-gray-400">
                  <i class="fas fa-clipboard-list text-4xl mb-3 opacity-30"></i>
                  <p class="text-sm font-medium">No recent activity</p>
                  <p class="text-xs mt-1">Activity will appear here as actions are performed</p>
                </div>
                
                <div v-else v-for="activity in recentActivity.slice(0, 6)" :key="activity.id" 
                     class="flex items-start gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colors border border-gray-100">
                  <div class="w-8 h-8 rounded-lg flex items-center justify-center text-white text-xs flex-shrink-0" :class="getActivityIconClass(activity.type)">
                    <i :class="getActivityIcon(activity.type)"></i>
                  </div>
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-800 mb-1">{{ activity.description }}</p>
                    <div class="flex items-center gap-2 text-xs text-gray-500">
                      <span>{{ activity.user || 'System' }}</span>
                      <span>•</span>
                      <span>{{ formatRelativeTime(activity.created_at) }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Quick Actions & Status -->
            <div class="space-y-4 md:space-y-6">
              <!-- Quick Actions -->
              <div class="rounded-xl bg-white p-5 md:p-6 shadow-lg border border-white/30">
                <h3 class="text-lg md:text-xl font-bold mb-4 flex items-center" style="color: #0A400C;">
                  <i class="fas fa-bolt mr-2 text-yellow-500"></i>
                  Quick Actions
                </h3>
                <div class="space-y-2.5">
                  <button @click="navigateToVehicles" class="w-full flex items-center gap-3 rounded-lg text-white p-3 font-medium transition-all duration-300 hover:scale-105 hover:shadow-lg text-sm" style="background-color: #0A400C;">
                    <i class="fas fa-plus text-sm"></i>
                    <span>Add Vehicle</span>
                  </button>
                  <button @click="navigateToFuelLogs" class="w-full flex items-center gap-3 rounded-lg bg-gradient-to-br from-green-500 to-green-600 text-white p-3 font-medium transition-all duration-300 hover:scale-105 hover:shadow-lg text-sm">
                    <i class="fas fa-gas-pump text-sm"></i>
                    <span>Log Fuel</span>
                  </button>
                  <button @click="navigateToMaintenance" class="w-full flex items-center gap-3 rounded-lg bg-gradient-to-br from-red-500 to-red-600 text-white p-3 font-medium transition-all duration-300 hover:scale-105 hover:shadow-lg text-sm">
                    <i class="fas fa-wrench text-sm"></i>
                    <span>Schedule Service</span>
                  </button>
                </div>
              </div>

              <!-- Fleet Status Overview -->
              <div class="rounded-xl bg-white p-5 md:p-6 shadow-lg border border-white/30">
                <h3 class="text-lg md:text-xl font-bold mb-4 flex items-center" style="color: #0A400C;">
                  <i class="fas fa-chart-pie mr-2 text-yellow-500"></i>
                  Fleet Status
                </h3>
                <div class="space-y-3">
                  <div class="flex items-center justify-between p-2 rounded-lg bg-green-50">
                    <div class="flex items-center gap-2">
                      <div class="w-2 h-2 bg-green-500 rounded-full"></div>
                      <span class="text-sm font-medium text-gray-700">Available</span>
                    </div>
                    <span class="text-sm font-bold text-green-600">{{ availabilityPercentage }}%</span>
                  </div>
                  <div class="flex items-center justify-between p-2 rounded-lg bg-orange-50">
                    <div class="flex items-center gap-2">
                      <div class="w-2 h-2 bg-orange-500 rounded-full"></div>
                      <span class="text-sm font-medium text-gray-700">In Use</span>
                    </div>
                    <span class="text-sm font-bold text-orange-600">{{ inUsePercentage }}%</span>
                  </div>
                  <div class="flex items-center justify-between p-2 rounded-lg bg-red-50">
                    <div class="flex items-center gap-2">
                      <div class="w-2 h-2 bg-red-500 rounded-full"></div>
                      <span class="text-sm font-medium text-gray-700">Maintenance</span>
                    </div>
                    <span class="text-sm font-bold text-red-600">{{ maintenancePercentage }}%</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Additional Info Cards -->
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-5">
            <!-- Fuel Usage -->
            <div class="rounded-xl bg-white p-5 shadow-lg border border-white/30">
              <div class="flex items-center justify-between mb-3">
                <h4 class="text-sm font-bold text-gray-700">Monthly Fuel Usage</h4>
                <i class="fas fa-gas-pump text-green-500"></i>
              </div>
              <p class="text-2xl font-bold" style="color: #0A400C;">{{ fuelStats.monthly }} L</p>
              <p class="text-xs text-gray-500 mt-1">
                <span :class="fuelStats.trend >= 0 ? 'text-red-500' : 'text-green-500'">
                  <i :class="fuelStats.trend >= 0 ? 'fas fa-arrow-up' : 'fas fa-arrow-down'"></i>
                  {{ Math.abs(fuelStats.trend) }}%
                </span>
                vs last month
              </p>
            </div>

            <!-- Maintenance Due -->
            <div class="rounded-xl bg-white p-5 shadow-lg border border-white/30">
              <div class="flex items-center justify-between mb-3">
                <h4 class="text-sm font-bold text-gray-700">Maintenance Due</h4>
                <i class="fas fa-calendar-alt text-red-500"></i>
              </div>
              <p class="text-2xl font-bold text-red-600">{{ maintenanceStats.dueSoon }}</p>
              <p class="text-xs text-gray-500 mt-1">vehicles need service soon</p>
            </div>

            <!-- Total Trips -->
            <div class="rounded-xl bg-white p-5 shadow-lg border border-white/30">
              <div class="flex items-center justify-between mb-3">
                <h4 class="text-sm font-bold text-gray-700">Trips This Month</h4>
                <i class="fas fa-route text-orange-500"></i>
              </div>
              <p class="text-2xl font-bold" style="color: #0A400C;">{{ tripStats.monthly }}</p>
              <p class="text-xs text-gray-500 mt-1">
                <span class="text-green-500">
                  <i class="fas fa-arrow-up"></i>
                  {{ tripStats.trend }}%
                </span>
                vs last month
              </p>
            </div>
          </div>

        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
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
    const currentDate = ref('')

    const vehicleStats = reactive({
      total: 0,
      available: 0,
      inUse: 0,
      maintenance: 0
    })

    const fuelStats = reactive({
      monthly: 0,
      trend: 0
    })

    const maintenanceStats = reactive({
      dueSoon: 0
    })

    const tripStats = reactive({
      monthly: 0,
      trend: 0
    })

    const recentActivity = ref([])

    // Computed percentages
    const availabilityPercentage = computed(() => {
      if (vehicleStats.total === 0) return 0
      return Math.round((vehicleStats.available / vehicleStats.total) * 100)
    })

    const inUsePercentage = computed(() => {
      if (vehicleStats.total === 0) return 0
      return Math.round((vehicleStats.inUse / vehicleStats.total) * 100)
    })

    const maintenancePercentage = computed(() => {
      if (vehicleStats.total === 0) return 0
      return Math.round((vehicleStats.maintenance / vehicleStats.total) * 100)
    })

    const updateCurrentDate = () => {
      const now = new Date()
      const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
      currentDate.value = now.toLocaleDateString('en-US', options)
    }

    const navigateToVehicles = () => {
      router.push('/vehicles')
      handleMenuClick()
    }

    const navigateToFuelLogs = () => {
      router.push('/fuel')
      handleMenuClick()
    }

    const navigateToMaintenance = () => {
      router.push('/maintenance')
      handleMenuClick()
    }

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
        'Dashboard': 'Welcome to the Dashboard',
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

    const formatRelativeTime = (dateString) => {
      const date = new Date(dateString)
      const now = new Date()
      const diffMs = now - date
      const diffMins = Math.floor(diffMs / 60000)
      const diffHours = Math.floor(diffMs / 3600000)
      const diffDays = Math.floor(diffMs / 86400000)

      if (diffMins < 1) return 'Just now'
      if (diffMins < 60) return `${diffMins}m ago`
      if (diffHours < 24) return `${diffHours}h ago`
      if (diffDays < 7) return `${diffDays}d ago`
      return date.toLocaleDateString()
    }

    const getActivityIcon = (type) => {
      const icons = {
        'fuel': 'fas fa-gas-pump',
        'maintenance': 'fas fa-wrench',
        'vehicle': 'fas fa-car',
        'trip': 'fas fa-route',
        'driver': 'fas fa-user-plus',
        'default': 'fas fa-circle'
      }
      return icons[type] || icons.default
    }

    const getActivityIconClass = (type) => {
      const classes = {
        'fuel': 'bg-green-500',
        'maintenance': 'bg-red-500',
        'vehicle': 'bg-blue-500',
        'trip': 'bg-orange-500',
        'driver': 'bg-purple-500',
        'default': 'bg-gray-500'
      }
      return classes[type] || classes.default
    }

    const loadUserProfile = async () => {
      try {
        const { data: { user }, error: authError } = await supabase.auth.getUser()

        if (authError) {
          console.error('Auth error:', authError)
          userRole.value = 'staff'
          return
        }

        if (user) {
          const { data: profile, error: profileError } = await supabase
            .from('profiles')
            .select('id, employee_id, full_name, position, department, phone, role')
            .eq('id', user.id)
            .single()

          if (profileError) {
            console.error('Error loading profile:', profileError)
            // Set default only if profile doesn't exist
            userRole.value = 'staff'
          } else if (profile) {
            userProfile.value = profile
            // Use the actual role from database
            userRole.value = profile.role || 'staff'
            console.log('User role loaded:', userRole.value) // Debug log
          }
        }
      } catch (error) {
        console.error('Error in loadUserProfile:', error)
        userRole.value = 'staff'
      }
    }

    const loadDashboardData = async () => {
      try {
        // ========================================
        // 1. LOAD VEHICLE STATS
        // ========================================
        const { data: vehicles, error: vehiclesError } = await supabase
          .from('vehicles')
          .select('status')

        if (vehiclesError) {
          console.error('Error loading vehicles:', vehiclesError)
        } else {
          vehicleStats.total = vehicles?.length || 0
          vehicleStats.available = vehicles?.filter(v => v.status === 'available')?.length || 0
          vehicleStats.inUse = vehicles?.filter(v => v.status === 'in_use')?.length || 0
          vehicleStats.maintenance = vehicles?.filter(v => v.status === 'maintenance')?.length || 0
        }

        // ========================================
        // 2. FETCH ALL RECENT ACTIVITIES
        // ========================================
        const allActivities = []

        // A. Fetch recent fuel logs
        const { data: fuelLogs, error: fuelError } = await supabase
          .from('fuel_logs')
          .select(`
            id, 
            created_at, 
            liters,
            vehicles (plate_number),
            drivers (full_name)
          `)
          .order('created_at', { ascending: false })
          .limit(5)

        if (fuelError) {
          console.error('Error loading fuel logs:', fuelError)
        } else if (fuelLogs) {
          fuelLogs.forEach(log => {
            allActivities.push({
              id: `fuel-${log.id}`,
              type: 'fuel',
              description: `Fuel logged for ${log.vehicles?.plate_number || 'vehicle'} - ${log.liters}L`,
              created_at: log.created_at,
              user: log.drivers?.full_name || 'System'
            })
          })
        }

        // B. Fetch recent vehicle additions
        const { data: recentVehicles, error: vehiclesListError } = await supabase
          .from('vehicles')
          .select('id, created_at, plate_number, vehicle_type')
          .order('created_at', { ascending: false })
          .limit(5)

        if (vehiclesListError) {
          console.error('Error loading recent vehicles:', vehiclesListError)
        } else if (recentVehicles) {
          recentVehicles.forEach(vehicle => {
            allActivities.push({
              id: `vehicle-${vehicle.id}`,
              type: 'vehicle',
              description: `New vehicle added: ${vehicle.plate_number} (${vehicle.vehicle_type})`,
              created_at: vehicle.created_at,
              user: 'Admin'
            })
          })
        }

        // C. Fetch recent maintenance records
        const { data: maintenanceRecords, error: maintenanceError } = await supabase
          .from('maintenance_records')
          .select(`
            id, 
            created_at, 
            type,
            description,
            vehicles (plate_number)
          `)
          .order('created_at', { ascending: false })
          .limit(5)

        if (maintenanceError) {
          console.error('Error loading maintenance records:', maintenanceError)
        } else if (maintenanceRecords) {
          maintenanceRecords.forEach(record => {
            allActivities.push({
              id: `maintenance-${record.id}`,
              type: 'maintenance',
              description: `${record.type} for ${record.vehicles?.plate_number || 'vehicle'}`,
              created_at: record.created_at,
              user: 'Maintenance Team'
            })
          })
        }

        // D. Fetch recent trips
        const { data: recentTrips, error: tripsError } = await supabase
          .from('trips')
          .select(`
            id,
            created_at,
            destination,
            status,
            vehicles (plate_number),
            drivers (full_name)
          `)
          .order('created_at', { ascending: false })
          .limit(5)

        if (tripsError) {
          console.error('Error loading trips:', tripsError)
        } else if (recentTrips) {
          recentTrips.forEach(trip => {
            allActivities.push({
              id: `trip-${trip.id}`,
              type: 'trip',
              description: `Trip to ${trip.destination} - ${trip.vehicles?.plate_number || 'vehicle'} (${trip.status})`,
              created_at: trip.created_at,
              user: trip.drivers?.full_name || 'Driver'
            })
          })
        }

        // E. Fetch recent driver registrations
        const { data: recentDrivers, error: driversError } = await supabase
          .from('drivers')
          .select('id, created_at, full_name, employee_id')
          .order('created_at', { ascending: false })
          .limit(5)

        if (driversError) {
          console.error('Error loading drivers:', driversError)
        } else if (recentDrivers) {
          recentDrivers.forEach(driver => {
            allActivities.push({
              id: `driver-${driver.id}`,
              type: 'driver',
              description: `New driver registered: ${driver.full_name} (${driver.employee_id})`,
              created_at: driver.created_at,
              user: 'Admin'
            })
          })
        }

        // F. Fetch recent maintenance schedules
        const { data: maintenanceSchedules, error: scheduleError } = await supabase
          .from('maintenance')
          .select(`
            id,
            created_at,
            service_type,
            vehicles (plate_number)
          `)
          .order('created_at', { ascending: false })
          .limit(5)

        if (scheduleError) {
          console.error('Error loading maintenance schedules:', scheduleError)
        } else if (maintenanceSchedules) {
          maintenanceSchedules.forEach(schedule => {
            allActivities.push({
              id: `schedule-${schedule.id}`,
              type: 'maintenance',
              description: `${schedule.service_type} scheduled for ${schedule.vehicles?.plate_number || 'vehicle'}`,
              created_at: schedule.created_at,
              user: 'Maintenance Team'
            })
          })
        }

        // Sort all activities by date (most recent first)
        allActivities.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))

        // Take only the 6 most recent
        recentActivity.value = allActivities.slice(0, 6)

        console.log('Recent activities loaded:', recentActivity.value.length) // Debug log

        // ========================================
        // 3. CALCULATE FUEL STATS
        // ========================================
        const { data: allFuelLogs } = await supabase
          .from('fuel_logs')
          .select('created_at, liters')
          .order('created_at', { ascending: false })

        if (allFuelLogs && allFuelLogs.length > 0) {
          const now = new Date()
          const currentMonth = now.getMonth()
          const currentYear = now.getFullYear()

          // Current month fuel
          const currentMonthFuel = allFuelLogs
            .filter(log => {
              const logDate = new Date(log.created_at)
              return logDate.getMonth() === currentMonth && logDate.getFullYear() === currentYear
            })
            .reduce((sum, log) => sum + (parseFloat(log.liters) || 0), 0)

          // Last month fuel
          const lastMonth = currentMonth === 0 ? 11 : currentMonth - 1
          const lastMonthYear = currentMonth === 0 ? currentYear - 1 : currentYear

          const lastMonthFuel = allFuelLogs
            .filter(log => {
              const logDate = new Date(log.created_at)
              return logDate.getMonth() === lastMonth && logDate.getFullYear() === lastMonthYear
            })
            .reduce((sum, log) => sum + (parseFloat(log.liters) || 0), 0)

          fuelStats.monthly = Math.round(currentMonthFuel)
          
          // Calculate trend percentage
          if (lastMonthFuel > 0) {
            fuelStats.trend = Math.round(((currentMonthFuel - lastMonthFuel) / lastMonthFuel) * 100)
          } else {
            fuelStats.trend = currentMonthFuel > 0 ? 100 : 0
          }
        }

        // ========================================
        // 4. MAINTENANCE DUE (using maintenance table)
        // ========================================
        const today = new Date()
        const thirtyDaysFromNow = new Date(today.getTime() + 30 * 24 * 60 * 60 * 1000)

        const { data: upcomingMaintenance } = await supabase
          .from('maintenance')
          .select('id, next_due_date')
          .lte('next_due_date', thirtyDaysFromNow.toISOString().split('T')[0])
          .eq('status', 'up-to-date')

        maintenanceStats.dueSoon = upcomingMaintenance?.length || 0

        // ========================================
        // 5. TRIP STATS
        // ========================================
        const { data: allTrips } = await supabase
          .from('trips')
          .select('created_at, status')
          .order('created_at', { ascending: false })

        if (allTrips && allTrips.length > 0) {
          const now = new Date()
          const currentMonth = now.getMonth()
          const currentYear = now.getFullYear()

          const currentMonthTrips = allTrips.filter(trip => {
            const tripDate = new Date(trip.created_at)
            return tripDate.getMonth() === currentMonth && tripDate.getFullYear() === currentYear
          }).length

          // Last month trips for trend
          const lastMonth = currentMonth === 0 ? 11 : currentMonth - 1
          const lastMonthYear = currentMonth === 0 ? currentYear - 1 : currentYear

          const lastMonthTrips = allTrips.filter(trip => {
            const tripDate = new Date(trip.created_at)
            return tripDate.getMonth() === lastMonth && tripDate.getFullYear() === lastMonthYear
          }).length

          tripStats.monthly = currentMonthTrips
          
          // Calculate trend
          if (lastMonthTrips > 0) {
            tripStats.trend = Math.round(((currentMonthTrips - lastMonthTrips) / lastMonthTrips) * 100)
          } else {
            tripStats.trend = currentMonthTrips > 0 ? 100 : 0
          }
        }

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
      updateCurrentDate()
      await loadUserProfile()
      await loadDashboardData()
      window.addEventListener('resize', handleResize)
      handleResize()
    })

    onUnmounted(() => {
      window.removeEventListener('resize', handleResize)
    })

    return {
      sidebarCollapsed,
      sidebarOpen,
      userProfile,
      userRole,
      currentDate,
      vehicleStats,
      fuelStats,
      maintenanceStats,
      tripStats,
      recentActivity,
      availabilityPercentage,
      inUsePercentage,
      maintenancePercentage,
      toggleSidebar,
      closeSidebar,
      openSidebar,
      handleMenuClick,
      getViewTitle,
      formatDate,
      formatRelativeTime,
      getActivityIcon,
      getActivityIconClass,
      navigateToVehicles,
      navigateToFuelLogs,
      navigateToMaintenance
    }
  }
}
</script>

<style scoped>
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

div::-webkit-scrollbar {
  width: 6px;
}

div::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.05);
}

div::-webkit-scrollbar-thumb {
  background: rgba(10, 64, 12, 0.3);
  border-radius: 3px;
}

div::-webkit-scrollbar-thumb:hover {
  background: rgba(10, 64, 12, 0.5);
}
</style>
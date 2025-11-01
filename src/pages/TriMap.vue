<template>
  <div class="flex h-screen bg-gradient-to-br from-green-50 to-green-100 font-inter overflow-hidden">
    <!-- Include Navbar Component -->
    <Navbar 
      :sidebar-collapsed="sidebarCollapsed"
      :sidebar-open="sidebarOpen"
      @toggle-sidebar="toggleSidebar"
      @close-sidebar="closeSidebar"
      @open-sidebar="openSidebar"
      @menu-click="handleMenuClick"
    />
    
    <!-- Sidebar overlay for mobile -->
    <div
      v-if="sidebarOpen && !sidebarCollapsed"
      class="fixed inset-0 bg-black/50 z-40 lg:hidden"
      @click="closeSidebar"
    ></div>

    <!-- Main Content - Fixed positioning to prevent navbar overlap -->
    <main 
      class="flex flex-1 flex-col transition-all duration-300 ease-in-out min-w-0 relative"
      :class="{ 
        'lg:ml-64': sidebarOpen && !sidebarCollapsed,
        'lg:ml-20': sidebarCollapsed || !sidebarOpen 
      }"
    >
      <!-- Header - Now properly positioned -->
      <header class="bg-white/95 backdrop-blur-xl py-4 px-4 sm:px-6 border-b border-white/20 flex flex-col sm:flex-row justify-between items-start sm:items-center shadow-sm sticky top-0 z-30 gap-3 sm:gap-0">
        <div class="flex items-center gap-3 sm:gap-4 w-full sm:w-auto">
          <button
            @click="openSidebar"
            class="bg-green-800 border-none text-white py-2.5 px-3 rounded-lg cursor-pointer transition-all duration-200 hover:bg-green-700 hover:scale-105 lg:hidden flex-shrink-0"
            v-if="!sidebarOpen"
            style="background-color: #0A400C;"
          >
            <i class="fas fa-bars"></i>
          </button>
          <div class="flex-1 min-w-0">
            <h1 class="m-0 text-lg sm:text-xl lg:text-2xl font-bold tracking-tight truncate" 
                style="color: #0A400C;">Live Tracking</h1>
            <div v-if="vehicleInfo" class="flex items-center gap-2 mt-1 flex-wrap">
              <span class="text-xs sm:text-sm text-slate-600">Vehicle:</span>
              <span class="font-semibold text-xs sm:text-sm truncate" style="color: #0A400C;">
                {{ vehicleInfo.plate_number }} - {{ vehicleInfo.year }} {{ vehicleInfo.make }} {{ vehicleInfo.model }}
              </span>
              <div class="flex items-center gap-1">
                <div class="w-2 h-2 rounded-full animate-pulse flex-shrink-0" :class="{
                  'bg-green-500': connectionStatus === 'connected',
                  'bg-red-500': connectionStatus === 'disconnected',
                  'bg-yellow-500': connectionStatus === 'connecting'
                }"></div>
                <span class="text-xs text-slate-600 capitalize">{{ connectionStatus }}</span>
              </div>
            </div>
          </div>
        </div>
        
        <div class="flex items-center gap-2 w-full sm:w-auto justify-end">
          <button
            @click="centerMapOnVehicle"
            class="bg-blue-500/10 text-blue-600 border border-blue-500/20 py-2 px-3 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 text-xs hover:bg-blue-500/20 flex-shrink-0"
          >
            <i class="fas fa-crosshairs"></i>
            <span class="hidden sm:inline">Center</span>
          </button>
          <button
            @click="toggleTracking"
            class="border border-green-500/20 py-2 px-3 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 text-xs flex-shrink-0"
            :class="{
              'bg-green-500/10 text-green-600 hover:bg-green-500/20': isTracking,
              'bg-gray-500/10 text-gray-600 hover:bg-gray-500/20': !isTracking
            }"
          >
            <i :class="isTracking ? 'fas fa-pause' : 'fas fa-play'"></i>
            <span class="hidden sm:inline">{{ isTracking ? 'Pause' : 'Start' }}</span>
          </button>
          <button
            @click="$router.go(-1)"
            class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2 px-3 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 text-xs hover:bg-slate-500/20 flex-shrink-0"
          >
            <i class="fas fa-arrow-left"></i>
            <span class="hidden sm:inline">Back</span>
          </button>
        </div>
      </header>

      <!-- Map and Info Panel Container - Fixed height calculation -->
      <div class="flex-1 flex flex-col lg:flex-row overflow-hidden">
        <!-- Map Container -->
        <div class="flex-1 relative h-64 sm:h-96 lg:h-full">
          <InteractiveMap 
            v-if="vehicleInfo && vehicleInfo.current_latitude && vehicleInfo.current_longitude"
            :vehicles="[vehicleInfo]"
            :center-lat="parseFloat(vehicleInfo.current_latitude)"
            :center-lng="parseFloat(vehicleInfo.current_longitude)"
            :zoom="15"
            @vehicle-selected="onVehicleSelected"
            @location-updated="onLocationUpdated"
          />
          <div v-else class="w-full h-full flex items-center justify-center bg-gray-100">
            <div class="text-center">
              <i class="fas fa-map-marked-alt text-4xl text-gray-400 mb-2"></i>
              <p class="text-gray-600">Loading vehicle location...</p>
            </div>
          </div>
        </div>

        <!-- Info Panel - Scrollable on mobile, fixed on desktop -->
        <div class="w-full lg:w-80 bg-white/90 backdrop-blur-xl border-t lg:border-t-0 lg:border-l border-gray-200 flex flex-col max-h-[50vh] lg:max-h-full overflow-hidden">
          <!-- Vehicle Status -->
          <div class="p-4 border-b border-gray-200 flex-shrink-0">
            <h3 class="font-semibold text-gray-800 mb-3 text-sm">Vehicle Status</h3>
            <div class="space-y-3">
              <div class="flex justify-between items-center">
                <span class="text-xs sm:text-sm text-gray-600">Engine Status</span>
                <span class="py-1 px-2 rounded-full text-xs font-semibold" :class="{
                  'bg-green-100 text-green-800': vehicleStatus.engine === 'running',
                  'bg-red-100 text-red-800': vehicleStatus.engine === 'stopped'
                }">
                  {{ vehicleStatus.engine }}
                </span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-xs sm:text-sm text-gray-600">Fuel Level</span>
                <div class="flex items-center gap-2">
                  <div class="w-16 h-2 bg-gray-200 rounded-full overflow-hidden">
                    <div 
                      class="h-full transition-all duration-300"
                      :class="{
                        'bg-green-500': vehicleStatus.fuel >= 50,
                        'bg-yellow-500': vehicleStatus.fuel >= 25 && vehicleStatus.fuel < 50,
                        'bg-red-500': vehicleStatus.fuel < 25
                      }"
                      :style="`width: ${vehicleStatus.fuel}%`"
                    ></div>
                  </div>
                  <span class="text-xs font-medium">{{ vehicleStatus.fuel }}%</span>
                </div>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-xs sm:text-sm text-gray-600">Battery</span>
                <span class="text-xs sm:text-sm font-medium">{{ vehicleStatus.battery }}%</span>
              </div>
            </div>
          </div>

          <!-- Trip Info -->
          <div class="p-4 border-b border-gray-200 flex-shrink-0">
            <h3 class="font-semibold text-gray-800 mb-3 text-sm">Current Trip</h3>
            <div class="space-y-3">
              <div>
                <span class="text-xs text-gray-500">Started</span>
                <p class="text-xs sm:text-sm font-medium">{{ formatTime(currentTrip.startTime) }}</p>
              </div>
              <div>
                <span class="text-xs text-gray-500">Distance</span>
                <p class="text-xs sm:text-sm font-medium">{{ currentTrip.distance.toFixed(1) }} km</p>
              </div>
              <div>
                <span class="text-xs text-gray-500">Duration</span>
                <p class="text-xs sm:text-sm font-medium">{{ currentTrip.duration }}</p>
              </div>
              <div v-if="currentTrip.driver">
                <span class="text-xs text-gray-500">Driver</span>
                <p class="text-xs sm:text-sm font-medium">{{ currentTrip.driver }}</p>
              </div>
            </div>
          </div>

          <!-- Recent Locations - Scrollable section -->
          <div class="flex-1 p-4 overflow-y-auto min-h-0">
            <h3 class="font-semibold text-gray-800 mb-3 text-sm">Location History</h3>
            <div class="space-y-2">
              <div 
                v-for="(location, index) in locationHistory" 
                :key="index"
                class="flex items-start gap-2 p-2 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer"
                @click="focusLocation(location)"
              >
                <div class="flex-shrink-0 w-2 h-2 mt-2 rounded-full" :class="{
                  'bg-green-500': index === 0,
                  'bg-gray-400': index > 0
                }"></div>
                <div class="flex-1 min-w-0">
                  <p class="text-xs sm:text-sm font-medium text-gray-800 truncate">{{ location.address }}</p>
                  <p class="text-xs text-gray-500">{{ formatTime(location.timestamp) }}</p>
                  <p class="text-xs text-gray-400">{{ location.speed }} km/h</p>
                </div>
              </div>
              <div v-if="locationHistory.length === 0" class="text-center py-4 text-gray-400 text-xs">
                No location history yet
              </div>
            </div>
          </div>

          <!-- Control Actions -->
          <div class="p-4 border-t border-gray-200 space-y-2 flex-shrink-0">
            <button
              @click="exportRoute"
              class="w-full bg-blue-500/10 text-blue-600 border border-blue-500/20 py-2 px-4 rounded-lg cursor-pointer font-medium flex items-center justify-center gap-2 transition-all duration-200 text-xs sm:text-sm hover:bg-blue-500/20"
            >
              <i class="fas fa-download"></i>
              Export Route
            </button>
            <button
              @click="shareLocation"
              class="w-full bg-green-500/10 text-green-600 border border-green-500/20 py-2 px-4 rounded-lg cursor-pointer font-medium flex items-center justify-center gap-2 transition-all duration-200 text-xs sm:text-sm hover:bg-green-500/20"
            >
              <i class="fas fa-share"></i>
              Share Location
            </button>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { ref, reactive, onMounted, onUnmounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../lib/supabase'
import Navbar from './Navbar.vue'
import InteractiveMap from '../components/InteractiveMap.vue'

export default {
  name: 'TripMap',
  components: { Navbar, InteractiveMap },
  setup() {
    const router = useRouter()
    const route = useRoute()
    const vehicleId = route.params.id

    // Sidebar state - Get from localStorage to persist across pages
    const getSidebarState = () => {
      const saved = localStorage.getItem('sidebarCollapsed')
      return saved ? JSON.parse(saved) : false
    }

    const sidebarCollapsed = ref(getSidebarState())
    const sidebarOpen = ref(window.innerWidth > 1024) // Auto-close on mobile

    // Tracking state
    const isTracking = ref(false)
    const connectionStatus = ref('connecting')

    // Vehicle and location data
    const vehicleInfo = ref(null)
    const currentLocation = reactive({
      address: 'Loading location...',
      speed: 0,
      timestamp: new Date()
    })

    const vehicleStatus = reactive({
      engine: 'running',
      fuel: 75,
      battery: 95
    })

    const currentTrip = reactive({
      startTime: new Date(),
      distance: 0,
      duration: '0h 0m',
      driver: null
    })

    const locationHistory = ref([])
    const updateInterval = ref(null)

    // Methods
    const toggleSidebar = () => {
      sidebarCollapsed.value = !sidebarCollapsed.value
      localStorage.setItem('sidebarCollapsed', JSON.stringify(sidebarCollapsed.value))
    }

    const closeSidebar = () => {
      if (window.innerWidth <= 1024) {
        sidebarOpen.value = false
      } else {
        sidebarCollapsed.value = true
        localStorage.setItem('sidebarCollapsed', 'true')
      }
    }

    const openSidebar = () => {
      sidebarOpen.value = true
      if (window.innerWidth > 1024) {
        sidebarCollapsed.value = false
        localStorage.setItem('sidebarCollapsed', 'false')
      }
    }

    const handleMenuClick = () => {
      if (window.innerWidth <= 1024) {
        sidebarOpen.value = false
      }
    }

    const formatTime = (timestamp) => {
      if (!timestamp) return 'N/A'
      return new Date(timestamp).toLocaleTimeString('en-US', { 
        hour: '2-digit', 
        minute: '2-digit' 
      })
    }

    const loadVehicleInfo = async () => {
      try {
        // First, try to get vehicle data with the join
        let { data, error } = await supabase
          .from('vehicles')
          .select('*, assigned_driver:assigned_driver_id(full_name)')
          .eq('id', vehicleId)
          .single()
        
        // If join fails, try without it
        if (error && error.code === 'PGRST116') {
          console.log('Trying query without join...')
          const result = await supabase
            .from('vehicles')
            .select('*')
            .eq('id', vehicleId)
            .single()
          
          data = result.data
          error = result.error
        }
        
        if (error) {
          console.error('Supabase error:', error)
          throw error
        }
        
        if (!data) {
          throw new Error('Vehicle not found')
        }
        
        vehicleInfo.value = data
        console.log('Vehicle loaded:', data)
        
        // Try to get driver name if we have the ID
        if (data.assigned_driver_id) {
          try {
            const { data: driverData } = await supabase
              .from('profiles')
              .select('full_name')
              .eq('id', data.assigned_driver_id)
              .single()
            
            if (driverData) {
              currentTrip.driver = driverData.full_name
            }
          } catch (driverError) {
            console.log('Could not load driver info:', driverError)
            currentTrip.driver = 'Unknown Driver'
          }
        } else {
          currentTrip.driver = 'No Driver Assigned'
        }
        
        // Update vehicle status based on real data
        if (data.device_status === 'offline') {
          connectionStatus.value = 'disconnected'
          vehicleStatus.engine = 'stopped'
        }
        
        // Set battery and other values from real data if available
        if (data.battery_level) {
          vehicleStatus.battery = data.battery_level
        }
        
        // Set fuel level if available
        if (data.fuel_level) {
          vehicleStatus.fuel = data.fuel_level
        }
        
      } catch (error) {
        console.error('Error loading vehicle info:', error)
        console.error('Error details:', JSON.stringify(error, null, 2))
        alert(`Failed to load vehicle information: ${error.message || 'Unknown error'}`)
        router.push('/vehicles')
      }
    }

    const simulateGPSData = () => {
      if (!vehicleInfo.value) return
      
      // Use real coordinates from vehicle data
      const lat = parseFloat(vehicleInfo.value.current_latitude)
      const lng = parseFloat(vehicleInfo.value.current_longitude)
      
      // Simulate slight movement (for demo purposes)
      const newLat = lat + (Math.random() - 0.5) * 0.001
      const newLng = lng + (Math.random() - 0.5) * 0.001
      
      const randomSpeed = Math.floor(Math.random() * 60) + 20
      
      currentLocation.address = `${newLat.toFixed(6)}, ${newLng.toFixed(6)}`
      currentLocation.speed = randomSpeed
      currentLocation.timestamp = new Date()
      
      // Add to history
      locationHistory.value.unshift({
        address: currentLocation.address,
        speed: randomSpeed,
        timestamp: new Date()
      })
      
      // Keep only last 10 locations
      if (locationHistory.value.length > 10) {
        locationHistory.value = locationHistory.value.slice(0, 10)
      }
      
      // Update trip distance (simulate)
      currentTrip.distance += Math.random() * 0.5
      
      // Update trip duration
      const now = new Date()
      const diff = now - currentTrip.startTime
      const hours = Math.floor(diff / (1000 * 60 * 60))
      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
      currentTrip.duration = `${hours}h ${minutes}m`
      
      // Simulate fuel consumption
      vehicleStatus.fuel = Math.max(0, vehicleStatus.fuel - Math.random() * 0.05)
    }

    const toggleTracking = () => {
      isTracking.value = !isTracking.value
      
      if (isTracking.value) {
        connectionStatus.value = 'connected'
        updateInterval.value = setInterval(simulateGPSData, 3000)
      } else {
        connectionStatus.value = 'disconnected'
        if (updateInterval.value) {
          clearInterval(updateInterval.value)
          updateInterval.value = null
        }
      }
    }

    const centerMapOnVehicle = () => {
      // This would be handled by the map component
      console.log('Centering map on vehicle')
    }

    const onVehicleSelected = (vehicle) => {
      console.log('Vehicle selected:', vehicle)
    }

    const onLocationUpdated = (location) => {
      console.log('User location updated:', location)
    }

    const focusLocation = (location) => {
      console.log('Focusing on location:', location)
    }

    const exportRoute = () => {
      const routeData = {
        vehicle: vehicleInfo.value,
        trip: currentTrip,
        locations: locationHistory.value
      }
      
      const dataStr = JSON.stringify(routeData, null, 2)
      const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr)
      
      const exportFileDefaultName = `route_${vehicleInfo.value?.plate_number}_${new Date().toISOString().split('T')[0]}.json`
      
      const linkElement = document.createElement('a')
      linkElement.setAttribute('href', dataUri)
      linkElement.setAttribute('download', exportFileDefaultName)
      linkElement.click()
    }

    const shareLocation = async () => {
      const shareData = {
        title: `${vehicleInfo.value?.plate_number} Live Location`,
        text: `Current location: ${currentLocation.address}`,
        url: window.location.href
      }
      
      if (navigator.share) {
        try {
          await navigator.share(shareData)
        } catch (err) {
          console.log('Share cancelled or failed:', err)
        }
      } else {
        try {
          await navigator.clipboard.writeText(window.location.href)
          alert('Location link copied to clipboard!')
        } catch (err) {
          console.error('Failed to copy:', err)
        }
      }
    }

    // Handle window resize
    const handleResize = () => {
      if (window.innerWidth > 1024) {
        sidebarOpen.value = true
      } else {
        sidebarOpen.value = false
      }
    }

    // Lifecycle
    onMounted(async () => {
      window.addEventListener('resize', handleResize)
      
      await loadVehicleInfo()
      
      setTimeout(() => {
        if (vehicleInfo.value) {
          connectionStatus.value = 'connected'
          toggleTracking()
        }
      }, 1500)
    })

    onUnmounted(() => {
      window.removeEventListener('resize', handleResize)
      if (updateInterval.value) {
        clearInterval(updateInterval.value)
      }
    })

    return {
      sidebarCollapsed,
      sidebarOpen,
      toggleSidebar,
      closeSidebar,
      openSidebar,
      handleMenuClick,
      vehicleInfo,
      currentLocation,
      vehicleStatus,
      currentTrip,
      locationHistory,
      isTracking,
      connectionStatus,
      formatTime,
      toggleTracking,
      centerMapOnVehicle,
      onVehicleSelected,
      onLocationUpdated,
      focusLocation,
      exportRoute,
      shareLocation
    }
  }
}
</script>

<style scoped>
.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.05);
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: rgba(10, 64, 12, 0.3);
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: rgba(10, 64, 12, 0.5);
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

/* Ensure proper z-index stacking */
.z-30 {
  z-index: 30;
}

.z-40 {
  z-index: 40;
}
</style>
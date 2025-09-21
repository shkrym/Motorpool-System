<template>
  <div class="flex h-screen bg-gradient-to-br from-green-50 to-green-100 font-inter">
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

     <main class="main-content flex flex-1 flex-col transition-all duration-300 ease-in-out min-w-0" :class="{ '!ml-0': sidebarCollapsed || !sidebarOpen }">

      
      <!-- Header -->
      <header class="bg-white/95 backdrop-blur-xl py-4 px-6 border-b border-white/20 flex flex-col sm:flex-row justify-between items-start sm:items-center shadow-sm sticky top-0 z-10 gap-3 sm:gap-0">
        <div class="flex items-center gap-4 w-full sm:w-auto">
          <button
            @click="openSidebar"
            class="bg-green-800 border-none text-white py-2.5 px-3 rounded-lg cursor-pointer transition-all duration-200 hover:bg-green-700 hover:scale-105 lg:hidden"
            v-if="!sidebarOpen"
            style="background-color: #0A400C;"
          >
            <i class="fas fa-bars"></i>
          </button>
          <div class="flex-1">
            <h1 class="m-0 text-xl sm:text-2xl lg:text-3xl font-bold tracking-tight" 
                style="color: #0A400C;">Live Tracking</h1>
            <div v-if="vehicleInfo" class="flex items-center gap-2 mt-1">
              <span class="text-sm text-slate-600">Vehicle:</span>
              <span class="font-semibold text-sm" style="color: #0A400C;">
                {{ vehicleInfo.plate_number }} - {{ vehicleInfo.year }} {{ vehicleInfo.make }} {{ vehicleInfo.model }}
              </span>
              <div class="flex items-center gap-1 ml-2">
                <div class="w-2 h-2 rounded-full animate-pulse" :class="{
                  'bg-green-500': connectionStatus === 'connected',
                  'bg-red-500': connectionStatus === 'disconnected',
                  'bg-yellow-500': connectionStatus === 'connecting'
                }"></div>
                <span class="text-xs text-slate-600 capitalize">{{ connectionStatus }}</span>
              </div>
            </div>
          </div>
        </div>
        
        <div class="flex items-center gap-3 w-full sm:w-auto">
          <button
            @click="centerMapOnVehicle"
            class="bg-blue-500/10 text-blue-600 border border-blue-500/20 py-2 px-3 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 text-xs sm:text-sm hover:bg-blue-500/20"
          >
            <i class="fas fa-crosshairs"></i>
            <span class="hidden sm:inline">Center</span>
          </button>
          <button
            @click="toggleTracking"
            class="border border-green-500/20 py-2 px-3 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 text-xs sm:text-sm"
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
            class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2 px-3 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 text-xs sm:text-sm hover:bg-slate-500/20"
          >
            <i class="fas fa-arrow-left"></i>
            <span class="hidden sm:inline">Back</span>
          </button>
        </div>
      </header>

      <!-- Map and Info Panel Container -->
      <div class="flex-1 flex flex-col lg:flex-row">
        <!-- Map Container -->
        <div class="flex-1 relative bg-gray-200">
          <!-- Placeholder Map -->
          <div id="map-container" class="w-full h-full bg-gradient-to-br from-blue-100 to-blue-200 relative">
            <!-- Mock Map Interface -->
            <div class="absolute inset-0 flex items-center justify-center">
              <div class="text-center">
                <i class="fas fa-map text-6xl text-blue-400 mb-4"></i>
                <h3 class="text-xl font-semibold text-gray-700 mb-2">Interactive Map</h3>
                <p class="text-gray-600">GPS tracking will be displayed here once connected</p>
                
                <!-- Mock Vehicle Position -->
                <div class="absolute top-1/3 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
                  <div class="relative">
                    <div class="w-4 h-4 bg-red-500 rounded-full animate-pulse shadow-lg"></div>
                    <div class="absolute -top-8 left-1/2 transform -translate-x-1/2">
                      <div class="bg-white px-2 py-1 rounded shadow text-xs font-semibold whitespace-nowrap">
                        {{ vehicleInfo?.plate_number || 'Vehicle' }}
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Mock Route Path -->
                <svg class="absolute inset-0 w-full h-full pointer-events-none">
                  <path 
                    d="M 100 200 Q 200 100 300 150 T 500 200" 
                    stroke="#3B82F6" 
                    stroke-width="3" 
                    fill="none" 
                    stroke-dasharray="5,5"
                    class="animate-pulse opacity-60"
                  />
                </svg>
              </div>
            </div>
          </div>

          <!-- Map Controls -->
          <div class="absolute top-4 right-4 flex flex-col gap-2">
            <button 
              @click="zoomIn"
              class="w-10 h-10 bg-white shadow-lg rounded-lg flex items-center justify-center hover:bg-gray-50 transition-colors"
            >
              <i class="fas fa-plus text-gray-600"></i>
            </button>
            <button 
              @click="zoomOut"
              class="w-10 h-10 bg-white shadow-lg rounded-lg flex items-center justify-center hover:bg-gray-50 transition-colors"
            >
              <i class="fas fa-minus text-gray-600"></i>
            </button>
          </div>

          <!-- Location Info Card -->
          <div class="absolute bottom-4 left-4 bg-white/95 backdrop-blur-xl rounded-xl p-4 shadow-lg min-w-64">
            <h4 class="font-semibold text-gray-800 mb-2">Current Location</h4>
            <div class="space-y-2 text-sm">
              <div class="flex items-center gap-2">
                <i class="fas fa-map-marker-alt text-red-500 w-4"></i>
                <span class="text-gray-600">{{ currentLocation.address || 'Loading...' }}</span>
              </div>
              <div class="flex items-center gap-2">
                <i class="fas fa-tachometer-alt text-blue-500 w-4"></i>
                <span class="text-gray-600">{{ currentLocation.speed || 0 }} km/h</span>
              </div>
              <div class="flex items-center gap-2">
                <i class="fas fa-clock text-green-500 w-4"></i>
                <span class="text-gray-600">{{ formatTime(currentLocation.timestamp) }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Info Panel -->
        <div class="w-full lg:w-80 bg-white/90 backdrop-blur-xl border-l border-white/20 flex flex-col">
          <!-- Vehicle Status -->
          <div class="p-4 border-b border-gray-200">
            <h3 class="font-semibold text-gray-800 mb-3">Vehicle Status</h3>
            <div class="space-y-3">
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Engine Status</span>
                <span class="py-1 px-2 rounded-full text-xs font-semibold" :class="{
                  'bg-green-100 text-green-800': vehicleStatus.engine === 'running',
                  'bg-red-100 text-red-800': vehicleStatus.engine === 'stopped'
                }">
                  {{ vehicleStatus.engine }}
                </span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Fuel Level</span>
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
                <span class="text-sm text-gray-600">Battery</span>
                <span class="text-sm font-medium">{{ vehicleStatus.battery }}%</span>
              </div>
            </div>
          </div>

          <!-- Trip Info -->
          <div class="p-4 border-b border-gray-200">
            <h3 class="font-semibold text-gray-800 mb-3">Current Trip</h3>
            <div class="space-y-3">
              <div>
                <span class="text-xs text-gray-500">Started</span>
                <p class="text-sm font-medium">{{ formatTime(currentTrip.startTime) }}</p>
              </div>
              <div>
                <span class="text-xs text-gray-500">Distance</span>
                <p class="text-sm font-medium">{{ currentTrip.distance }} km</p>
              </div>
              <div>
                <span class="text-xs text-gray-500">Duration</span>
                <p class="text-sm font-medium">{{ currentTrip.duration }}</p>
              </div>
              <div v-if="currentTrip.driver">
                <span class="text-xs text-gray-500">Driver</span>
                <p class="text-sm font-medium">{{ currentTrip.driver }}</p>
              </div>
            </div>
          </div>

          <!-- Recent Locations -->
          <div class="flex-1 p-4 overflow-y-auto">
            <h3 class="font-semibold text-gray-800 mb-3">Location History</h3>
            <div class="space-y-3">
              <div 
                v-for="(location, index) in locationHistory" 
                :key="index"
                class="flex items-start gap-3 p-2 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer"
                @click="focusLocation(location)"
              >
                <div class="flex-shrink-0 w-2 h-2 mt-2 rounded-full" :class="{
                  'bg-green-500': index === 0,
                  'bg-gray-400': index > 0
                }"></div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-gray-800 truncate">{{ location.address }}</p>
                  <p class="text-xs text-gray-500">{{ formatTime(location.timestamp) }}</p>
                  <p class="text-xs text-gray-400">{{ location.speed }} km/h</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Control Actions -->
          <div class="p-4 border-t border-gray-200 space-y-2">
            <button
              @click="exportRoute"
              class="w-full bg-blue-500/10 text-blue-600 border border-blue-500/20 py-2 px-4 rounded-lg cursor-pointer font-medium flex items-center justify-center gap-2 transition-all duration-200 text-sm hover:bg-blue-500/20"
            >
              <i class="fas fa-download"></i>
              Export Route
            </button>
            <button
              @click="shareLocation"
              class="w-full bg-green-500/10 text-green-600 border border-green-500/20 py-2 px-4 rounded-lg cursor-pointer font-medium flex items-center justify-center gap-2 transition-all duration-200 text-sm hover:bg-green-500/20"
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
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../lib/supabase'
import Navbar from './Navbar.vue'

export default {
  name: 'TripMap',
  components: { Navbar },
  setup() {
    const router = useRouter()
    const route = useRoute()
    const vehicleId = route.params.id

    // Sidebar state
    const sidebarCollapsed = ref(false)
    const sidebarOpen = ref(true)

    // Tracking state
    const isTracking = ref(false)
    const connectionStatus = ref('connecting') // connecting, connected, disconnected

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
    }

    const closeSidebar = () => {
      if (window.innerWidth <= 1024) {
        sidebarOpen.value = false
      } else {
        sidebarCollapsed.value = true
      }
    }

    const openSidebar = () => {
      sidebarOpen.value = true
      if (window.innerWidth > 1024) {
        sidebarCollapsed.value = false
      }
    }

    const handleMenuClick = () => {
      if (window.innerWidth <= 1024) {
        sidebarOpen.value = false
      }
    }

    const formatTime = (timestamp) => {
      if (!timestamp) return 'N/A'
      return new Date(timestamp).toLocaleTimeString()
    }

    const loadVehicleInfo = async () => {
      try {
        const { data, error } = await supabase
          .from('vehicles')
          .select(`
            *,
            profiles:assigned_driver_id (full_name)
          `)
          .eq('id', vehicleId)
          .single()
        
        if (error) throw error
        vehicleInfo.value = data
        currentTrip.driver = data.profiles?.full_name
      } catch (error) {
        console.error('Error loading vehicle info:', error)
        // Sample data
        vehicleInfo.value = {
          plate_number: 'ABC-1234',
          year: 2022,
          make: 'Toyota',
          model: 'Camry'
        }
        currentTrip.driver = 'John Doe'
      }
    }

    const simulateGPSData = () => {
      // Simulate GPS data updates
      const locations = [
        'Main Office, Manila',
        'EDSA Corner Shaw Blvd',
        'Ortigas Center',
        'BGC Taguig',
        'Makati CBD'
      ]
      
      const randomLocation = locations[Math.floor(Math.random() * locations.length)]
      const randomSpeed = Math.floor(Math.random() * 60) + 20
      
      currentLocation.address = randomLocation
      currentLocation.speed = randomSpeed
      currentLocation.timestamp = new Date()
      
      // Add to history
      locationHistory.value.unshift({
        address: randomLocation,
        speed: randomSpeed,
        timestamp: new Date()
      })
      
      // Keep only last 10 locations
      if (locationHistory.value.length > 10) {
        locationHistory.value = locationHistory.value.slice(0, 10)
      }
      
      // Update trip distance
      currentTrip.distance += Math.random() * 2
      currentTrip.distance = Math.round(currentTrip.distance * 10) / 10
      
      // Update trip duration
      const now = new Date()
      const diff = now - currentTrip.startTime
      const hours = Math.floor(diff / (1000 * 60 * 60))
      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
      currentTrip.duration = `${hours}h ${minutes}m`
      
      // Simulate fuel consumption
      vehicleStatus.fuel = Math.max(0, vehicleStatus.fuel - Math.random() * 0.1)
      vehicleStatus.fuel = Math.round(vehicleStatus.fuel * 10) / 10
    }

    const toggleTracking = () => {
      isTracking.value = !isTracking.value
      
      if (isTracking.value) {
        connectionStatus.value = 'connected'
        updateInterval.value = setInterval(simulateGPSData, 3000) // Update every 3 seconds
      } else {
        connectionStatus.value = 'disconnected'
        if (updateInterval.value) {
          clearInterval(updateInterval.value)
          updateInterval.value = null
        }
      }
    }

    const centerMapOnVehicle = () => {
      console.log('Centering map on vehicle location')
      // In a real implementation, this would center the map on the vehicle's current position
    }

    const zoomIn = () => {
      console.log('Zooming in')
      // Map zoom functionality would be implemented here
    }

    const zoomOut = () => {
      console.log('Zooming out')
      // Map zoom functionality would be implemented here
    }

    const focusLocation = (location) => {
      console.log('Focusing on location:', location)
      // This would center the map on the selected location
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

    const shareLocation = () => {
      if (navigator.share) {
        navigator.share({
          title: `${vehicleInfo.value?.plate_number} Live Location`,
          text: `Current location: ${currentLocation.address}`,
          url: window.location.href
        })
      } else {
        // Fallback: copy to clipboard
        navigator.clipboard.writeText(window.location.href)
        alert('Location link copied to clipboard!')
      }
    }

    // Lifecycle
    onMounted(async () => {
      await loadVehicleInfo()
      
      // Start with a connecting status
      setTimeout(() => {
        connectionStatus.value = 'connected'
        // Auto-start tracking after loading
        toggleTracking()
      }, 2000)
    })

    onUnmounted(() => {
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
      zoomIn,
      zoomOut,
      focusLocation,
      exportRoute,
      shareLocation
    }
  }
}
</script>

<style scoped>
.overflow-y-auto::-webkit-scrollbar {
  width: 8px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 4px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: rgba(10, 64, 12, 0.4);
  border-radius: 4px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: rgba(10, 64, 12, 0.6);
}

.transition-all {
  transition-property: all;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
  transition-duration: 300ms;
}

.fas, .far, .fal, .fab {
  font-family: "Font Awesome 6 Free";
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: .5;
  }
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
</style>
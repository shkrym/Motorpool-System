<template>
  <div class="flex h-screen bg-gradient-to-br from-green-50 via-emerald-100 to-teal-100">
    <Navbar 
      :sidebar-collapsed="sidebarCollapsed"
      :sidebar-open="sidebarOpen"
      @toggle-sidebar="toggleSidebar"
      @close-sidebar="closeSidebar"
      @open-sidebar="openSidebar"
    />

    <div class="flex-1 flex flex-col overflow-hidden transition-all duration-300 ease-in-out min-w-0" :class="{ '!ml-0': sidebarCollapsed || !sidebarOpen }">
      
      <!-- Backdrop overlay for mobile sidebar -->
      <div
        v-if="sidebarOpen && !sidebarCollapsed"
        class="fixed inset-0 bg-black/50 z-40 lg:hidden"
        @click="closeSidebar"
      ></div>

      <!-- Header -->
      <header class="bg-gradient-to-br from-green-800 to-green-600 text-white shadow-xl">
        <div class="px-3 sm:px-6 lg:px-8 py-3 sm:py-6">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-2 sm:gap-3 flex-1 min-w-0">
              <button
                @click="openSidebar"
                v-if="!sidebarOpen"
                class="lg:hidden bg-green-700 text-white py-2 px-3 rounded-lg hover:bg-green-600 transition-colors flex-shrink-0"
              >
                <i class="fas fa-bars"></i>
              </button>
              <div class="flex-1 min-w-0">
                <h1 class="text-lg sm:text-2xl lg:text-3xl font-bold tracking-tight truncate">🗺️ Live GPS Tracking</h1>
                <p class="text-green-100 text-xs sm:text-sm mt-1 hidden sm:block">Real-time vehicle location monitoring</p>
              </div>
            </div>
            <div class="flex items-center gap-2 sm:gap-4">
              <div class="text-right hidden xs:block">
                <div class="text-xs text-green-200">Active</div>
                <div class="text-lg sm:text-2xl font-bold">{{ activeVehicles }}</div>
              </div>
              <button 
                @click="toggleVehicleList"
                class="lg:hidden bg-white/20 hover:bg-white/30 px-3 py-2 rounded-lg transition-all flex items-center gap-2"
              >
                <i class="fas fa-list"></i>
                <span class="hidden xs:inline text-sm">Vehicles</span>
              </button>
              <button 
                @click="refreshLocations"
                class="bg-white/20 hover:bg-white/30 px-3 sm:px-4 py-2 rounded-lg transition-all flex items-center gap-2"
                :disabled="loading"
              >
                <i :class="loading ? 'fas fa-spinner fa-spin' : 'fas fa-sync-alt'"></i>
                <span class="hidden sm:inline">Refresh</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      <!-- Main Content -->
      <div class="flex-1 flex overflow-hidden bg-gradient-to-br from-green-50/70 to-emerald-100/70 relative">
        
        <!-- Sidebar - Vehicle List (Desktop: sidebar, Mobile: slide-out overlay) -->
        <div 
          class="w-80 bg-white/90 backdrop-blur-xl shadow-xl overflow-y-auto transition-transform duration-300 z-20"
          :class="{
            'hidden lg:block': !vehicleListOpen,
            'fixed inset-y-0 left-0 lg:relative': vehicleListOpen,
            'translate-x-0': vehicleListOpen,
            '-translate-x-full lg:translate-x-0': !vehicleListOpen
          }"
        >
          <div class="p-3 sm:p-4 border-b border-gray-200 flex items-center justify-between">
            <input 
              v-model="searchQuery"
              type="text" 
              placeholder="🔍 Search vehicles..."
              class="flex-1 px-3 sm:px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent text-sm"
            />
            <button 
              @click="toggleVehicleList"
              class="lg:hidden ml-2 text-gray-500 hover:text-gray-700 p-2"
            >
              <i class="fas fa-times"></i>
            </button>
          </div>

          <div class="p-3 sm:p-4 space-y-3">
            <div 
              v-for="vehicle in filteredVehicles" 
              :key="vehicle.vehicle_id"
              @click="selectVehicleAndClose(vehicle)"
              class="bg-white rounded-lg p-3 sm:p-4 border-2 cursor-pointer transition-all hover:shadow-lg"
              :class="selectedVehicle?.vehicle_id === vehicle.vehicle_id ? 'border-green-500 shadow-lg' : 'border-gray-200'"
            >
              <div class="flex items-start justify-between">
                <div class="flex-1 min-w-0">
                  <div class="font-semibold text-gray-900 truncate">{{ vehicle.plate_number }}</div>
                  <div class="text-sm text-gray-600 truncate">{{ vehicle.vehicle_code }}</div>
                  <div class="text-xs text-gray-500 mt-1 truncate">{{ vehicle.make }} {{ vehicle.model }}</div>
                </div>
                <div class="text-right flex-shrink-0 ml-2">
                  <div :class="getStatusColor(vehicle.seconds_since_update)" class="text-xs font-semibold">
                    {{ formatTime(vehicle.device_timestamp) }}
                  </div>
                </div>
              </div>

              <!-- Driver Info -->
              <div v-if="vehicle.driver_code" class="mt-2 pt-2 border-t border-gray-100">
                <div class="text-xs text-gray-600 flex items-center gap-1">
                  <i class="fas fa-user"></i>
                  <span class="truncate">{{ vehicle.driver_code }}</span>
                </div>
              </div>

              <!-- GPS Update Time -->
              <div class="mt-2 pt-2 border-t border-gray-100">
                <div class="text-xs text-gray-500 flex items-center gap-1">
                  <i class="fas fa-clock"></i>
                  <span>Updated {{ formatTime(vehicle.device_timestamp) }}</span>
                </div>
              </div>
            </div>

            <div v-if="filteredVehicles.length === 0 && !loading" class="text-center py-8 text-gray-500">
              <div class="text-4xl mb-2">🚗</div>
              <div class="font-semibold">No vehicles found</div>
              <div class="text-sm mt-1">{{ vehicles.length === 0 ? 'No GPS-enabled vehicles' : 'Try a different search' }}</div>
            </div>

            <div v-if="loading" class="text-center py-8 text-gray-500">
              <i class="fas fa-spinner fa-spin text-2xl mb-2"></i>
              <div class="text-sm">Loading vehicles...</div>
            </div>
          </div>
        </div>

        <!-- Overlay for mobile when vehicle list is open -->
        <div 
          v-if="vehicleListOpen"
          @click="toggleVehicleList"
          class="lg:hidden fixed inset-0 bg-black/50 z-10"
        ></div>

        <!-- Map Container -->
        <div class="flex-1 relative">
          <div id="map" class="w-full h-full"></div>
          
          <!-- Map Controls -->
          <div class="absolute top-2 right-2 sm:top-4 sm:right-4 bg-white/95 backdrop-blur-xl rounded-lg shadow-xl p-2 sm:p-4 space-y-1.5 sm:space-y-2">
            <button 
              @click="centerMap"
              class="w-full px-2 sm:px-4 py-1.5 sm:py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-all text-xs sm:text-sm flex items-center justify-center gap-1 sm:gap-2"
            >
              <i class="fas fa-crosshairs"></i>
              <span class="hidden sm:inline">Center All</span>
            </button>
            <button 
              @click="toggleTrails"
              class="w-full px-2 sm:px-4 py-1.5 sm:py-2 transition-all text-xs sm:text-sm flex items-center justify-center gap-1 sm:gap-2"
              :class="showTrails ? 'bg-blue-600 text-white hover:bg-blue-700' : 'bg-gray-500 text-white hover:bg-gray-600'"
            >
              <i :class="showTrails ? 'fas fa-eye' : 'fas fa-eye-slash'"></i>
              <span>2H Trail</span>
            </button>
            <button 
              @click="toggle24HTrails"
              class="w-full px-2 sm:px-4 py-1.5 sm:py-2 transition-all text-xs sm:text-sm flex items-center justify-center gap-1 sm:gap-2"
              :class="show24HTrails ? 'bg-purple-600 text-white hover:bg-purple-700' : 'bg-gray-500 text-white hover:bg-gray-600'"
              :disabled="loading24HTrails"
            >
              <i v-if="loading24HTrails" class="fas fa-spinner fa-spin"></i>
              <i v-else :class="show24HTrails ? 'fas fa-eye' : 'fas fa-eye-slash'"></i>
              <span>24H Trail</span>
            </button>
          </div>

          <!-- Selected Vehicle Info Panel -->
          <div 
            v-if="selectedVehicle"
            class="absolute bottom-2 left-2 right-2 sm:bottom-4 sm:left-4 sm:right-auto bg-white/95 backdrop-blur-xl rounded-lg shadow-xl p-3 sm:p-6 sm:max-w-md"
          >
            <div class="flex justify-between items-start mb-3 sm:mb-4">
              <div class="flex-1 min-w-0">
                <h3 class="text-base sm:text-xl font-bold text-gray-900 truncate">{{ selectedVehicle.plate_number }}</h3>
                <p class="text-xs sm:text-sm text-gray-600 truncate">{{ selectedVehicle.vehicle_code }}</p>
              </div>
              <button 
                @click="selectedVehicle = null"
                class="text-gray-400 hover:text-gray-600 transition-colors ml-2 flex-shrink-0"
              >
                <i class="fas fa-times"></i>
              </button>
            </div>

            <div class="grid grid-cols-2 gap-2 sm:gap-4 text-xs sm:text-sm">
              <div>
                <div class="text-gray-500">Type</div>
                <div class="font-semibold truncate">{{ selectedVehicle.vehicle_type }}</div>
              </div>
              <div>
                <div class="text-gray-500">Status</div>
                <div class="font-semibold capitalize truncate">{{ selectedVehicle.vehicle_status }}</div>
              </div>
              <div v-if="selectedVehicle.driver_code" class="col-span-2">
                <div class="text-gray-500">Driver</div>
                <div class="font-semibold truncate">{{ selectedVehicle.driver_code }}</div>
              </div>
              <div class="col-span-2">
                <div class="text-gray-500">GPS Coordinates</div>
                <div class="font-mono text-xs bg-gray-100 p-2 rounded break-all">
                  {{ selectedVehicle.latitude?.toFixed(6) || 'N/A' }}, {{ selectedVehicle.longitude?.toFixed(6) || 'N/A' }}
                </div>
              </div>
              <div class="col-span-2">
                <div class="text-gray-500">Last GPS Update</div>
                <div class="font-semibold text-xs sm:text-sm">{{ formatDateTime(selectedVehicle.device_timestamp) }}</div>
              </div>
            </div>

            <div class="mt-3 sm:mt-4 space-y-1.5 sm:space-y-2">
              <button 
                @click="centerOnVehicle"
                class="w-full px-3 sm:px-4 py-1.5 sm:py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-all flex items-center justify-center gap-2 text-xs sm:text-sm"
              >
                <i class="fas fa-crosshairs"></i>
                <span>Center on Vehicle</span>
              </button>
              <button 
                @click="show24HourHistory"
                class="w-full px-3 sm:px-4 py-1.5 sm:py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all flex items-center justify-center gap-2 text-xs sm:text-sm"
              >
                <i class="fas fa-history"></i>
                <span class="hidden xs:inline">View Route History (24H)</span>
                <span class="xs:hidden">24H History</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 24-Hour Route History Modal -->
    <div v-if="show24HModal" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[70] backdrop-blur-sm p-2 sm:p-4" @click.self="close24HModal">
      <div class="bg-white rounded-xl sm:rounded-2xl w-full max-w-4xl max-h-[95vh] sm:max-h-[90vh] overflow-hidden shadow-2xl">
        <!-- Modal Header -->
        <div class="relative py-4 px-4 sm:py-6 sm:px-8 bg-gradient-to-br from-blue-800 to-blue-600 text-white">
          <div class="flex items-center justify-between">
            <div class="flex-1 min-w-0 mr-2">
              <h3 class="text-lg sm:text-2xl font-bold truncate">24-Hour Route History</h3>
              <p class="text-blue-100 text-xs sm:text-sm mt-1 truncate">{{ selectedVehicle?.plate_number }} - Last 24 hours</p>
            </div>
            <button 
              @click="close24HModal" 
              class="w-8 h-8 sm:w-10 sm:h-10 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors flex-shrink-0"
            >
              <i class="fas fa-times text-sm sm:text-lg"></i>
            </button>
          </div>
        </div>

        <!-- Modal Body -->
        <div class="p-3 sm:p-6 overflow-y-auto max-h-[calc(95vh-80px)] sm:max-h-[calc(90vh-120px)]">
          <div v-if="loading24H" class="text-center py-12 sm:py-16">
            <i class="fas fa-spinner fa-spin text-4xl sm:text-5xl mb-4 sm:mb-5 text-blue-600"></i>
            <p class="text-sm sm:text-base text-gray-600">Loading 24-hour route history...</p>
          </div>

          <div v-else-if="history24H.length === 0" class="text-center py-12 sm:py-16">
            <i class="fas fa-route text-5xl sm:text-7xl mb-4 sm:mb-5 text-gray-300"></i>
            <h3 class="text-xl sm:text-2xl font-bold text-gray-900 mb-2">No Route History</h3>
            <p class="text-sm sm:text-base text-gray-600">No GPS data found for the last 24 hours</p>
          </div>

          <div v-else>
            <!-- Summary Stats -->
            <div class="grid grid-cols-3 gap-2 sm:gap-4 mb-4 sm:mb-6">
              <div class="bg-blue-50 rounded-lg sm:rounded-xl p-2 sm:p-4 text-center">
                <div class="text-xl sm:text-3xl font-bold text-blue-600">{{ history24H.length }}</div>
                <div class="text-xs sm:text-sm text-gray-600 mt-1">GPS Points</div>
              </div>
              <div class="bg-green-50 rounded-lg sm:rounded-xl p-2 sm:p-4 text-center">
                <div class="text-xl sm:text-3xl font-bold text-green-600">{{ formatDuration(history24HDuration) }}</div>
                <div class="text-xs sm:text-sm text-gray-600 mt-1">Duration</div>
              </div>
              <div class="bg-purple-50 rounded-lg sm:rounded-xl p-2 sm:p-4 text-center">
                <div class="text-xl sm:text-3xl font-bold text-purple-600">{{ history24H[0]?.timestamp ? formatTime(history24H[0].timestamp) : 'N/A' }}</div>
                <div class="text-xs sm:text-sm text-gray-600 mt-1">Latest Update</div>
              </div>
            </div>

            <!-- Route Timeline -->
            <div class="bg-gray-50 rounded-lg sm:rounded-xl p-3 sm:p-6">
              <h4 class="font-semibold text-sm sm:text-base text-gray-900 mb-3 sm:mb-4 flex items-center gap-2">
                <i class="fas fa-map-marked-alt text-blue-600"></i>
                Route Timeline
              </h4>
              <div class="space-y-1.5 sm:space-y-2 max-h-80 sm:max-h-96 overflow-y-auto">
                <div 
                  v-for="(point, index) in history24H" 
                  :key="index"
                  class="flex items-center gap-2 sm:gap-3 bg-white rounded-lg p-2 sm:p-3 hover:shadow-md transition-shadow"
                >
                  <div class="flex-shrink-0 w-6 h-6 sm:w-8 sm:h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center text-xs font-bold">
                    {{ index + 1 }}
                  </div>
                  <div class="flex-1 min-w-0">
                    <div class="text-xs sm:text-sm font-medium text-gray-900 truncate">{{ formatDateTime(point.timestamp) }}</div>
                    <div class="text-xs text-gray-500 font-mono truncate">{{ point.lat.toFixed(6) }}, {{ point.long.toFixed(6) }}</div>
                  </div>
                  <button 
                    @click="focusOnPoint(point)"
                    class="flex-shrink-0 px-2 sm:px-3 py-1 bg-blue-50 text-blue-600 rounded-lg hover:bg-blue-100 transition-colors text-xs font-medium"
                  >
                    <i class="fas fa-crosshairs sm:mr-1"></i>
                    <span class="hidden sm:inline">View</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import Navbar from './Navbar.vue'
import { supabase } from '../lib/supabase'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

// Fix Leaflet default marker icon issue
delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
})

// Router
const route = useRoute()

// State
const sidebarCollapsed = ref(false)
const sidebarOpen = ref(true) // Sidebar open by default (like other pages)
const vehicleListOpen = ref(false) // Mobile vehicle list toggle
const vehicles = ref([])
const selectedVehicle = ref(null)
const searchQuery = ref('')
const loading = ref(false)
const showTrails = ref(true) // Now enabled by default for live tracking

// 24-Hour History Modal State
const show24HModal = ref(false)
const loading24H = ref(false)
const history24H = ref([])
const history24HDuration = ref(0)

// 24-Hour Trail Display State
const show24HTrails = ref(false)
const loading24HTrails = ref(false)
let trail24HPolylines = {}
let trail24HCircles = {}

// Map instance
let map = null
let markers = {}
let trailPolylines = {}
let trailCircles = {} // Store breadcrumb circles

const TRAIL_POINT_LIMIT = 240  // 2 hours of GPS data (30 sec intervals = 240 points)

function normalizeRpcTrailData(points) {
  if (!Array.isArray(points)) return []
  return points
    .filter(point => point && point.latitude != null && point.longitude != null)
    .map(point => ({
      lat: point.latitude,
      long: point.longitude,
      timestamp: point.gps_timestamp
    }))
}

// Realtime subscription
let realtimeSubscription = null
let refreshInterval = null
let trailRefreshInterval = null // Separate interval for trail updates

// Computed
const activeVehicles = computed(() => {
  return vehicles.value.filter(v => v.device_timestamp && v.seconds_since_update < 300).length
})

const filteredVehicles = computed(() => {
  if (!searchQuery.value) return vehicles.value
  
  const query = searchQuery.value.toLowerCase()
  return vehicles.value.filter(v => 
    v.plate_number?.toLowerCase().includes(query) ||
    v.vehicle_code?.toLowerCase().includes(query) ||
    v.driver_code?.toLowerCase().includes(query)
  )
})

// Methods
function toggleSidebar() {
  sidebarCollapsed.value = !sidebarCollapsed.value
}

function openSidebar() {
  sidebarOpen.value = true
}

function closeSidebar() {
  sidebarOpen.value = false
}

function toggleVehicleList() {
  vehicleListOpen.value = !vehicleListOpen.value
}

function selectVehicleAndClose(vehicle) {
  selectVehicle(vehicle)
  // Close vehicle list on mobile after selection
  if (window.innerWidth < 1024) { // lg breakpoint
    vehicleListOpen.value = false
  }
}

function getStatusColor(secondsSinceUpdate) {
  if (!secondsSinceUpdate) return 'text-gray-500'
  if (secondsSinceUpdate < 60) return 'text-green-600'
  if (secondsSinceUpdate < 300) return 'text-yellow-600'
  return 'text-red-600'
}

async function loadVehicleLocations() {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('vehicle_latest_gps')
      .select('*')
      .order('device_timestamp', { ascending: false })

    if (error) throw error
    
    vehicles.value = data || []
    updateMapMarkers()
    
    // Auto-update trails if enabled
    if (showTrails.value) {
      updateLiveTrails()
    }
  } catch (error) {
    console.error('Error loading vehicle locations:', error)
    alert('Failed to load vehicle locations: ' + error.message)
  } finally {
    loading.value = false
  }
}

async function refreshLocations() {
  await loadVehicleLocations()
}

function selectVehicle(vehicle) {
  selectedVehicle.value = vehicle
  
  // Center map on selected vehicle
  if (map && vehicle.latitude && vehicle.longitude) {
    map.flyTo([vehicle.latitude, vehicle.longitude], 16, {
      duration: 1.0
    })
    
    // Make the marker bounce
    if (markers[vehicle.vehicle_id]) {
      markers[vehicle.vehicle_id].openPopup()
    }
  }
}

function formatTime(timestamp) {
  if (!timestamp) return 'N/A'
  
  try {
    // Database stores PH time (UTC+8), parse it WITHOUT timezone conversion
    let date = new Date(timestamp)
    if (isNaN(date.getTime())) return 'N/A'
    
    // Get the UTC components (which are actually PH time in the database)
    // and treat them as local time to avoid timezone conversion
    const year = date.getUTCFullYear()
    const month = date.getUTCMonth()
    const day = date.getUTCDate()
    const hours = date.getUTCHours()
    const minutes = date.getUTCMinutes()
    const seconds = date.getUTCSeconds()
    
    // Create a new date with these values as LOCAL time
    const phDate = new Date(year, month, day, hours, minutes, seconds)
    
    // Calculate time difference using the corrected PH time
    const now = new Date()
    const diffMs = now - phDate
    const diffMins = Math.floor(diffMs / 60000)
    
    // Show relative time
    if (diffMins < 1) return 'Just now'
    if (diffMins < 60) return `${diffMins}m ago`
    if (diffMins < 1440) return `${Math.floor(diffMins / 60)}h ago`
    const days = Math.floor(diffMins / 1440)
    if (days === 1) return 'Yesterday'
    if (days < 7) return `${days} days ago`
    
    // For older data, show date
    return phDate.toLocaleDateString('en-PH')
  } catch (error) {
    console.error('Error formatting time:', timestamp, error)
    return 'N/A'
  }
}

function formatDateTime(timestamp) {
  if (!timestamp) return 'N/A'
  
  try {
    // Database stores PH time, parse it WITHOUT timezone conversion
    let date = new Date(timestamp)
    
    if (isNaN(date.getTime())) {
      console.warn('Invalid timestamp:', timestamp)
      return 'Invalid Date'
    }
    
    // Get the UTC components (which are actually PH time in the database)
    // and treat them as local time to avoid timezone conversion
    const year = date.getUTCFullYear()
    const month = date.getUTCMonth()
    const day = date.getUTCDate()
    const hours = date.getUTCHours()
    const minutes = date.getUTCMinutes()
    const seconds = date.getUTCSeconds()
    
    // Create a new date with these values as LOCAL time
    const phDate = new Date(year, month, day, hours, minutes, seconds)
    
    // Format this date
    return phDate.toLocaleString('en-PH', { 
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true
    })
  } catch (error) {
    console.error('Error formatting timestamp:', timestamp, error)
    return 'Error'
  }
}

function centerMap() {
  if (!map || vehicles.value.length === 0) return
  
  const bounds = vehicles.value
    .filter(v => v.latitude && v.longitude)
    .map(v => [v.latitude, v.longitude])
  
  if (bounds.length > 0) {
    map.fitBounds(bounds, { padding: [50, 50] })
  }
}

function toggleTrails() {
  showTrails.value = !showTrails.value
  
  if (showTrails.value) {
    // Load and display trails for all active vehicles
    updateLiveTrails()
  } else {
    // Hide all trails and breadcrumbs
    clearAllTrails()
  }
}

async function toggle24HTrails() {
  show24HTrails.value = !show24HTrails.value
  
  if (show24HTrails.value) {
    // Load and display 24-hour trails
    await load24HTrails()
  } else {
    // Hide 24-hour trails
    clear24HTrails()
  }
}

// Calculate distance between two GPS coordinates using Haversine formula
// Returns distance in kilometers
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371 // Earth's radius in kilometers
  const dLat = (lat2 - lat1) * Math.PI / 180
  const dLon = (lon2 - lon1) * Math.PI / 180
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c // Distance in km
}

function clearAllTrails() {
  // Remove all polylines (handle both array and single polyline)
  Object.values(trailPolylines).forEach(polylineData => {
    if (Array.isArray(polylineData)) {
      polylineData.forEach(p => map.removeLayer(p))
    } else {
      map.removeLayer(polylineData)
    }
  })
  trailPolylines = {}
  
  // Remove all breadcrumb circles
  Object.values(trailCircles).forEach(circles => {
    circles.forEach(circle => map.removeLayer(circle))
  })
  trailCircles = {}
}

async function updateLiveTrails() {
  // Only show trails for active vehicles (updated in last 5 minutes)
  const activeVehicles = vehicles.value.filter(v => 
    v.latitude && v.longitude && v.seconds_since_update < 300
  )
  
  // Load trails for each active vehicle
  for (const vehicle of activeVehicles) {
    await loadVehicleTrail(vehicle)
  }
}

async function loadVehicleTrail(vehicle) {
  try {
    console.log(`📍 Loading trail for vehicle: ${vehicle.plate_number} (${vehicle.vehicle_id})`)
    
    // Query approach: Get recent GPS data including queued data with NULL timestamps
    // Strategy: Get last 500 points by ID (which includes both timestamped and queued data)
    // then filter to last 2 hours where timestamp exists
    const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString()
    
    console.log(`  → Querying gps_data for vehicle_id: ${vehicle.vehicle_id}`)
    console.log(`  → Time filter: >= ${twoHoursAgo} (or recent NULL timestamps for queued data)`)
    
    // Get recent records by ID to include queued data with NULL timestamps
    const { data: allData, error: fetchError } = await supabase
      .from('gps_data')
      .select('id, lat, long, timestamp')
      .eq('vehicle_id', vehicle.vehicle_id)
      .order('id', { ascending: false }) // Most recent first by ID
      .limit(500)
    
    if (fetchError) {
      console.error(`❌ Error fetching trail for ${vehicle.plate_number}:`, fetchError)
      console.error(`  → Error details:`, JSON.stringify(fetchError, null, 2))
      return
    }
    
    console.log(`✓ Fetched ${allData?.length || 0} GPS points for ${vehicle.plate_number}`)
    
    if (!allData || allData.length === 0) {
      console.warn(`  ⚠️  No GPS data found for this vehicle`)
      return
    }
    
    // Filter to last 2 hours OR recent NULL timestamps (queued data)
    // Strategy: Keep timestamped data from last 2 hours + recent queued data (NULL timestamp)
    const filteredByTime = allData.filter(point => {
      if (!point.timestamp) {
        // NULL timestamp = queued data, keep it (it's recent by ID)
        return true
      }
      // Regular timestamped data - check if within 2 hours
      const pointTime = new Date(point.timestamp)
      const twoHoursAgoDate = new Date(Date.now() - 2 * 60 * 60 * 1000)
      return pointTime >= twoHoursAgoDate
    })
    
    console.log(`✓ ${filteredByTime.length} points after time filtering (includes queued data)`)
    
    // Filter out invalid coordinates (but allow NULL timestamp for queued data)
    const validData = filteredByTime.filter(point => 
      point.lat != null && 
      point.long != null && 
      !isNaN(point.lat) &&
      !isNaN(point.long)
    )
    
    // Sort by timestamp (nulls last), then by ID for consistent order
    validData.sort((a, b) => {
      if (!a.timestamp && !b.timestamp) return a.id - b.id
      if (!a.timestamp) return 1 // NULLs go to end
      if (!b.timestamp) return -1
      return new Date(a.timestamp) - new Date(b.timestamp)
    })
    
    console.log(`✓ ${validData.length} valid GPS points after coordinate filtering`)
    
    if (validData.length === 0) {
      console.warn(`  ⚠️  All GPS points were invalid (missing coordinates)`)
      return
    }
    
    const queuedCount = validData.filter(p => !p.timestamp).length
    const liveCount = validData.length - queuedCount
    console.log(`  → ${liveCount} live points (timestamped), ${queuedCount} queued points (no timestamp)`)
    
    if (validData.length > 0) {
      console.log(`  → First point: [${validData[0].lat}, ${validData[0].long}] at ${validData[0].timestamp || 'QUEUED'}`)
      console.log(`  → Last point: [${validData[validData.length - 1].lat}, ${validData[validData.length - 1].long}] at ${validData[validData.length - 1].timestamp || 'QUEUED'}`)
    }
    
    if (validData && validData.length > 0) {
      const data = validData
      console.log(`  → First point: [${data[0].lat}, ${data[0].long}] at ${data[0].timestamp || 'QUEUED'}`)
      console.log(`  → Last point: [${data[data.length - 1].lat}, ${data[data.length - 1].long}] at ${data[data.length - 1].timestamp || 'QUEUED'}`)
      
      // Remove existing trails
      if (trailPolylines[vehicle.vehicle_id]) {
        if (Array.isArray(trailPolylines[vehicle.vehicle_id])) {
          trailPolylines[vehicle.vehicle_id].forEach(p => map.removeLayer(p))
        } else {
          map.removeLayer(trailPolylines[vehicle.vehicle_id])
        }
      }
      
      // Remove existing breadcrumbs
      if (trailCircles[vehicle.vehicle_id]) {
        trailCircles[vehicle.vehicle_id].forEach(circle => map.removeLayer(circle))
      }
      
      // Choose color based on vehicle status
      const trailColor = getTrailColor(vehicle.seconds_since_update)
      
      // Split trail into segments to avoid straight lines across gaps
      // Detect gaps: large time jumps (>5min) or large distance jumps (>500m)
      const segments = []
      let currentSegment = []
      
      for (let i = 0; i < data.length; i++) {
        const point = data[i]
        const coord = [point.lat, point.long]
        
        if (i === 0) {
          // First point - start new segment
          currentSegment.push(coord)
        } else {
          const prevPoint = data[i - 1]
          let hasGap = false
          
          // Check for time gap (if both points have timestamps)
          if (point.timestamp && prevPoint.timestamp) {
            const timeDiff = Math.abs(new Date(point.timestamp) - new Date(prevPoint.timestamp))
            const fiveMinutes = 5 * 60 * 1000
            if (timeDiff > fiveMinutes) {
              hasGap = true
              console.log(`  → Gap detected: ${Math.round(timeDiff / 1000 / 60)}min time difference`)
            }
          }
          
          // Check for distance gap (using Haversine formula)
          const distance = calculateDistance(
            prevPoint.lat, prevPoint.long,
            point.lat, point.long
          )
          if (distance > 0.5) { // 500 meters
            hasGap = true
            console.log(`  → Gap detected: ${distance.toFixed(2)}km distance jump`)
          }
          
          if (hasGap) {
            // Save current segment and start new one
            if (currentSegment.length > 0) {
              segments.push([...currentSegment])
            }
            currentSegment = [coord]
          } else {
            // Continue current segment
            currentSegment.push(coord)
          }
        }
      }
      
      // Add final segment
      if (currentSegment.length > 0) {
        segments.push(currentSegment)
      }
      
      console.log(`  → Split into ${segments.length} trail segments`)
      
      // Draw each segment as a separate polyline
      trailPolylines[vehicle.vehicle_id] = []
      segments.forEach((segmentCoords, idx) => {
        if (segmentCoords.length > 1) { // Need at least 2 points for a line
          const polyline = L.polyline(segmentCoords, {
            color: trailColor,
            weight: 4,
            opacity: 0.8,
            smoothFactor: 1
          }).addTo(map)
          
          trailPolylines[vehicle.vehicle_id].push(polyline)
          console.log(`  → Segment ${idx + 1}: ${segmentCoords.length} points`)
        }
      })
      
      console.log(`  ✓ Added ${segments.length} trail polyline segments`)
      
      // Add breadcrumb circles at each GPS point
      trailCircles[vehicle.vehicle_id] = []
      data.forEach((point, index) => {
        // Calculate opacity: oldest first (index 0) faded, newest last (index max) bright
        const progress = index / (data.length - 1 || 1) // 0 to 1
        const opacity = Math.max(0.4, 0.4 + progress * 0.6) // 0.4 to 1.0
        
        // Use different styling for queued data (no timestamp)
        const isQueued = !point.timestamp
        
        const circle = L.circleMarker([point.lat, point.long], {
          radius: isQueued ? 4 : 3,
          fillColor: isQueued ? '#f59e0b' : trailColor, // Orange for queued
          color: isQueued ? '#fbbf24' : '#fff',
          weight: isQueued ? 2 : 1,
          opacity: opacity,
          fillOpacity: opacity
        }).addTo(map)
        
        // Add tooltip showing time or queued status
        const timeStr = point.timestamp ? formatDateTime(point.timestamp) : '⚠️ QUEUED (No signal)'
        circle.bindTooltip(`${vehicle.plate_number}<br>${timeStr}`, {
          permanent: false,
          direction: 'top',
          className: isQueued ? 'queued-tooltip' : 'custom-tooltip'
        })
        
        trailCircles[vehicle.vehicle_id].push(circle)
      })
      
      console.log(`  ✓ Added ${data.length} breadcrumb circles`)
    } else {
      console.warn(`⚠️  No trail data found for ${vehicle.plate_number}`)
      console.log(`  → Vehicle needs GPS history (waiting for GPS updates...)`)
      console.log(`  → Each GPS point is sent every 30 seconds`)
    }
  } catch (error) {
    console.error(`❌ Error loading vehicle trail for ${vehicle.plate_number}:`, error)
  }
}

function getTrailColor(secondsSinceUpdate) {
  if (!secondsSinceUpdate) return '#9ca3af' // gray
  if (secondsSinceUpdate < 60) return '#10b981' // green - very recent
  if (secondsSinceUpdate < 180) return '#3b82f6' // blue - recent
  if (secondsSinceUpdate < 300) return '#f59e0b' // yellow - getting old
  return '#ef4444' // red - stale
}

function centerOnVehicle() {
  if (!selectedVehicle.value) return
  selectVehicle(selectedVehicle.value)
}

function createCustomIcon(vehicle) {
  const color = getMarkerColor(vehicle.seconds_since_update)
  
  return L.divIcon({
    html: `
      <div style="color: ${color}; font-size: 24px;">
        <i class="fas fa-map-marker-alt"></i>
      </div>
    `,
    className: 'custom-vehicle-marker',
    iconSize: [30, 30],
    iconAnchor: [15, 15]
  })
}

function getMarkerColor(secondsSinceUpdate) {
  if (!secondsSinceUpdate) return '#6b7280'
  if (secondsSinceUpdate < 60) return '#10b981'
  if (secondsSinceUpdate < 300) return '#f59e0b'
  return '#ef4444'
}

function initializeMap() {
  // Initialize Leaflet map centered on Philippines
  map = L.map('map').setView([14.5995, 120.9842], 13)
  
  // Add OpenStreetMap tiles
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors',
    maxZoom: 19
  }).addTo(map)
  
  console.log('✓ Map initialized successfully')
}

function updateMapMarkers() {
  if (!map) return
  
  // Remove all existing markers
  Object.values(markers).forEach(marker => {
    map.removeLayer(marker)
  })
  markers = {}
  
  // Add markers for vehicles with GPS data
  vehicles.value.forEach(vehicle => {
    if (vehicle.latitude && vehicle.longitude) {
      const icon = createCustomIcon(vehicle)
      
      const marker = L.marker([vehicle.latitude, vehicle.longitude], { icon })
        .addTo(map)
        .bindPopup(`
          <div class="p-2">
            <h3 class="font-bold text-lg">${vehicle.plate_number}</h3>
            <p class="text-sm text-gray-600">${vehicle.vehicle_code}</p>
            <p class="text-sm mt-2"><strong>Type:</strong> ${vehicle.vehicle_type}</p>
            <p class="text-sm"><strong>Status:</strong> ${vehicle.vehicle_status}</p>
            ${vehicle.driver_code ? `<p class="text-sm"><strong>Driver:</strong> ${vehicle.driver_code}</p>` : ''}
            <p class="text-sm"><strong>Last Update:</strong> ${formatTime(vehicle.device_timestamp)}</p>
          </div>
        `)
      
      marker.on('click', () => {
        selectVehicle(vehicle)
      })
      
      markers[vehicle.vehicle_id] = marker
    }
  })
  
  console.log(`✓ Updated ${Object.keys(markers).length} vehicle markers`)
}

function setupRealtimeSubscription() {
  // Subscribe to real-time GPS updates
  realtimeSubscription = supabase
    .channel('gps-updates')
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'gps_data'
      },
      (payload) => {
        console.log('New GPS data received:', payload.new)
        loadVehicleLocations()
      }
    )
    .subscribe()
  
  console.log('✓ Real-time subscription active')
}

// 24-Hour Trail Display Functions
async function load24HTrails() {
  if (!map) return
  
  loading24HTrails.value = true
  
  try {
    const activeVehicles = vehicles.value.filter(v => v.latitude && v.longitude)
    
    console.log(`📊 Loading 24-hour trails for ${activeVehicles.length} vehicles`)
    
    for (const vehicle of activeVehicles) {
      await load24HTrailForVehicle(vehicle)
    }
  } catch (error) {
    console.error('Error loading 24-hour trails:', error)
  } finally {
    loading24HTrails.value = false
  }
}

async function load24HTrailForVehicle(vehicle) {
  try {
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
    
    const { data, error } = await supabase
      .from('gps_data')
      .select('lat, long, timestamp')
      .eq('vehicle_id', vehicle.vehicle_id)
      .gte('timestamp', twentyFourHoursAgo)
      .order('timestamp', { ascending: true })
      .limit(2880) // 24 hours max
    
    if (error) throw error
    
    if (!data || data.length === 0) {
      console.warn(`No 24H data for ${vehicle.plate_number}`)
      return
    }
    
    console.log(`✓ Loaded ${data.length} points for ${vehicle.plate_number} (24H)`)
    
    // Filter valid points
    const validData = data.filter(point => 
      point.lat != null && 
      point.long != null && 
      !isNaN(point.lat) && 
      !isNaN(point.long)
    )
    
    if (validData.length === 0) return
    
    // Create route coordinates
    const routeCoords = validData.map(point => [point.lat, point.long])
    
    // Use different color for 24H trail (purple/magenta)
    const trail24HColor = '#9333ea' // Purple
    
    // Add polyline
    trail24HPolylines[vehicle.vehicle_id] = L.polyline(routeCoords, {
      color: trail24HColor,
      weight: 3,
      opacity: 0.6,
      smoothFactor: 1,
      dashArray: '10, 5' // Dashed line to differentiate from 2H trail
    }).addTo(map)
    
    // Add breadcrumb circles (smaller and more transparent for 24H)
    trail24HCircles[vehicle.vehicle_id] = []
    
    // Only show circles for every 10th point to reduce clutter
    validData.forEach((point, index) => {
      if (index % 10 === 0) {
        const circle = L.circleMarker([point.lat, point.long], {
          radius: 2,
          fillColor: trail24HColor,
          color: '#fff',
          weight: 1,
          opacity: 0.4,
          fillOpacity: 0.4
        }).addTo(map)
        
        circle.bindTooltip(`${vehicle.plate_number}<br>${formatDateTime(point.timestamp)}`, {
          permanent: false,
          direction: 'top',
          className: 'custom-tooltip'
        })
        
        trail24HCircles[vehicle.vehicle_id].push(circle)
      }
    })
    
    console.log(`✓ Added 24H trail for ${vehicle.plate_number}: ${validData.length} points, ${Math.floor(validData.length / 10)} circles`)
  } catch (error) {
    console.error(`Error loading 24H trail for ${vehicle.plate_number}:`, error)
  }
}

function clear24HTrails() {
  // Remove all 24H polylines
  Object.values(trail24HPolylines).forEach(polyline => {
    if (map && polyline) map.removeLayer(polyline)
  })
  trail24HPolylines = {}
  
  // Remove all 24H breadcrumb circles
  Object.values(trail24HCircles).forEach(circles => {
    circles.forEach(circle => {
      if (map && circle) map.removeLayer(circle)
    })
  })
  trail24HCircles = {}
  
  console.log('✓ Cleared all 24-hour trails')
}

// 24-Hour History Functions
async function show24HourHistory() {
  if (!selectedVehicle.value) return
  
  show24HModal.value = true
  loading24H.value = true
  history24H.value = []
  
  try {
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
    
    console.log(`📊 Loading 24-hour history for ${selectedVehicle.value.plate_number}`)
    
    const { data, error } = await supabase
      .from('gps_data')
      .select('lat, long, timestamp')
      .eq('vehicle_id', selectedVehicle.value.vehicle_id)
      .gte('timestamp', twentyFourHoursAgo)
      .order('timestamp', { ascending: false })
      .limit(2880) // 24 hours × 60 minutes × 2 points/minute
    
    if (error) throw error
    
    history24H.value = data || []
    
    // Calculate duration
    if (history24H.value.length > 1) {
      const first = new Date(history24H.value[history24H.value.length - 1].timestamp)
      const last = new Date(history24H.value[0].timestamp)
      history24HDuration.value = Math.floor((last - first) / 1000 / 60) // minutes
    }
    
    console.log(`✓ Loaded ${history24H.value.length} GPS points for last 24 hours`)
  } catch (error) {
    console.error('Error loading 24-hour history:', error)
    alert('Failed to load 24-hour history: ' + error.message)
  } finally {
    loading24H.value = false
  }
}

function close24HModal() {
  show24HModal.value = false
}

function formatDuration(minutes) {
  if (minutes < 60) return `${minutes}m`
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  return `${hours}h ${mins}m`
}

function focusOnPoint(point) {
  if (!map) return
  
  // Close modal
  close24HModal()
  
  // Center map on point
  map.flyTo([point.lat, point.long], 18, {
    duration: 1.0
  })
  
  // Add a temporary marker
  const tempMarker = L.marker([point.lat, point.long], {
    icon: L.divIcon({
      html: '<div style="color: #ef4444; font-size: 32px;"><i class="fas fa-map-marker-alt"></i></div>',
      className: 'temp-marker',
      iconSize: [32, 32],
      iconAnchor: [16, 32]
    })
  }).addTo(map)
  
  tempMarker.bindPopup(`
    <div class="p-2">
      <h4 class="font-bold">${selectedVehicle.value.plate_number}</h4>
      <p class="text-sm">${formatDateTime(point.timestamp)}</p>
      <p class="text-xs font-mono">${point.lat.toFixed(6)}, ${point.long.toFixed(6)}</p>
    </div>
  `).openPopup()
  
  // Remove temporary marker after 5 seconds
  setTimeout(() => {
    map.removeLayer(tempMarker)
  }, 5000)
}

// Lifecycle
onMounted(async () => {
  console.log('🗺️ LiveMap component mounted')
  
  // Initialize map first
  initializeMap()
  
  // Load vehicle locations
  await loadVehicleLocations()
  
  // Check if we should focus on a specific vehicle (from Vehicles page)
  const vehicleId = route.query.vehicle
  if (vehicleId) {
    // Find the vehicle with this ID
    const targetVehicle = vehicles.value.find(v => v.vehicle_id === vehicleId)
    if (targetVehicle) {
      // Select and center on this vehicle
      setTimeout(() => {
        selectVehicle(targetVehicle)
      }, 500) // Small delay to ensure map is ready
    }
  } else {
    // Center map on all vehicles
    if (vehicles.value.length > 0) {
      centerMap()
    }
  }
  
  // Setup real-time updates
  setupRealtimeSubscription()
  
  // Auto-refresh every 30 seconds
  refreshInterval = setInterval(() => {
    loadVehicleLocations()
  }, 30000)
})

// Watch for vehicle query parameter changes
watch(() => route.query.vehicle, (newVehicleId) => {
  if (newVehicleId && vehicles.value.length > 0) {
    const targetVehicle = vehicles.value.find(v => v.vehicle_id === newVehicleId)
    if (targetVehicle) {
      selectVehicle(targetVehicle)
    }
  }
})

onUnmounted(() => {
  console.log('🗺️ LiveMap component unmounting')
  
  if (realtimeSubscription) {
    supabase.removeChannel(realtimeSubscription)
  }
  
  if (refreshInterval) {
    clearInterval(refreshInterval)
  }
  
  if (trailRefreshInterval) {
    clearInterval(trailRefreshInterval)
  }
  
  // Clear all trails before unmounting
  clearAllTrails()
  clear24HTrails()
  
  if (map) {
    map.remove()
  }
})
</script>

<style scoped>
#map {
  z-index: 0;
}

.custom-vehicle-marker {
  background: transparent;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Smooth animations */
.transition-all {
  transition: all 0.3s ease;
}

/* Scrollbar styling */
.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>

<style>
/* Global Leaflet styles (not scoped so they work with Leaflet) */
.custom-tooltip {
  background: rgba(0, 0, 0, 0.85) !important;
  border: none !important;
  border-radius: 8px !important;
  padding: 6px 10px !important;
  font-size: 11px !important;
  color: white !important;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3) !important;
  backdrop-filter: blur(10px) !important;
}

.custom-tooltip::before {
  border-top-color: rgba(0, 0, 0, 0.85) !important;
}

/* Queued data tooltip styling - warning style for data without signal */
.queued-tooltip {
  background: rgba(251, 191, 36, 0.95) !important;
  border: 2px solid #f59e0b !important;
  color: #78350f !important;
  font-weight: 600 !important;
  box-shadow: 0 4px 12px rgba(251, 191, 36, 0.4) !important;
  border-radius: 8px !important;
  padding: 6px 10px !important;
  font-size: 11px !important;
}

.queued-tooltip::before {
  border-top-color: rgba(251, 191, 36, 0.95) !important;
}
</style>
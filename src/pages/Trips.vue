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
      <header class="bg-white/95 backdrop-blur-xl py-5 px-8 border-b border-white/20 flex flex-col sm:flex-row justify-between items-start sm:items-center shadow-sm sticky top-0 z-10 gap-4 sm:gap-0">
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
                style="color: #0A400C;">Trip History</h1>
            <div v-if="vehicleInfo" class="flex items-center gap-2 mt-2">
              <span class="text-sm text-slate-600">Vehicle:</span>
              <span class="font-semibold text-sm" style="color: #0A400C;">
                {{ vehicleInfo.plate_number }} - {{ vehicleInfo.year }} {{ vehicleInfo.make }} {{ vehicleInfo.model }}
              </span>
            </div>
          </div>
        </div>
        <div class="flex items-center gap-4 w-full sm:w-auto">
          <button
            @click="$router.go(-1)"
            class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2 px-3 sm:py-3 sm:px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 text-xs sm:text-sm hover:bg-slate-500/20"
          >
            <i class="fas fa-arrow-left"></i>
            <span class="hidden sm:inline">Back</span>
          </button>
          <button
            @click="openAddModal"
            class="bg-gradient-to-br text-white border-none py-2 px-3 sm:py-3 sm:px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg text-xs sm:text-sm hover:-translate-y-0.5 hover:shadow-xl"
            style="background: linear-gradient(135deg, #0A400C, #155c1a); box-shadow: 0 10px 25px rgba(10, 64, 12, 0.3);"
          >
            <i class="fas fa-plus"></i>
            <span class="hidden sm:inline">Add Trip</span>
          </button>
        </div>
      </header>

      <!-- Main Content -->
      <div class="flex-1 p-4 sm:p-6 lg:p-8 overflow-y-auto">
        <div class="max-w-7xl mx-auto">
          <!-- Filters Section -->
          <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-5 rounded-xl mb-6 sm:mb-8 shadow-lg"
               style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
            <div class="flex flex-col sm:flex-row gap-4 sm:gap-5 items-stretch sm:items-center">
              <div class="relative flex-1 min-w-0">
                <i class="fas fa-search absolute left-4 top-1/2 transform -translate-y-1/2 text-slate-500"></i>
                <input
                  type="text"
                  v-model="searchQuery"
                  placeholder="Search by origin, destination, driver..."
                  class="w-full py-3 pl-11 pr-4 border border-slate-300 rounded-lg text-sm bg-white transition-colors duration-200 focus:outline-none focus:ring-4"
                  style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                  :style="{ 'border-color': searchQuery ? '#0A400C' : '' }"
                >
              </div>

              <div class="flex flex-col sm:flex-row gap-4 items-stretch sm:items-center">
                <select v-model="statusFilter" class="py-2.5 px-3 border border-slate-300 rounded-lg bg-white text-sm text-gray-700 min-w-0 sm:min-w-36 focus:outline-none focus:ring-4"
                        style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <option value="">All Status</option>
                  <option value="completed">Completed</option>
                  <option value="ongoing">Ongoing</option>
                  <option value="cancelled">Cancelled</option>
                </select>

                <input 
                  type="date" 
                  v-model="dateFilter"
                  class="py-2.5 px-3 border border-slate-300 rounded-lg bg-white text-sm text-gray-700 min-w-0 sm:min-w-36 focus:outline-none focus:ring-4"
                  style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                >

                <button @click="clearFilters" class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2.5 px-4 rounded-lg cursor-pointer font-medium flex items-center justify-center gap-1.5 transition-all duration-200 text-sm hover:bg-slate-500/20 hover:text-slate-700 whitespace-nowrap">
                  <i class="fas fa-times"></i>
                  <span class="hidden sm:inline">Clear</span>
                </button>
              </div>
            </div>
          </div>

          <!-- Trip Statistics Cards -->
          <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-6 sm:mb-8">
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg text-center"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="text-2xl sm:text-3xl font-bold mb-2" style="color: #0A400C;">{{ tripStats.total }}</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Total Trips</div>
            </div>
            
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg text-center"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="text-2xl sm:text-3xl font-bold mb-2 text-green-600">{{ tripStats.completed }}</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Completed</div>
            </div>
            
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg text-center"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="text-2xl sm:text-3xl font-bold mb-2 text-blue-600">{{ tripStats.ongoing }}</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Ongoing</div>
            </div>
            
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg text-center"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="text-2xl sm:text-3xl font-bold mb-2 text-gray-600">{{ tripStats.totalDistance }} km</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Total Distance</div>
            </div>
          </div>

          <!-- Trips Content -->
          <div v-if="loading" class="text-center py-16 bg-white/90 backdrop-blur-xl rounded-2xl shadow-lg"
               style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
            <i class="fas fa-spinner fa-spin text-5xl mb-5" style="color: #0A400C;"></i>
            <span class="text-slate-600 text-base font-medium">Loading trip history...</span>
          </div>

          <div v-else-if="filteredTrips.length === 0" class="text-center py-16 bg-white/90 backdrop-blur-xl rounded-2xl shadow-lg"
               style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
            <i class="fas fa-route text-7xl mb-5" style="color: rgba(10, 64, 12, 0.3);"></i>
            <h3 class="text-2xl mb-2.5" style="color: #0A400C;">No trips found</h3>
            <p class="text-slate-600 mb-6">{{ hasActiveFilters ? 'Try adjusting your search criteria' : 'No trips recorded for this vehicle yet.' }}</p>
          </div>

          <!-- Trip Cards -->
          <div v-else class="space-y-4">
            <div v-for="trip in filteredTrips" :key="trip.id" 
                 class="bg-white/95 backdrop-blur-xl rounded-2xl p-4 sm:p-6 shadow-lg border border-white/30 transition-all duration-300 hover:shadow-xl"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              
              <!-- Trip Header -->
              <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-4 gap-4">
                <div class="flex items-center gap-4">
                  <div class="p-3 rounded-full" :class="{
                    'bg-green-500/10': trip.status === 'completed',
                    'bg-blue-500/10': trip.status === 'ongoing',
                    'bg-red-500/10': trip.status === 'cancelled'
                  }">
                    <i class="text-xl" :class="{
                      'fas fa-check-circle text-green-600': trip.status === 'completed',
                      'fas fa-play-circle text-blue-600': trip.status === 'ongoing',
                      'fas fa-times-circle text-red-600': trip.status === 'cancelled'
                    }"></i>
                  </div>
                  <div>
                    <h3 class="text-lg font-semibold text-gray-800 m-0">{{ trip.origin }} → {{ trip.destination }}</h3>
                    <p class="text-sm text-slate-600 m-0 mt-1">{{ formatDate(trip.start_time) }}</p>
                  </div>
                </div>
                
                <div class="flex items-center gap-2">
                  <span class="py-1.5 px-3 rounded-2xl text-xs font-semibold uppercase" :class="{
                    'bg-green-500/10 text-green-600': trip.status === 'completed',
                    'bg-blue-500/10 text-blue-600': trip.status === 'ongoing',
                    'bg-red-500/10 text-red-600': trip.status === 'cancelled'
                  }">
                    {{ trip.status }}
                  </span>
                </div>
              </div>

              <!-- Trip Details Grid -->
              <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-4">
                <div class="text-center p-3 bg-gray-50 rounded-lg">
                  <div class="text-xs text-gray-600 font-medium mb-1">Driver</div>
                  <div class="font-semibold text-sm">{{ trip.driver_name || 'N/A' }}</div>
                </div>
                <div class="text-center p-3 bg-gray-50 rounded-lg">
                  <div class="text-xs text-gray-600 font-medium mb-1">Distance</div>
                  <div class="font-semibold text-sm">{{ trip.distance || 0 }} km</div>
                </div>
                <div class="text-center p-3 bg-gray-50 rounded-lg">
                  <div class="text-xs text-gray-600 font-medium mb-1">Duration</div>
                  <div class="font-semibold text-sm">{{ formatDuration(trip.start_time, trip.end_time) }}</div>
                </div>
                <div class="text-center p-3 bg-gray-50 rounded-lg">
                  <div class="text-xs text-gray-600 font-medium mb-1">Purpose</div>
                  <div class="font-semibold text-sm">{{ trip.purpose || 'General' }}</div>
                </div>
              </div>

              <!-- Trip Notes -->
              <div v-if="trip.notes" class="mb-4 p-3 bg-gray-50 rounded-lg border-l-4" style="border-left-color: #0A400C;">
                <div class="text-xs text-gray-600 font-medium mb-1">Notes</div>
                <p class="text-sm text-gray-700 m-0">{{ trip.notes }}</p>
              </div>

              <!-- Action Buttons -->
              <div class="flex gap-2 justify-end pt-4 border-t border-gray-200">
                <button @click="viewTripDetails(trip)" class="bg-blue-500/10 text-blue-600 border border-blue-500/20 py-2 px-4 rounded-lg cursor-pointer font-medium flex items-center gap-2 transition-all duration-200 text-sm hover:bg-blue-500/20 hover:scale-105">
                  <i class="fas fa-eye"></i>
                  View
                </button>
                <button @click="editTrip(trip)" class="bg-amber-500/10 text-amber-600 border border-amber-500/20 py-2 px-4 rounded-lg cursor-pointer font-medium flex items-center gap-2 transition-all duration-200 text-sm hover:bg-amber-500/20 hover:scale-105">
                  <i class="fas fa-edit"></i>
                  Edit
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Add/Edit Trip Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm">
      <div class="bg-white rounded-2xl p-0 w-11/12 max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl">
        <div class="py-6 px-8 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br text-white rounded-t-2xl"
             style="background: linear-gradient(135deg, #0A400C, #155c1a);">
          <h3 class="m-0 text-xl font-semibold">{{ editingTrip ? 'Edit Trip' : 'Add New Trip' }}</h3>
          <button class="bg-white/10 border-none text-white w-8 h-8 rounded-lg cursor-pointer flex items-center justify-center transition-colors duration-200 hover:bg-white/20" @click="closeModal">
            <i class="fas fa-times"></i>
          </button>
        </div>

        <form @submit.prevent="submitForm" class="p-8">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Origin *</label>
              <input type="text" v-model="tripForm.origin" required class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4" style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
            </div>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Destination *</label>
              <input type="text" v-model="tripForm.destination" required class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4" style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Start Time *</label>
              <input type="datetime-local" v-model="tripForm.start_time" required class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4" style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
            </div>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">End Time</label>
              <input type="datetime-local" v-model="tripForm.end_time" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4" style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Driver</label>
              <select v-model="tripForm.driver_id" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4" style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                <option value="">Select Driver</option>
                <option v-for="driver in drivers" :key="driver.id" :value="driver.id">{{ driver.full_name }}</option>
              </select>
            </div>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Distance (km)</label>
              <input type="number" v-model.number="tripForm.distance" step="0.1" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4" style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Purpose</label>
              <select v-model="tripForm.purpose" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4" style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                <option value="">Select Purpose</option>
                <option value="official">Official Business</option>
                <option value="transport">Transport</option>
                <option value="delivery">Delivery</option>
                <option value="maintenance">Maintenance</option>
                <option value="emergency">Emergency</option>
                <option value="other">Other</option>
              </select>
            </div>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Status</label>
              <select v-model="tripForm.status" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4" style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                <option value="ongoing">Ongoing</option>
                <option value="completed">Completed</option>
                <option value="cancelled">Cancelled</option>
              </select>
            </div>
          </div>

          <div class="flex flex-col gap-2 mb-5">
            <label class="font-semibold text-gray-700 text-sm">Notes</label>
            <textarea v-model="tripForm.notes" rows="3" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white resize-y min-h-20 focus:outline-none focus:ring-4" style="--tw-ring-color: rgba(10, 64, 12, 0.1);"></textarea>
          </div>

          <div class="flex gap-4 justify-end mt-8 pt-5 border-t border-gray-200">
            <button type="button" @click="closeModal" class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2.5 px-4 rounded-lg cursor-pointer font-medium flex items-center gap-1.5 transition-all duration-200 text-sm hover:bg-slate-500/20 hover:text-slate-700">Cancel</button>
            <button type="submit" class="bg-gradient-to-br text-white border-none py-3 px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg text-sm hover:-translate-y-0.5 hover:shadow-xl disabled:opacity-60 disabled:cursor-not-allowed disabled:transform-none" style="background: linear-gradient(135deg, #0A400C, #155c1a); box-shadow: 0 10px 25px rgba(10, 64, 12, 0.3);" :disabled="submitting">
              <i v-if="submitting" class="fas fa-spinner fa-spin"></i>
              {{ editingTrip ? 'Update Trip' : 'Add Trip' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../lib/supabase'
import Navbar from './Navbar.vue'

export default {
  name: 'Trips',
  components: { Navbar },
  setup() {
    const router = useRouter()
    const route = useRoute()
    const vehicleId = route.params.id

    // Sidebar state
    const sidebarCollapsed = ref(false)
    const sidebarOpen = ref(true)

    // Data
    const trips = ref([])
    const vehicleInfo = ref(null)
    const drivers = ref([])
    const loading = ref(true)

    // Filters
    const searchQuery = ref('')
    const statusFilter = ref('')
    const dateFilter = ref('')

    // Modal state
    const showModal = ref(false)
    const editingTrip = ref(null)
    const submitting = ref(false)

    const tripForm = reactive({
      origin: '',
      destination: '',
      start_time: '',
      end_time: '',
      driver_id: '',
      distance: null,
      purpose: '',
      status: 'ongoing',
      notes: ''
    })

    // Computed
    const filteredTrips = computed(() => {
      let filtered = trips.value

      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        filtered = filtered.filter(trip =>
          trip.origin.toLowerCase().includes(query) ||
          trip.destination.toLowerCase().includes(query) ||
          (trip.driver_name && trip.driver_name.toLowerCase().includes(query))
        )
      }

      if (statusFilter.value) {
        filtered = filtered.filter(trip => trip.status === statusFilter.value)
      }

      if (dateFilter.value) {
        filtered = filtered.filter(trip => 
          trip.start_time && trip.start_time.startsWith(dateFilter.value)
        )
      }

      return filtered
    })

    const hasActiveFilters = computed(() => {
      return searchQuery.value || statusFilter.value || dateFilter.value
    })

    const tripStats = computed(() => {
      const total = trips.value.length
      const completed = trips.value.filter(t => t.status === 'completed').length
      const ongoing = trips.value.filter(t => t.status === 'ongoing').length
      const totalDistance = trips.value.reduce((sum, t) => sum + (t.distance || 0), 0)
      
      return { total, completed, ongoing, totalDistance }
    })

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

    const formatDate = (dateString) => {
      if (!dateString) return 'N/A'
      return new Date(dateString).toLocaleString()
    }

    const formatDuration = (start, end) => {
      if (!start || !end) return 'N/A'
      const diff = new Date(end) - new Date(start)
      const hours = Math.floor(diff / (1000 * 60 * 60))
      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
      return `${hours}h ${minutes}m`
    }

    const loadVehicleInfo = async () => {
      try {
        const { data, error } = await supabase
          .from('vehicles')
          .select('*')
          .eq('id', vehicleId)
          .single()
        
        if (error) throw error
        vehicleInfo.value = data
      } catch (error) {
        console.error('Error loading vehicle info:', error)
        vehicleInfo.value = {
          plate_number: 'ABC-1234',
          year: 2022,
          make: 'Toyota',
          model: 'Camry'
        }
      }
    }

    const loadTrips = async () => {
      loading.value = true
      try {
        const { data, error } = await supabase
          .from('trips')
          .select(`
            *,
            profiles:driver_id (full_name)
          `)
          .eq('vehicle_id', vehicleId)
          .order('start_time', { ascending: false })
        
        if (error) throw error
        
        trips.value = data.map(trip => ({
          ...trip,
          driver_name: trip.profiles?.full_name || null
        }))
      } catch (error) {
        console.error('Error loading trips:', error)
        // Sample data
        trips.value = [
          {
            id: 1,
            origin: 'Main Office',
            destination: 'Branch Office',
            start_time: '2024-01-15T09:00:00',
            end_time: '2024-01-15T11:30:00',
            driver_name: 'John Doe',
            distance: 25,
            purpose: 'official',
            status: 'completed',
            notes: 'Regular delivery run'
          },
          {
            id: 2,
            origin: 'Branch Office',
            destination: 'Client Site',
            start_time: '2024-01-16T14:00:00',
            end_time: null,
            driver_name: 'Jane Smith',
            distance: null,
            purpose: 'delivery',
            status: 'ongoing',
            notes: 'Client meeting and equipment delivery'
          }
        ]
      } finally {
        loading.value = false
      }
    }

    const loadDrivers = async () => {
      try {
        const { data, error } = await supabase
          .from('drivers')
          .select('id, full_name, employee_id')
          .eq('is_active', true)
          .order('full_name')
        
        if (error) throw error
        drivers.value = data
      } catch (error) {
        console.error('Error loading drivers:', error)
        drivers.value = [
          { id: 'driver1', full_name: 'John Doe' },
          { id: 'driver2', full_name: 'Jane Smith' }
        ]
      }
    }

    const openAddModal = () => {
      editingTrip.value = null
      resetForm()
      showModal.value = true
    }

    const closeModal = () => {
      showModal.value = false
      editingTrip.value = null
      resetForm()
    }

    const resetForm = () => {
      Object.assign(tripForm, {
        origin: '',
        destination: '',
        start_time: '',
        end_time: '',
        driver_id: '',
        distance: null,
        purpose: '',
        status: 'ongoing',
        notes: ''
      })
    }

    const editTrip = (trip) => {
      editingTrip.value = trip
      Object.assign(tripForm, {
        origin: trip.origin,
        destination: trip.destination,
        start_time: trip.start_time,
        end_time: trip.end_time || '',
        driver_id: trip.driver_id || '',
        distance: trip.distance,
        purpose: trip.purpose || '',
        status: trip.status,
        notes: trip.notes || ''
      })
      showModal.value = true
    }

    const viewTripDetails = (trip) => {
      // Could open a detailed modal or navigate to trip details page
      console.log('View trip details:', trip)
    }

    const submitForm = async () => {
      submitting.value = true
      try {
        const tripData = {
          vehicle_id: vehicleId,
          origin: tripForm.origin,
          destination: tripForm.destination,
          start_time: tripForm.start_time,
          end_time: tripForm.end_time || null,
          driver_id: tripForm.driver_id || null,
          distance: tripForm.distance,
          purpose: tripForm.purpose || null,
          status: tripForm.status,
          notes: tripForm.notes || null
        }

        if (editingTrip.value) {
          const { error } = await supabase
            .from('trips')
            .update(tripData)
            .eq('id', editingTrip.value.id)
          
          if (error) throw error
          
          // Update local data
          const index = trips.value.findIndex(t => t.id === editingTrip.value.id)
          if (index !== -1) {
            const driver = drivers.value.find(d => d.id === tripForm.driver_id)
            trips.value[index] = {
              ...editingTrip.value,
              ...tripData,
              driver_name: driver ? driver.full_name : null
            }
          }
        } else {
          const { data, error } = await supabase
            .from('trips')
            .insert(tripData)
            .select()
            .single()
          
          if (error) throw error
          
          const driver = drivers.value.find(d => d.id === tripForm.driver_id)
          trips.value.unshift({
            ...data,
            driver_name: driver ? driver.full_name : null
          })
        }

        closeModal()
      } catch (error) {
        console.error('Error submitting trip:', error)
        alert('Error: ' + error.message)
      } finally {
        submitting.value = false
      }
    }

    const clearFilters = () => {
      searchQuery.value = ''
      statusFilter.value = ''
      dateFilter.value = ''
    }

    onMounted(async () => {
      await Promise.all([
        loadVehicleInfo(),
        loadTrips(),
        loadDrivers()
      ])
    })

    return {
      sidebarCollapsed,
      sidebarOpen,
      toggleSidebar,
      closeSidebar,
      openSidebar,
      handleMenuClick,
      vehicleInfo,
      trips,
      filteredTrips,
      hasActiveFilters,
      tripStats,
      loading,
      searchQuery,
      statusFilter,
      dateFilter,
      showModal,
      editingTrip,
      submitting,
      tripForm,
      drivers,
      formatDate,
      formatDuration,
      openAddModal,
      closeModal,
      editTrip,
      viewTripDetails,
      submitForm,
      clearFilters
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
</style>
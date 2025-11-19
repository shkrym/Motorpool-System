<template>
  <div class="flex h-screen bg-gradient-to-br from-slate-50 to-slate-100 font-inter">
    <Navbar 
      :sidebar-collapsed="sidebarCollapsed"
      :sidebar-open="sidebarOpen"
      @toggle-sidebar="toggleSidebar"
      @close-sidebar="closeSidebar"
      @open-sidebar="openSidebar"
      @menu-click="handleMenuClick"
    />
    
    <div
      v-if="sidebarOpen && !sidebarCollapsed"
      class="fixed inset-0 bg-black/50 z-40 lg:hidden"
      @click="closeSidebar"
    ></div>

    <main class="main-content flex flex-1 flex-col transition-all duration-300 ease-in-out min-w-0" :class="{ '!ml-0': sidebarCollapsed || !sidebarOpen }">
      
      <!-- Modern Header with Breadcrumb -->
      <header class="bg-gradient-to-br from-green-800 to-green-600 shadow-lg border-b border-slate-200 sticky top-0 z-10">
        <div class="px-4 sm:px-6 lg:px-8 py-4">
          <!-- Breadcrumb -->
          <div class="flex items-center gap-2 text-sm text-white mb-3">
            <i class="fas fa-home"></i>
            <i class="fas fa-chevron-right text-xs"></i>
            <span class="hover:text-green-700 text-white cursor-pointer" @click="$router.push('/vehicles')">Vehicles</span>
            <i class="fas fa-chevron-right text-xs"></i>
            <span class="text-white font-medium">Trip History</span>
          </div>

          <!-- Header Content -->
          <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 ">
            <div class="flex items-center gap-4 w-full sm:w-auto">
              <button
                @click="openSidebar"
                class="lg:hidden bg-green-700 text-white p-2.5 rounded-lg hover:bg-green-800 transition-colors"
                v-if="!sidebarOpen"
              >
                <i class="fas fa-bars"></i>
              </button>
              
              <div class="flex-1">
                <div class="flex items-center gap-3">
                  <div class="p-3 bg-green-100 rounded-xl">
                    <i class="fas fa-route text-2xl text-green-700"></i>
                  </div>
                  <div>
                    <div v-if="vehicleInfo" class="flex items-center gap-2 mt-0.5">
                      <span class="px-2 py-0.5 text-3xl font-bold text-white">
                        {{ vehicleInfo.plate_number }}
                      </span>
                      <span class="text-md bg-white rounded pr-2 pl-2 font font-semibold text-[#0A400C]">
                        {{ vehicleInfo.year }} {{ vehicleInfo.make }} {{ vehicleInfo.model }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="flex items-center gap-3 w-full sm:w-auto mb-2">
              <button
                @click="openAddModal"
                class="flex-1 sm:flex-none bg-gradient-to-br from-green-800 to-green-700 text-white py-2.5 px-5 rounded-lg font-semibold flex items-center justify-center gap-2 hover:from-green-700 hover:to-green-800 transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
              >
                <i class="fas fa-plus"></i>
                <span>New Trip</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      <!-- Main Content -->
      <div class="flex-1 p-4 sm:p-6 lg:p-8 overflow-y-auto  bg-green-100/80">
        <div class="max-w-7xl mx-auto space-y-6">
          
          <!-- Statistics Overview -->
          <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <div class="bg-white rounded-xl p-5 border border-slate-200 shadow-sm hover:shadow-md transition-shadow">
              <div class="flex items-center justify-between mb-3">
                <div class="p-2.5 bg-blue-100 rounded-lg">
                  <i class="fas fa-route text-blue-600 text-lg"></i>
                </div>
                <span class="text-xs font-medium text-slate-500 uppercase tracking-wide">Total</span>
              </div>
              <div class="text-3xl font-bold text-slate-800">{{ tripStats.total }}</div>
              <div class="text-sm text-slate-600 mt-1">All Trips</div>
            </div>
            
            <div class="bg-white rounded-xl p-5 border border-slate-200 shadow-sm hover:shadow-md transition-shadow">
              <div class="flex items-center justify-between mb-3">
                <div class="p-2.5 bg-green-100 rounded-lg">
                  <i class="fas fa-check-circle text-green-600 text-lg"></i>
                </div>
                <span class="text-xs font-medium text-slate-500 uppercase tracking-wide">Done</span>
              </div>
              <div class="text-3xl font-bold text-green-600">{{ tripStats.completed }}</div>
              <div class="text-sm text-slate-600 mt-1">Completed</div>
            </div>
            
            <div class="bg-white rounded-xl p-5 border border-slate-200 shadow-sm hover:shadow-md transition-shadow">
              <div class="flex items-center justify-between mb-3">
                <div class="p-2.5 bg-amber-100 rounded-lg">
                  <i class="fas fa-spinner text-amber-600 text-lg"></i>
                </div>
                <span class="text-xs font-medium text-slate-500 uppercase tracking-wide">Active</span>
              </div>
              <div class="text-3xl font-bold text-amber-600">{{ tripStats.ongoing }}</div>
              <div class="text-sm text-slate-600 mt-1">In Progress</div>
            </div>
            
            <div class="bg-white rounded-xl p-5 border border-slate-200 shadow-sm hover:shadow-md transition-shadow">
              <div class="flex items-center justify-between mb-3">
                <div class="p-2.5 bg-purple-100 rounded-lg">
                  <i class="fas fa-road text-purple-600 text-lg"></i>
                </div>
                <span class="text-xs font-medium text-slate-500 uppercase tracking-wide">Distance</span>
              </div>
              <div class="text-3xl font-bold text-slate-800">{{ tripStats.totalDistance }}</div>
              <div class="text-sm text-slate-600 mt-1">Kilometers</div>
            </div>
          </div>

          <!-- Filters and Search -->
          <div class="bg-white rounded-xl border border-slate-200 shadow-sm">
            <div class="p-5">
              <div class="flex flex-col lg:flex-row gap-4">
                <!-- Search -->
                <div class="relative flex-1">
                  <i class="fas fa-search absolute left-4 top-1/2 transform -translate-y-1/2 text-slate-400"></i>
                  <input
                    type="text"
                    v-model="searchQuery"
                    placeholder="Search trips by location or driver name..."
                    class="w-full py-3 pl-11 pr-4 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all"
                  >
                </div>

                <!-- Filters -->
                <div class="flex flex-col sm:flex-row gap-3">
                  <select v-model="statusFilter" class="px-4 py-3 border border-slate-300 rounded-lg text-sm text-slate-700 bg-white focus:outline-none focus:ring-2 focus:ring-green-500 min-w-[140px]">
                    <option value="">All Status</option>
                    <option value="completed">Completed</option>
                    <option value="ongoing">Ongoing</option>
                    <option value="cancelled">Cancelled</option>
                  </select>

                  <input 
                    type="date" 
                    v-model="dateFilter"
                    class="px-4 py-3 border border-slate-300 rounded-lg text-sm text-slate-700 bg-white focus:outline-none focus:ring-2 focus:ring-green-500"
                  >

                  <button 
                    v-if="hasActiveFilters"
                    @click="clearFilters" 
                    class="px-4 py-3 bg-slate-100 text-slate-700 rounded-lg font-medium hover:bg-slate-200 transition-colors flex items-center gap-2"
                  >
                    <i class="fas fa-times"></i>
                    <span class="hidden sm:inline">Clear</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Trips List -->
          <div v-if="loading" class="bg-white rounded-xl border border-slate-200 shadow-sm p-16 text-center">
            <div class="inline-block p-4 bg-green-50 rounded-full mb-4">
              <i class="fas fa-spinner fa-spin text-4xl text-green-600"></i>
            </div>
            <p class="text-slate-600 font-medium">Loading trips...</p>
          </div>

          <div v-else-if="filteredTrips.length === 0" class="bg-white rounded-xl border border-slate-200 shadow-sm p-16 text-center">
            <div class="inline-block p-5 bg-slate-100 rounded-full mb-4">
              <i class="fas fa-route text-5xl text-slate-400"></i>
            </div>
            <h3 class="text-xl font-semibold text-slate-800 mb-2">No trips found</h3>
            <p class="text-slate-600 mb-6">
              {{ hasActiveFilters ? 'Try adjusting your filters or search terms' : 'Start by adding your first trip for this vehicle' }}
            </p>
            <button
              v-if="!hasActiveFilters"
              @click="openAddModal"
              class="inline-flex items-center gap-2 bg-gradient-to-br from-green-800 to-green-700 text-white px-6 py-3 rounded-lg font-semibold hover:bg-green-700 transition-colors"
            >
              <i class="fas fa-plus"></i>
              Add First Trip
            </button>
          </div>

          <!-- Trip Cards -->
          <div v-else class="space-y-4">
            <div v-for="trip in filteredTrips" :key="trip.id" 
                 class="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all overflow-hidden group">
              
              <!-- Trip Header -->
              <div class="p-3 border-b border-slate-100 bg-gradient-to-br from-green-800/90 to-green-700/80">
                <div class="flex flex-col sm:flex-row jus tify-between items-start gap-3">
                  <div class="flex items-start gap-4 flex-1">
                    <!-- Status Icon -->
                    <div class="p-3 rounded-xl shrink-0" :class="{
                      'bg-green-100': trip.status === 'completed',
                      'bg-amber-100': trip.status === 'ongoing',
                      'bg-red-100': trip.status === 'cancelled'
                    }">
                      <i class="text-xl" :class="{
                        'fas fa-check-circle text-green-600': trip.status === 'completed',
                        'fas fa-spinner text-amber-600': trip.status === 'ongoing',
                        'fas fa-ban text-red-600': trip.status === 'cancelled'
                      }"></i>
                    </div>
                    
                    <!-- Trip Info -->
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-2 mb-2">
                        <h3 class="text-lg font-semibold text-white truncate">{{ trip.origin }}</h3>
                        <i class="fas fa-arrow-right text-slate-400 text-sm shrink-0"></i>
                        <h3 class="text-lg font-semibold text-green-400 truncate">{{ trip.destination }}</h3>
                      </div>
                      <div class="flex flex-wrap items-center gap-3 text-sm text-white">
                        <span class="flex items-center gap-1.5">
                          <i class="far fa-calendar"></i>
                          {{ formatDate(trip.start_time) }}
                        </span>
                        <span v-if="trip.driver_name" class="flex items-center gap-1.5">
                          <i class="far fa-user"></i>
                          {{ trip.driver_name }}
                        </span>
                      </div>
                    </div>
                  </div>
                  
                  <!-- Status Badge -->
                  <span class="px-3 py-1.5 rounded-full text-xs font-bold uppercase tracking-wide shrink-0" :class="{
                    'bg-green-100 text-green-700': trip.status === 'completed',
                    'bg-amber-100 text-amber-700': trip.status === 'ongoing',
                    'bg-red-100 text-red-700': trip.status === 'cancelled'
                  }">
                    {{ trip.status }}
                  </span>
                </div>
              </div>

              <!-- Trip Details -->
              <div class="p-3">
                <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-4">
                  <div class="space-y-1">
                    <div class="text-xs font-medium text-slate-500 uppercase tracking-wide">Distance</div>
                    <div class="text-md font-bold text-slate-800">{{ trip.distance || 0 }} km</div>
                  </div>
                  <div class="space-y-1">
                    <div class="text-xs font-medium text-slate-500 uppercase tracking-wide">Duration</div>
                    <div class="text-md font-bold text-slate-800">{{ formatDuration(trip.start_time, trip.end_time) }}</div>
                  </div>
                  <div class="space-y-1">
                    <div class="text-xs font-medium text-slate-500 uppercase tracking-wide">Purpose</div>
                    <div class="text-sm font-semibold text-slate-700 capitalize">{{ trip.purpose || 'General' }}</div>
                  </div>
                  <div class="space-y-1">
                    <div class="text-xs font-medium text-slate-500 uppercase tracking-wide">Driver</div>
                    <div class="text-sm font-semibold text-slate-700 truncate">{{ trip.driver_name || 'Unassigned' }}</div>
                  </div>
                </div>

                <!-- Notes -->
                <div v-if="trip.notes" class="p-4 bg-slate-50 rounded-lg border-l-4 border-green-600 mb-4">
                  <div class="text-xs font-semibold text-slate-600 uppercase tracking-wide mb-1">Trip Notes</div>
                  <p class="text-sm text-slate-700 leading-relaxed">{{ trip.notes }}</p>
                </div>

                <!-- Actions -->
                <div class="flex gap-2 pt-4 border-t justify-end  border-slate-100">
                  <button 
                    @click="viewTripDetails(trip)" 
                    class="flex-1 sm:flex-none px-4 py-2.5 bg-blue-50 text-blue-700 border border-blue-200 rounded-lg font-medium hover:bg-blue-100 transition-colors flex items-center justify-center gap-2"
                  >
                    <i class="fas fa-eye"></i>
                    <span class="hidden sm:inline">View Details</span>
                    <span class="sm:hidden">View</span>
                  </button>
                  <button   
                    @click="editTrip(trip)" 
                    class="flex-1 sm:flex-none px-4 py-2.5 bg-slate-50 text-slate-700 border border-slate-200 rounded-lg font-medium hover:bg-slate-100 transition-colors flex items-center justify-center gap-2"
                  >
                    <i class="fas fa-edit"></i>
                    <span class="hidden sm:inline">Edit</span>
                    <span class="sm:hidden">Edit</span>
                  </button>
                  <button 
                    @click="deleteTrip(trip)" 
                    class="px-4 py-2.5 bg-red-50 text-red-700 border border-red-200 rounded-lg font-medium hover:bg-red-100 transition-colors flex items-center justify-center gap-2"
                  >
                    <i class="fas fa-trash"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Add/Edit Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden shadow-2xl">
        <!-- Modal Header -->
        <div class="relative py-6 px-8 bg-gradient-to-br from-green-800 to-green-600 text-white p-6 flex justify-between items-center">
          <div class="flex items-center gap-3">
            <div class="p-2 bg-white/20 rounded-lg">
              <i class="fas fa-route text-xl"></i>
            </div>
            <h3 class="text-xl font-bold">{{ editingTrip ? 'Edit Trip' : 'Add New Trip' }}</h3>
          </div>
          <button class="p-2 hover:bg-white/20 rounded-lg transition-colors" @click="closeModal">
            <i class="fas fa-times text-xl"></i>
          </button>
        </div>

        <!-- Modal Content -->
        <form @submit.prevent="submitForm" class="p-6 overflow-y-auto max-h-[calc(90vh-88px)]">
          <!-- Route Information -->
          <div class="mb-6">
            <h4 class="text-sm font-bold text-slate-700 uppercase tracking-wide mb-4 flex items-center gap-2">
              <i class="fas fa-map-marked-alt text-green-600"></i>
              Route Information
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Origin Location *</label>
                <input 
                  type="text" 
                  v-model="tripForm.origin" 
                  required 
                  placeholder="Starting point"
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
              </div>
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Destination *</label>
                <input 
                  type="text" 
                  v-model="tripForm.destination" 
                  required 
                  placeholder="End point"
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
              </div>
            </div>
          </div>

          <!-- Time Information -->
          <div class="mb-6">
            <h4 class="text-sm font-bold text-slate-700 uppercase tracking-wide mb-4 flex items-center gap-2">
              <i class="fas fa-clock text-green-600"></i>
              Schedule
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Start Date & Time *</label>
                <input 
                  type="datetime-local" 
                  v-model="tripForm.start_time" 
                  required 
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
              </div>
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">End Date & Time</label>
                <input 
                  type="datetime-local" 
                  v-model="tripForm.end_time" 
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
              </div>
            </div>
          </div>

          <!-- Trip Details -->
          <div class="mb-6">
            <h4 class="text-sm font-bold text-slate-700 uppercase tracking-wide mb-4 flex items-center gap-2">
              <i class="fas fa-info-circle text-green-600"></i>
              Trip Details
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Assigned Driver</label>
                <select 
                  v-model="tripForm.driver_id" 
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent bg-white"
                >
                  <option value="">Select a driver</option>
                  <option v-for="driver in drivers" :key="driver.id" :value="driver.id">
                    {{ driver.full_name }}
                  </option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Distance (kilometers)</label>
                <input 
                  type="number" 
                  v-model.number="tripForm.distance" 
                  step="0.1" 
                  min="0"
                  placeholder="0.0"
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
              </div>
              
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Trip Purpose</label>
                <select 
                  v-model="tripForm.purpose" 
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent bg-white"
                >
                  <option value="">Select purpose</option>
                  <option value="official">Official Business</option>
                  <option value="transport">Personnel Transport</option>
                  <option value="delivery">Delivery</option>
                  <option value="maintenance">Maintenance</option>
                  <option value="emergency">Emergency</option>
                  <option value="other">Other</option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Trip Status</label>
                <select 
                  v-model="tripForm.status" 
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent bg-white"
                >
                  <option value="ongoing">Ongoing</option>
                  <option value="completed">Completed</option>
                  <option value="cancelled">Cancelled</option>
                </select>
              </div>
            </div>
          </div>
          

          <!-- Notes -->
          <div class="mb-6">
            <label class="block text-sm font-semibold text-slate-700 mb-2">Additional Notes</label>
            <textarea 
              v-model="tripForm.notes" 
              rows="4" 
              placeholder="Add any relevant information about this trip..."
              class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent resize-none"
            ></textarea>
          </div>

          <!-- Form Actions -->
          <div class="flex gap-3 pt-6 border-t border-slate-200">
            <button 
              type="button" 
              @click="closeModal" 
              class="flex-1 px-6 py-3 bg-slate-100 text-slate-700 rounded-lg font-semibold hover:bg-slate-200 transition-colors"
            >
              Cancel
            </button>
            <button 
              type="submit" 
              class="flex-1 px-6 py-3 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-lg font-semibold hover:from-green-700 hover:to-green-800 transition-all shadow-lg disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2" 
              :disabled="submitting"
            >
              <i v-if="submitting" class="fas fa-spinner fa-spin"></i>
              <i v-else class="fas fa-save"></i>
              {{ editingTrip ? 'Update Trip' : 'Create Trip' }}
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

    const sidebarCollapsed = ref(false)
    const sidebarOpen = ref(true)
    const trips = ref([])
    const vehicleInfo = ref(null)
    const drivers = ref([])
    const loading = ref(true)
    const searchQuery = ref('')
    const statusFilter = ref('')
    const dateFilter = ref('')
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
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', { 
        month: 'short', 
        day: 'numeric', 
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
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
      } finally {
        loading.value = false
      }
    }

    const loadDrivers = async () => {
      try {
        const { data, error } = await supabase
          .from('drivers')
          .select('id, employee_id, full_name')
          .eq('is_active', true)
          .order('full_name')

        if (error) throw error
        drivers.value = data || []
      } catch (error) {
        console.error('Error loading drivers:', error)
        drivers.value = []
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
      console.log('View trip details:', trip)
    }

    const deleteTrip = async (trip) => {
      if (!confirm('Are you sure you want to delete this trip?')) return

      try {
        const { error } = await supabase
          .from('trips')
          .delete()
          .eq('id', trip.id)
        
        if (error) throw error
        
        trips.value = trips.value.filter(t => t.id !== trip.id)
      } catch (error) {
        console.error('Error deleting trip:', error)
        alert('Error deleting trip: ' + error.message)
      }
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
      deleteTrip,
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
  background: #f1f5f9;
  border-radius: 4px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 4px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}
</style>
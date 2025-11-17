<template>
  <div class="flex h-screen bg-gradient-to-br from-green-50 via-emerald-100 to-teal-100 font-inter">
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
      <header class="sticky top-0 z-50 bg-gradient-to-br from-green-800 to-green-600 text-white shadow-lg">
        <div class="px-4 sm:px-6 py-4">
          <div class="flex items-center justify-between flex-wrap gap-4">
            <div class="flex items-center gap-3">
              <button
                @click="openSidebar"
                v-if="!sidebarOpen"
                class="lg:hidden bg-green-800 text-white py-2.5 px-3 rounded-lg hover:bg-green-700 transition-colors"
              >
                <i class="fas fa-bars"></i>
              </button>
              <div>
                <h1 class="text-xl sm:text-2xl font-bold">Fuel Logs</h1>
                <p class="text-xs sm:text-sm text-green-100 mt-0.5">
                  Track and manage fuel consumption
                </p>
              </div>
            </div>
          </div>
        </div>
      </header>

      <!-- Main Content -->
      <div class="flex-1 p-4 sm:p-6 lg:p-8 overflow-y-auto bg-gradient-to-br from-green-50/70 to-emerald-100/70">
        <div class="max-w-7xl mx-auto">
          
          <!-- Statistics Cards -->
          <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-6 sm:mb-8">
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg text-center"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="text-2xl sm:text-3xl font-bold mb-2" style="color: #0A400C;">{{ fuelStats.totalLogs }}</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Total Logs</div>
            </div>
            
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg text-center"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="text-2xl sm:text-3xl font-bold mb-2 text-blue-600">{{ fuelStats.totalLiters }}L</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Total Liters</div>
            </div>
            
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg text-center"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="text-2xl sm:text-3xl font-bold mb-2 text-green-600">₱{{ fuelStats.totalCost }}</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Total Cost</div>
            </div>
            
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg text-center"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="text-2xl sm:text-3xl font-bold mb-2 text-orange-600">₱{{ fuelStats.avgCostPerLiter }}</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Avg Cost/L</div>
            </div>
          </div>

          <!-- Filters Section -->
          <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6">
            <div class="flex flex-col lg:flex-row gap-4">
              <div class="flex-1 relative">
                <i class="fas fa-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                <input
                  type="text"
                  v-model="searchQuery"
                  placeholder="Search by vehicle plate, driver, trip..."
                  class="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent"
                >
              </div>

              <div class="flex items-center gap-2 flex-wrap">
                <select v-model="vehicleFilter" class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors text-sm">
                  <option value="">All Vehicles</option>
                  <option v-for="vehicle in vehicles" :key="vehicle.id" :value="vehicle.id">
                    {{ vehicle.plate_number }}
                  </option>
                </select>

                <input 
                  type="date" 
                  v-model="dateFilter"
                  class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors text-sm"
                >

                <button 
                  @click="clearFilters"
                  class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  <i class="fas fa-times mr-2"></i>
                  <span class="hidden sm:inline">Clear</span>
                </button>

                <button 
                  @click="openAddModal"
                  class="bg-gradient-to-br from-green-800 to-green-700 text-white py-2 px-4 rounded-lg font-medium flex items-center justify-center gap-2 hover:from-green-700 hover:to-green-800 transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 whitespace-nowrap"
                >
                  <i class="fas fa-plus"></i>
                  <span class="hidden sm:inline">Add Fuel Log</span>
                </button>
              </div>
            </div>
          </div>

          <!-- Fuel Logs Content -->
          <div v-if="loading" class="text-center py-16 bg-white/90 backdrop-blur-xl rounded-2xl shadow-lg"
               style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
            <i class="fas fa-spinner fa-spin text-5xl mb-5" style="color: #0A400C;"></i>
            <span class="text-slate-600 text-base font-medium">Loading fuel logs...</span>
          </div>

          <div v-else-if="filteredLogs.length === 0" class="text-center py-16 bg-white/90 backdrop-blur-xl rounded-2xl shadow-lg"
               style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
            <i class="fas fa-gas-pump text-7xl mb-5" style="color: rgba(10, 64, 12, 0.3);"></i>
            <h3 class="text-2xl mb-2.5" style="color: #0A400C;">No fuel logs found</h3>
            <p class="text-slate-600 mb-6">{{ hasActiveFilters ? 'Try adjusting your search criteria' : 'No fuel logs recorded yet.' }}</p>
            <button
              v-if="!hasActiveFilters"
              @click="openAddModal"
              class="bg-gradient-to-br text-white border-none py-3 px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg text-sm hover:-translate-y-0.5 hover:shadow-xl mx-auto"
              style="background: linear-gradient(135deg, #0A400C, #155c1a); box-shadow: 0 10px 25px rgba(10, 64, 12, 0.3);"
            >
              <i class="fas fa-plus"></i>
              Add First Fuel Log
            </button>
          </div>

          <!-- Fuel Logs Table/Cards -->
          <div v-else class="bg-white/90 backdrop-blur-xl rounded-2xl shadow-lg overflow-hidden"
               style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
            
            <!-- Desktop Table View -->
            <div class="hidden lg:block overflow-x-auto">
              <table class="w-full">
                <thead>
                  <tr class="bg-gradient-to-br text-white"
                      style="background: linear-gradient(135deg, #0A400C, #155c1a);">
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">Date</th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">Vehicle</th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">Driver</th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">Liters</th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">Cost</th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">Odometer</th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">Trip</th>
                    <th class="px-6 py-4 text-center text-xs font-semibold uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                  <tr v-for="log in filteredLogs" :key="log.id" class="hover:bg-gray-50 transition-colors">
                    <td class="px-6 py-4 text-sm text-gray-900">{{ formatDate(log.created_at) }}</td>
                    <td class="px-6 py-4 text-sm">
                      <div class="font-medium text-gray-900">{{ getVehiclePlate(log.vehicle_id) }}</div>
                      <div class="text-gray-500 text-xs">{{ getVehicleDetails(log.vehicle_id) }}</div>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-900">{{ log.driver_name || 'N/A' }}</td>
                    <td class="px-6 py-4 text-sm font-medium text-blue-600">{{ log.liters }}L</td>
                    <td class="px-6 py-4 text-sm font-medium text-green-600">₱{{ log.cost || 'N/A' }}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">{{ log.odometer || 'N/A' }}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">{{ log.trip_reference || 'General' }}</td>
                    <td class="px-6 py-4 text-center">
                      <div class="flex items-center justify-center gap-2">
                        <button @click="editLog(log)" class="text-amber-600 hover:text-amber-800 transition-colors">
                          <i class="fas fa-edit"></i>
                        </button>
                        <button @click="confirmDelete(log)" class="text-red-600 hover:text-red-800 transition-colors">
                          <i class="fas fa-trash"></i>
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Mobile Card View -->
            <div class="lg:hidden divide-y divide-gray-200">
              <div v-for="log in filteredLogs" :key="log.id" class="p-4">
                <div class="flex justify-between items-start mb-3">
                  <div>
                    <div class="font-semibold text-gray-900">{{ getVehiclePlate(log.vehicle_id) }}</div>
                    <div class="text-sm text-gray-600">{{ formatDate(log.created_at) }}</div>
                  </div>
                  <div class="flex gap-2">
                    <button @click="editLog(log)" class="w-8 h-8 bg-amber-500/10 text-amber-600 rounded-lg flex items-center justify-center">
                      <i class="fas fa-edit text-xs"></i>
                    </button>
                    <button @click="confirmDelete(log)" class="w-8 h-8 bg-red-500/10 text-red-600 rounded-lg flex items-center justify-center">
                      <i class="fas fa-trash text-xs"></i>
                    </button>
                  </div>
                </div>
                
                <div class="grid grid-cols-2 gap-3 text-sm">
                  <div>
                    <span class="text-gray-500">Liters:</span>
                    <span class="font-medium text-blue-600 ml-1">{{ log.liters }}L</span>
                  </div>
                  <div>
                    <span class="text-gray-500">Cost:</span>
                    <span class="font-medium text-green-600 ml-1">₱{{ log.cost || 'N/A' }}</span>
                  </div>
                  <div>
                    <span class="text-gray-500">Driver:</span>
                    <span class="font-medium ml-1">{{ log.driver_name || 'N/A' }}</span>
                  </div>
                  <div>
                    <span class="text-gray-500">Odometer:</span>
                    <span class="font-medium ml-1">{{ log.odometer || 'N/A' }}</span>
                  </div>
                </div>
                
                <div v-if="log.trip_reference" class="mt-2 text-sm">
                  <span class="text-gray-500">Trip:</span>
                  <span class="font-medium ml-1">{{ log.trip_reference }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Add/Edit Fuel Log Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm">
      <div class="bg-white rounded-2xl p-0 w-11/12 max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl">
        <div class="py-6 px-8 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br text-white rounded-t-2xl"
             style="background: linear-gradient(135deg, #0A400C, #155c1a);">
          <h3 class="m-0 text-xl font-semibold">{{ editingLog ? 'Edit Fuel Log' : 'Add New Fuel Log' }}</h3>
          <button class="bg-white/10 border-none text-white w-8 h-8 rounded-lg cursor-pointer flex items-center justify-center transition-colors duration-200 hover:bg-white/20" @click="closeModal">
            <i class="fas fa-times"></i>
          </button>
        </div>

        <form @submit.prevent="submitForm" class="p-8">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Vehicle *</label>
              <select v-model="form.vehicle_id" required class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                      style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                <option value="">Select Vehicle</option>
                <option v-for="vehicle in vehicles" :key="vehicle.id" :value="vehicle.id">
                  {{ vehicle.plate_number }} - {{ vehicle.make }} {{ vehicle.model }}
                </option>
              </select>
            </div>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Trip (Optional)</label>
              <select v-model="form.trip_id" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                      style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                <option value="">General Fuel</option>
                <option v-for="trip in trips" :key="trip.id" :value="trip.id">
                  {{ getVehiclePlate(trip.vehicle_id) }} - {{ trip.origin }} → {{ trip.destination }}
                </option>
              </select>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Liters *</label>
              <input type="number" v-model.number="form.liters" step="0.01" required 
                     placeholder="e.g., 50.5"
                     class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                     style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
            </div>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Cost (₱)</label>
              <input type="number" v-model.number="form.cost" step="0.01"
                     placeholder="e.g., 2500.00"
                     class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                     style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Odometer Reading</label>
              <input type="number" v-model.number="form.odometer"
                     placeholder="e.g., 45000"
                     class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                     style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
            </div>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Driver</label>
              <select v-model="form.driver_id" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                      style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                <option value="">Select Driver</option>
                <option v-for="driver in drivers" :key="driver.id" :value="driver.id">
                  {{ driver.full_name }} ({{ driver.employee_id }})
                </option>
              </select>
            </div>
          </div>

          <div class="flex flex-col gap-2 mb-5">
            <label class="font-semibold text-gray-700 text-sm">Station/Location</label>
            <input type="text" v-model="form.station"
                   placeholder="e.g., Shell Station EDSA"
                   class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                   style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
          </div>

          <div class="flex flex-col gap-2 mb-5">
            <label class="font-semibold text-gray-700 text-sm">Notes</label>
            <textarea v-model="form.notes" rows="3"
                      placeholder="Additional notes or remarks..."
                      class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white resize-y min-h-20 focus:outline-none focus:ring-4"
                      style="--tw-ring-color: rgba(10, 64, 12, 0.1);"></textarea>
          </div>

          <div class="flex gap-4 justify-end mt-8 pt-5 border-t border-gray-200">
            <button type="button" @click="closeModal" class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2.5 px-4 rounded-lg cursor-pointer font-medium flex items-center gap-1.5 transition-all duration-200 text-sm hover:bg-slate-500/20 hover:text-slate-700">
              Cancel
            </button>
            <button type="submit" class="bg-gradient-to-br text-white border-none py-3 px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg text-sm hover:-translate-y-0.5 hover:shadow-xl disabled:opacity-60 disabled:cursor-not-allowed disabled:transform-none" 
                    style="background: linear-gradient(135deg, #0A400C, #155c1a); box-shadow: 0 10px 25px rgba(10, 64, 12, 0.3);"
                    :disabled="submitting">
              <i v-if="submitting" class="fas fa-spinner fa-spin"></i>
              {{ editingLog ? 'Update Log' : 'Add Log' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="logToDelete" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm">
      <div class="bg-white rounded-2xl p-0 w-11/12 max-w-md shadow-2xl">
        <div class="py-6 px-8 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br from-red-500 to-red-600 text-white rounded-t-2xl">
          <h3 class="m-0 text-xl font-semibold">Confirm Deletion</h3>
          <button class="bg-white/10 border-none text-white w-8 h-8 rounded-lg cursor-pointer flex items-center justify-center transition-colors duration-200 hover:bg-white/20" @click="logToDelete = null">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8 text-center">
          <p class="text-lg text-gray-700 mb-6">Are you sure you want to delete this fuel log? This action cannot be undone.</p>
          <div class="flex gap-4 justify-center">
            <button @click="logToDelete = null" class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2.5 px-4 rounded-lg cursor-pointer font-medium flex items-center gap-1.5 transition-all duration-200 text-sm hover:bg-slate-500/20 hover:text-slate-700">
              Cancel
            </button>
            <button @click="deleteLog" class="bg-gradient-to-br from-red-500 to-red-600 text-white border-none py-3 px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg shadow-red-500/30 text-sm hover:from-red-600 hover:to-red-700 hover:-translate-y-0.5 hover:shadow-xl hover:shadow-red-500/40">
              <i class="fas fa-trash"></i>
              Delete Log
            </button>
          </div>
        </div>
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
  name: 'FuelLogs',
  components: { Navbar },
  setup() {
    const router = useRouter()
    const route = useRoute()

    // Sidebar state
    const sidebarCollapsed = ref(false)
    const sidebarOpen = ref(true)

    // Data
    const fuelLogs = ref([])
    const vehicles = ref([])
    const trips = ref([])
    const drivers = ref([])
    const loading = ref(true)

    // Filters
    const searchQuery = ref('')
    const vehicleFilter = ref('')
    const dateFilter = ref('')

    // Modal state
    const showModal = ref(false)
    const editingLog = ref(null)
    const submitting = ref(false)
    const logToDelete = ref(null)

    const form = reactive({
      vehicle_id: '',
      trip_id: '',
      liters: null,
      cost: null,
      odometer: null,
      driver_id: '',
      station: '',
      notes: ''
    })

    // Computed
    const filteredLogs = computed(() => {
      let filtered = fuelLogs.value

      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        filtered = filtered.filter(log =>
          getVehiclePlate(log.vehicle_id).toLowerCase().includes(query) ||
          (log.driver_name && log.driver_name.toLowerCase().includes(query)) ||
          (log.station && log.station.toLowerCase().includes(query))
        )
      }

      if (vehicleFilter.value) {
        filtered = filtered.filter(log => log.vehicle_id === vehicleFilter.value)
      }

      if (dateFilter.value) {
        filtered = filtered.filter(log => 
          log.created_at && log.created_at.startsWith(dateFilter.value)
        )
      }

      return filtered.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
    })

    const hasActiveFilters = computed(() => {
      return searchQuery.value || vehicleFilter.value || dateFilter.value
    })

    const fuelStats = computed(() => {
      const logs = fuelLogs.value
      const totalLogs = logs.length
      const totalLiters = logs.reduce((sum, log) => sum + (log.liters || 0), 0).toFixed(1)
      const totalCost = logs.reduce((sum, log) => sum + (log.cost || 0), 0).toFixed(2)
      const avgCostPerLiter = totalLiters > 0 ? (totalCost / totalLiters).toFixed(2) : '0.00'
      
      return { totalLogs, totalLiters, totalCost, avgCostPerLiter }
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

    const getVehiclePlate = (vehicleId) => {
      const vehicle = vehicles.value.find(v => v.id === vehicleId)
      return vehicle ? vehicle.plate_number : 'Unknown'
    }

    const getVehicleDetails = (vehicleId) => {
      const vehicle = vehicles.value.find(v => v.id === vehicleId)
      return vehicle ? `${vehicle.make} ${vehicle.model}` : ''
    }

    const loadData = async () => {
      loading.value = true
      try {
        // Load vehicles
        const { data: vehiclesData, error: vehiclesError } = await supabase
          .from('vehicles')
          .select('*')
          .order('plate_number')
        
        if (vehiclesError) throw vehiclesError
        vehicles.value = vehiclesData

        // Load trips
        const { data: tripsData, error: tripsError } = await supabase
          .from('trips')
          .select('*')
          .order('created_at', { ascending: false })
          .limit(50)
        
        if (tripsError) throw tripsError
        trips.value = tripsData

        // Load drivers
        const { data: driversData, error: driversError } = await supabase
          .from('drivers')
          .select('id, full_name, employee_id')
          .eq('is_active', true)
          .order('full_name')
        
        if (driversError) throw driversError
        drivers.value = driversData

        // Load fuel logs
        const { data: logsData, error: logsError } = await supabase
          .from('fuel_logs')
          .select(`
            *,
            drivers:driver_id (full_name)
          `)
          .order('created_at', { ascending: false })
          .limit(100)
        
        if (logsError) throw logsError
        
        fuelLogs.value = logsData.map(log => ({
          ...log,
          driver_name: log.drivers?.full_name || null
        }))

      } catch (error) {
        console.error('Error loading data:', error)
        // Sample data for demo
        vehicles.value = [
          { id: 1, plate_number: 'ABC-1234', make: 'Toyota', model: 'Camry' },
          { id: 2, plate_number: 'XYZ-7890', make: 'Ford', model: 'Transit' }
        ]
        
        drivers.value = [
          { id: 'driver1', full_name: 'John Doe', employee_id: 'EMP001' },
          { id: 'driver2', full_name: 'Jane Smith', employee_id: 'EMP002' }
        ]
        
        trips.value = [
          { id: 1, vehicle_id: 1, origin: 'Main Office', destination: 'Branch Office' },
          { id: 2, vehicle_id: 2, origin: 'Branch Office', destination: 'Client Site' }
        ]
        
        fuelLogs.value = [
          {
            id: 1,
            vehicle_id: 1,
            liters: 50.5,
            cost: 2525.00,
            odometer: 45000,
            driver_name: 'John Doe',
            station: 'Shell EDSA',
            created_at: new Date().toISOString(),
            trip_reference: 'Main Office → Branch Office'
          },
          {
            id: 2,
            vehicle_id: 2,
            liters: 75.0,
            cost: 3750.00,
            odometer: 32000,
            driver_name: 'Jane Smith',
            station: 'Petron BGC',
            created_at: new Date(Date.now() - 86400000).toISOString(),
            trip_reference: 'General'
          }
        ]
      } finally {
        loading.value = false
      }
    }

    const openAddModal = () => {
      editingLog.value = null
      resetForm()
      showModal.value = true
    }

    const closeModal = () => {
      showModal.value = false
      editingLog.value = null
      resetForm()
    }

    const resetForm = () => {
      Object.assign(form, {
        vehicle_id: '',
        trip_id: '',
        liters: null,
        cost: null,
        odometer: null,
        driver_id: '',
        station: '',
        notes: ''
      })
    }

    const editLog = (log) => {
      editingLog.value = log
      Object.assign(form, {
        vehicle_id: log.vehicle_id,
        trip_id: log.trip_id || '',
        liters: log.liters,
        cost: log.cost,
        odometer: log.odometer,
        driver_id: log.driver_id || '',
        station: log.station || '',
        notes: log.notes || ''
      })
      showModal.value = true
    }

    const submitForm = async () => {
      submitting.value = true
      try {
        const logData = {
          vehicle_id: form.vehicle_id,
          trip_id: form.trip_id || null,
          liters: form.liters,
          cost: form.cost || null,
          odometer: form.odometer || null,
          driver_id: form.driver_id || null,
          station: form.station || null,
          notes: form.notes || null
        }

        if (editingLog.value) {
          const { error } = await supabase
            .from('fuel_logs')
            .update(logData)
            .eq('id', editingLog.value.id)
          
          if (error) throw error
          
          // Update local data
          const index = fuelLogs.value.findIndex(log => log.id === editingLog.value.id)
          if (index !== -1) {
            const driver = drivers.value.find(d => d.id === form.driver_id)
            fuelLogs.value[index] = {
              ...editingLog.value,
              ...logData,
              driver_name: driver ? driver.full_name : null
            }
          }
        } else {
          const { data, error } = await supabase
            .from('fuel_logs')
            .insert(logData)
            .select()
            .single()
          
          if (error) throw error
          
          const driver = drivers.value.find(d => d.id === form.driver_id)
          fuelLogs.value.unshift({
            ...data,
            driver_name: driver ? driver.full_name : null
          })
        }

        closeModal()
      } catch (error) {
        console.error('Error submitting fuel log:', error)
        alert('Error: ' + error.message)
      } finally {
        submitting.value = false
      }
    }

    const confirmDelete = (log) => {
      logToDelete.value = log
    }

    const deleteLog = async () => {
      if (!logToDelete.value) return
      
      try {
        const { error } = await supabase
          .from('fuel_logs')
          .delete()
          .eq('id', logToDelete.value.id)
        
        if (error) throw error

        fuelLogs.value = fuelLogs.value.filter(log => log.id !== logToDelete.value.id)
        logToDelete.value = null
      } catch (error) {
        console.error('Error deleting fuel log:', error)
        alert('Error deleting fuel log: ' + error.message)
      }
    }

    const clearFilters = () => {
      searchQuery.value = ''
      vehicleFilter.value = ''
      dateFilter.value = ''
    }

    onMounted(async () => {
      await loadData()
    })

    return {
      sidebarCollapsed,
      sidebarOpen,
      toggleSidebar,
      closeSidebar,
      openSidebar,
      handleMenuClick,
      fuelLogs,
      vehicles,
      trips,
      drivers,
      loading,
      searchQuery,
      vehicleFilter,
      dateFilter,
      filteredLogs,
      hasActiveFilters,
      fuelStats,
      showModal,
      editingLog,
      submitting,
      logToDelete,
      form,
      formatDate,
      getVehiclePlate,
      getVehicleDetails,
      openAddModal,
      closeModal,
      editLog,
      submitForm,
      confirmDelete,
      deleteLog,
      clearFilters,
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
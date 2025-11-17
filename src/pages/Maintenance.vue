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
                <h1 class="text-xl sm:text-2xl font-bold">Maintenance Schedule</h1>
                <p class="text-xs sm:text-sm text-green-100 mt-0.5">
                  Schedule and track vehicle maintenance
                </p>
              </div>
            </div>
          </div>
        </div>
      </header>

      <!-- Main Content -->
      <div class="flex-1 p-3 sm:p-4 lg:p-6 overflow-y-auto bg-gradient-to-br from-green-50/70 to-emerald-100/70">
        <div class="max-w-7xl mx-auto">
          <!-- Stats Cards -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 sm:gap-4 mb-4 sm:mb-6">
            <div class="bg-white/90 backdrop-blur-xl p-4 rounded-lg shadow-lg border-l-4" style="border-left-color: #0A400C; box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="text-gray-600 text-xs sm:text-sm font-medium mb-1">Total Vehicles</div>
              <div class="text-2xl sm:text-3xl font-bold" style="color: #0A400C;">{{ vehicles.length }}</div>
            </div>
            <div class="bg-white/90 backdrop-blur-xl p-4 rounded-lg shadow-lg border-l-4 border-amber-500" style="box-shadow: 0 10px 25px rgba(245, 158, 11, 0.1);">
              <div class="text-gray-600 text-xs sm:text-sm font-medium mb-1">Due Soon (7 days)</div>
              <div class="text-2xl sm:text-3xl font-bold text-amber-600">{{ dueSoon }}</div>
            </div>
            <div class="bg-white/90 backdrop-blur-xl p-4 rounded-lg shadow-lg border-l-4 border-red-500" style="box-shadow: 0 10px 25px rgba(239, 68, 68, 0.1);">
              <div class="text-gray-600 text-xs sm:text-sm font-medium mb-1">Overdue</div>
              <div class="text-2xl sm:text-3xl font-bold text-red-600">{{ overdue }}</div>
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
                  placeholder="Search by plate, type, or service..."
                  class="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent"
                >
              </div>

              <div class="flex items-center gap-2 flex-wrap">
                <select v-model="filterStatus" class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors text-sm">
                  <option value="">All Status</option>
                  <option value="overdue">Overdue</option>
                  <option value="due-soon">Due Soon</option>
                  <option value="up-to-date">Up to Date</option>
                </select>

                <select v-model="filterType" class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors text-sm">
                  <option value="">All Types</option>
                  <option value="car">Car</option>
                  <option value="van">Van</option>
                  <option value="truck">Truck</option>
                  <option value="suv">SUV</option>
                  <option value="motorcycle">Motorcycle</option>
                  <option value="bus">Bus</option>
                </select>

                <button 
                  @click="clearFilters" 
                  class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  <i class="fas fa-times mr-2"></i>
                  <span class="hidden sm:inline">Clear</span>
                </button>

                <button 
                  @click="showAddModal = true"
                  class="bg-gradient-to-br from-green-800 to-green-700 text-white py-2 px-4 rounded-lg font-medium flex items-center justify-center gap-2 hover:from-green-700 hover:to-green-800 transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 whitespace-nowrap"
                >
                  <i class="fas fa-plus"></i>
                  <span class="hidden sm:inline">Add Schedule</span>
                </button>
              </div>
            </div>
          </div>

          <!-- Maintenance Cards Grid -->
          <div class="maintenance-content">
            <!-- Empty State -->
            <div v-if="filteredMaintenanceData.length === 0" class="text-center py-12 sm:py-16 bg-white/90 backdrop-blur-xl rounded-lg shadow-lg"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <i class="fas fa-wrench text-4xl sm:text-6xl mb-4" style="color: rgba(10, 64, 12, 0.3);"></i>
              <h3 class="text-lg sm:text-xl mb-2" style="color: #0A400C;">No maintenance schedules found</h3>
              <p class="text-slate-600 mb-4 text-sm sm:text-base">Start by creating your first maintenance schedule</p>
              <button
                @click="showAddModal = true"
                class="bg-gradient-to-br text-white border-none py-2.5 px-4 rounded-lg cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg text-sm hover:-translate-y-0.5 hover:shadow-xl mx-auto"
                style="background: linear-gradient(135deg, #0A400C, #155c1a); box-shadow: 0 10px 25px rgba(10, 64, 12, 0.3);"
              >
                <i class="fas fa-plus"></i>
                Create First Schedule
              </button>
            </div>

            <!-- Maintenance Cards -->
            <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5">
              <div
                v-for="maintenance in filteredMaintenanceData"
                :key="maintenance.id"
                class="bg-white/95 backdrop-blur-xl rounded-lg shadow-lg border-t-4 transition-all duration-300 overflow-hidden hover:shadow-xl hover:-translate-y-1"
                :style="{ 'border-top-color': getStatusColor(maintenance.status), 'box-shadow': '0 10px 25px rgba(10, 64, 12, 0.1)' }"
              >
                <!-- Vehicle Info Header -->
                <div class="p-4 sm:p-5 pb-3" style="background: linear-gradient(to right, rgba(10, 64, 12, 0.05), rgba(10, 64, 12, 0.02));">
                  <div class="flex justify-between items-start mb-2">
                    <div>
                      <h3 class="text-base sm:text-lg font-bold" style="color: #0A400C;">{{ maintenance.vehicle_plate }}</h3>
                      <p class="text-xs sm:text-sm text-gray-600">{{ maintenance.vehicle_type }}</p>
                    </div>
                    <span
                      class="px-2 sm:px-3 py-1 text-xs font-semibold text-white rounded-full"
                      :style="{ 'background-color': getStatusColor(maintenance.status) }"
                    >
                      {{ formatStatus(maintenance.status) }}
                    </span>
                  </div>
                </div>

                <!-- Maintenance Details -->
                <div class="px-4 sm:px-5 py-3 sm:py-4 border-t border-gray-200">
                  <div class="space-y-2 sm:space-y-2.5">
                    <div class="flex items-start text-xs sm:text-sm">
                      <span class="font-medium text-gray-600 w-20 sm:w-24 flex-shrink-0">Service:</span>
                      <span class="font-semibold" style="color: #0A400C;">{{ maintenance.service_type }}</span>
                    </div>
                    <div class="flex items-start text-xs sm:text-sm">
                      <span class="font-medium text-gray-600 w-20 sm:w-24 flex-shrink-0">Last Done:</span>
                      <span>{{ formatDate(maintenance.last_service_date) }}</span>
                    </div>
                    <div class="flex items-start text-xs sm:text-sm">
                      <span class="font-medium text-gray-600 w-20 sm:w-24 flex-shrink-0">Due Date:</span>
                      <span class="font-semibold">{{ formatDate(maintenance.next_due_date) }}</span>
                    </div>
                    <div class="flex items-start text-xs sm:text-sm">
                      <span class="font-medium text-gray-600 w-20 sm:w-24 flex-shrink-0">Interval:</span>
                      <span>Every {{ maintenance.interval_days }} days</span>
                    </div>
                    <div class="flex items-start text-xs sm:text-sm">
                      <span class="font-medium text-gray-600 w-20 sm:w-24 flex-shrink-0">Cost:</span>
                      <span class="font-semibold" style="color: #0A400C;">₱{{ maintenance.estimated_cost }}</span>
                    </div>
                    <div v-if="maintenance.notes" class="flex items-start text-xs sm:text-sm">
                      <span class="font-medium text-gray-600 w-20 sm:w-24 flex-shrink-0">Notes:</span>
                      <span class="text-gray-700">{{ maintenance.notes }}</span>
                    </div>
                  </div>
                </div>

                <!-- Actions -->
                <div class="px-4 sm:px-5 py-3 bg-gray-50 flex gap-2">
                  <button
                    @click="editMaintenance(maintenance)"
                    class="flex-1 px-2 sm:px-3 py-1.5 sm:py-2 text-xs sm:text-sm font-medium text-white rounded-lg transition-all hover:scale-105"
                    style="background-color: #0A400C;"
                  >
                    Edit
                  </button>
                  <button
                    @click="markAsCompleted(maintenance.id)"
                    class="flex-1 px-2 sm:px-3 py-1.5 sm:py-2 text-xs sm:text-sm font-medium rounded-lg border-2 transition-all hover:scale-105"
                    style="color: #0A400C; border-color: #0A400C; background-color: white;"
                  >
                    Done
                  </button>
                  <button
                    @click="deleteMaintenance(maintenance.id)"
                    class="flex-1 px-2 sm:px-3 py-1.5 sm:py-2 text-xs sm:text-sm font-medium text-white rounded-lg bg-red-600 hover:bg-red-700 transition-all hover:scale-105"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Add/Edit Modal -->
    <div v-if="showAddModal" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm p-4">
      <div class="bg-white rounded-lg shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div class="py-4 px-6 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br text-white rounded-t-lg"
             style="background: linear-gradient(135deg, #0A400C, #155c1a);">
          <h3 class="m-0 text-lg font-semibold">
            {{ editingId ? 'Edit Maintenance Schedule' : 'Add Maintenance Schedule' }}
          </h3>
          <button @click="closeModal" class="bg-white/10 border-none text-white w-7 h-7 rounded-md cursor-pointer flex items-center justify-center transition-colors duration-200 hover:bg-white/20">
            <i class="fas fa-times text-sm"></i>
          </button>
        </div>

        <form @submit.prevent="saveMaintenance" class="p-6 space-y-4">
          <!-- Select Vehicle -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Select Vehicle *</label>
            <select
              v-model="formData.vehicle_id"
              class="w-full py-2.5 px-3 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-4"
              style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
              :style="{ 'border-color': formData.vehicle_id ? '#0A400C' : '' }"
              required
            >
              <option value="">-- Select a vehicle --</option>
              <option v-for="vehicle in availableVehicles" :key="vehicle.id" :value="vehicle.id">
                {{ vehicle.plate_number }} - {{ vehicle.vehicle_type }}
              </option>
            </select>
          </div>

          <!-- Service Type -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Service Type *</label>
            <select
              v-model="formData.service_type"
              class="w-full py-2.5 px-3 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-4"
              style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
              :style="{ 'border-color': formData.service_type ? '#0A400C' : '' }"
              required
            >
              <option value="">-- Select service --</option>
              <option>Oil Change</option>
              <option>Tire Rotation</option>
              <option>Filter Replacement</option>
              <option>Brake Service</option>
              <option>Battery Check</option>
              <option>Transmission Fluid</option>
              <option>Coolant Check</option>
              <option>Air Filter</option>
              <option>Spark Plugs</option>
              <option>General Inspection</option>
            </select>
          </div>

          <!-- Last Service Date -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Last Service Date *</label>
            <input
              v-model="formData.last_service_date"
              type="date"
              class="w-full py-2.5 px-3 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-4"
              style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
              :style="{ 'border-color': formData.last_service_date ? '#0A400C' : '' }"
              required
            />
          </div>

          <!-- Interval Days -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Interval (days) *</label>
            <input
              v-model="formData.interval_days"
              type="number"
              placeholder="e.g., 90 for every 3 months"
              class="w-full py-2.5 px-3 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-4"
              style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
              :style="{ 'border-color': formData.interval_days ? '#0A400C' : '' }"
              required
            />
          </div>

          <!-- Estimated Cost -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Estimated Cost (₱)</label>
            <input
              v-model="formData.estimated_cost"
              type="number"
              step="0.01"
              placeholder="0.00"
              class="w-full py-2.5 px-3 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-4"
              style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
              :style="{ 'border-color': formData.estimated_cost ? '#0A400C' : '' }"
            />
          </div>

          <!-- Notes -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Notes</label>
            <textarea
              v-model="formData.notes"
              placeholder="Additional maintenance notes..."
              class="w-full py-2.5 px-3 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-4 resize-y min-h-16"
              style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
              rows="3"
            ></textarea>
          </div>

          <!-- Buttons -->
          <div class="flex gap-3 pt-4 border-t border-gray-200">
            <button
              type="button"
              @click="closeModal"
              class="flex-1 bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2.5 px-4 rounded-lg cursor-pointer font-medium transition-all duration-200 text-sm hover:bg-slate-500/20"
            >
              Cancel
            </button>
            <button
              type="submit"
              :disabled="submitting"
              class="flex-1 text-white border-none py-2.5 px-4 rounded-lg cursor-pointer font-semibold transition-all duration-300 shadow-lg text-sm hover:-translate-y-0.5 hover:shadow-xl disabled:opacity-50 disabled:cursor-not-allowed"
              style="background: linear-gradient(135deg, #0A400C, #155c1a); box-shadow: 0 10px 25px rgba(10, 64, 12, 0.3);"
            >
              <i v-if="submitting" class="fas fa-spinner fa-spin mr-2"></i>
              {{ editingId ? 'Update Schedule' : 'Create Schedule' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { supabase } from '../lib/supabase'
import Navbar from './Navbar.vue'

export default {
  name: 'Maintenance',
  components: {
    Navbar
  },
  setup() {
    // Sidebar state
    const sidebarCollapsed = ref(false)
    const sidebarOpen = ref(true)
    const userProfile = ref(null)

    // Data state
    const vehicles = ref([])
    const maintenance = ref([])
    const showAddModal = ref(false)
    const editingId = ref(null)
    const submitting = ref(false)
    const searchQuery = ref('')
    const filterStatus = ref('')
    const filterType = ref('')

    const formData = ref({
      vehicle_id: '',
      service_type: '',
      last_service_date: '',
      interval_days: '',
      estimated_cost: '',
      notes: ''
    })

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

    const handleResize = () => {
      const width = window.innerWidth
      if (width <= 768) {
        sidebarOpen.value = false
        sidebarCollapsed.value = false
      } else {
        sidebarOpen.value = true
      }
    }

    // Load user profile
    const loadUserProfile = async () => {
      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (user) {
          const { data: profile } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .single()
          
          userProfile.value = profile || { full_name: 'Admin User', role: 'admin' }
        }
      } catch (error) {
        console.error('Error loading user profile:', error)
      }
    }

    // Fetch vehicles
    const loadVehicles = async () => {
      try {
        const { data, error } = await supabase
          .from('vehicles')
          .select('*')
          .order('plate_number')
        
        if (error) throw error
        vehicles.value = data || []
      } catch (error) {
        console.error('Error loading vehicles:', error)
        // Sample data for demo
        vehicles.value = [
          { id: 1, plate_number: 'ABC-1234', vehicle_type: 'car' },
          { id: 2, plate_number: 'XYZ-7890', vehicle_type: 'van' }
        ]
      }
    }

    // Fetch maintenance data
    const loadMaintenance = async () => {
      try {
        const { data, error } = await supabase
          .from('maintenance')
          .select(`
            *,
            vehicles:vehicle_id(id, plate_number, vehicle_type)
          `)
          .order('next_due_date', { ascending: true })
        
        if (error) throw error
        
        // Recalculate status for each record based on current date
        if (data) {
          maintenance.value = data.map(record => ({
            ...record,
            status: calculateStatus(record.next_due_date)
          }))
          
          // Update database with recalculated statuses (fire and forget)
          data.forEach(record => {
            const newStatus = calculateStatus(record.next_due_date)
            if (newStatus !== record.status) {
              supabase
                .from('maintenance')
                .update({ status: newStatus })
                .eq('id', record.id)
                .then(() => {})
                .catch(err => console.error('Error auto-updating status:', err))
            }
          })
        } else {
          maintenance.value = []
        }
      } catch (error) {
        console.error('Error loading maintenance:', error)
        maintenance.value = []
      }
    }

    // Computed properties
    const availableVehicles = computed(() => vehicles.value)

    const filteredMaintenanceData = computed(() => {
      return maintenance.value
        .map(m => ({
          ...m,
          vehicle_plate: m.vehicles?.plate_number || 'Unknown',
          vehicle_type: m.vehicles?.vehicle_type || 'Unknown'
        }))
        .filter(m => {
          const matchSearch =
            m.vehicle_plate.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
            m.vehicle_type.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
            m.service_type.toLowerCase().includes(searchQuery.value.toLowerCase())
          
          const matchStatus = !filterStatus.value || m.status === filterStatus.value
          const matchType = !filterType.value || m.vehicle_type === filterType.value
          
          return matchSearch && matchStatus && matchType
        })
    })

    const dueSoon = computed(() => {
      const today = new Date()
      const sevenDaysAhead = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000)
      
      return maintenance.value.filter(m => {
        const dueDate = new Date(m.next_due_date)
        return dueDate <= sevenDaysAhead && dueDate > today && m.status !== 'completed'
      }).length
    })

    const overdue = computed(() => {
      const today = new Date()
      return maintenance.value.filter(m => {
        const dueDate = new Date(m.next_due_date)
        return dueDate < today && m.status !== 'completed'
      }).length
    })

    // Utility methods
    const getStatusColor = (status) => {
      if (status === 'overdue') return '#ef4444'
      if (status === 'due-soon') return '#f59e0b'
      return '#10b981'
    }

    const formatStatus = (status) => {
      if (status === 'overdue') return 'Overdue'
      if (status === 'due-soon') return 'Due Soon'
      if (status === 'up-to-date') return 'Up to Date'
      return status
    }

    const formatDate = (dateString) => {
      if (!dateString) return ''
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }

    // Helper function to calculate status based on due date
    const calculateStatus = (nextDueDate) => {
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const dueDate = new Date(nextDueDate)
      dueDate.setHours(0, 0, 0, 0)
      
      if (dueDate < today) {
        return 'overdue'
      } else if (dueDate <= new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000)) {
        return 'due-soon'
      } else {
        return 'up-to-date'
      }
    }

    // CRUD operations
    const saveMaintenance = async () => {
      submitting.value = true
      try {
        const nextDueDate = new Date(formData.value.last_service_date)
        nextDueDate.setDate(nextDueDate.getDate() + parseInt(formData.value.interval_days))
        const nextDueDateStr = nextDueDate.toISOString().split('T')[0]

        const payload = {
          vehicle_id: formData.value.vehicle_id,
          service_type: formData.value.service_type,
          last_service_date: formData.value.last_service_date,
          next_due_date: nextDueDateStr,
          interval_days: parseInt(formData.value.interval_days),
          estimated_cost: parseFloat(formData.value.estimated_cost) || 0,
          notes: formData.value.notes,
          status: calculateStatus(nextDueDateStr)
        }

        if (editingId.value) {
          const { error } = await supabase
            .from('maintenance')
            .update(payload)
            .eq('id', editingId.value)
          
          if (error) throw error
        } else {
          const { error } = await supabase
            .from('maintenance')
            .insert([payload])
          
          if (error) throw error
        }

        closeModal()
        await loadMaintenance()
      } catch (error) {
        console.error('Error saving maintenance:', error)
        alert('Error saving maintenance schedule: ' + error.message)
      } finally {
        submitting.value = false
      }
    }

const editMaintenance = (m) => {
  editingId.value = m.id
  formData.value = {
    vehicle_id: m.vehicle_id,
    service_type: m.service_type,
    last_service_date: m.last_service_date,
    interval_days: m.interval_days,
    estimated_cost: m.estimated_cost,
    notes: m.notes || ''
  }
  showAddModal.value = true
}

const markAsCompleted = async (id) => {
  try {
    // Get the maintenance record first to know the interval
    const maintenanceRecord = maintenance.value.find(m => m.id === id)
    if (!maintenanceRecord) {
      alert('Maintenance record not found')
      return
    }

    // Calculate new dates
    const today = new Date()
    const todayStr = today.toISOString().split('T')[0]
    const nextDueDate = new Date(today)
    nextDueDate.setDate(nextDueDate.getDate() + maintenanceRecord.interval_days)
    const nextDueDateStr = nextDueDate.toISOString().split('T')[0]

    // Update with new dates and status
    const { error } = await supabase
      .from('maintenance')
      .update({ 
        last_service_date: todayStr,
        next_due_date: nextDueDateStr,
        status: calculateStatus(nextDueDateStr)
      })
      .eq('id', id)
    
    if (error) throw error
    await loadMaintenance()
    alert('Maintenance marked as completed! Next service scheduled.')
  } catch (error) {
    console.error('Error updating maintenance:', error)
    alert('Error marking as completed: ' + error.message)
  }
}

const deleteMaintenance = async (id) => {
  if (!confirm('Are you sure you want to delete this maintenance schedule?')) return
  
  try {
    const { error } = await supabase
      .from('maintenance')
      .delete()
      .eq('id', id)
    
    if (error) throw error
    await loadMaintenance()
  } catch (error) {
    console.error('Error deleting maintenance:', error)
  }
}

const closeModal = () => {
  showAddModal.value = false
  editingId.value = null
  formData.value = {
    vehicle_id: '',
    service_type: '',
    last_service_date: '',
    interval_days: '',
    estimated_cost: '',
    notes: '',
  }
}

// Lifecycle - Load data when component mounts
onMounted(async () => {
  await loadVehicles()
  await loadMaintenance()
  await loadUserProfile()
  window.addEventListener('resize', handleResize)
  handleResize()
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
})

return {
      // Sidebar
      sidebarCollapsed,
      sidebarOpen,
      userProfile,
      toggleSidebar,
      closeSidebar,
      openSidebar,
      handleMenuClick,
      handleResize,
      
      // Data & Filtering
      vehicles,
      maintenance,
      showAddModal,
      submitting,
      searchQuery,
      filterStatus,
      filterType,
      formData,

      // Computed
      availableVehicles,
      filteredMaintenanceData,
      dueSoon,
      overdue,

      // Methods
      getStatusColor,
      formatStatus,
      formatDate,
      saveMaintenance,
      editMaintenance,
      markAsCompleted,
      deleteMaintenance,
      closeModal,
      }
    }
 }
</script>

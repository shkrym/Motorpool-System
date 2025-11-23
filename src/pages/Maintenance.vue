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
      <div class="sticky top-0 z-50">
        <PageHeader
          icon="fas fa-tools"
          title="Maintenance Schedule"
          subtitle="Schedule and track vehicle maintenance"
        >
          <template #leading>
            <button
              @click="openSidebar"
              v-if="!sidebarOpen"
              class="lg:hidden btn btn-secondary"
            >
              <i class="fas fa-bars"></i>
            </button>
          </template>
        </PageHeader>
      </div>

      <!-- Main Content -->
      <div class="flex-1 p-3 sm:p-4 lg:p-6 overflow-y-auto bg-gradient-to-br from-green-50/70 to-emerald-100/70">
        <div class="max-w-7xl mx-auto">
          <!-- Stats Cards -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 sm:gap-6 mb-6">
            <div class="glass-card p-5">
              <div class="flex items-center justify-between mb-2">
                <div class="stat-card-icon bg-emerald-100 text-emerald-600">
                  <i class="fas fa-warehouse"></i>
                </div>
              </div>
              <div class="text-2xl sm:text-3xl font-bold text-slate-900">{{ vehicles.length }}</div>
              <p class="text-xs uppercase tracking-wide text-slate-500 mt-1">Total Vehicles</p>
            </div>
            <div class="glass-card p-5">
              <div class="flex items-center justify-between mb-2">
                <div class="stat-card-icon bg-amber-100 text-amber-600">
                  <i class="fas fa-hourglass-half"></i>
                </div>
              </div>
              <div class="text-2xl sm:text-3xl font-bold text-amber-600">{{ dueSoon }}</div>
              <p class="text-xs uppercase tracking-wide text-slate-500 mt-1">Due (7 days)</p>
            </div>
            <div class="glass-card p-5">
              <div class="flex items-center justify-between mb-2">
                <div class="stat-card-icon bg-red-100 text-red-600">
                  <i class="fas fa-triangle-exclamation"></i>
                </div>
              </div>
              <div class="text-2xl sm:text-3xl font-bold text-red-600">{{ overdue }}</div>
              <p class="text-xs uppercase tracking-wide text-slate-500 mt-1">Overdue</p>
            </div>
          </div>

          <!-- Filters Section -->
          <div class="glass-card p-4 sm:p-5 mb-6">
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
                  class="btn btn-primary whitespace-nowrap"
                >
                  <i class="fas fa-plus"></i>
                  <span class="hidden sm:inline">Add Schedule</span>
                  <span class="sm:hidden">New</span>
                </button>
              </div>
            </div>
          </div>

          <!-- Maintenance Cards Grid -->
          <div class="maintenance-content">
            <!-- Empty State -->
            <div v-if="filteredMaintenanceData.length === 0" class="glass-card text-center py-12 sm:py-16">
              <i class="fas fa-wrench text-4xl sm:text-6xl mb-4 text-emerald-100"></i>
              <h3 class="text-lg sm:text-xl mb-2 text-slate-900">No maintenance schedules found</h3>
              <p class="text-slate-600 mb-4 text-sm sm:text-base">Start by creating your first maintenance schedule</p>
              <button
                @click="showAddModal = true"
                class="btn btn-primary mx-auto text-sm"
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
                class="glass-card p-6 hover:-translate-y-1 transition-all duration-300"
              >
                <div class="flex justify-between items-start mb-4">
                  <div class="flex items-center gap-3">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-green-500 to-green-700 text-white flex items-center justify-center">
                      <i class="fas fa-car-side"></i>
                    </div>
                    <div>
                      <h3 class="text-base sm:text-lg font-bold text-slate-900">{{ maintenance.vehicle_plate }}</h3>
                      <p class="text-xs sm:text-sm text-slate-500">{{ maintenance.vehicle_type }}</p>
                    </div>
                  </div>
                  <span class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold"
                        :class="getScheduleBadge(maintenance.status)">
                    <span class="w-2 h-2 rounded-full" :class="getScheduleDot(maintenance.status)"></span>
                    {{ formatScheduleStatus(maintenance.status) }}
                  </span>
                </div>

                <div class="my-4 p-3 rounded-xl bg-slate-50 border border-white/50">
                  <div class="flex items-center justify-between text-sm text-slate-600 mb-2">
                    <span>Next Service Due</span>
                    <span class="font-semibold text-slate-900">{{ formatDate(maintenance.next_due_date || maintenance.next_service_due) }}</span>
                  </div>
                  <div class="flex items-center gap-3 text-sm">
                    <div class="flex items-center gap-1 text-emerald-600 font-semibold">
                      <i class="fas fa-calendar-check"></i>
                      {{ calculateDaysUntil(maintenance.next_due_date || maintenance.next_service_due) }} days left
                    </div>
                    <span class="text-xs px-2 py-0.5 rounded-full" :class="getUrgencyPill(maintenance.next_due_date || maintenance.next_service_due)">
                      {{ getUrgencyLabel(maintenance.next_due_date || maintenance.next_service_due) }}
                    </span>
                  </div>
                </div>

                <div class="grid grid-cols-2 gap-3 text-sm text-slate-600 mb-3">
                  <div>
                    <p class="text-xs uppercase text-slate-400">Service Type</p>
                    <p class="font-semibold text-slate-900">{{ maintenance.service_type }}</p>
                  </div>
                  <div>
                    <p class="text-xs uppercase text-slate-400">Interval</p>
                    <p class="font-semibold text-slate-900">{{ maintenance.interval_days }} days</p>
                  </div>
                  <div>
                    <p class="text-xs uppercase text-slate-400">Estimated Cost</p>
                    <p class="font-semibold text-slate-900">₱{{ maintenance.estimated_cost?.toLocaleString() || '0' }}</p>
                  </div>
                  <div>
                    <p class="text-xs uppercase text-slate-400">Last Service</p>
                    <p class="font-semibold text-slate-900">{{ formatDate(maintenance.last_service_date) }}</p>
                  </div>
                </div>

                <div v-if="maintenance.notes" class="mb-4 p-3 rounded-xl bg-amber-50/80 text-amber-900 text-sm border border-amber-100">
                  <i class="fas fa-sticky-note mr-2"></i>
                  {{ maintenance.notes }}
                </div>

                <div class="flex items-center gap-1.5 sm:gap-2 flex-nowrap overflow-x-auto">
                  <button
                    @click="editMaintenance(maintenance)"
                    class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-medium bg-blue-50 text-blue-600 hover:bg-blue-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0"
                  >
                    <i class="fas fa-edit text-xs sm:text-sm"></i>
                    <span class="hidden sm:inline text-xs font-medium">Edit</span>
                  </button>
                  <button
                    @click="markAsCompleted(maintenance.id)"
                    class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-medium bg-green-50 text-green-600 hover:bg-green-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0"
                  >
                    <i class="fas fa-check-circle text-xs sm:text-sm"></i>
                    <span class="hidden sm:inline text-xs font-medium">Mark Done</span>
                  </button>
                  <button
                    @click="deleteMaintenance(maintenance.id)"
                    class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-medium bg-red-50 text-red-600 hover:bg-red-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0"
                  >
                    <i class="fas fa-trash text-xs sm:text-sm"></i>
                    <span class="hidden sm:inline text-xs font-medium">Delete</span>
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
import { useToast } from '../composables/useToast'
import { useSidebar } from '../composables/useSidebar'
import Navbar from './Navbar.vue'
import PageHeader from '../components/PageHeader.vue'

export default {
  name: 'Maintenance',
  components: {
    Navbar,
    PageHeader
  },
  setup() {
    const { success, error, warning } = useToast()
    // Sidebar state
    const { sidebarCollapsed, sidebarOpen, toggleSidebar, closeSidebar, openSidebar, handleMenuClick } = useSidebar()
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

    // Sidebar methods are now from useSidebar composable

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

    const formatScheduleStatus = (status) => formatStatus(status)

    const getScheduleBadge = (status) => {
      if (status === 'overdue') return 'bg-red-50 text-red-600 border border-red-100'
      if (status === 'due-soon') return 'bg-amber-50 text-amber-600 border border-amber-100'
      if (status === 'completed') return 'bg-emerald-50 text-emerald-600 border border-emerald-100'
      return 'bg-emerald-50 text-emerald-600 border border-emerald-100'
    }

    const getScheduleDot = (status) => {
      if (status === 'overdue') return 'bg-red-500'
      if (status === 'due-soon') return 'bg-amber-500'
      if (status === 'completed') return 'bg-emerald-500'
      return 'bg-emerald-500'
    }

    const calculateDaysUntil = (dateString) => {
      if (!dateString) return 0
      const today = new Date()
      const due = new Date(dateString)
      const diff = Math.ceil((due - today) / (1000 * 60 * 60 * 24))
      return diff < 0 ? 0 : diff
    }

    const getUrgencyPill = (dateString) => {
      const status = calculateStatus(dateString)
      if (status === 'overdue') return 'bg-red-100 text-red-700'
      if (status === 'due-soon') return 'bg-amber-100 text-amber-700'
      return 'bg-emerald-100 text-emerald-700'
    }

    const getUrgencyLabel = (dateString) => {
      const status = calculateStatus(dateString)
      if (status === 'overdue') return 'Overdue'
      if (status === 'due-soon') return 'Due soon'
      return 'Scheduled'
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

        // Show success message BEFORE closing modal (so editingId is still set)
        success(editingId.value ? 'Maintenance schedule updated successfully!' : 'Maintenance schedule created successfully!')
        closeModal()
        await loadMaintenance()
      } catch (err) {
        console.error('Error saving maintenance:', err)
        error('Error saving maintenance schedule: ' + err.message)
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
      warning('Maintenance record not found')
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
    success('Maintenance marked as completed! Next service scheduled.')
  } catch (error) {
    console.error('Error updating maintenance:', error)
    error('Error marking as completed: ' + error.message)
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
    success('Maintenance schedule deleted successfully!')
  } catch (err) {
    console.error('Error deleting maintenance:', err)
    error('Error deleting maintenance: ' + err.message)
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
      formatScheduleStatus,
      getScheduleBadge,
      getScheduleDot,
      calculateDaysUntil,
      getUrgencyPill,
      getUrgencyLabel,
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

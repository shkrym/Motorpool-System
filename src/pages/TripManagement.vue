<template>
  <div>
    <!-- Toolbar -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6">
      <div class="flex flex-col sm:flex-row gap-4">
        <div class="flex-1 relative">
          <i class="fas fa-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
          <input
            type="text"
            v-model="searchQuery"
            placeholder="Search trips by ID, vehicle, driver, or destination..."
            class="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent"
          />
        </div>
        <select v-model="statusFilter" class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C]">
          <option value="">All Status</option>
          <option value="pending">Pending</option>
          <option value="approved">Approved</option>
          <option value="in_progress">In Progress</option>
          <option value="completed">Completed</option>
          <option value="cancelled">Cancelled</option>
        </select>
        <button 
          @click="openAddModal"
          class="flex items-center gap-2 bg-[#0A400C] text-white px-5 py-2.5 rounded-lg hover:bg-[#155c1a] transition-all shadow-md whitespace-nowrap"
        >
          <i class="fas fa-plus"></i>
          <span class="hidden sm:inline">Create Trip</span>
          <span class="sm:hidden">New</span>
        </button>
      </div>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-2 sm:grid-cols-5 gap-4 mb-6">
      <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm">
        <p class="text-sm text-gray-600 mb-1">Total</p>
        <p class="text-3xl font-bold text-gray-900">{{ trips.length }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm">
        <p class="text-sm text-gray-600 mb-1">Pending</p>
        <p class="text-3xl font-bold text-amber-600">{{ tripsByStatus('pending') }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm">
        <p class="text-sm text-gray-600 mb-1">In Progress</p>
        <p class="text-3xl font-bold text-blue-600">{{ tripsByStatus('in_progress') }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm">
        <p class="text-sm text-gray-600 mb-1">Completed</p>
        <p class="text-3xl font-bold text-emerald-600">{{ tripsByStatus('completed') }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm">
        <p class="text-sm text-gray-600 mb-1">Cancelled</p>
        <p class="text-3xl font-bold text-red-600">{{ tripsByStatus('cancelled') }}</p>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="text-center py-16 bg-white rounded-xl shadow-sm">
      <i class="fas fa-spinner fa-spin text-5xl mb-5 text-[#0A400C]"></i>
      <p class="text-gray-600">Loading trips...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredTrips.length === 0" class="text-center py-16 bg-white rounded-xl shadow-sm">
      <i class="fas fa-route text-7xl mb-5 text-gray-300"></i>
      <h3 class="text-2xl font-bold text-gray-900 mb-2">No trips found</h3>
      <p class="text-gray-600">{{ hasActiveFilters ? 'Try adjusting your filters' : 'Start by creating your first trip' }}</p>
    </div>

    <!-- Trips Grid -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      <div
        v-for="trip in filteredTrips"
        :key="trip.id"
        class="bg-white rounded-xl border border-gray-200 hover:shadow-lg transition-all p-5"
      >
        <div class="flex items-start justify-between mb-4">
          <div>
            <h3 class="text-lg font-bold text-gray-900">{{ trip.trip_id }}</h3>
            <p class="text-sm text-gray-600">{{ getVehicleDisplay(trip.vehicle_id) }}</p>
          </div>
          <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold"
                :class="getTripStatusColor(trip.status)">
            {{ formatTripStatus(trip.status) }}
          </span>
        </div>
        
        <div class="space-y-2 mb-4">
          <div class="flex items-center gap-2 text-sm">
            <i class="fas fa-user w-4 text-gray-400"></i>
            <span class="text-gray-700">{{ getDriverDisplay(trip.driver_id) }}</span>
          </div>
          <div class="flex items-center gap-2 text-sm">
            <i class="fas fa-map-marker-alt w-4 text-gray-400"></i>
            <span class="text-gray-700">{{ trip.destination }}</span>
          </div>
          <div class="flex items-center gap-2 text-sm">
            <i class="fas fa-calendar w-4 text-gray-400"></i>
            <span class="text-gray-700">{{ formatDateTime(trip.start_time) }}</span>
          </div>
          <div v-if="trip.purpose" class="flex items-center gap-2 text-sm">
            <i class="fas fa-info-circle w-4 text-gray-400"></i>
            <span class="text-gray-700 truncate">{{ trip.purpose }}</span>
          </div>
        </div>

        <div class="flex gap-2">
          <button 
            @click="viewTrip(trip)"
            class="flex-1 py-2 px-3 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 text-sm font-medium transition-colors"
          >
            <i class="fas fa-eye mr-1"></i>
            View
          </button>
          <button 
            v-if="trip.status === 'pending'"
            @click="approveTrip(trip)"
            class="flex-1 py-2 px-3 rounded-lg bg-emerald-50 text-emerald-600 hover:bg-emerald-100 text-sm font-medium transition-colors"
          >
            <i class="fas fa-check mr-1"></i>
            Approve
          </button>
          <button 
            v-if="trip.status === 'approved'"
            @click="startTrip(trip)"
            class="flex-1 py-2 px-3 rounded-lg bg-teal-50 text-teal-600 hover:bg-teal-100 text-sm font-medium transition-colors"
          >
            <i class="fas fa-play mr-1"></i>
            Start
          </button>
          <button 
            v-if="trip.status === 'in_progress'"
            @click="completeTrip(trip)"
            class="py-2 px-3 rounded-lg bg-purple-50 text-purple-600 hover:bg-purple-100 text-sm font-medium transition-colors"
          >
            <i class="fas fa-flag-checkered"></i>
          </button>
          <button 
            v-if="['pending', 'approved'].includes(trip.status)"
            @click="editTrip(trip)"
            class="py-2 px-3 rounded-lg bg-amber-50 text-amber-600 hover:bg-amber-100 text-sm font-medium transition-colors"
          >
            <i class="fas fa-edit"></i>
          </button>
          <button 
            v-if="['pending', 'approved', 'in_progress'].includes(trip.status)"
            @click="confirmCancel(trip)"
            class="py-2 px-3 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 text-sm font-medium transition-colors"
          >
            <i class="fas fa-times"></i>
          </button>
        </div>
      </div>
    </div>

    <!-- Add/Edit Trip Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] backdrop-blur-sm p-4" @click.self="closeModal">
      <div class="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden shadow-2xl animate-modalSlideIn">
        <div class="relative py-6 px-8 bg-gradient-to-br from-green-800 to-green-600 text-white">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-2xl font-bold">{{ editingTrip ? 'Edit Trip' : 'Create New Trip' }}</h3>
              <p class="text-green-100 text-sm mt-1">{{ editingTrip ? 'Update trip information' : 'Schedule a new trip' }}</p>
            </div>
            <button 
              @click="closeModal" 
              class="w-10 h-10 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
            >
              <i class="fas fa-times text-lg"></i>
            </button>
          </div>
          <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400"></div>
        </div>

        <form @submit.prevent="submitForm" class="p-8 overflow-y-auto max-h-[calc(90vh-120px)]">
          <div class="space-y-6">
            
            <!-- Vehicle & Driver Selection -->
            <div class="bg-gray-50 rounded-xl p-5 border border-gray-200">
              <h4 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-4 flex items-center gap-2">
                <i class="fas fa-car text-[#0A400C]"></i>
                Vehicle & Driver
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 text-sm">Vehicle <span class="text-red-500">*</span></label>
                  <select 
                    v-model="form.vehicle_id" 
                    required
                    @change="onVehicleSelect"
                    class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] bg-white"
                  >
                    <option value="">Select a vehicle</option>
                    <option 
                      v-for="vehicle in availableVehicles" 
                      :key="vehicle.id" 
                      :value="vehicle.id"
                    >
                      {{ vehicle.vehicle_id }} - {{ vehicle.plate_number }} ({{ vehicle.vehicle_type }})
                    </option>
                  </select>
                  <p v-if="selectedVehicle" class="text-xs text-gray-600">
                    <i class="fas fa-info-circle mr-1"></i>
                    Status: <span :class="selectedVehicle.status === 'available' ? 'text-emerald-600' : 'text-amber-600'">
                      {{ formatStatus(selectedVehicle.status) }}
                    </span>
                  </p>
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 text-sm">Driver <span class="text-red-500">*</span></label>
                  <select 
                    v-model="form.driver_id" 
                    required
                    class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] bg-white"
                  >
                    <option value="">Select a driver</option>
                    <option 
                      v-for="driver in activeDrivers" 
                      :key="driver.id" 
                      :value="driver.id"
                    >
                      {{ driver.full_name }} ({{ driver.employee_id }})
                    </option>
                  </select>
                  <p v-if="selectedVehicle && selectedVehicle.assigned_driver_id" class="text-xs text-blue-600">
                    <i class="fas fa-star mr-1"></i>
                    Assigned: {{ getDriverNameById(selectedVehicle.assigned_driver_id) }}
                  </p>
                </div>
              </div>
            </div>

            <!-- Trip Schedule -->
            <div class="bg-gray-50 rounded-xl p-5 border border-gray-200">
              <h4 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-4 flex items-center gap-2">
                <i class="fas fa-clock text-[#0A400C]"></i>
                Trip Schedule
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 text-sm">Start Time <span class="text-red-500">*</span></label>
                  <input
                    type="datetime-local"
                    v-model="form.start_time"
                    required
                    class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C]"
                  />
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 text-sm">Expected End Time</label>
                  <input
                    type="datetime-local"
                    v-model="form.expected_end_time"
                    class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C]"
                  />
                </div>
              </div>
            </div>

            <!-- Trip Details -->
            <div class="bg-gray-50 rounded-xl p-5 border border-gray-200">
              <h4 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-4 flex items-center gap-2">
                <i class="fas fa-map-marked-alt text-[#0A400C]"></i>
                Trip Details
              </h4>
              <div class="space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                  <div class="flex flex-col gap-2">
                    <label class="font-semibold text-gray-700 text-sm">Origin</label>
                    <input
                      type="text"
                      v-model="form.origin"
                      placeholder="e.g., Main Office"
                      class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C]"
                    />
                  </div>
                  <div class="flex flex-col gap-2">
                    <label class="font-semibold text-gray-700 text-sm">Destination <span class="text-red-500">*</span></label>
                    <input
                      type="text"
                      v-model="form.destination"
                      placeholder="e.g., City Hall"
                      required
                      class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C]"
                    />
                  </div>
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 text-sm">Purpose <span class="text-red-500">*</span></label>
                  <input
                    type="text"
                    v-model="form.purpose"
                    placeholder="e.g., Official meeting, Document delivery"
                    required
                    class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C]"
                  />
                </div>
              </div>
            </div>

            <!-- Odometer Reading (for starting trip) -->
            <div v-if="editingTrip && editingTrip.status === 'approved'" class="bg-gray-50 rounded-xl p-5 border border-gray-200">
              <h4 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-4 flex items-center gap-2">
                <i class="fas fa-tachometer-alt text-[#0A400C]"></i>
                Odometer Reading
              </h4>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 text-sm">Start Odometer <span class="text-red-500">*</span></label>
                <input
                  type="number"
                  v-model="form.start_odometer"
                  placeholder="Current mileage"
                  required
                  class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C]"
                />
              </div>
            </div>

            <!-- Additional Notes -->
            <div class="bg-gray-50 rounded-xl p-5 border border-gray-200">
              <h4 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-4 flex items-center gap-2">
                <i class="fas fa-sticky-note text-[#0A400C]"></i>
                Additional Notes
              </h4>
              <div class="flex flex-col gap-2">
                <textarea
                  v-model="form.notes"
                  placeholder="Enter any additional notes or special instructions..."
                  rows="3"
                  class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] resize-y"
                ></textarea>
              </div>
            </div>

          </div>

          <div class="flex gap-4 justify-end mt-8 pt-6 border-t border-gray-200">
            <button 
              type="button" 
              @click="closeModal" 
              class="px-6 py-3 border-2 border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-all font-semibold"
            >
              Cancel
            </button>
            <button 
              type="submit" 
              :disabled="submitting" 
              class="flex items-center gap-2 bg-gradient-to-r from-[#0A400C] to-[#155c1a] text-white px-8 py-3 rounded-lg font-semibold hover:scale-105 transition-all shadow-lg disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:scale-100"
            >
              <i v-if="submitting" class="fas fa-spinner fa-spin"></i>
              <i v-else class="fas" :class="editingTrip ? 'fa-check' : 'fa-plus'"></i>
              {{ editingTrip ? 'Update Trip' : 'Create Trip' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- View Trip Modal -->
    <div v-if="selectedTrip" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] backdrop-blur-sm p-4" @click.self="selectedTrip = null">
      <div class="bg-white rounded-2xl w-full max-w-3xl max-h-[90vh] overflow-hidden shadow-2xl animate-modalSlideIn">
        <div class="relative py-5 px-8 bg-gradient-to-br from-green-800 to-green-600 text-white">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-2xl font-bold">{{ selectedTrip.trip_id }}</h3>
              <p class="text-green-100 text-base mt-1">Trip Details & Information</p>
            </div>
            <button 
              @click="selectedTrip = null" 
              class="w-10 h-10 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
            >
              <i class="fas fa-times text-lg"></i>
            </button>
          </div>
          <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400"></div>
        </div>

        <div class="p-5 overflow-y-auto max-h-[calc(90vh-140px)]">
          <div class="space-y-3">
            
            <!-- Status & Trip ID Row -->
            <div class="bg-gradient-to-br from-gray-50 to-white rounded-xl p-3 border border-gray-200">
              <div class="grid grid-cols-2 gap-2.5">
                <div class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <p class="text-xs text-gray-500 uppercase font-medium mb-0.5">Trip ID</p>
                  <p class="text-sm font-bold text-gray-900">{{ selectedTrip.trip_id }}</p>
                </div>
                <div class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <p class="text-xs text-gray-500 uppercase font-medium mb-0.5">Status</p>
                  <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold mt-0.5"
                        :class="getTripStatusColor(selectedTrip.status)">
                    <i class="fas fa-circle text-xs"></i>
                    {{ formatTripStatus(selectedTrip.status) }}
                  </span>
                </div>
              </div>
            </div>

            <!-- Vehicle & Driver Section -->
            <div class="bg-gradient-to-br from-blue-50 to-white rounded-xl p-3 border border-blue-100">
              <h4 class="text-xs font-semibold text-gray-600 uppercase tracking-wider mb-2.5 flex items-center gap-2">
                <i class="fas fa-car text-[#0A400C]"></i>
                Vehicle & Driver
              </h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                <div class="flex items-center gap-2.5 bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="w-9 h-9 rounded-lg bg-blue-50 flex items-center justify-center flex-shrink-0">
                    <i class="fas fa-car-side text-blue-600 text-sm"></i>
                  </div>
                  <div class="flex-1 min-w-0">
                    <p class="text-xs text-gray-500 uppercase font-medium">Vehicle</p>
                    <p class="text-sm font-bold text-gray-900 truncate">{{ getVehicleDisplay(selectedTrip.vehicle_id) }}</p>
                  </div>
                </div>
                <div class="flex items-center gap-2.5 bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="w-9 h-9 rounded-lg bg-purple-50 flex items-center justify-center flex-shrink-0">
                    <i class="fas fa-user text-purple-600 text-sm"></i>
                  </div>
                  <div class="flex-1 min-w-0">
                    <p class="text-xs text-gray-500 uppercase font-medium">Driver</p>
                    <p class="text-sm font-bold text-gray-900 truncate">{{ getDriverDisplay(selectedTrip.driver_id) }}</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Trip Route Section -->
            <div class="bg-gradient-to-br from-green-50 to-white rounded-xl p-3 border border-green-100">
              <h4 class="text-xs font-semibold text-gray-600 uppercase tracking-wider mb-2.5 flex items-center gap-2">
                <i class="fas fa-route text-[#0A400C]"></i>
                Trip Route
              </h4>
              <div class="space-y-2.5">
                <div class="flex items-start gap-2.5 bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="w-9 h-9 rounded-lg bg-green-50 flex items-center justify-center flex-shrink-0">
                    <i class="fas fa-map-marker-alt text-green-600 text-sm"></i>
                  </div>
                  <div class="flex-1">
                    <p class="text-xs text-gray-500 uppercase font-medium">Origin</p>
                    <p class="text-sm font-semibold text-gray-900">{{ selectedTrip.origin || 'Not specified' }}</p>
                  </div>
                </div>
                <div class="flex items-start gap-2.5 bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="w-9 h-9 rounded-lg bg-red-50 flex items-center justify-center flex-shrink-0">
                    <i class="fas fa-map-pin text-red-600 text-sm"></i>
                  </div>
                  <div class="flex-1">
                    <p class="text-xs text-gray-500 uppercase font-medium">Destination</p>
                    <p class="text-sm font-semibold text-gray-900">{{ selectedTrip.destination }}</p>
                  </div>
                </div>
                <div class="flex items-start gap-2.5 bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="w-9 h-9 rounded-lg bg-amber-50 flex items-center justify-center flex-shrink-0">
                    <i class="fas fa-clipboard-list text-amber-600 text-sm"></i>
                  </div>
                  <div class="flex-1">
                    <p class="text-xs text-gray-500 uppercase font-medium">Purpose</p>
                    <p class="text-sm font-semibold text-gray-900">{{ selectedTrip.purpose }}</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Schedule Section -->
            <div class="bg-gradient-to-br from-purple-50 to-white rounded-xl p-3 border border-purple-100">
              <h4 class="text-xs font-semibold text-gray-600 uppercase tracking-wider mb-2.5 flex items-center gap-2">
                <i class="fas fa-clock text-[#0A400C]"></i>
                Schedule
              </h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                <div class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="flex items-center gap-2 mb-0.5">
                    <i class="fas fa-calendar-check text-green-600 text-xs"></i>
                    <p class="text-xs text-gray-500 uppercase font-medium">Scheduled Start</p>
                  </div>
                  <p class="text-sm font-semibold text-gray-900">{{ formatDateTime(selectedTrip.start_time) }}</p>
                </div>
                <div v-if="selectedTrip.expected_end_time" class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="flex items-center gap-2 mb-0.5">
                    <i class="fas fa-calendar-times text-amber-600 text-xs"></i>
                    <p class="text-xs text-gray-500 uppercase font-medium">Expected End</p>
                  </div>
                  <p class="text-sm font-semibold text-gray-900">{{ formatDateTime(selectedTrip.expected_end_time) }}</p>
                </div>
                <div v-if="selectedTrip.actual_start_time" class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="flex items-center gap-2 mb-0.5">
                    <i class="fas fa-play-circle text-blue-600 text-xs"></i>
                    <p class="text-xs text-gray-500 uppercase font-medium">Actual Start</p>
                  </div>
                  <p class="text-sm font-semibold text-gray-900">{{ formatDateTime(selectedTrip.actual_start_time) }}</p>
                </div>
                <div v-if="selectedTrip.actual_end_time" class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="flex items-center gap-2 mb-0.5">
                    <i class="fas fa-stop-circle text-purple-600 text-xs"></i>
                    <p class="text-xs text-gray-500 uppercase font-medium">Actual End</p>
                  </div>
                  <p class="text-sm font-semibold text-gray-900">{{ formatDateTime(selectedTrip.actual_end_time) }}</p>
                </div>
              </div>
            </div>

            <!-- Passengers Section -->
            <div v-if="selectedTrip.passenger_name || selectedTrip.passenger_count || selectedTrip.passenger_department" class="bg-gradient-to-br from-teal-50 to-white rounded-xl p-3 border border-teal-100">
              <h4 class="text-xs font-semibold text-gray-600 uppercase tracking-wider mb-2.5 flex items-center gap-2">
                <i class="fas fa-users text-[#0A400C]"></i>
                Passenger Details
              </h4>
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-2.5">
                <div v-if="selectedTrip.passenger_name" class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <p class="text-xs text-gray-500 uppercase font-medium mb-0.5">Name</p>
                  <p class="text-sm font-semibold text-gray-900">{{ selectedTrip.passenger_name }}</p>
                </div>
                <div v-if="selectedTrip.passenger_count" class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <p class="text-xs text-gray-500 uppercase font-medium mb-0.5">Count</p>
                  <p class="text-sm font-semibold text-gray-900">{{ selectedTrip.passenger_count }}</p>
                </div>
                <div v-if="selectedTrip.passenger_department" class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <p class="text-xs text-gray-500 uppercase font-medium mb-0.5">Department</p>
                  <p class="text-sm font-semibold text-gray-900">{{ selectedTrip.passenger_department }}</p>
                </div>
              </div>
            </div>

            <!-- Trip Metrics Section -->
            <div v-if="selectedTrip.start_odometer || selectedTrip.end_odometer || selectedTrip.distance_km" class="bg-gradient-to-br from-indigo-50 to-white rounded-xl p-3 border border-indigo-100">
              <h4 class="text-xs font-semibold text-gray-600 uppercase tracking-wider mb-2.5 flex items-center gap-2">
                <i class="fas fa-tachometer-alt text-[#0A400C]"></i>
                Trip Metrics
              </h4>
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-2.5">
                <div v-if="selectedTrip.start_odometer" class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="flex items-center gap-2 mb-0.5">
                    <i class="fas fa-play text-green-600 text-xs"></i>
                    <p class="text-xs text-gray-500 uppercase font-medium">Start Odometer</p>
                  </div>
                  <p class="text-base font-bold text-gray-900">{{ selectedTrip.start_odometer }} <span class="text-xs text-gray-500">km</span></p>
                </div>
                <div v-if="selectedTrip.end_odometer" class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="flex items-center gap-2 mb-0.5">
                    <i class="fas fa-stop text-red-600 text-xs"></i>
                    <p class="text-xs text-gray-500 uppercase font-medium">End Odometer</p>
                  </div>
                  <p class="text-base font-bold text-gray-900">{{ selectedTrip.end_odometer }} <span class="text-xs text-gray-500">km</span></p>
                </div>
                <div v-if="selectedTrip.distance_km" class="bg-white rounded-lg p-2.5 border border-gray-100">
                  <div class="flex items-center gap-2 mb-0.5">
                    <i class="fas fa-road text-blue-600 text-xs"></i>
                    <p class="text-xs text-gray-500 uppercase font-medium">Distance Traveled</p>
                  </div>
                  <p class="text-base font-bold text-blue-600">{{ selectedTrip.distance_km }} <span class="text-xs text-gray-500">km</span></p>
                </div>
              </div>
            </div>

            <!-- Notes Section -->
            <div v-if="selectedTrip.notes" class="bg-gradient-to-br from-amber-50 to-white rounded-xl p-3 border border-amber-100">
              <h4 class="text-xs font-semibold text-gray-600 uppercase tracking-wider mb-2.5 flex items-center gap-2">
                <i class="fas fa-sticky-note text-[#0A400C]"></i>
                Notes
              </h4>
              <div class="bg-white rounded-lg p-2.5 border-l-4 border-amber-400">
                <p class="text-sm text-gray-700 leading-relaxed">{{ selectedTrip.notes }}</p>
              </div>
            </div>

            <!-- Cancellation Reason -->
            <div v-if="selectedTrip.cancellation_reason" class="bg-gradient-to-br from-red-50 to-white rounded-xl p-3 border border-red-100">
              <h4 class="text-xs font-semibold text-gray-600 uppercase tracking-wider mb-2.5 flex items-center gap-2">
                <i class="fas fa-exclamation-triangle text-red-600"></i>
                Cancellation Reason
              </h4>
              <div class="bg-white rounded-lg p-2.5 border-l-4 border-red-500">
                <p class="text-sm text-gray-700 leading-relaxed">{{ selectedTrip.cancellation_reason }}</p>
              </div>
            </div>

            <!-- Timestamps -->
            <div class="bg-gradient-to-br from-gray-50 to-white rounded-xl p-3 border border-gray-200">
              <h4 class="text-xs font-semibold text-gray-600 uppercase tracking-wider mb-2.5 flex items-center gap-2">
                <i class="fas fa-history text-[#0A400C]"></i>
                Record Information
              </h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5 text-xs text-gray-600">
                <div class="flex items-center gap-2 bg-white rounded-lg p-2 border border-gray-100">
                  <i class="fas fa-calendar-plus text-green-600 w-4"></i>
                  <div>
                    <span class="font-medium block text-gray-500">Created</span>
                    <span class="text-gray-900">{{ formatDateTime(selectedTrip.created_at) }}</span>
                  </div>
                </div>
                <div v-if="selectedTrip.updated_at && selectedTrip.updated_at !== selectedTrip.created_at" class="flex items-center gap-2 bg-white rounded-lg p-2 border border-gray-100">
                  <i class="fas fa-edit text-blue-600 w-4"></i>
                  <div>
                    <span class="font-medium block text-gray-500">Updated</span>
                    <span class="text-gray-900">{{ formatDateTime(selectedTrip.updated_at) }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="mt-5 pt-4 border-t border-gray-200">
            <button 
              @click="editTrip(selectedTrip); selectedTrip = null" 
              class="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-gradient-to-r from-amber-500 to-amber-600 text-white rounded-lg hover:from-amber-600 hover:to-amber-700 transition-all font-semibold text-sm shadow-md hover:scale-105"
            >
              <i class="fas fa-edit"></i>
              Edit Trip Details
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Complete Trip Modal -->
    <div v-if="tripToComplete" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] backdrop-blur-sm p-4">
      <div class="bg-white rounded-2xl w-full max-w-md shadow-2xl animate-modalSlideIn">
        <div class="relative py-5 px-8 bg-gradient-to-br from-green-800 to-green-600 text-white">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-xl font-bold">Complete Trip</h3>
              <p class="text-green-100 text-sm mt-1">{{ tripToComplete.trip_id }}</p>
            </div>
            <button 
              @click="tripToComplete = null" 
              class="w-10 h-10 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
            >
              <i class="fas fa-times text-lg"></i>
            </button>
          </div>
          <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400"></div>
        </div>

        <div class="p-6">
          <div class="bg-gradient-to-br from-gray-50 to-white rounded-xl p-4 border border-gray-200 mb-5">
            <div class="flex items-center gap-3 mb-4">
              <div class="w-12 h-12 rounded-lg bg-purple-50 flex items-center justify-center">
                <i class="fas fa-tachometer-alt text-purple-600 text-xl"></i>
              </div>
              <div>
                <p class="text-xs text-gray-500 uppercase font-medium">Start Odometer</p>
                <p class="text-xl font-bold text-gray-900">{{ tripToComplete.start_odometer }} km</p>
              </div>
            </div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">
              End Odometer Reading <span class="text-red-500">*</span>
            </label>
            <input
              type="number"
              v-model="completeForm.end_odometer"
              placeholder="Enter final mileage"
              required
              class="w-full py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent"
            />
          </div>

          <div class="flex gap-3">
            <button 
              @click="tripToComplete = null" 
              class="flex-1 px-4 py-3 border-2 border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-all font-semibold"
            >
              Cancel
            </button>
            <button 
              @click="submitCompleteTrip" 
              class="flex-1 flex items-center justify-center gap-2 bg-gradient-to-r from-[#0A400C] to-[#155c1a] text-white px-4 py-3 rounded-lg font-semibold hover:scale-105 transition-all shadow-lg"
            >
              <i class="fas fa-check-circle"></i>
              Complete Trip
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Cancel Confirmation Modal -->
    <div v-if="tripToCancel" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] backdrop-blur-sm p-4">
      <div class="bg-white rounded-2xl w-full max-w-md shadow-2xl animate-modalSlideIn">
        <div class="relative py-5 px-8 bg-gradient-to-br from-green-800 to-green-600 text-white">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-xl font-bold">Cancel Trip</h3>
              <p class="text-green-100 text-sm mt-1">{{ tripToCancel.trip_id }}</p>
            </div>
            <button 
              @click="tripToCancel = null" 
              class="w-10 h-10 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
            >
              <i class="fas fa-times text-lg"></i>
            </button>
          </div>
          <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400"></div>
        </div>

        <div class="p-6">
          <div class="bg-red-50 border-l-4 border-red-500 rounded-lg p-4 mb-5">
            <div class="flex items-start gap-3">
              <i class="fas fa-exclamation-triangle text-red-600 text-xl mt-0.5"></i>
              <div>
                <p class="text-sm font-semibold text-red-800 mb-1">Warning</p>
                <p class="text-sm text-red-700">This action cannot be undone. Please provide a reason for cancellation.</p>
              </div>
            </div>
          </div>

          <div class="mb-5">
            <label class="block text-sm font-semibold text-gray-700 mb-2">
              Reason for Cancellation <span class="text-red-500">*</span>
            </label>
            <textarea
              v-model="cancelForm.reason"
              placeholder="Enter the reason for cancelling this trip..."
              rows="3"
              class="w-full py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 resize-y"
            ></textarea>
          </div>

          <div class="flex gap-3">
            <button 
              @click="tripToCancel = null" 
              class="flex-1 px-4 py-3 border-2 border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-all font-semibold"
            >
              Keep Trip
            </button>
            <button 
              @click="cancelTrip" 
              class="flex-1 flex items-center justify-center gap-2 bg-gradient-to-r from-red-500 to-red-600 text-white px-4 py-3 rounded-lg font-semibold hover:scale-105 transition-all shadow-lg"
            >
              <i class="fas fa-times-circle"></i>
              Cancel Trip
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TripManagement',
  props: {
    vehicles: { type: Array, default: () => [] },
    drivers: { type: Array, default: () => [] }
  },
  data() {
    return {
      trips: [],
      loading: true,
      submitting: false,
      searchQuery: '',
      statusFilter: '',
      showModal: false,
      editingTrip: null,
      selectedTrip: null,
      tripToCancel: null,
      tripToComplete: null,
      selectedVehicle: null,
      form: {
        vehicle_id: '',
        driver_id: '',
        origin: '',
        destination: '',
        purpose: '',
        start_time: '',
        expected_end_time: '',
        passenger_name: '',
        passenger_count: null,
        passenger_department: '',
        start_odometer: null,
        notes: ''
      },
      completeForm: { end_odometer: null },
      cancelForm: { reason: '' }
    }
  },
  computed: {
    filteredTrips() {
      let filtered = this.trips
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase()
        filtered = filtered.filter(t =>
          t.trip_id?.toLowerCase().includes(query) ||
          t.destination?.toLowerCase().includes(query) ||
          this.getVehicleDisplay(t.vehicle_id)?.toLowerCase().includes(query) ||
          this.getDriverDisplay(t.driver_id)?.toLowerCase().includes(query)
        )
      }
      if (this.statusFilter) {
        filtered = filtered.filter(t => t.status === this.statusFilter)
      }
      return filtered
    },
    hasActiveFilters() {
      return this.searchQuery || this.statusFilter
    },
    availableVehicles() {
      return this.vehicles.filter(v => v.status === 'available' || v.status === 'in_use')
    },
    activeDrivers() {
      return this.drivers.filter(d => d.is_active)
    }
  },
  methods: {
    tripsByStatus(status) {
      return this.trips.filter(t => t.status === status).length
    },
    getTripStatusColor(status) {
      const colors = {
        pending: 'bg-amber-50 text-amber-700 border border-amber-200',
        approved: 'bg-green-50 text-green-700 border border-green-200',
        in_progress: 'bg-blue-50 text-blue-700 border border-blue-200',
        completed: 'bg-emerald-50 text-emerald-700 border border-emerald-200',
        cancelled: 'bg-red-50 text-red-700 border border-red-200'
      }
      return colors[status] || colors.pending
    },
    formatTripStatus(status) {
      const labels = {
        pending: 'Pending',
        approved: 'Approved',
        in_progress: 'In Progress',
        completed: 'Completed',
        cancelled: 'Cancelled'
      }
      return labels[status] || 'Unknown'
    },
    formatStatus(status) {
      const labels = {
        available: 'Available',
        in_use: 'In Use',
        maintenance: 'Maintenance',
        out_of_service: 'Out of Service'
      }
      return labels[status] || 'Unknown'
    },
    formatDateTime(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    },
    getVehicleDisplay(vehicleId) {
      const vehicle = this.vehicles.find(v => v.id === vehicleId)
      if (!vehicle) return 'Unknown Vehicle'
      return `${vehicle.vehicle_id} (${vehicle.plate_number})`
    },
    getDriverDisplay(driverId) {
      const driver = this.drivers.find(d => d.id === driverId)
      if (!driver) return 'Unknown Driver'
      return `${driver.full_name} (${driver.employee_id})`
    },
    getDriverNameById(driverId) {
      const driver = this.drivers.find(d => d.id === driverId)
      return driver ? driver.full_name : 'Unknown'
    },
    onVehicleSelect() {
      if (this.form.vehicle_id) {
        this.selectedVehicle = this.vehicles.find(v => v.id === this.form.vehicle_id)
        if (this.selectedVehicle?.assigned_driver_id) {
          this.form.driver_id = this.selectedVehicle.assigned_driver_id
        }
      } else {
        this.selectedVehicle = null
      }
    },
    resetForm() {
      this.form = {
        vehicle_id: '',
        driver_id: '',
        origin: '',
        destination: '',
        purpose: '',
        start_time: '',
        expected_end_time: '',
        passenger_name: '',
        passenger_count: null,
        passenger_department: '',
        start_odometer: null,
        notes: ''
      }
      this.selectedVehicle = null
    },
    openAddModal() {
      this.editingTrip = null
      this.resetForm()
      this.showModal = true
    },
    closeModal() {
      this.showModal = false
      this.editingTrip = null
      this.resetForm()
    },
    editTrip(trip) {
      this.editingTrip = trip
      this.form = {
        vehicle_id: trip.vehicle_id,
        driver_id: trip.driver_id,
        origin: trip.origin || '',
        destination: trip.destination,
        purpose: trip.purpose,
        start_time: trip.start_time ? new Date(trip.start_time).toISOString().slice(0, 16) : '',
        expected_end_time: trip.expected_end_time ? new Date(trip.expected_end_time).toISOString().slice(0, 16) : '',
        passenger_name: trip.passenger_name || '',
        passenger_count: trip.passenger_count || null,
        passenger_department: trip.passenger_department || '',
        start_odometer: trip.start_odometer || null,
        notes: trip.notes || ''
      }
      this.onVehicleSelect()
      this.showModal = true
    },
    viewTrip(trip) {
      this.selectedTrip = trip
    },
    confirmCancel(trip) {
      this.tripToCancel = trip
      this.cancelForm.reason = ''
    },
    completeTrip(trip) {
      this.tripToComplete = trip
      this.completeForm.end_odometer = null
    },
    async submitForm() {
      console.log('Form submitted')
    },
    async approveTrip(trip) {
      console.log('Approve trip:', trip.trip_id)
    },
    async startTrip(trip) {
      console.log('Start trip:', trip.trip_id)
    },
    async submitCompleteTrip() {
      console.log('Complete trip')
    },
    async cancelTrip() {
      console.log('Cancel trip')
    }
  },
  mounted() {
    // Simulate loading trips - replace with actual API call
    setTimeout(() => {
      this.loading = false
    }, 500)
  }
}
</script>
<template>
  <div>
    <!-- Toolbar -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6 ">
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
          class="flex items-center gap-2 bg-gradient-to-br from-green-800 to-green-700 text-white px-5 py-2.5 rounded-lg hover:bg-[#155c1a] transition-all shadow-md whitespace-nowrap"
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

   <!-- Add/Edit Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden shadow-2xl">
        <!-- Modal Header -->
        <div class="relative py-6 px-8  bg-gradient-to-br from-green-800 to-green-600 text-white p-6 flex justify-between items-center">
          <div class="flex items-center gap-3">
            <div class="p-2 bg-white/20 rounded-lg">
              <i class="fas fa-route text-xl"></i>
            </div>
            <h3 class="text-xl font-bold">{{ editingTrip ? 'Edit Trip' : 'Add New Trip' }}</h3>
          </div>
          <button class="p-2 hover:bg-white/20 rounded-lg transition-colors" @click="closeModal">
            <i class="fas fa-times text-xl"></i>
          </button>
                    <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400"></div>
        </div>

        <!-- Modal Content -->
        <form @submit.prevent="submitForm" class="p-6 overflow-y-auto max-h-[calc(90vh-88px)]">
          <!-- Vehicle Selection -->
          <div class="mb-6">
            <h4 class="text-sm font-bold text-slate-700 uppercase tracking-wide mb-4 flex items-center gap-2">
              <i class="fas fa-car text-green-600"></i>
              Vehicle Selection
            </h4>
            <div>
              <label class="block text-sm font-semibold text-slate-700 mb-2">Select Vehicle *</label>
              <select 
                v-model="form.vehicle_id" 
                required
                class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent bg-white"
              >
                <option value="">Choose a vehicle</option>
                <option v-for="vehicle in availableVehicles" :key="vehicle.id" :value="vehicle.id">
                  {{ vehicle.vehicle_id }} - {{ vehicle.plate_number }} ({{ vehicle.vehicle_type }})
                </option>
              </select>
            </div>
          </div>

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
                  v-model="form.origin" 
                  required 
                  placeholder="Starting point"
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
              </div>
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Destination *</label>
                <input 
                  type="text" 
                  v-model="form.destination" 
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
                  v-model="form.start_time" 
                  required 
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
              </div>
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Expected End Date & Time</label>
                <input 
                  type="datetime-local" 
                  v-model="form.expected_end_time" 
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
                        <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 text-sm">
                  <i class="fas fa-user mr-2"></i>Driver
                </label>
                <select 
                  v-model="form.driver_id" 
                  class="px-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent transition-all"
                >
                  <option value="">Select Driver</option>
                  <option v-for="driver in drivers" :key="driver.id" :value="driver.id">
                    {{ driver.employee_id }} - {{ driver.full_name }}
                  </option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Start Odometer</label>
                <input 
                  type="number" 
                  v-model.number="form.start_odometer" 
                  step="0.1" 
                  min="0"
                  placeholder="e.g., 45000"
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Trip Purpose</label>
                <select 
                  v-model="form.purpose" 
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent bg-white"
                >
                  <option value="">Select purpose</option>
                  <option value="Official Business">Official Business</option>
                  <option value="Personnel Transport">Personnel Transport</option>
                  <option value="Delivery">Delivery</option>
                  <option value="Maintenance">Maintenance</option>
                  <option value="Emergency">Emergency</option>
                  <option value="Other">Other</option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-semibold text-slate-700 mb-2">Passenger Count</label>
                <input 
                  type="number" 
                  v-model.number="form.passenger_count" 
                  min="0"
                  placeholder="e.g., 5"
                  class="w-full px-4 py-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
              </div>
            </div>
          </div>
          

          <!-- Notes -->
          <div class="mb-6">
            <label class="block text-sm font-semibold text-slate-700 mb-2">Additional Notes</label>
            <textarea 
              v-model="form.notes" 
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

    <!-- View Trip Modal -->
    <div v-if="selectedTrip" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] backdrop-blur-sm p-4" @click.self="selectedTrip = null">
      <div class="bg-white rounded-2xl w-full max-w-3xl max-h-[90vh] overflow-hidden shadow-2xl">
        <div class="py-6 px-8 bg-gradient-to-r from-[#0A400C] to-[#155c1a] text-white flex justify-between items-center">
          <div>
            <h3 class="text-xl font-bold">{{ selectedTrip.trip_id }}</h3>
            <p class="text-green-100 text-sm">Trip Details</p>
          </div>
          <button @click="selectedTrip = null" class="w-10 h-10 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors">
            <i class="fas fa-times text-lg"></i>
          </button>
        </div>

        <div class="p-8 overflow-y-auto max-h-[calc(90vh-120px)]">
          <!-- Status -->
          <div class="mb-6">
            <span class="inline-flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-semibold"
                  :class="getTripStatusColor(selectedTrip.status)">
              {{ formatTripStatus(selectedTrip.status) }}
            </span>
          </div>

          <div class="space-y-6">
            <!-- Vehicle & Driver -->
            <div>
              <h4 class="text-sm font-semibold text-gray-500 uppercase mb-3">Vehicle & Driver</h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Vehicle</span>
                  <span class="font-medium">{{ getVehicleDisplay(selectedTrip.vehicle_id) }}</span>
                </div>
                <div class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Driver</span>
                  <span class="font-medium">{{ getDriverDisplay(selectedTrip.driver_id) }}</span>
                </div>
              </div>
            </div>

            <!-- Trip Details -->
            <div>
              <h4 class="text-sm font-semibold text-gray-500 uppercase mb-3">Trip Information</h4>
              <div class="space-y-2">
                <div class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Origin</span>
                  <span class="font-medium">{{ selectedTrip.origin || 'Not specified' }}</span>
                </div>
                <div class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Destination</span>
                  <span class="font-medium">{{ selectedTrip.destination }}</span>
                </div>
                <div class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Purpose</span>
                  <span class="font-medium">{{ selectedTrip.purpose }}</span>
                </div>
              </div>
            </div>

            <!-- Schedule -->
            <div>
              <h4 class="text-sm font-semibold text-gray-500 uppercase mb-3">Schedule</h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Start Time</span>
                  <span class="font-medium">{{ formatDateTime(selectedTrip.start_time) }}</span>
                </div>
                <div v-if="selectedTrip.expected_end_time" class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Expected End</span>
                  <span class="font-medium">{{ formatDateTime(selectedTrip.expected_end_time) }}</span>
                </div>
                <div v-if="selectedTrip.actual_start_time" class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Actual Start</span>
                  <span class="font-medium">{{ formatDateTime(selectedTrip.actual_start_time) }}</span>
                </div>
                <div v-if="selectedTrip.actual_end_time" class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Actual End</span>
                  <span class="font-medium">{{ formatDateTime(selectedTrip.actual_end_time) }}</span>
                </div>
              </div>
            </div>

            <!-- Passengers -->
            <div v-if="selectedTrip.passenger_name || selectedTrip.passenger_count">
              <h4 class="text-sm font-semibold text-gray-500 uppercase mb-3">Passenger Details</h4>
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div v-if="selectedTrip.passenger_name" class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Name</span>
                  <span class="font-medium">{{ selectedTrip.passenger_name }}</span>
                </div>
                <div v-if="selectedTrip.passenger_count" class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Count</span>
                  <span class="font-medium">{{ selectedTrip.passenger_count }}</span>
                </div>
                <div v-if="selectedTrip.passenger_department" class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Department</span>
                  <span class="font-medium">{{ selectedTrip.passenger_department }}</span>
                </div>
              </div>
            </div>

            <!-- Metrics -->
            <div v-if="selectedTrip.start_odometer || selectedTrip.distance_km">
              <h4 class="text-sm font-semibold text-gray-500 uppercase mb-3">Trip Metrics</h4>
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div v-if="selectedTrip.start_odometer" class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Start Odometer</span>
                  <span class="font-medium">{{ selectedTrip.start_odometer }} km</span>
                </div>
                <div v-if="selectedTrip.end_odometer" class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">End Odometer</span>
                  <span class="font-medium">{{ selectedTrip.end_odometer }} km</span>
                </div>
                <div v-if="selectedTrip.distance_km" class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Distance</span>
                  <span class="font-medium text-blue-600">{{ selectedTrip.distance_km }} km</span>
                </div>
              </div>
            </div>

            <!-- Notes -->
            <div v-if="selectedTrip.notes">
              <h4 class="text-sm font-semibold text-gray-500 uppercase mb-3">Notes</h4>
              <p class="text-gray-700 leading-relaxed py-3 px-4 bg-gray-50 rounded-lg border-l-4 border-[#0A400C]">
                {{ selectedTrip.notes }}
              </p>
            </div>

            <!-- Cancellation Reason -->
            <div v-if="selectedTrip.cancellation_reason">
              <h4 class="text-sm font-semibold text-gray-500 uppercase mb-3">Cancellation Reason</h4>
              <p class="text-gray-700 leading-relaxed py-3 px-4 bg-red-50 rounded-lg border-l-4 border-red-500">
                {{ selectedTrip.cancellation_reason }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Complete Trip Modal -->
    <div v-if="tripToComplete" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] backdrop-blur-sm p-4">
      <div class="bg-white rounded-2xl w-full max-w-md shadow-2xl">
        <div class="py-6 px-8 bg-gradient-to-r from-purple-500 to-purple-600 text-white flex justify-between items-center rounded-t-2xl">
          <h3 class="text-xl font-semibold">Complete Trip</h3>
          <button @click="tripToComplete = null" class="bg-white/10 hover:bg-white/20 w-8 h-8 rounded-lg flex items-center justify-center transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8">
          <div class="mb-6">
            <label class="block text-sm font-semibold text-gray-700 mb-2">End Odometer Reading <span class="text-red-500">*</span></label>
            <input
              type="number"
              v-model="completeForm.end_odometer"
              placeholder="Final mileage"
              required
              class="w-full py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500"
            />
            <p class="text-xs text-gray-500 mt-2">
              <i class="fas fa-info-circle mr-1"></i>
              Start: {{ tripToComplete.start_odometer }} km
            </p>
          </div>
          <div class="flex gap-4 justify-end">
            <button @click="tripToComplete = null" class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
              Cancel
            </button>
            <button @click="submitCompleteTrip" class="flex items-center gap-2 bg-gradient-to-r from-purple-500 to-purple-600 text-white px-5 py-2.5 rounded-lg font-semibold hover:scale-105 transition-all shadow-lg">
              <i class="fas fa-check-circle"></i>
              Complete Trip
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Cancel Confirmation Modal -->
    <div v-if="tripToCancel" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] backdrop-blur-sm p-4">
      <div class="bg-white rounded-2xl w-full max-w-md shadow-2xl">
        <div class="py-6 px-8 bg-gradient-to-r from-red-500 to-red-600 text-white flex justify-between items-center rounded-t-2xl">
          <h3 class="text-xl font-semibold">Cancel Trip</h3>
          <button @click="tripToCancel = null" class="bg-white/10 hover:bg-white/20 w-8 h-8 rounded-lg flex items-center justify-center transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8">
          <p class="text-lg text-gray-700 mb-4">Cancel trip <strong>{{ tripToCancel.trip_id }}</strong>?</p>
          <div class="mb-6">
            <label class="block text-sm font-semibold text-gray-700 mb-2">Reason for Cancellation</label>
            <textarea
              v-model="cancelForm.reason"
              placeholder="Enter reason..."
              rows="3"
              class="w-full py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 resize-y"
            ></textarea>
          </div>
          <div class="flex gap-4 justify-end">
            <button @click="tripToCancel = null" class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
              No, Keep It
            </button>
            <button @click="cancelTrip" class="flex items-center gap-2 bg-gradient-to-r from-red-500 to-red-600 text-white px-5 py-2.5 rounded-lg font-semibold hover:scale-105 transition-all shadow-lg">
              <i class="fas fa-times-circle"></i>
              Yes, Cancel Trip
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'

export default {
  name: 'TripManagement',
  props: {
    vehicles: {
      type: Array,
      default: () => []
    },
    drivers: {
      type: Array,
      default: () => []
    }
  },
  emits: ['trip-added'],
  setup(props, { emit }) {
    const router = useRouter()
    
    const trips = ref([])
    const loading = ref(true)
    const submitting = ref(false)
    const searchQuery = ref('')
    const statusFilter = ref('')
    
    const showModal = ref(false)
    const editingTrip = ref(null)
    const selectedTrip = ref(null)
    const tripToCancel = ref(null)
    const tripToComplete = ref(null)
    const selectedVehicle = ref(null)
    
    const form = reactive({
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
    })

    const completeForm = reactive({
      end_odometer: null
    })

    const cancelForm = reactive({
      reason: ''
    })

    // Computed
    const filteredTrips = computed(() => {
      let filtered = trips.value

      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        filtered = filtered.filter(t =>
          t.trip_id?.toLowerCase().includes(query) ||
          t.destination?.toLowerCase().includes(query) ||
          getVehicleDisplay(t.vehicle_id)?.toLowerCase().includes(query) ||
          getDriverDisplay(t.driver_id)?.toLowerCase().includes(query)
        )
      }

      if (statusFilter.value) {
        filtered = filtered.filter(t => t.status === statusFilter.value)
      }

      return filtered
    })

    const hasActiveFilters = computed(() => {
      return searchQuery.value || statusFilter.value
    })

    const availableVehicles = computed(() => {
      return props.vehicles.filter(v => 
        v.status === 'available' || v.status === 'in_use'
      )
    })

    const activeDrivers = computed(() => {
      return props.drivers.filter(d => d.is_active)
    })

    const tripsByStatus = (status) => {
      return trips.value.filter(t => t.status === status).length
    }

    // Methods
    const getTripStatusColor = (status) => {
      const colors = {
        pending: 'bg-amber-50 text-amber-700 border border-amber-200',
        approved: 'bg-green-50 text-green-700 border border-green-200',
        in_progress: 'bg-blue-50 text-blue-700 border border-blue-200',
        completed: 'bg-emerald-50 text-emerald-700 border border-emerald-200',
        cancelled: 'bg-red-50 text-red-700 border border-red-200'
      }
      return colors[status] || colors.pending
    }

    const formatTripStatus = (status) => {
      const labels = {
        pending: 'Pending',
        approved: 'Approved',
        in_progress: 'In Progress',
        completed: 'Completed',
        cancelled: 'Cancelled'
      }
      return labels[status] || 'Unknown'
    }

    const formatStatus = (status) => {
      const labels = {
        available: 'Available',
        in_use: 'In Use',
        maintenance: 'Maintenance',
        out_of_service: 'Out of Service'
      }
      return labels[status] || 'Unknown'
    }

    const formatDateTime = (dateString) => {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    }

    const getVehicleDisplay = (vehicleId) => {
      const vehicle = props.vehicles.find(v => v.id === vehicleId)
      if (!vehicle) return 'Unknown Vehicle'
      return `${vehicle.vehicle_id} (${vehicle.plate_number})`
    }

    const getDriverDisplay = (driverId) => {
      const driver = props.drivers.find(d => d.id === driverId)
      if (!driver) return 'Unknown Driver'
      return `${driver.full_name} (${driver.employee_id})`
    }

    const getDriverNameById = (driverId) => {
      const driver = props.drivers.find(d => d.id === driverId)
      return driver ? driver.full_name : 'Unknown'
    }

   // Add this method with the other methods
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

    const loadData = async () => {
      loading.value = true
      try {
        // Load all data in parallel for better performance
        const [vehiclesData, tripsData, driversData, logsData] = await Promise.all([
          supabase.from('vehicles').select('*').order('plate_number'),
          supabase.from('trips').select('*').order('created_at', { ascending: false }).limit(50),
          supabase.from('drivers').select('id, employee_id, full_name').eq('is_active', true).order('full_name'),
          supabase.from('fuel_logs').select(`*, drivers:driver_id (full_name)`).order('created_at', { ascending: false })
        ])

        if (vehiclesData.error) throw vehiclesData.error
        if (tripsData.error) throw tripsData.error
        if (driversData.error) throw driversData.error
        if (logsData.error) throw logsData.error

        vehicles.value = vehiclesData.data || []
        trips.value = tripsData.data || []
        drivers.value = driversData.data || []
        fuelLogs.value = (logsData.data || []).map(log => ({
          ...log,
          driver_name: log.drivers?.full_name || null
        }))

      } catch (error) {
        console.error('Error loading data:', error)
      } finally {
        loading.value = false
      }
    }

    // Add this helper for driver display format
    const formatDriverOption = (driver) => {
      return `${driver.employee_id} - ${driver.full_name}`
    }


    const onVehicleSelect = () => {
      if (form.vehicle_id) {
        selectedVehicle.value = props.vehicles.find(v => v.id === form.vehicle_id)
        
        // Auto-assign driver if vehicle has one
        if (selectedVehicle.value?.assigned_driver_id) {
          form.driver_id = selectedVehicle.value.assigned_driver_id
        }
      } else {
        selectedVehicle.value = null
      }
    }

    const loadTrips = async () => {
      loading.value = true
      try {
        const { data, error } = await supabase
          .from('trips')
          .select('*')
          .order('created_at', { ascending: false })
        
        if (error) throw error
        trips.value = data || []
      } catch (error) {
        console.error('Error loading trips:', error)
        trips.value = []
      } finally {
        loading.value = false
      }
    }

    const resetForm = () => {
      Object.assign(form, {
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
      })
      selectedVehicle.value = null
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

    const editTrip = (trip) => {
      editingTrip.value = trip
      Object.assign(form, {
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
      })
      onVehicleSelect()
      showModal.value = true
    }

    const viewTrip = (trip) => {
      selectedTrip.value = trip
    }

    const submitForm = async () => {
      submitting.value = true
      try {
        const tripData = {
          trip_id: editingTrip.value?.trip_id || `TRP-${Date.now()}`,
          vehicle_id: form.vehicle_id || null,
          driver_id: form.driver_id || null,
          origin: form.origin || null,
          destination: form.destination,
          purpose: form.purpose || null,
          start_time: form.start_time,
          expected_end_time: form.expected_end_time || null,
          passenger_name: form.passenger_name || null,
          passenger_count: form.passenger_count || null,
          passenger_department: form.passenger_department || null,
          start_odometer: form.start_odometer || null,
          notes: form.notes || null,
          status: editingTrip.value?.status || 'pending'
        }

        if (editingTrip.value) {
          const { error } = await supabase
            .from('trips')
            .update(tripData)
            .eq('id', editingTrip.value.id)
          
          if (error) throw error
          
          const index = trips.value.findIndex(t => t.id === editingTrip.value.id)
          if (index !== -1) {
            trips.value[index] = {
              ...editingTrip.value,
              ...tripData,
              updated_at: new Date().toISOString()
            }
          }

          alert('Trip updated successfully!')
        } else {
          const { data, error } = await supabase
            .from('trips')
            .insert(tripData)
            .select()
            .single()
          
          if (error) throw error
          trips.value.unshift(data)
          emit('trip-added')
          alert('Trip created successfully!')
        }

        closeModal()
      } catch (error) {
        console.error('Error submitting trip:', error)
        alert('Error: ' + error.message)
      } finally {
        submitting.value = false
      }
    }

    const approveTrip = async (trip) => {
      if (!confirm(`Approve trip ${trip.trip_id}?`)) return

      try {
        const { error } = await supabase
          .from('trips')
          .update({ status: 'approved' })
          .eq('id', trip.id)
        
        if (error) throw error

        const index = trips.value.findIndex(t => t.id === trip.id)
        if (index !== -1) {
          trips.value[index].status = 'approved'
        }

        alert('Trip approved!')
      } catch (error) {
        console.error('Error approving trip:', error)
        alert('Error: ' + error.message)
      }
    }

    const startTrip = async (trip) => {
      try {
        const { error } = await supabase
          .from('trips')
          .update({ 
            status: 'in_progress',
            actual_start_time: new Date().toISOString()
          })
          .eq('id', trip.id)
        
        if (error) throw error

        const index = trips.value.findIndex(t => t.id === trip.id)
        if (index !== -1) {
          trips.value[index].status = 'in_progress'
          trips.value[index].actual_start_time = new Date().toISOString()
        }

        // Update vehicle status to in_use
        await supabase
          .from('vehicles')
          .update({ status: 'in_use' })
          .eq('id', trip.vehicle_id)

        alert('Trip started!')
      } catch (error) {
        console.error('Error starting trip:', error)
        alert('Error: ' + error.message)
      }
    }

    const completeTrip = (trip) => {
      tripToComplete.value = trip
      completeForm.end_odometer = null
    }

    const submitCompleteTrip = async () => {
      if (!tripToComplete.value) return
      if (!completeForm.end_odometer) {
        alert('Please enter end odometer reading')
        return
      }

      try {
        const distance = tripToComplete.value.start_odometer 
          ? completeForm.end_odometer - tripToComplete.value.start_odometer
          : null

        const { error } = await supabase
          .from('trips')
          .update({ 
            status: 'completed',
            actual_end_time: new Date().toISOString(),
            end_odometer: completeForm.end_odometer,
            distance_km: distance
          })
          .eq('id', tripToComplete.value.id)
        
        if (error) throw error

        const index = trips.value.findIndex(t => t.id === tripToComplete.value.id)
        if (index !== -1) {
          trips.value[index].status = 'completed'
          trips.value[index].actual_end_time = new Date().toISOString()
          trips.value[index].end_odometer = completeForm.end_odometer
          trips.value[index].distance_km = distance
        }

        // Update vehicle odometer and status
        await supabase
          .from('vehicles')
          .update({ 
            status: 'available',
            odometer_reading: completeForm.end_odometer
          })
          .eq('id', tripToComplete.value.vehicle_id)

        alert('Trip completed!')
        tripToComplete.value = null
      } catch (error) {
        console.error('Error completing trip:', error)
        alert('Error: ' + error.message)
      }
    }

    const confirmCancel = (trip) => {
      tripToCancel.value = trip
      cancelForm.reason = ''
    }

    const cancelTrip = async () => {
      if (!tripToCancel.value) return
      
      try {
        const { error } = await supabase
          .from('trips')
          .update({ 
            status: 'cancelled',
            cancellation_reason: cancelForm.reason || 'No reason provided'
          })
          .eq('id', tripToCancel.value.id)
        
        if (error) throw error

        const index = trips.value.findIndex(t => t.id === tripToCancel.value.id)
        if (index !== -1) {
          trips.value[index].status = 'cancelled'
          trips.value[index].cancellation_reason = cancelForm.reason || 'No reason provided'
        }

        // If trip was in progress, update vehicle status
        if (tripToCancel.value.status === 'in_progress') {
          await supabase
            .from('vehicles')
            .update({ status: 'available' })
            .eq('id', tripToCancel.value.vehicle_id)
        }
        
        alert('Trip cancelled')
        tripToCancel.value = null
      } catch (error) {
        console.error('Error cancelling trip:', error)
        alert('Error: ' + error.message)
      }
    }

    onMounted(() => {
      loadTrips()
    })

    return {
      trips,
      loading,
      submitting,
      searchQuery,
      statusFilter,
      filteredTrips,
      hasActiveFilters,
      availableVehicles,
      activeDrivers,
      showModal,
      editingTrip,
      selectedTrip,
      tripToCancel,
      tripToComplete,
      selectedVehicle,
      form,
      completeForm,
      cancelForm,
      tripsByStatus,
      getTripStatusColor,
      formatTripStatus,
      formatStatus,
      formatDateTime,
      getVehicleDisplay,
      getDriverDisplay,
      getDriverNameById,
      onVehicleSelect,
      openAddModal,
      closeModal,
      editTrip,
      viewTrip,
      submitForm, 
      approveTrip,
      startTrip,
      completeTrip,
      submitCompleteTrip,
      confirmCancel,
      cancelTrip
    }
  }
}
</script>
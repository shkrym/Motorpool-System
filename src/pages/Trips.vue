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
      
      <div class="sticky top-0 z-10">
        <PageHeader
          icon="fas fa-route"
          title="Trip History"
          subtitle="View and manage trips for this vehicle"
        >
          <template #leading>
            <div class="flex items-center gap-3">
              <button
                @click="goBackToVehicles"
                class="btn btn-secondary p-2.5"
                title="Back to Vehicles"
              >
                <i class="fas fa-arrow-left"></i>
              </button>
              <button
                @click="openSidebar"
                class="lg:hidden btn btn-secondary p-2.5"
                v-if="!sidebarOpen"
              >
                <i class="fas fa-bars"></i>
              </button>
            </div>
          </template>
        </PageHeader>
      </div>

      <!-- Main Content -->
      <div class="flex-1 p-4 sm:p-6 lg:p-8 overflow-y-auto  bg-green-100/80">
        <div class="max-w-7xl mx-auto space-y-6">
          
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
                    <option value="pending">Pending</option>
                    <option value="approved">Approved</option>
                    <option value="in_progress">In Progress</option>
                    <option value="completed">Completed</option>
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

                  <button
                    @click="openAddModal"
                    class="btn btn-primary px-4 py-3 flex items-center gap-2 whitespace-nowrap"
                  >
                    <i class="fas fa-plus"></i>
                    <span>New Trip</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

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
              class="btn btn-primary"
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
                      'bg-amber-100': trip.status === 'in_progress' || trip.status === 'ongoing',
                      'bg-blue-100': trip.status === 'pending' || trip.status === 'approved',
                      'bg-red-100': trip.status === 'cancelled'
                    }">
                      <i class="text-xl" :class="{
                        'fas fa-check-circle text-green-600': trip.status === 'completed',
                        'fas fa-spinner text-amber-600': trip.status === 'in_progress' || trip.status === 'ongoing',
                        'fas fa-clock text-blue-600': trip.status === 'pending' || trip.status === 'approved',
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
                        <span v-if="trip.actual_start_time" class="flex items-center gap-1.5">
                          <i class="far fa-calendar"></i>
                          {{ formatActualTime(trip.actual_start_time) }}
                        </span>
                        <span v-else class="flex items-center gap-1.5">
                          <i class="far fa-calendar"></i>
                          Not Started
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
                    'bg-amber-100 text-amber-700': trip.status === 'in_progress' || trip.status === 'ongoing',
                    'bg-blue-100 text-blue-700': trip.status === 'pending' || trip.status === 'approved',
                    'bg-red-100 text-red-700': trip.status === 'cancelled'
                  }">
                    {{ trip.status === 'in_progress' ? 'In Progress' : trip.status === 'ongoing' ? 'Ongoing' : trip.status }}
                  </span>
                </div>
              </div>

              <!-- Trip Details -->
              <div class="p-3">
                <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-4">
                  <div class="space-y-1" v-if="trip.distance_km">
                    <div class="text-xs font-medium text-slate-500 uppercase tracking-wide">Distance</div>
                    <div class="text-md font-bold text-slate-800">{{ trip.distance_km }} km</div>
                  </div>
                  <div class="space-y-1" v-else>
                    <div class="text-xs font-medium text-slate-500 uppercase tracking-wide">Distance</div>
                    <div class="text-md font-bold text-slate-400">-</div>
                  </div>
                  <div class="space-y-1">
                    <div class="text-xs font-medium text-slate-500 uppercase tracking-wide">Duration</div>
                    <div class="text-md font-bold text-slate-800">{{ formatDuration(trip.actual_start_time, trip.actual_end_time) }}</div>
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
                <div class="flex items-center gap-1.5 sm:gap-2 flex-nowrap overflow-x-auto pt-4 border-t border-slate-100">
                  <!-- Status-based action buttons -->
                  <button 
                    v-if="trip.status === 'pending'"
                    @click="confirmApprove(trip)" 
                    class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-emerald-50 text-emerald-600 hover:bg-emerald-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0"
                    title="Approve Trip"
                  >
                    <i class="fas fa-check-circle text-xs sm:text-sm"></i>
                    <span class="text-xs font-medium">Approve</span>
                  </button>
                  <button 
                    v-if="trip.status === 'approved'"
                    @click="startTrip(trip)" 
                    class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-teal-50 text-teal-600 hover:bg-teal-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0"
                    title="Start Trip"
                  >
                    <i class="fas fa-play-circle text-xs sm:text-sm"></i>
                    <span class="text-xs font-medium">Start</span>
                  </button>
                  <button 
                    v-if="trip.status === 'in_progress'"
                    @click="completeTrip(trip)" 
                    class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-purple-50 text-purple-600 hover:bg-purple-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0"
                    title="Complete Trip"
                  >
                    <i class="fas fa-flag-checkered text-xs sm:text-sm"></i>
                    <span class="text-xs font-medium">Complete</span>
                  </button>
                  
                  <!-- Standard action buttons -->
                  <button 
                    @click="viewTripDetails(trip)" 
                    class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0"
                    title="View Details"
                  >
                    <i class="fas fa-eye text-xs sm:text-sm"></i>
                    <span class="text-xs font-medium">View</span>
                  </button>
                  <button   
                    @click="editTrip(trip)" 
                    class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-amber-50 text-amber-600 hover:bg-amber-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0"
                    title="Edit Trip"
                  >
                    <i class="fas fa-edit text-xs sm:text-sm"></i>
                    <span class="text-xs font-medium">Edit</span>
                  </button>
                  <button 
                    @click="deleteTrip(trip)" 
                    class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0"
                    title="Delete Trip"
                  >
                    <i class="fas fa-trash text-xs sm:text-sm"></i>
                    <span class="text-xs font-medium">Delete</span>
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
                <label class="block text-sm font-semibold text-slate-700 mb-2">Start Odometer</label>
                <input 
                  type="number" 
                  v-model.number="tripForm.start_odometer" 
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
                  v-model="tripForm.purpose" 
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
                  v-model.number="tripForm.passenger_count" 
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

    <!-- View Trip Details Modal -->
    <div v-if="selectedTrip" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] backdrop-blur-sm p-4" @click.self="selectedTrip = null">
      <div class="bg-white rounded-2xl w-full max-w-3xl max-h-[90vh] overflow-hidden shadow-2xl">
        <div class="py-6 px-8 bg-gradient-to-r from-green-800 to-green-600 text-white flex justify-between items-center">
          <div>
            <h3 class="text-xl font-bold">{{ selectedTrip.trip_id || 'Trip Details' }}</h3>
            <p class="text-green-100 text-sm">Trip Information</p>
          </div>
          <button @click="selectedTrip = null" class="w-10 h-10 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors">
            <i class="fas fa-times text-lg"></i>
          </button>
        </div>

        <div class="p-8 overflow-y-auto max-h-[calc(90vh-120px)]">
          <!-- Status -->
          <div class="mb-6">
            <span class="inline-flex items-center gap-1.5 px-4 py-2 rounded-full text-sm font-semibold capitalize"
                  :class="{
                    'bg-green-100 text-green-700': selectedTrip.status === 'completed',
                    'bg-amber-100 text-amber-700': selectedTrip.status === 'ongoing' || selectedTrip.status === 'in_progress',
                    'bg-red-100 text-red-700': selectedTrip.status === 'cancelled',
                    'bg-blue-100 text-blue-700': selectedTrip.status === 'pending' || selectedTrip.status === 'approved'
                  }">
              {{ selectedTrip.status }}
            </span>
          </div>

          <div class="space-y-6">
            <!-- Vehicle & Driver -->
            <div>
              <h4 class="text-sm font-semibold text-gray-500 uppercase mb-3">Vehicle & Driver</h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Vehicle</span>
                  <span class="font-medium">{{ vehicleInfo?.plate_number || vehicleInfo?.vehicle_id || 'N/A' }}</span>
                </div>
                <div class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Driver</span>
                  <span class="font-medium">{{ selectedTrip.driver_name || 'Unassigned' }}</span>
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
                  <span class="font-medium">{{ selectedTrip.purpose || 'Not specified' }}</span>
                </div>
              </div>
            </div>

            <!-- Schedule -->
            <div>
              <h4 class="text-sm font-semibold text-gray-500 uppercase mb-3">Schedule</h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div v-if="selectedTrip.actual_start_time" class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Start Time</span>
                  <span class="font-medium">{{ formatActualTime(selectedTrip.actual_start_time) }}</span>
                </div>
                <div v-else class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Start Time</span>
                  <span class="font-medium text-gray-400">Not Started</span>
                </div>
                <div v-if="selectedTrip.actual_end_time" class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">End Time</span>
                  <span class="font-medium">{{ formatActualTime(selectedTrip.actual_end_time) }}</span>
                </div>
                <div v-else class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">End Time</span>
                  <span class="font-medium text-gray-400">Not Completed</span>
                </div>
              </div>
            </div>

            <!-- Passengers -->
            <div v-if="selectedTrip.passenger_count">
              <h4 class="text-sm font-semibold text-gray-500 uppercase mb-3">Passenger Details</h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="flex justify-between py-2 border-b border-gray-100">
                  <span class="text-gray-600">Count</span>
                  <span class="font-medium">{{ selectedTrip.passenger_count }}</span>
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
              <p class="text-gray-700 leading-relaxed py-3 px-4 bg-gray-50 rounded-lg border-l-4 border-green-600">
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
            <p class="text-xs text-gray-500 mt-2" v-if="tripToComplete?.start_odometer">
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

    <!-- Approve Confirmation Modal -->
    <div v-if="tripToApprove" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] backdrop-blur-sm p-4">
      <div class="bg-white rounded-2xl w-full max-w-md shadow-2xl">
        <div class="py-6 px-8 bg-gradient-to-r from-emerald-500 to-emerald-600 text-white flex justify-between items-center rounded-t-2xl">
          <h3 class="text-xl font-semibold">Approve Trip</h3>
          <button @click="closeApproveModal" class="bg-white/10 hover:bg-white/20 w-8 h-8 rounded-lg flex items-center justify-center transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8">
          <p class="text-lg text-gray-700 mb-6">Approve trip <strong>{{ tripToApprove?.trip_id }}</strong>?</p>
          <div class="flex gap-4 justify-end">
            <button @click="closeApproveModal" class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
              Cancel
            </button>
            <button @click="approveTrip" class="flex items-center gap-2 bg-gradient-to-r from-emerald-500 to-emerald-600 text-white px-5 py-2.5 rounded-lg font-semibold hover:scale-105 transition-all shadow-lg">
              <i class="fas fa-check-circle"></i>
              Yes, Approve Trip
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
import { useToast } from '../composables/useToast'
import { useSidebar } from '../composables/useSidebar'
import Navbar from './Navbar.vue'
import PageHeader from '../components/PageHeader.vue'

export default {
  name: 'Trips',
  components: { Navbar, PageHeader },
  setup() {
    const { success, error, warning } = useToast()
    const router = useRouter()
    const route = useRoute()
    const vehicleId = route.params.id
    const { sidebarCollapsed, sidebarOpen, toggleSidebar, closeSidebar, openSidebar, handleMenuClick } = useSidebar()
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
      driver_id: '',
      start_odometer: null,
      purpose: '',
      passenger_count: null,
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
          trip.actual_start_time && trip.actual_start_time.startsWith(dateFilter.value)
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

    // Sidebar methods are now from useSidebar composable

    // Format function for start_time and expected_end_time
    // These may have been saved incorrectly (local time strings interpreted as UTC)
    // So we extract UTC components and treat them as local time
    const formatDate = (dateString) => {
      if (!dateString) return 'N/A'
      
      try {
        // Use the same approach as map pages (LiveMap.vue, TriMap.vue)
        // Database may have stored times incorrectly (local time strings interpreted as UTC)
        // Extract UTC components and treat them as local time to avoid double conversion
        let date = new Date(dateString)
        if (isNaN(date.getTime())) return 'N/A'
        
        // Get the UTC components (which may actually be PH time in the database)
        // and treat them as local time to avoid timezone conversion
        const year = date.getUTCFullYear()
        const month = date.getUTCMonth()
        const day = date.getUTCDate()
        const hours = date.getUTCHours()
        const minutes = date.getUTCMinutes()
        
        // Create a new date with these values as LOCAL time
        const localDate = new Date(year, month, day, hours, minutes)
        
        // Format this date
        return localDate.toLocaleDateString('en-US', {
          month: 'short',
          day: 'numeric',
          year: 'numeric'
        }) + ', ' + localDate.toLocaleTimeString('en-US', { 
          hour: '2-digit', 
          minute: '2-digit',
          hour12: true
        })
      } catch (error) {
        console.error('Error formatting date:', dateString, error)
        return 'N/A'
      }
    }

    // Format function for actual_start_time and actual_end_time
    // These are correctly saved as UTC (using toISOString()), so use normal JavaScript conversion
    const formatActualTime = (dateString) => {
      if (!dateString) return 'N/A'
      
      try {
        // These timestamps are correctly stored in UTC
        // JavaScript automatically converts UTC to local time when creating a Date object
        let date = new Date(dateString)
        if (isNaN(date.getTime())) return 'N/A'
        
        // Format directly as local time (JavaScript handles UTC to local conversion)
        return date.toLocaleDateString('en-US', {
          month: 'short',
          day: 'numeric',
          year: 'numeric'
        }) + ', ' + date.toLocaleTimeString('en-US', { 
          hour: '2-digit', 
          minute: '2-digit',
          hour12: true
        })
      } catch (error) {
        console.error('Error formatting actual time:', dateString, error)
        return 'N/A'
      }
    }

    const formatDuration = (start, end) => {
      if (!start || !end) return 'N/A'
      
      try {
        // Use the same UTC component extraction approach to avoid timezone issues
        const parseDate = (dateString) => {
          if (!dateString) return null
          const date = new Date(dateString)
          if (isNaN(date.getTime())) return null
          
          // Extract UTC components and treat as local time
          const year = date.getUTCFullYear()
          const month = date.getUTCMonth()
          const day = date.getUTCDate()
          const hours = date.getUTCHours()
          const minutes = date.getUTCMinutes()
          const seconds = date.getUTCSeconds()
          
          return new Date(year, month, day, hours, minutes, seconds)
        }
        
        const startDate = parseDate(start)
        const endDate = parseDate(end)
        
        if (!startDate || !endDate) return 'N/A'
        
        const diff = endDate - startDate
        const hours = Math.floor(Math.abs(diff) / (1000 * 60 * 60))
        const minutes = Math.floor((Math.abs(diff) % (1000 * 60 * 60)) / (1000 * 60))
        
        // Handle negative duration (shouldn't happen, but just in case)
        if (diff < 0) {
          return `-${hours}h ${minutes}m`
        }
        
        return `${hours}h ${minutes}m`
      } catch (error) {
        console.error('Error formatting duration:', error)
        return 'N/A'
      }
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
          .order('actual_start_time', { ascending: false })
        
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
        expected_end_time: '',
        driver_id: '',
        start_odometer: null,
        purpose: '',
        passenger_count: null,
        notes: ''
      })
    }

    const selectedTrip = ref(null)
    const tripToApprove = ref(null)
    const tripToComplete = ref(null)
    const completeForm = reactive({
      end_odometer: null
    })
    
    const editTrip = (trip) => {
      editingTrip.value = trip
      Object.assign(tripForm, {
        origin: trip.origin,
        destination: trip.destination,
        driver_id: trip.driver_id || '',
        start_odometer: trip.start_odometer || null,
        purpose: trip.purpose || '',
        passenger_count: trip.passenger_count || null,
        notes: trip.notes || ''
      })
      showModal.value = true
    }
    
    const viewTripDetails = (trip) => {
      selectedTrip.value = trip
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
        error('Error deleting trip: ' + error.message)
      }
    }

    const submitForm = async () => {
      submitting.value = true
      try {
        const tripData = {
          trip_id: editingTrip.value?.trip_id || `TRP-${Date.now()}`,
          vehicle_id: vehicleId,
          origin: tripForm.origin,
          destination: tripForm.destination,
          driver_id: tripForm.driver_id || null,
          start_odometer: tripForm.start_odometer || null,
          purpose: tripForm.purpose || null,
          passenger_count: tripForm.passenger_count || null,
          notes: tripForm.notes || null,
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

        success(editingTrip.value ? 'Trip updated successfully!' : 'Trip created successfully!')
        closeModal()
      } catch (err) {
        console.error('Error submitting trip:', err)
        error('Error: ' + err.message)
      } finally {
        submitting.value = false
      }
    }

    const clearFilters = () => {
      searchQuery.value = ''
      statusFilter.value = ''
      dateFilter.value = ''
    }

    const goBackToVehicles = () => {
      router.push('/vehicles')
    }

    const confirmApprove = (trip) => {
      tripToApprove.value = trip
    }

    const closeApproveModal = () => {
      tripToApprove.value = null
    }

    const approveTrip = async () => {
      if (!tripToApprove.value) return

      try {
        const { error } = await supabase
          .from('trips')
          .update({ status: 'approved' })
          .eq('id', tripToApprove.value.id)
        
        if (error) throw error

        const index = trips.value.findIndex(t => t.id === tripToApprove.value.id)
        if (index !== -1) {
          trips.value[index].status = 'approved'
        }

        success('Trip approved!')
        closeApproveModal()
      } catch (err) {
        console.error('Error approving trip:', err)
        error('Error: ' + err.message)
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

        success('Trip started!')
        await loadTrips() // Reload to refresh the list
      } catch (err) {
        console.error('Error starting trip:', err)
        error('Error: ' + err.message)
      }
    }

    const completeTrip = (trip) => {
      tripToComplete.value = trip
      completeForm.end_odometer = null
    }

    const submitCompleteTrip = async () => {
      if (!tripToComplete.value) return
      if (!completeForm.end_odometer) {
        warning('Please enter end odometer reading')
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

        success('Trip completed!')
        tripToComplete.value = null
        await loadTrips() // Reload to refresh the list
      } catch (err) {
        console.error('Error completing trip:', err)
        error('Error: ' + err.message)
      }
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
      selectedTrip,
      submitting,
      tripForm,
      drivers,
      vehicleInfo,
      formatDate,
      formatActualTime,
      formatDuration,
      tripToApprove,
      tripToComplete,
      completeForm,
      confirmApprove,
      closeApproveModal,
      approveTrip,
      startTrip,
      completeTrip,
      submitCompleteTrip,
      openAddModal,
      closeModal,
      editTrip,
      viewTripDetails,
      deleteTrip,
      submitForm,
      clearFilters,
      goBackToVehicles
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
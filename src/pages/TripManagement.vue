<template>
  <div>
    <!-- Toolbar -->
    <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 mb-6 transition-colors duration-200">
      <div class="flex flex-col sm:flex-row gap-4">
        <div class="flex-1 relative">
          <i class="fas fa-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 dark:text-[#8b949e]"></i>
          <input
            type="text"
            v-model="searchQuery"
            placeholder="Search trips by ID, vehicle, driver, or destination..."
            class="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent bg-white dark:bg-[#1c2128] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
          />
        </div>
        <select v-model="statusFilter" class="px-4 py-2 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] bg-white dark:bg-[#1c2128] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">
          <option value="">All Status</option>
          <option value="pending">Pending</option>
          <option value="approved">Approved</option>
          <option value="in_progress">In Progress</option>
          <option value="completed">Completed</option>
          <option value="cancelled">Cancelled</option>
        </select>
        <button 
          @click="openAddModal"
          class="btn btn-primary whitespace-nowrap"
        >
          <i class="fas fa-plus"></i>
          <span class="hidden sm:inline">Create Trip</span>
          <span class="sm:hidden">New</span>
        </button>
      </div>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-2 lg:grid-cols-5 gap-4 mb-6">
      <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 transition-colors duration-200">
        <div class="stat-card-icon bg-emerald-100 dark:bg-[#1a2f23] text-emerald-600 dark:text-[#3fb950] mb-3">
          <i class="fas fa-route"></i>
        </div>
        <div class="text-2xl sm:text-3xl font-bold text-slate-900 dark:text-[#e6edf3] transition-colors duration-200">{{ trips.length }}</div>
        <p class="text-xs uppercase tracking-wide text-slate-500 dark:text-[#8b949e] mt-1 transition-colors duration-200">Total Trips</p>
      </div>
      <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 transition-colors duration-200">
        <div class="stat-card-icon bg-amber-100 dark:bg-[#2d4a2f] text-amber-600 dark:text-[#6fc276] mb-3">
          <i class="fas fa-clock"></i>
        </div>
        <div class="text-2xl sm:text-3xl font-bold text-amber-600 dark:text-[#6fc276] transition-colors duration-200">{{ tripsByStatus('pending') }}</div>
        <p class="text-xs uppercase tracking-wide text-slate-500 dark:text-[#8b949e] mt-1 transition-colors duration-200">Pending</p>
      </div>
      <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 transition-colors duration-200">
        <div class="stat-card-icon bg-blue-100 dark:bg-[#1a2a1f] text-blue-600 dark:text-[#8fbc8f] mb-3">
          <i class="fas fa-play"></i>
        </div>
        <div class="text-2xl sm:text-3xl font-bold text-blue-600 dark:text-[#8fbc8f] transition-colors duration-200">{{ tripsByStatus('in_progress') }}</div>
        <p class="text-xs uppercase tracking-wide text-slate-500 dark:text-[#8b949e] mt-1 transition-colors duration-200">In Progress</p>
      </div>
      <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 transition-colors duration-200">
        <div class="stat-card-icon bg-green-100 dark:bg-[#1a2f23] text-green-600 dark:text-[#3fb950] mb-3">
          <i class="fas fa-flag-checkered"></i>
        </div>
        <div class="text-2xl sm:text-3xl font-bold text-green-600 dark:text-green-400 transition-colors duration-200">{{ tripsByStatus('completed') }}</div>
        <p class="text-xs uppercase tracking-wide text-slate-500 dark:text-slate-400 mt-1 transition-colors duration-200">Completed</p>
      </div>
      <div class="glass-card dark:bg-slate-800 dark:border-slate-700 p-4 sm:p-5 transition-colors duration-200">
        <div class="stat-card-icon bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 mb-3">
          <i class="fas fa-ban"></i>
        </div>
        <div class="text-2xl sm:text-3xl font-bold text-red-600 dark:text-red-400 transition-colors duration-200">{{ tripsByStatus('cancelled') }}</div>
        <p class="text-xs uppercase tracking-wide text-slate-500 dark:text-slate-400 mt-1 transition-colors duration-200">Cancelled</p>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="glass-card dark:bg-[#161b22] dark:border-[#30363d] text-center py-16 transition-colors duration-200">
      <i class="fas fa-spinner fa-spin text-5xl mb-5 text-emerald-600 dark:text-[#3fb950]"></i>
      <p class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Loading trips...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredTrips.length === 0" class="glass-card dark:bg-[#161b22] dark:border-[#30363d] text-center py-16 transition-colors duration-200">
      <i class="fas fa-route text-7xl mb-5 text-emerald-100 dark:text-[#1a2f23]"></i>
      <h3 class="text-2xl font-bold text-gray-900 dark:text-[#e6edf3] mb-2 transition-colors duration-200">No trips found</h3>
      <p class="text-gray-600 dark:text-[#8b949e] mb-6 transition-colors duration-200">{{ hasActiveFilters ? 'Try adjusting your filters' : 'Start by creating your first trip' }}</p>
      <button
        v-if="!hasActiveFilters"
        @click="openAddModal"
        class="btn btn-primary"
      >
        <i class="fas fa-plus"></i>
        Create Trip
      </button>
    </div>

    <!-- Trips Grid -->
    <div v-else>
      <div class="flex justify-between items-center mb-4">
        <div class="text-sm text-gray-600 dark:text-[#8b949e] transition-colors duration-200">
          Showing <span class="font-semibold text-gray-900 dark:text-[#e6edf3]">{{ filteredTrips.length }}</span> of 
          <span class="font-semibold text-gray-900 dark:text-[#e6edf3]">{{ trips.length }}</span> trips
        </div>
        <div class="view-toggle flex bg-white/90 dark:bg-[#161b22] transition-colors duration-200">
          <button
            @click="viewMode = 'grid'"
            :class="viewMode === 'grid' ? 'bg-emerald-600 dark:bg-[#238636] text-white' : 'text-slate-500 dark:text-[#8b949e] bg-transparent'"
          >
            <i class="fas fa-th-large"></i>
          </button>
          <button
            @click="viewMode = 'list'"
            :class="viewMode === 'list' ? 'bg-emerald-600 text-white' : 'text-slate-500 bg-transparent'"
          >
            <i class="fas fa-table"></i>
          </button>
        </div>
      </div>

    <div v-if="viewMode === 'grid'" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      <div
        v-for="trip in filteredTrips"
        :key="trip.id"
        class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-5 hover:-translate-y-1 transition-all duration-300"
      >
        <div class="flex items-start justify-between mb-4">
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-green-500 to-green-700 dark:from-[#2d4a2f] dark:to-[#1a2f23] text-white flex items-center justify-center shadow-inner">
              <i class="fas fa-route"></i>
            </div>
            <div>
              <div class="text-base font-bold text-slate-900 dark:text-[#e6edf3] transition-colors duration-200">{{ trip.trip_id }}</div>
              <div class="text-xs text-slate-500 dark:text-[#8b949e] transition-colors duration-200">{{ getVehicleDisplay(trip.vehicle_id) }}</div>
            </div>
          </div>
          <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold"
                :class="getTripStatusColor(trip.status)">
            {{ formatTripStatus(trip.status) }}
          </span>
        </div>
        
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-4">
          <div class="p-3 rounded-xl bg-slate-50 dark:bg-[#1c2128] flex items-center gap-3 transition-colors duration-200">
            <div class="w-8 h-8 rounded-full bg-emerald-100 dark:bg-emerald-900/30 text-emerald-600 dark:text-emerald-400 flex items-center justify-center transition-colors duration-200">
              <i class="fas fa-user"></i>
            </div>
            <div>
              <p class="text-xs text-slate-500 dark:text-[#8b949e] uppercase transition-colors duration-200">Driver</p>
              <p class="text-sm font-semibold text-slate-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ getDriverDisplay(trip.driver_id) }}</p>
            </div>
          </div>
          <div class="p-3 rounded-xl bg-slate-50 dark:bg-[#1c2128] flex items-center gap-3 transition-colors duration-200">
            <div class="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 flex items-center justify-center transition-colors duration-200">
              <i class="fas fa-map-marker-alt"></i>
            </div>
            <div>
              <p class="text-xs text-slate-500 dark:text-[#8b949e] uppercase transition-colors duration-200">Destination</p>
              <p class="text-sm font-semibold text-slate-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ trip.destination }}</p>
            </div>
          </div>
          <div class="p-3 rounded-xl bg-slate-50 dark:bg-[#1c2128] flex items-center gap-3 transition-colors duration-200">
            <div class="w-8 h-8 rounded-full bg-amber-100 dark:bg-amber-900/30 text-amber-600 dark:text-amber-400 flex items-center justify-center transition-colors duration-200">
              <i class="fas fa-calendar"></i>
            </div>
            <div>
              <p class="text-xs text-slate-500 dark:text-[#8b949e] uppercase transition-colors duration-200">Start Time</p>
              <p class="text-sm font-semibold text-slate-900 dark:text-[#e6edf3] transition-colors duration-200">{{ trip.actual_start_time ? formatActualTime(trip.actual_start_time) : 'Not Started' }}</p>
            </div>
          </div>
          <div class="p-3 rounded-xl bg-slate-50 dark:bg-[#1c2128] flex items-center gap-3 transition-colors duration-200" v-if="trip.purpose">
            <div class="w-8 h-8 rounded-full bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400 flex items-center justify-center transition-colors duration-200">
              <i class="fas fa-info-circle"></i>
            </div>
            <div>
              <p class="text-xs text-slate-500 dark:text-[#8b949e] uppercase transition-colors duration-200">Purpose</p>
              <p class="text-sm font-semibold text-slate-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ trip.purpose }}</p>
            </div>
          </div>
        </div>

        <div class="flex items-center gap-1.5 flex-nowrap overflow-x-auto pb-1">
          <button 
            @click="viewTrip(trip)"
            class="shrink-0 p-2 rounded-lg bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 hover:bg-blue-100 dark:hover:bg-blue-900/50 transition-colors"
            title="View Details"
          >
            <i class="fas fa-eye text-sm"></i>
          </button>
          <button 
            v-if="trip.status === 'pending'"
            @click="confirmApprove(trip)"
            class="shrink-0 p-2 rounded-lg bg-emerald-50 dark:bg-emerald-900/30 text-emerald-600 dark:text-emerald-400 hover:bg-emerald-100 dark:hover:bg-emerald-900/50 transition-colors"
            title="Approve Trip"
          >
            <i class="fas fa-check text-sm"></i>
          </button>
          <button 
            v-if="trip.status === 'approved'"
            @click="startTrip(trip)"
            class="shrink-0 p-2 rounded-lg bg-teal-50 dark:bg-teal-900/30 text-teal-600 dark:text-teal-400 hover:bg-teal-100 dark:hover:bg-teal-900/50 transition-colors"
            title="Start Trip"
          >
            <i class="fas fa-play text-sm"></i>
          </button>
          <button 
            v-if="trip.status === 'in_progress'"
            @click="completeTrip(trip)"
            class="shrink-0 p-2 rounded-lg bg-purple-50 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400 hover:bg-purple-100 dark:hover:bg-purple-900/50 transition-colors"
            title="Complete Trip"
          >
            <i class="fas fa-flag-checkered text-sm"></i>
          </button>
          <button 
            @click="editTrip(trip)"
            class="shrink-0 p-2 rounded-lg bg-amber-50 dark:bg-amber-900/30 text-amber-600 dark:text-amber-400 hover:bg-amber-100 dark:hover:bg-amber-900/50 transition-colors"
            title="Edit Trip"
          >
            <i class="fas fa-edit text-sm"></i>
          </button>
          <button 
            v-if="['pending', 'approved', 'in_progress'].includes(trip.status)"
            @click="confirmCancel(trip)"
            class="shrink-0 p-2 rounded-lg bg-orange-50 dark:bg-orange-900/30 text-orange-600 dark:text-orange-400 hover:bg-orange-100 dark:hover:bg-orange-900/50 transition-colors"
            title="Cancel Trip"
          >
            <i class="fas fa-times text-sm"></i>
          </button>
          <button 
            v-if="['pending', 'approved', 'cancelled', 'completed'].includes(trip.status)"
            @click="deleteTrip(trip)"
            class="shrink-0 p-2 rounded-lg bg-red-50 dark:bg-red-900/30 text-red-600 dark:text-red-400 hover:bg-red-100 dark:hover:bg-red-900/50 transition-colors"
            title="Delete Trip"
          >
            <i class="fas fa-trash text-sm"></i>
          </button>
        </div>
      </div>
    </div>
    <div v-else class="glass-card dark:bg-[#161b22] dark:border-[#30363d] overflow-x-auto transition-colors duration-200">
      <table class="w-full">
        <thead class="bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] border-b border-gray-200 dark:border-[#30363d]">
          <tr>
            <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Trip</th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Vehicle</th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Driver</th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Destination</th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Status</th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Actions</th>
          </tr>
        </thead>
        <tbody class="text-sm text-slate-700 dark:text-[#e6edf3] divide-y divide-gray-200 dark:divide-[#30363d]">
          <tr v-for="trip in filteredTrips" :key="trip.id" class="hover:bg-slate-50/60 dark:hover:bg-[#1c2128] transition-colors">
            <td class="py-3 px-4">
              <div class="font-semibold text-slate-900 dark:text-[#e6edf3] transition-colors duration-200">{{ trip.trip_id }}</div>
              <div class="text-xs text-slate-500 dark:text-[#8b949e] transition-colors duration-200">{{ trip.actual_start_time ? formatActualTime(trip.actual_start_time) : 'Not Started' }}</div>
            </td>
            <td class="py-3 px-4 text-slate-700 dark:text-[#e6edf3] transition-colors duration-200">{{ getVehicleDisplay(trip.vehicle_id) }}</td>
            <td class="py-3 px-4 text-slate-700 dark:text-[#e6edf3] transition-colors duration-200">{{ getDriverDisplay(trip.driver_id) }}</td>
            <td class="py-3 px-4 text-slate-700 dark:text-[#e6edf3] transition-colors duration-200">{{ trip.destination }}</td>
            <td class="py-3 px-4">
              <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold"
                    :class="getTripStatusColor(trip.status)">
                {{ formatTripStatus(trip.status) }}
              </span>
            </td>
            <td class="py-3 px-4">
              <div class="flex items-center gap-1.5 sm:gap-2 flex-nowrap overflow-x-auto justify-end">
                <button @click="viewTrip(trip)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 hover:bg-blue-100 dark:hover:bg-blue-900/50 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="View">
                  <i class="fas fa-eye text-xs sm:text-sm"></i>
                  <span class="hidden lg:inline text-xs font-medium ml-0.5">View</span>
                </button>
                <button v-if="trip.status === 'pending'" @click="confirmApprove(trip)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-emerald-50 dark:bg-emerald-900/30 text-emerald-600 dark:text-emerald-400 hover:bg-emerald-100 dark:hover:bg-emerald-900/50 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Approve">
                  <i class="fas fa-check text-xs sm:text-sm"></i>
                  <span class="hidden lg:inline text-xs font-medium ml-0.5">Approve</span>
                </button>
                <button v-if="trip.status === 'approved'" @click="startTrip(trip)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-teal-50 dark:bg-teal-900/30 text-teal-600 dark:text-teal-400 hover:bg-teal-100 dark:hover:bg-teal-900/50 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Start">
                  <i class="fas fa-play text-xs sm:text-sm"></i>
                  <span class="hidden lg:inline text-xs font-medium ml-0.5">Start</span>
                </button>
                <button v-if="trip.status === 'in_progress'" @click="completeTrip(trip)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-purple-50 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400 hover:bg-purple-100 dark:hover:bg-purple-900/50 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Complete">
                  <i class="fas fa-flag-checkered text-xs sm:text-sm"></i>
                  <span class="hidden lg:inline text-xs font-medium ml-0.5">Complete</span>
                </button>
                <button @click="editTrip(trip)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-amber-50 dark:bg-amber-900/30 text-amber-600 dark:text-amber-400 hover:bg-amber-100 dark:hover:bg-amber-900/50 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Edit Trip">
                  <i class="fas fa-edit text-xs sm:text-sm"></i>
                  <span class="hidden lg:inline text-xs font-medium ml-0.5">Edit</span>
                </button>
                <button v-if="['pending', 'approved', 'cancelled', 'completed'].includes(trip.status)" @click="deleteTrip(trip)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-red-50 dark:bg-red-900/30 text-red-600 dark:text-red-400 hover:bg-red-100 dark:hover:bg-red-900/50 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Delete Trip">
                  <i class="fas fa-trash text-xs sm:text-sm"></i>
                  <span class="hidden lg:inline text-xs font-medium ml-0.5">Delete</span>
                </button>
                <button v-if="['pending', 'approved', 'in_progress'].includes(trip.status)" @click="confirmCancel(trip)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-orange-50 dark:bg-orange-900/30 text-orange-600 dark:text-orange-400 hover:bg-orange-100 dark:hover:bg-orange-900/50 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Cancel Trip">
                  <i class="fas fa-times text-xs sm:text-sm"></i>
                  <span class="hidden lg:inline text-xs font-medium ml-0.5">Cancel</span>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    </div>

   <!-- Add/Edit Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 dark:bg-black/80 backdrop-blur-sm flex items-center justify-center z-50 p-4 transition-colors duration-200">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden shadow-2xl transition-colors duration-200">
        <!-- Modal Header -->
        <div class="relative py-6 px-8 bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] text-white p-6 flex justify-between items-center transition-colors duration-200">
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
            <h4 class="text-sm font-bold text-slate-700 dark:text-[#e6edf3] uppercase tracking-wide mb-4 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-car text-green-600 dark:text-[#3fb950]"></i>
              Vehicle Selection
            </h4>
            <div>
              <label class="block text-sm font-semibold text-slate-700 dark:text-[#e6edf3] mb-2 transition-colors duration-200">Select Vehicle *</label>
              <select 
                v-model="form.vehicle_id" 
                required
                class="w-full px-4 py-3 border border-slate-300 dark:border-[#30363d] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-[#3fb950] focus:border-transparent bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200"
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
            <h4 class="text-sm font-bold text-slate-700 dark:text-[#e6edf3] uppercase tracking-wide mb-4 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-map-marked-alt text-green-600 dark:text-[#3fb950]"></i>
              Route Information
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-semibold text-slate-700 dark:text-[#e6edf3] mb-2 transition-colors duration-200">Origin Location *</label>
                <input 
                  type="text" 
                  v-model="form.origin" 
                  required 
                  placeholder="Starting point"
                  class="w-full px-4 py-3 border border-slate-300 dark:border-[#30363d] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-[#3fb950] focus:border-transparent bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                >
              </div>
              <div>
                <label class="block text-sm font-semibold text-slate-700 dark:text-[#e6edf3] mb-2 transition-colors duration-200">Destination *</label>
                <input 
                  type="text" 
                  v-model="form.destination" 
                  required 
                  placeholder="End point"
                  class="w-full px-4 py-3 border border-slate-300 dark:border-[#30363d] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-[#3fb950] focus:border-transparent bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                >
              </div>
            </div>
          </div>

          <!-- Trip Details -->
          <div class="mb-6">
            <h4 class="text-sm font-bold text-slate-700 dark:text-[#e6edf3] uppercase tracking-wide mb-4 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-info-circle text-green-600 dark:text-[#3fb950]"></i>
              Trip Details
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">
                  <i class="fas fa-user mr-2"></i>Driver
                </label>
                <select 
                  v-model="form.driver_id" 
                  class="px-4 py-2.5 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200"
                >
                  <option value="">Select Driver</option>
                  <option v-for="driver in drivers" :key="driver.id" :value="driver.id">
                    {{ driver.employee_id }} - {{ driver.full_name }}
                  </option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-semibold text-slate-700 dark:text-[#e6edf3] mb-2 transition-colors duration-200">Start Odometer</label>
                <input 
                  type="number" 
                  v-model.number="form.start_odometer" 
                  step="0.1" 
                  min="0"
                  placeholder="e.g., 45000"
                  class="w-full px-4 py-3 border border-slate-300 dark:border-[#30363d] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-[#3fb950] focus:border-transparent bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                >
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-semibold text-slate-700 dark:text-[#e6edf3] mb-2 transition-colors duration-200">Trip Purpose</label>
                <select 
                  v-model="form.purpose" 
                  class="w-full px-4 py-3 border border-slate-300 dark:border-[#30363d] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-[#3fb950] focus:border-transparent bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200"
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
                <label class="block text-sm font-semibold text-slate-700 dark:text-[#e6edf3] mb-2 transition-colors duration-200">Passenger Count</label>
                <input 
                  type="number" 
                  v-model.number="form.passenger_count" 
                  min="0"
                  placeholder="e.g., 5"
                  class="w-full px-4 py-3 border border-slate-300 dark:border-[#30363d] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-[#3fb950] focus:border-transparent bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                >
              </div>
            </div>
          </div>
          

          <!-- Notes -->
          <div class="mb-6">
            <label class="block text-sm font-semibold text-slate-700 dark:text-[#e6edf3] mb-2 transition-colors duration-200">Additional Notes</label>
            <textarea 
              v-model="form.notes" 
              rows="4" 
              placeholder="Add any relevant information about this trip..."
              class="w-full px-4 py-3 border border-slate-300 dark:border-[#30363d] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 dark:focus:ring-[#3fb950] focus:border-transparent resize-none bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
            ></textarea>
          </div>

          <!-- Form Actions -->
          <div class="flex gap-3 pt-6 border-t border-slate-200 dark:border-[#30363d] transition-colors duration-200">
            <button 
              type="button" 
              @click="closeModal" 
              class="flex-1 px-6 py-3 bg-slate-100 dark:bg-[#1c2128] text-slate-700 dark:text-[#e6edf3] rounded-lg font-semibold hover:bg-slate-200 dark:hover:bg-[#21262d] transition-colors"
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
    <div v-if="selectedTrip" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-[60] backdrop-blur-sm p-4 transition-colors duration-200" @click.self="selectedTrip = null">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-3xl max-h-[90vh] overflow-hidden shadow-2xl transition-colors duration-200">
        <div class="py-6 px-8 bg-gradient-to-r from-emerald-800 to-emerald-600 dark:from-[#1a2f23] dark:to-[#0f1e13] text-white flex justify-between items-center transition-colors duration-200">
          <div>
            <h3 class="text-xl font-bold">{{ selectedTrip.trip_id }}</h3>
            <p class="text-green-100 dark:text-emerald-200 text-sm transition-colors duration-200">Trip Details</p>
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
              <h4 class="text-sm font-semibold text-gray-500 dark:text-[#8b949e] uppercase mb-3 transition-colors duration-200">Vehicle & Driver</h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Vehicle</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ getVehicleDisplay(selectedTrip.vehicle_id) }}</span>
                </div>
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Driver</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ getDriverDisplay(selectedTrip.driver_id) }}</span>
                </div>
              </div>
            </div>

            <!-- Trip Details -->
            <div>
              <h4 class="text-sm font-semibold text-gray-500 dark:text-[#8b949e] uppercase mb-3 transition-colors duration-200">Trip Information</h4>
              <div class="space-y-2">
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Origin</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedTrip.origin || 'Not specified' }}</span>
                </div>
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Destination</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedTrip.destination }}</span>
                </div>
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Purpose</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedTrip.purpose }}</span>
                </div>
              </div>
            </div>

            <!-- Schedule -->
            <div>
              <h4 class="text-sm font-semibold text-gray-500 dark:text-[#8b949e] uppercase mb-3 transition-colors duration-200">Schedule</h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div v-if="selectedTrip.actual_start_time" class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Start Time</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ formatActualTime(selectedTrip.actual_start_time) }}</span>
                </div>
                <div v-else class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Start Time</span>
                  <span class="font-medium text-gray-400 dark:text-[#6e7681] transition-colors duration-200">Not Started</span>
                </div>
                <div v-if="selectedTrip.actual_end_time" class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">End Time</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ formatActualTime(selectedTrip.actual_end_time) }}</span>
                </div>
                <div v-else class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">End Time</span>
                  <span class="font-medium text-gray-400 dark:text-[#6e7681] transition-colors duration-200">Not Completed</span>
                </div>
              </div>
            </div>

            <!-- Passengers -->
            <div v-if="selectedTrip.passenger_name || selectedTrip.passenger_count">
              <h4 class="text-sm font-semibold text-gray-500 dark:text-[#8b949e] uppercase mb-3 transition-colors duration-200">Passenger Details</h4>
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div v-if="selectedTrip.passenger_name" class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Name</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedTrip.passenger_name }}</span>
                </div>
                <div v-if="selectedTrip.passenger_count" class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Count</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedTrip.passenger_count }}</span>
                </div>
                <div v-if="selectedTrip.passenger_department" class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Department</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedTrip.passenger_department }}</span>
                </div>
              </div>
            </div>

            <!-- Metrics -->
            <div v-if="selectedTrip.start_odometer || selectedTrip.distance_km">
              <h4 class="text-sm font-semibold text-gray-500 dark:text-[#8b949e] uppercase mb-3 transition-colors duration-200">Trip Metrics</h4>
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div v-if="selectedTrip.start_odometer" class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Start Odometer</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedTrip.start_odometer }} km</span>
                </div>
                <div v-if="selectedTrip.end_odometer" class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">End Odometer</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedTrip.end_odometer }} km</span>
                </div>
                <div v-if="selectedTrip.distance_km" class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Distance</span>
                  <span class="font-medium text-blue-600 dark:text-blue-400 transition-colors duration-200">{{ selectedTrip.distance_km }} km</span>
                </div>
              </div>
            </div>

            <!-- Notes -->
            <div v-if="selectedTrip.notes">
              <h4 class="text-sm font-semibold text-gray-500 dark:text-[#8b949e] uppercase mb-3 transition-colors duration-200">Notes</h4>
              <p class="text-gray-700 dark:text-[#e6edf3] leading-relaxed py-3 px-4 bg-gray-50 dark:bg-[#1c2128] rounded-lg border-l-4 border-emerald-600 dark:border-[#3fb950] transition-colors duration-200">
                {{ selectedTrip.notes }}
              </p>
            </div>

            <!-- Cancellation Reason -->
            <div v-if="selectedTrip.cancellation_reason">
              <h4 class="text-sm font-semibold text-gray-500 dark:text-[#8b949e] uppercase mb-3 transition-colors duration-200">Cancellation Reason</h4>
              <p class="text-gray-700 dark:text-[#e6edf3] leading-relaxed py-3 px-4 bg-red-50 dark:bg-red-900/20 rounded-lg border-l-4 border-red-500 dark:border-red-600 transition-colors duration-200">
                {{ selectedTrip.cancellation_reason }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Complete Trip Modal -->
    <div v-if="tripToComplete" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-[60] backdrop-blur-sm p-4 transition-colors duration-200">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-md shadow-2xl transition-colors duration-200">
        <div class="py-6 px-8 bg-gradient-to-r from-purple-500 to-purple-600 text-white flex justify-between items-center rounded-t-2xl">
          <h3 class="text-xl font-semibold">Complete Trip</h3>
          <button @click="tripToComplete = null" class="bg-white/10 hover:bg-white/20 w-8 h-8 rounded-lg flex items-center justify-center transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8">
          <div class="mb-6">
            <label class="block text-sm font-semibold text-gray-700 dark:text-[#e6edf3] mb-2 transition-colors duration-200">End Odometer Reading <span class="text-red-500">*</span></label>
            <input
              type="number"
              v-model="completeForm.end_odometer"
              placeholder="Final mileage"
              required
              class="w-full py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 dark:focus:ring-purple-400 bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200"
            />
            <p class="text-xs text-gray-500 dark:text-[#8b949e] mt-2 transition-colors duration-200">
              <i class="fas fa-info-circle mr-1"></i>
              Start: {{ tripToComplete.start_odometer }} km
            </p>
          </div>
          <div class="flex gap-4 justify-end">
            <button @click="tripToComplete = null" class="px-4 py-2 border border-gray-300 dark:border-[#30363d] rounded-lg hover:bg-gray-50 dark:hover:bg-[#1c2128] transition-colors text-gray-700 dark:text-[#e6edf3]">
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
    <div v-if="tripToApprove" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-[60] backdrop-blur-sm p-4 transition-colors duration-200">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-md shadow-2xl transition-colors duration-200">
        <div class="py-6 px-8 bg-gradient-to-r from-emerald-500 to-emerald-600 dark:from-[#2d4a2f] dark:to-[#1a2f23] text-white flex justify-between items-center rounded-t-2xl transition-colors duration-200">
          <h3 class="text-xl font-semibold">Approve Trip</h3>
          <button @click="closeApproveModal" class="bg-white/10 hover:bg-white/20 w-8 h-8 rounded-lg flex items-center justify-center transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8">
          <p class="text-lg text-gray-700 dark:text-[#e6edf3] mb-6 transition-colors duration-200">Approve trip <strong>{{ tripToApprove?.trip_id }}</strong>?</p>
          <div class="flex gap-4 justify-end">
            <button @click="closeApproveModal" class="px-4 py-2 border border-gray-300 dark:border-[#30363d] rounded-lg hover:bg-gray-50 dark:hover:bg-[#1c2128] transition-colors text-gray-700 dark:text-[#e6edf3]">
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

    <!-- Cancel Confirmation Modal -->
    <div v-if="tripToCancel" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-[60] backdrop-blur-sm p-4 transition-colors duration-200">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-md shadow-2xl transition-colors duration-200">
        <div class="py-6 px-8 bg-gradient-to-r from-red-500 to-red-600 text-white flex justify-between items-center rounded-t-2xl">
          <h3 class="text-xl font-semibold">Cancel Trip</h3>
          <button @click="tripToCancel = null" class="bg-white/10 hover:bg-white/20 w-8 h-8 rounded-lg flex items-center justify-center transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8">
          <p class="text-lg text-gray-700 dark:text-[#e6edf3] mb-4 transition-colors duration-200">Cancel trip <strong>{{ tripToCancel.trip_id }}</strong>?</p>
          <div class="mb-6">
            <label class="block text-sm font-semibold text-gray-700 dark:text-[#e6edf3] mb-2 transition-colors duration-200">Reason for Cancellation</label>
            <textarea
              v-model="cancelForm.reason"
              placeholder="Enter reason..."
              rows="3"
              class="w-full py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 dark:focus:ring-red-400 resize-y bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
            ></textarea>
          </div>
          <div class="flex gap-4 justify-end">
            <button @click="tripToCancel = null" class="px-4 py-2 border border-gray-300 dark:border-[#30363d] rounded-lg hover:bg-gray-50 dark:hover:bg-[#1c2128] transition-colors text-gray-700 dark:text-[#e6edf3]">
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
import { useToast } from '../composables/useToast'

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
    const { success, error, warning } = useToast()
    
    const trips = ref([])
    const viewMode = ref('grid')
    const loading = ref(true)
    const submitting = ref(false)
    const searchQuery = ref('')
    const statusFilter = ref('')
    
    const showModal = ref(false)
    const editingTrip = ref(null)
    const selectedTrip = ref(null)
    const tripToApprove = ref(null)
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
      
      try {
        // Database stores all timestamps in UTC
        // JavaScript automatically converts UTC to local time when creating a Date object
        // So we just format it as local time
        let date = new Date(dateString)
        if (isNaN(date.getTime())) return ''
        
        // Format directly as local time (JavaScript handles UTC to local conversion)
        return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      } catch (error) {
        console.error('Error formatting date:', dateString, error)
        return ''
      }
    }

    // Format function for actual_start_time and actual_end_time
    // These are correctly saved as UTC (using toISOString()), so use normal JavaScript conversion
    const formatActualTime = (dateString) => {
      if (!dateString) return ''
      
      try {
        // These timestamps are correctly stored in UTC
        // JavaScript automatically converts UTC to local time when creating a Date object
        let date = new Date(dateString)
        if (isNaN(date.getTime())) return ''
        
        // Format directly as local time (JavaScript handles UTC to local conversion)
        return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      } catch (error) {
        console.error('Error formatting actual time:', dateString, error)
        return ''
      }
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

    const deleteTrip = async (trip) => {
      if (!confirm('Are you sure you want to delete this trip? This action cannot be undone.')) return

      try {
        const { error } = await supabase
          .from('trips')
          .delete()
          .eq('id', trip.id)
        
        if (error) throw error
        
        trips.value = trips.value.filter(t => t.id !== trip.id)
        success('Trip deleted successfully!')
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
          vehicle_id: form.vehicle_id || null,
          driver_id: form.driver_id || null,
          origin: form.origin || null,
          destination: form.destination,
          purpose: form.purpose || null,
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

          success('Trip updated successfully!')
        } else {
          const { data, error } = await supabase
            .from('trips')
            .insert(tripData)
            .select()
            .single()
          
          if (error) throw error
          trips.value.unshift(data)
          emit('trip-added')
          success('Trip created successfully!')
        }

        closeModal()
      } catch (err) {
        console.error('Error submitting trip:', err)
        error('Error: ' + err.message)
      } finally {
        submitting.value = false
      }
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
      } catch (err) {
        console.error('Error completing trip:', err)
        error('Error: ' + err.message)
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

        // Always update vehicle status to available when trip is cancelled
        if (tripToCancel.value.vehicle_id) {
          const { error: vehicleError } = await supabase
            .from('vehicles')
            .update({ status: 'available' })
            .eq('id', tripToCancel.value.vehicle_id)
          
          if (vehicleError) {
            console.error('Error updating vehicle status:', vehicleError)
          }
        }
        
        success('Trip cancelled')
        tripToCancel.value = null
      } catch (err) {
        console.error('Error cancelling trip:', err)
        error('Error: ' + err.message)
      }
    }

    onMounted(() => {
      loadTrips()
    })

    return {
      viewMode,
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
      tripToApprove,
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
      formatActualTime,
      getVehicleDisplay,
      getDriverDisplay,
      getDriverNameById,
      onVehicleSelect,
      openAddModal,
      closeModal,
      editTrip,
      viewTrip,
      deleteTrip,
      submitForm, 
      confirmApprove,
      closeApproveModal,
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
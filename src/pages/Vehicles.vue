<template>
  <div class="flex h-screen bg-gradient-to-br from-gray-50 to-gray-100">
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

    <main class="flex flex-1 flex-col transition-all duration-300 ease-in-out min-w-0" :class="{ '!ml-0': sidebarCollapsed || !sidebarOpen }">
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
                <h1 class="text-xl sm:text-2xl font-bold">Fleet Management</h1>
                <p class="text-xs sm:text-sm text-green-100 mt-0.5">
                  {{ getTabSubtitle() }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Tabs -->
        <div class="border-t bg-[#155c1a]/60">
          <div class="px-4 sm:px-6 flex w-full justify-between items-center overflow-x-auto">
            
            <div class="flex gap-1">
              <button
                v-for="tab in tabs"
                :key="tab.id"
                @click="switchTab(tab.id)"
                class="px-4 sm:px-6 py-3 font-medium text-sm capitalize transition-all whitespace-nowrap"
                :class="activeTab === tab.id
                  ? 'text-white border-b-2 border-white'
                  : 'text-green-200 hover:text-white hover:bg-green-900/30'"
              >
                <i :class="tab.icon" class="mr-2"></i>
                {{ tab.label }}
              </button>
            </div> 
          </div>
        </div>
      </header>

      <!-- Main Content Area -->
      <div class="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8  bg-green-100/80">
        <div class="max-w-7xl mx-auto">
          
          <!-- VEHICLES TAB -->
          <div v-show="activeTab === 'vehicles'">
            <!-- Toolbar -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6">
              <div class="flex flex-col lg:flex-row gap-4">
                <div class="flex-1 relative">
                  <i class="fas fa-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                  <input
                    type="text"
                    v-model="searchQuery"
                    placeholder="Search vehicles by plate, ID, or driver..."
                    class="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent"
                  />
                </div>

                <div class="flex items-center gap-2 flex-wrap">
                  <div class="flex bg-gray-100 rounded-lg p-1">
                    <button
                      @click="viewMode = 'grid'"
                      class="p-2 rounded transition-colors"
                      :class="viewMode === 'grid' ? 'bg-white shadow-sm' : 'hover:bg-gray-200'"
                    >
                      <i class="fas fa-th"></i>
                    </button>
                    <button
                      @click="viewMode = 'list'"
                      class="p-2 rounded transition-colors"
                      :class="viewMode === 'list' ? 'bg-white shadow-sm' : 'hover:bg-gray-200'"
                    >
                      <i class="fas fa-list"></i>
                    </button>
                  </div>

                  <button
                    @click="showFilters = !showFilters"
                    class="flex items-center gap-2 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    <i class="fas fa-filter"></i>
                    <span class="hidden sm:inline">Filters</span>
                  </button>

                  <button 
                    @click="clearFilters"
                    v-if="hasActiveFilters"
                    class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    <i class="fas fa-times mr-2"></i>
                    <span class="hidden sm:inline">Clear</span>
                  </button>
                  <button 
                    v-if="activeTab === 'vehicles'"
                    @click="openAddModal"
                    class="sm:flex-none bg-gradient bg-gradient-to-br from-green-800 to-green-700 text-white py-2 px-2 rounded-lg font-md\
                    4  flex items-center justify-center gap-2 hover:from-green-700 hover:to-green-800 transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 whitespace-nowrap"
                  >
                    <i class="fas fa-plus"></i>
                    <span class="hidden sm:inline">Add Vehicle</span>
                    <span class="sm:hidden">Add</span>
                  </button>
                </div>
              </div>

              <!-- Filters Panel -->
              <div v-if="showFilters" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4 mt-4 pt-4 border-t border-gray-200">
                <select v-model="statusFilter" class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C]">
                  <option value="">All Status</option>
                  <option value="available">Available</option>
                  <option value="in_use">In Use</option>
                  <option value="maintenance">Maintenance</option>
                  <option value="out_of_service">Out of Service</option>
                </select>
                <select v-model="typeFilter" class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C]">
                  <option value="">All Types</option>
                  <option value="car">Car</option>
                  <option value="van">Van</option>
                  <option value="utility vehicles">Utility Vehicles</option>
                  <option value="minibus">Minibus</option>
                </select>
                <select v-model="departmentFilter" class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C]">
                  <option value="">All Departments</option>
                  <option v-for="dept in uniqueDepartments" :key="dept" :value="dept">{{ dept }}</option>
                </select>
              </div>
            </div>

            <!-- Stats Cards -->
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6">
              <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
                <p class="text-sm text-gray-600 mb-1">Total</p>
                <p class="text-3xl font-bold text-gray-900">{{ vehicles.length }}</p>
              </div>
              <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
                <p class="text-sm text-gray-600 mb-1">Available</p>
                <p class="text-3xl font-bold text-emerald-600">{{ vehiclesByStatus('available') }}</p>
              </div>
              <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
                <p class="text-sm text-gray-600 mb-1">In Use</p>
                <p class="text-3xl font-bold text-blue-600">{{ vehiclesByStatus('in_use') }}</p>
              </div>
              <div class="bg-white rounded-xl p-5 border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
                <p class="text-sm text-gray-600 mb-1">Maintenance</p>
                <p class="text-3xl font-bold text-amber-600">{{ vehiclesByStatus('maintenance') }}</p>
              </div>
            </div>

            <!-- Loading State -->
            <div v-if="loading" class="text-center py-16 bg-white rounded-xl shadow-sm">
              <i class="fas fa-spinner fa-spin text-5xl mb-5 text-[#0A400C]"></i>
              <p class="text-gray-600">Loading vehicles...</p>
            </div>

            <!-- Empty State -->
            <div v-else-if="filteredVehicles.length === 0" class="text-center py-16 bg-white rounded-xl shadow-sm">
              <i class="fas fa-car text-7xl mb-5 text-gray-300"></i>
              <h3 class="text-2xl font-bold text-gray-900 mb-2">No vehicles found</h3>
              <p class="text-gray-600">{{ hasActiveFilters ? 'Try adjusting your filters' : 'Start by adding your first vehicle' }}</p>
            </div>

            <!-- Grid View -->
            <div v-else-if="viewMode === 'grid'" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
              <div
                v-for="vehicle in filteredVehicles"
                :key="vehicle.id"
                class="bg-white rounded-xl border border-gray-200 hover:border-[#0A400C] transition-all duration-300 hover:shadow-xl overflow-hidden"
              >
                <div class="h-1" :class="getStatusColor(vehicle.status, 'bg')"></div>
                
                <div class="p-6">
                  <div class="flex items-start justify-between mb-4">
                    <div class="flex-1">
                      <div class="flex items-center gap-2 mb-1">
                        <h3 class="text-lg font-bold text-gray-900">{{ vehicle.plate_number }}</h3>
                        <span class="text-xs text-gray-500 bg-gray-100 px-2 py-0.5 rounded">{{ vehicle.vehicle_id }}</span>
                      </div>
                      <p class="text-sm text-gray-600">{{ vehicle.year }} • {{ vehicle.vehicle_type.toUpperCase() }}</p>
                    </div>
                    <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold border"
                          :class="getStatusColor(vehicle.status, 'badge')">
                      <i :class="getStatusIcon(vehicle.status)"></i>
                      {{ formatStatus(vehicle.status) }}
                    </span>
                  </div>

                  <div class="space-y-3 mb-4">
                    <div v-if="vehicle.assigned_driver_code" class="flex items-center gap-2 text-sm">
                      <i class="fas fa-user w-4 text-gray-400"></i>
                      <span class="text-gray-700">{{ getDriverName(vehicle.assigned_driver_code) }}</span>
                    </div>
                    <div class="flex items-center gap-2 text-sm">
                      <i class="fas fa-building w-4 text-gray-400"></i>
                      <span class="text-gray-700">{{ vehicle.assigned_department || 'Not assigned' }}</span>
                    </div>
                  </div>

                  <div class="grid grid-cols-4 gap-2">
                    <button @click="viewVehicle(vehicle)" class="flex items-center justify-center p-1 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-colors" title="View">
                       <i class="fas fa-eye mr-1"></i> <span>view</span>               
                    </button>
                    <button @click="viewHistory(vehicle)" class="flex items-center justify-center p-2 rounded-lg bg-purple-50 text-purple-600 hover:bg-purple-100 transition-colors" title="History">
                      <i class="fas fa-history"></i>    
                    </button>
                    <button @click="viewLiveMap(vehicle)" class="flex items-center justify-center p-2 rounded-lg bg-teal-50 text-teal-600 hover:bg-teal-100 transition-colors" title="Map">
                      <i class="fas fa-map-marker-alt"></i>
                    </button>
                    <button @click="confirmDelete(vehicle)" class="flex items-center justify-center p-2 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 transition-colors" title="Delete">
                      <i class="fas fa-trash"></i>
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Table View -->
            <div v-else class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
              <div class="overflow-x-auto">
                <table class="w-full">
                  <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Vehicle</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Year</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Type</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Status</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Driver</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Department</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="vehicle in filteredVehicles" :key="vehicle.id" class="border-b border-gray-100 hover:bg-gray-50 transition-colors">
                      <td class="px-4 py-4">
                        <div class="font-semibold text-gray-900">{{ vehicle.plate_number }}</div>
                        <div class="text-xs text-gray-500">{{ vehicle.vehicle_id }}</div>
                      </td>
                      <td class="px-4 py-4 text-sm text-gray-700">{{ vehicle.year }}</td>
                      <td class="px-4 py-4 text-sm text-gray-700">{{ vehicle.vehicle_type.toUpperCase() }}</td>
                      <td class="px-4 py-4">
                        <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold border"
                              :class="getStatusColor(vehicle.status, 'badge')">
                          <i :class="getStatusIcon(vehicle.status)"></i>
                          {{ formatStatus(vehicle.status) }}
                        </span>
                      </td>
                      <td class="px-4 py-4 text-sm text-gray-700">{{ getDriverName(vehicle.assigned_driver_code) || '-' }}</td>
                      <td class="px-4 py-4 text-sm text-gray-700">{{ vehicle.assigned_department || '-' }}</td>
                      <td class="px-4 py-4">
                        <div class="flex items-center gap-1">
                          <button @click="viewVehicle(vehicle)" class="p-1.5 rounded hover:bg-blue-50 text-blue-600" title="View">
                            <i class="fas fa-eye"></i> <span>view</span> 
                          </button>
                          <button @click="editVehicle(vehicle)" class="p-1.5 rounded hover:bg-amber-50 text-amber-600" title="Edit">
                            <i class="fas fa-edit"></i>
                          </button>
                          <button @click="viewHistory(vehicle)" class="p-1.5 rounded hover:bg-purple-50 text-purple-600" title="History">
                            <i class="fas fa-history"></i>
                          </button>
                          <button @click="viewLiveMap(vehicle)" class="p-1.5 rounded hover:bg-teal-50 text-teal-600" title="Map">
                            <i class="fas fa-map-marker-alt"></i>
                          </button>
                          <button @click="confirmDelete(vehicle)" class="p-1.5 rounded hover:bg-red-50 text-red-600" title="Delete">
                            <i class="fas fa-trash"></i>
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- DRIVERS TAB -->
          <div v-show="activeTab === 'drivers'">
            <DriverManagement @driver-updated="loadDrivers" />
          </div>

          <!-- TRIPS TAB -->
          <div v-show="activeTab === 'trips'">
            <TripManagement 
              :vehicles="vehicles" 
              :drivers="drivers"
              @trip-added="loadTrips"
            />
          </div>

        </div>
      </div>
    </main>

    <!-- Add/Edit Vehicle Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] backdrop-blur-sm p-4" @click.self="closeModal">
      <div class="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden shadow-2xl animate-modalSlideIn">
        <!-- Modal Header -->
        <div class="relative py-6 px-8 bg-gradient-to-br from-green-800 to-green-600 text-white">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-2xl font-bold">{{ editingVehicle ? 'Edit Vehicle' : 'Register New Vehicle' }}</h3>
              <p class="text-green-100 text-sm mt-1">{{ editingVehicle ? 'Update vehicle information' : 'Add a new vehicle to your fleet' }}</p>
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

        <!-- Modal Body -->
        <form @submit.prevent="submitVehicleForm" class="p-8 overflow-y-auto max-h-[calc(90vh-120px)]">
          <div class="space-y-6">
            
            <!-- Vehicle Identification Section -->
            <div class="bg-gray-50 rounded-xl p-5 border border-gray-200">
              <h4 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-4 flex items-center gap-2">
                <i class="fas fa-id-card text-[#0A400C]"></i>
                Vehicle Identification
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 text-sm flex items-center gap-2">
                    Vehicle ID <span class="text-red-500">*</span>
                    <span v-if="editingVehicle" class="text-xs text-gray-500 font-normal">(Cannot be changed)</span>
                  </label>
                  <input
                    type="text"
                    v-model="vehicleForm.vehicle_id"
                    placeholder="e.g., MP-001"
                    required
                    :disabled="editingVehicle !== null"
                    class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent transition-all disabled:bg-gray-100 disabled:cursor-not-allowed"
                  />
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 text-sm">Plate Number <span class="text-red-500">*</span></label>
                  <input
                    type="text"
                    v-model="vehicleForm.plate_number"
                    placeholder="e.g., ABC-1234"
                    required
                    class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent transition-all uppercase"
                  />
                </div>
              </div>
            </div>

            <!-- Vehicle Specifications Section -->
            <div class="bg-gray-50 rounded-xl p-5 border border-gray-200">
              <h4 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-4 flex items-center gap-2">
                <i class="fas fa-cog text-[#0A400C]"></i>
                Vehicle Specifications
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 text-sm">Year <span class="text-red-500">*</span></label>
                  <input
                    type="number"
                    v-model="vehicleForm.year"
                    :min="1990"
                    :max="new Date().getFullYear() + 1"
                    required
                    class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent transition-all"
                  />
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 text-sm">Vehicle Type <span class="text-red-500">*</span></label>
                  <select 
                    v-model="vehicleForm.vehicle_type" 
                    required 
                    class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent transition-all bg-white"
                  >
                    <option value="">Select Type</option>
                    <option value="car">Car</option>
                    <option value="van">Van</option>
                    <option value="utility vehicles">Utility Vehicles</option>
                    <option value="minibus">Minibus</option>
                  </select>
                </div>
              </div>
            </div>

            <!-- Assignment Section -->
            <div class="bg-gray-50 rounded-xl p-5 border border-gray-200">
              <h4 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-4 flex items-center gap-2">
                <i class="fas fa-users text-[#0A400C]"></i>
                Driver & Department Assignment
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 text-sm">Assigned Driver</label>
                  <select
                    v-model="vehicleForm.assigned_driver_code"
                    class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent transition-all bg-white"
                  >
                    <option value="">No driver assigned</option>
                    <option v-for="driver in drivers" :key="driver.id" :value="driver.employee_id">
                      {{ driver.full_name }} ({{ driver.employee_id }})
                    </option>
                  </select>
                  <p class="text-xs text-gray-500 mt-1">
                    <i class="fas fa-info-circle mr-1"></i>
                    {{ drivers.length }} registered driver(s) available
                  </p>
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 text-sm">Status</label>
                  <select 
                    v-model="vehicleForm.status" 
                    class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent transition-all bg-white"
                  >
                    <option value="available">Available</option>
                    <option value="in_use">In Use</option>
                    <option value="maintenance">Under Maintenance</option>
                    <option value="out_of_service">Out of Service</option>
                  </select>
                </div>
              </div>
              
              <div class="flex flex-col gap-2 mt-5">
                <label class="font-semibold text-gray-700 text-sm">Department</label>
                <input 
                  v-model="vehicleForm.assigned_department" 
                  type="text"
                  placeholder="e.g., Administration, HR, Maintenance"
                  class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent transition-all"
                />
              </div>
            </div>

            <!-- Additional Information Section -->
            <div class="bg-gray-50 rounded-xl p-5 border border-gray-200">
              <h4 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-4 flex items-center gap-2">
                <i class="fas fa-clipboard text-[#0A400C]"></i>
                Additional Information
              </h4>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 text-sm">Notes</label>
                <textarea
                  v-model="vehicleForm.notes"
                  placeholder="Enter any additional notes, remarks, or special instructions about this vehicle..."
                  rows="4"
                  class="py-3 px-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] focus:border-transparent transition-all resize-y"
                ></textarea>
              </div>
            </div>

          </div>

          <!-- Form Actions -->
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
              <i v-else class="fas" :class="editingVehicle ? 'fa-check' : 'fa-plus'"></i>
              {{ editingVehicle ? 'Update Vehicle' : 'Add Vehicle' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- View Vehicle Details Modal -->
    <div v-if="selectedVehicle" class="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] backdrop-blur-sm p-4" @click.self="selectedVehicle = null">
      <div class="bg-white rounded-2xl w-full max-w-md max-h-[90vh] overflow-hidden shadow-2xl animate-modalSlideIn">
        <!-- Modal Header -->
        <div class="relative py-4 px-6 bg-gradient-to-r from-[#0A400C] via-[#0d4f0f] to-[#155c1a] text-white">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 bg-white/10 rounded-lg flex items-center justify-center">
                <i class="fas fa-car text-lg"></i>
              </div>
              <div>
                <h3 class="text-lg font-bold">{{ selectedVehicle.plate_number }}</h3>
                <p class="text-green-100 text-xs">ID: {{ selectedVehicle.vehicle_id }}</p>
              </div>
            </div>
            <button 
              @click="selectedVehicle = null" 
              class="w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
            >
              <i class="fas fa-times text-sm"></i>
            </button>
          </div>
        </div>

        <!-- Modal Body -->
        <div class="p-5 overflow-y-auto max-h-[calc(90vh-100px)]">
          
          <!-- Status Badge -->
          <div class="mb-4">
            <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold border"
                  :class="getStatusColor(selectedVehicle.status, 'badge')">
              <i :class="getStatusIcon(selectedVehicle.status)" class="text-xs"></i>
              {{ formatStatus(selectedVehicle.status) }}
            </span>
          </div>

          <!-- Vehicle Info Grid -->
          <div class="space-y-3 mb-4">
            <div class="flex items-center justify-between py-2 border-b border-gray-100">
              <span class="text-xs text-gray-500 uppercase font-medium">Year</span>
              <span class="text-sm font-bold text-gray-900">{{ selectedVehicle.year }}</span>
            </div>
            <div class="flex items-center justify-between py-2 border-b border-gray-100">
              <span class="text-xs text-gray-500 uppercase font-medium">Type</span>
              <span class="text-sm font-bold text-gray-900">{{ selectedVehicle.vehicle_type.toUpperCase() }}</span>
            </div>
            <div class="flex items-center justify-between py-2 border-b border-gray-100">
              <span class="text-xs text-gray-500 uppercase font-medium">Driver</span>
              <span class="text-sm font-semibold text-gray-900">{{ getDriverName(selectedVehicle.assigned_driver_code) || 'Unassigned' }}</span>
            </div>
            <div class="flex items-center justify-between py-2 border-b border-gray-100">
              <span class="text-xs text-gray-500 uppercase font-medium">Department</span>
              <span class="text-sm font-semibold text-gray-900">{{ selectedVehicle.assigned_department || 'Not assigned' }}</span>
            </div>
          </div>

          <!-- Notes Section -->
          <div v-if="selectedVehicle.notes" class="mb-4">
            <p class="text-xs text-gray-500 uppercase font-medium mb-2">Notes</p>
            <div class="bg-amber-50 border-l-3 border-amber-400 rounded p-3">
              <p class="text-sm text-gray-700 leading-relaxed">{{ selectedVehicle.notes }}</p>
            </div>
          </div>

          <!-- Registration Info -->
          <div class="text-xs text-gray-500 space-y-1 mb-5 pt-3 border-t border-gray-100">
            <p><i class="fas fa-calendar-plus text-green-600 mr-2"></i>Added: {{ formatDate(selectedVehicle.created_at) }}</p>
            <p v-if="selectedVehicle.updated_at !== selectedVehicle.created_at">
              <i class="fas fa-edit text-blue-600 mr-2"></i>Updated: {{ formatDate(selectedVehicle.updated_at) }}
            </p>
          </div>

          <!-- Action Button -->
          <button 
            @click="editVehicle(selectedVehicle); selectedVehicle = null" 
            class="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-gradient-to-r from-amber-500 to-amber-600 text-white rounded-lg hover:from-amber-600 hover:to-amber-700 transition-all font-semibold text-sm shadow-md"
          >
            <i class="fas fa-edit"></i>
            Edit Vehicle
          </button>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="vehicleToDelete" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm p-4">
      <div class="bg-white rounded-2xl w-full max-w-md shadow-2xl">
        <div class="py-6 px-8 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br from-red-500 to-red-600 text-white rounded-t-2xl">
          <h3 class="text-xl font-semibold">Confirm Deletion</h3>
          <button @click="vehicleToDelete = null" class="bg-white/10 hover:bg-white/20 w-8 h-8 rounded-lg flex items-center justify-center transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8 text-center">
          <p class="text-lg text-gray-700 mb-6">Are you sure you want to delete vehicle <strong>{{ vehicleToDelete.plate_number }}</strong>? This action cannot be undone.</p>
          <div class="flex gap-4 justify-center">
            <button @click="vehicleToDelete = null" class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
              Cancel
            </button>
            <button @click="deleteVehicle" class="flex items-center gap-2 bg-gradient-to-br from-red-500 to-red-600 text-white px-5 py-2.5 rounded-lg font-semibold hover:scale-105 transition-all shadow-lg">
              <i class="fas fa-trash"></i>
              Delete Vehicle
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../lib/supabase'
import Navbar from './Navbar.vue'
import DriverManagement from './DriverManagement.vue'
import TripManagement from './TripManagement.vue'

export default {
  name: 'VehicleManagement',
  components: {
    Navbar,
    DriverManagement,
    TripManagement
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    // State
    const activeTab = computed(() => route.query.tab || 'vehicles')
    const sidebarCollapsed = ref(false)
    const sidebarOpen = ref(true)
    const viewMode = ref('grid')
    const showFilters = ref(false)
    
    const vehicles = ref([])
    const drivers = ref([])
    const loading = ref(true)
    const submitting = ref(false)
    
    // Filters
    const searchQuery = ref('')
    const statusFilter = ref('')
    const typeFilter = ref('')
    const departmentFilter = ref('')
    
    // Modals
    const showModal = ref(false)
    const modalType = ref('vehicle')
    const editingVehicle = ref(null)
    const selectedVehicle = ref(null)
    const vehicleToDelete = ref(null)
    
    // Forms
    const vehicleForm = reactive({
      vehicle_id: '',
      plate_number: '',
      year: null,
      vehicle_type: '',
      status: 'available',
      assigned_driver_code: '',
      assigned_department: '',
      notes: ''
    })

    const tabs = [
      { id: 'vehicles', label: 'Vehicles', icon: 'fas fa-car' },
      { id: 'drivers', label: 'Drivers', icon: 'fas fa-user-tie' },
      { id: 'trips', label: 'Trips', icon: 'fas fa-route' }
    ]

    // Computed
    const filteredVehicles = computed(() => {
      let filtered = vehicles.value

      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        filtered = filtered.filter(v =>
          v.plate_number.toLowerCase().includes(query) ||
          v.vehicle_id.toLowerCase().includes(query) ||
          (v.assigned_driver_code && getDriverName(v.assigned_driver_code)?.toLowerCase().includes(query))
        )
      }

      if (statusFilter.value) {
        filtered = filtered.filter(v => v.status === statusFilter.value)
      }

      if (typeFilter.value) {
        filtered = filtered.filter(v => v.vehicle_type === typeFilter.value)
      }

      if (departmentFilter.value) {
        filtered = filtered.filter(v => v.assigned_department === departmentFilter.value)
      }

      return filtered
    })

    const hasActiveFilters = computed(() => {
      return searchQuery.value || statusFilter.value || typeFilter.value || departmentFilter.value
    })

    const uniqueDepartments = computed(() => {
      const depts = vehicles.value
        .map(v => v.assigned_department)
        .filter(d => d)
      return [...new Set(depts)]
    })

    const vehiclesByStatus = (status) => {
      return vehicles.value.filter(v => v.status === status).length
    }

    // Methods
    const getTabSubtitle = () => {
      const subtitles = {
        vehicles: 'Manage your fleet vehicles',
        drivers: 'Manage and register drivers',
        trips: 'Track and manage trips'
      }
      return subtitles[activeTab.value] || ''
    }

    const switchTab = (tab) => {
      router.push({ query: { tab } })
    }

    const switchToDriverTab = () => {
      closeModal()
      switchTab('drivers')
    }

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

    const getStatusColor = (status, type) => {
      const colors = {
        available: {
          bg: 'bg-emerald-500',
          badge: 'bg-emerald-50 text-emerald-700 border-emerald-200'
        },
        in_use: {
          bg: 'bg-blue-500',
          badge: 'bg-blue-50 text-blue-700 border-blue-200'
        },
        maintenance: {
          bg: 'bg-amber-500',
          badge: 'bg-amber-50 text-amber-700 border-amber-200'
        },
        out_of_service: {
          bg: 'bg-red-500',
          badge: 'bg-red-50 text-red-700 border-red-200'
        }
      }
      return colors[status]?.[type] || colors.available[type]
    }

    const getStatusIcon = (status) => {
      const icons = {
        available: 'fas fa-check-circle',
        in_use: 'fas fa-road',
        maintenance: 'fas fa-wrench',
        out_of_service: 'fas fa-times-circle'
      }
      return icons[status] || 'fas fa-question-circle'
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

    const formatDate = (dateString) => {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    }

    const getDriverName = (employeeId) => {
      if (!employeeId) return null
      const driver = drivers.value.find(d => d.employee_id === employeeId)
      return driver ? driver.full_name : employeeId
    }

    const clearFilters = () => {
      searchQuery.value = ''
      statusFilter.value = ''
      typeFilter.value = ''
      departmentFilter.value = ''
    }

    const loadVehicles = async () => {
      loading.value = true
      try {
        const { data, error } = await supabase
          .from('vehicles')
          .select('*')
          .order('created_at', { ascending: false })
        
        if (error) throw error
        vehicles.value = data || []
      } catch (error) {
        console.error('Error loading vehicles:', error)
        vehicles.value = []
      } finally {
        loading.value = false
      }
    }

    const loadDrivers = async () => {
      try {
        const { data, error } = await supabase
          .from('drivers')
          .select('id, employee_id, full_name, is_active')
          .order('full_name')

        if (error) throw error
        drivers.value = data || []
      } catch (error) {
        console.error('Error loading drivers:', error)
      }
    }

    const loadTrips = async () => {
      // This will be handled by TripManagement component
    }

    const openAddModal = () => {
      if (activeTab.value === 'vehicles') {
        modalType.value = 'vehicle'
        editingVehicle.value = null
        resetVehicleForm()
        showModal.value = true
      }
    }

    const closeModal = () => {
      showModal.value = false
      editingVehicle.value = null
      resetVehicleForm()
    }

    const resetVehicleForm = () => {
      Object.assign(vehicleForm, {
        vehicle_id: '',
        plate_number: '',
        year: null,
        vehicle_type: '',
        status: 'available',
        assigned_driver_code: '',
        assigned_department: '',
        notes: ''
      })
    }

    const editVehicle = (vehicle) => {
      editingVehicle.value = vehicle
      Object.assign(vehicleForm, {
        ...vehicle,
        assigned_driver_code: vehicle.assigned_driver_code || '',
        assigned_department: vehicle.assigned_department || ''
      })
      modalType.value = 'vehicle'
      showModal.value = true
    }

    const viewVehicle = (vehicle) => {
      selectedVehicle.value = vehicle
    }

    const viewHistory = (vehicle) => {
      router.push(`/trips/${vehicle.id}`)
    }

    const viewLiveMap = (vehicle) => {
      router.push(`/tripmap/${vehicle.id}`)
    }

    const submitVehicleForm = async () => {
      submitting.value = true
      try {
        const vehicleData = {
          vehicle_id: vehicleForm.vehicle_id,
          plate_number: vehicleForm.plate_number,
          year: parseInt(vehicleForm.year),
          vehicle_type: vehicleForm.vehicle_type,
          status: vehicleForm.status,
          assigned_driver_code: vehicleForm.assigned_driver_code || null,
          assigned_department: vehicleForm.assigned_department || null,
          notes: vehicleForm.notes || null
        }

        if (editingVehicle.value) {
          const { error } = await supabase
            .from('vehicles')
            .update(vehicleData)
            .eq('id', editingVehicle.value.id)
          
          if (error) throw error
          
          const index = vehicles.value.findIndex(v => v.id === editingVehicle.value.id)
          if (index !== -1) {
            vehicles.value[index] = {
              ...editingVehicle.value,
              ...vehicleData,
              updated_at: new Date().toISOString()
            }
          }
        } else {
          const { data, error } = await supabase
            .from('vehicles')
            .insert(vehicleData)
            .select()
            .single()
          
          if (error) throw error
          vehicles.value.unshift(data)
        }

        closeModal()
      } catch (error) {
        console.error('Error submitting form:', error)
        alert('Error: ' + error.message)
      } finally {
        submitting.value = false
      }
    }

    const confirmDelete = (vehicle) => {
      vehicleToDelete.value = vehicle
    }

    const deleteVehicle = async () => {
      if (!vehicleToDelete.value) return
      
      try {
        const { error } = await supabase
          .from('vehicles')
          .delete()
          .eq('id', vehicleToDelete.value.id)
        
        if (error) throw error

        vehicles.value = vehicles.value.filter(v => v.id !== vehicleToDelete.value.id)
        vehicleToDelete.value = null
      } catch (error) {
        console.error('Error deleting vehicle:', error)
        alert('Error deleting vehicle: ' + error.message)
      }
    }

    const handleResize = () => {
      const width = window.innerWidth
      if (width <= 1024) {
        sidebarOpen.value = false
        sidebarCollapsed.value = false
      } else {
        sidebarOpen.value = true
      }
    }

    // Lifecycle
    onMounted(async () => {
      await loadVehicles()
      await loadDrivers()
      
      window.addEventListener('resize', handleResize)
      handleResize()
    })

    watch(() => route.query.tab, (newTab) => {
      if (newTab === 'vehicles') {
        loadDrivers()
      }
    })

    return {
      activeTab,
      tabs,
      sidebarCollapsed,
      sidebarOpen,
      viewMode,
      showFilters,
      vehicles,
      drivers,
      loading,
      submitting,
      searchQuery,
      statusFilter,
      typeFilter,
      departmentFilter,
      filteredVehicles,
      hasActiveFilters,
      uniqueDepartments,
      showModal,
      modalType,
      editingVehicle,
      selectedVehicle,
      vehicleToDelete,
      vehicleForm,
      getTabSubtitle,
      switchTab,
      switchToDriverTab,
      toggleSidebar,
      closeSidebar,
      openSidebar,
      handleMenuClick,
      getStatusColor,
      getStatusIcon,
      formatStatus,
      formatDate,
      getDriverName,
      clearFilters,
      vehiclesByStatus,
      openAddModal,
      closeModal,
      editVehicle,
      viewVehicle,
      viewHistory,
      viewLiveMap,
      submitVehicleForm,
      confirmDelete,
      deleteVehicle,
      loadDrivers,
      loadTrips
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
</style>
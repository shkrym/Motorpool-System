<template>
  <div class="flex h-screen bg-gradient-to-br from-green-50 via-emerald-100 to-teal-100 dark:from-[#0d1117] dark:via-[#0d1117] dark:to-[#161b22] transition-colors duration-200">
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
      class="fixed inset-0 bg-black/50 dark:bg-black/70 z-40 lg:hidden transition-colors duration-200"
      @click="closeSidebar"
    ></div>

    <main class="flex flex-1 flex-col transition-all duration-300 ease-in-out min-w-0" :class="{ '!ml-0': sidebarCollapsed || !sidebarOpen }">
      <div class="sticky top-0 z-50">
        <PageHeader
          icon="fas fa-truck"
          title="Fleet Management"
          :subtitle="getTabSubtitle()"
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
          <template #actions>
            <div class="chip text-xs sm:text-sm hidden sm:inline-flex">
              {{ tabs.length }} sections
            </div>
          </template>
        </PageHeader>

        <!-- Tabs -->
        <div class="border-t bg-[#155c1a]/90 dark:bg-[#161b22] transition-colors duration-200">
          <div class="px-4 sm:px-6 flex w-full justify-between items-center overflow-x-auto">
            
            <div class="flex gap-1">
              <button
                v-for="tab in tabs"
                :key="tab.id"
                @click="switchTab(tab.id)"
                class="px-4 sm:px-6 py-3 font-medium text-sm capitalize transition-all whitespace-nowrap"
                :class="activeTab === tab.id
                  ? 'text-white dark:text-[#3fb950] border-b-2 border-white dark:border-[#3fb950]'
                  : 'text-green-200 dark:text-[#8b949e] hover:text-white dark:hover:text-[#3fb950] hover:bg-green-900/30 dark:hover:bg-[#1c2128]'"
              >
                <i :class="tab.icon" class="mr-2"></i>
                {{ tab.label }}
              </button>
            </div> 
          </div>
        </div>
      </div>

      <!-- Main Content Area -->
      <div class="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8 bg-green-100/80 dark:bg-[#0d1117] transition-colors duration-200">
        <div class="max-w-7xl mx-auto">
          
          <!-- VEHICLES TAB -->
          <div v-show="activeTab === 'vehicles'">
            <!-- Toolbar -->
            <div class="bg-white dark:bg-[#161b22] rounded-xl shadow-sm border border-gray-200 dark:border-[#30363d] p-4 mb-6 transition-colors duration-200">
              <div class="flex flex-col lg:flex-row gap-4">
                <div class="flex-1 relative">
                  <i class="fas fa-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 dark:text-[#8b949e]"></i>
                  <input
                    type="text"
                    v-model="searchQuery"
                    placeholder="Search vehicles by plate, ID, or driver..."
                    class="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent bg-white dark:bg-[#1c2128] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                  />
                </div>

                <div class="flex items-center gap-2 flex-wrap">
                  <button
                    @click="showFilters = !showFilters"
                    class="flex items-center gap-2 px-4 py-2 border border-gray-300 dark:border-[#30363d] rounded-lg hover:bg-gray-50 dark:hover:bg-[#1c2128] transition-colors text-gray-700 dark:text-[#e6edf3]"
                  >
                    <i class="fas fa-filter"></i>
                    <span class="hidden sm:inline">Filters</span>
                  </button>

                  <button 
                    @click="clearFilters"
                    v-if="hasActiveFilters"
                    class="px-4 py-2 border border-gray-300 dark:border-[#30363d] rounded-lg hover:bg-gray-50 dark:hover:bg-[#1c2128] transition-colors text-gray-700 dark:text-[#e6edf3]"
                  >
                    <i class="fas fa-times mr-2"></i>
                    <span class="hidden sm:inline">Clear</span>
                  </button>
                  <button 
                    v-if="activeTab === 'vehicles'"
                    @click="openAddModal"
                    class="btn btn-primary sm:flex-none whitespace-nowrap"
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
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-6">
              <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 hover:-translate-y-0.5 transition-all duration-300">
                <div class="flex items-center justify-between mb-3">
                  <div class="stat-card-icon bg-emerald-100 dark:bg-[#1a2f23] text-emerald-600 dark:text-[#3fb950]">
                    <i class="fas fa-truck"></i>
                  </div>
                </div>
                <div class="text-2xl sm:text-3xl font-bold text-slate-900 dark:text-[#e6edf3] transition-colors duration-200">{{ vehicles.length }}</div>
                <p class="text-xs text-slate-500 dark:text-[#8b949e] mt-1 tracking-wide uppercase transition-colors duration-200">Total Vehicles</p>
              </div>
              <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 hover:-translate-y-0.5 transition-all duration-300">
                <div class="flex items-center justify-between mb-3">
                  <div class="stat-card-icon bg-green-100 dark:bg-[#2d4a2f] text-green-600 dark:text-[#6fc276]">
                    <i class="fas fa-check-circle"></i>
                  </div>
                </div>
                <div class="text-2xl sm:text-3xl font-bold text-green-600 dark:text-[#6fc276] transition-colors duration-200">{{ vehiclesByStatus('available') }}</div>
                <p class="text-xs text-slate-500 dark:text-[#8b949e] mt-1 tracking-wide uppercase transition-colors duration-200">Available</p>
              </div>
              <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 hover:-translate-y-0.5 transition-all duration-300">
                <div class="flex items-center justify-between mb-3">
                  <div class="stat-card-icon bg-blue-100 dark:bg-[#1a2a1f] text-blue-600 dark:text-[#8fbc8f]">
                    <i class="fas fa-route"></i>
                  </div>
                </div>
                <div class="text-2xl sm:text-3xl font-bold text-blue-600 dark:text-[#8fbc8f] transition-colors duration-200">{{ vehiclesByStatus('in_use') }}</div>
                <p class="text-xs text-slate-500 dark:text-[#8b949e] mt-1 tracking-wide uppercase transition-colors duration-200">On Trip</p>
              </div>
              <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 hover:-translate-y-0.5 transition-all duration-300">
                <div class="flex items-center justify-between mb-3">
                  <div class="stat-card-icon bg-amber-100 dark:bg-[#1a2f23] text-amber-600 dark:text-[#3fb950]">
                    <i class="fas fa-tools"></i>
                  </div>
                </div>
                <div class="text-2xl sm:text-3xl font-bold text-amber-600 dark:text-[#3fb950] transition-colors duration-200">{{ vehiclesByStatus('maintenance') }}</div>
                <p class="text-xs text-slate-500 dark:text-[#8b949e] mt-1 tracking-wide uppercase transition-colors duration-200">Maintenance</p>
              </div>
            </div>

            <div class="flex justify-between items-center mb-4">
              <div class="text-sm text-gray-600 dark:text-[#8b949e] transition-colors duration-200">
                Showing <span class="font-semibold text-gray-900 dark:text-[#e6edf3]">{{ filteredVehicles.length }}</span> of 
                <span class="font-semibold text-gray-900 dark:text-[#e6edf3]">{{ vehicles.length }}</span> vehicles
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
                  :class="viewMode === 'list' ? 'bg-emerald-600 dark:bg-[#238636] text-white' : 'text-slate-500 dark:text-[#8b949e] bg-transparent'"
                >
                  <i class="fas fa-table"></i>
                </button>
              </div>
            </div>

            <!-- Loading State -->
            <div v-if="loading" class="glass-card dark:bg-[#161b22] dark:border-[#30363d] text-center py-16 transition-colors duration-200">
              <i class="fas fa-spinner fa-spin text-5xl mb-5 text-emerald-600 dark:text-[#3fb950]"></i>
              <p class="text-gray-600 dark:text-[#8b949e] font-medium transition-colors duration-200">Loading vehicles...</p>
            </div>

            <!-- Empty State -->
            <div v-else-if="filteredVehicles.length === 0" class="glass-card dark:bg-[#161b22] dark:border-[#30363d] text-center py-16 transition-colors duration-200">
              <i class="fas fa-truck text-7xl mb-5 text-emerald-200 dark:text-[#1a2f23]"></i>
              <h3 class="text-2xl font-bold text-gray-900 dark:text-[#e6edf3] mb-2 transition-colors duration-200">No vehicles found</h3>
              <p class="text-gray-600 dark:text-[#8b949e] mb-6 transition-colors duration-200">{{ hasActiveFilters ? 'Try adjusting your filters' : 'Start by adding your first vehicle' }}</p>
              <button
                v-if="!hasActiveFilters"
                @click="openAddModal"
                class="btn btn-primary"
              >
                <i class="fas fa-plus"></i>
                Add Vehicle
              </button>
            </div>

            <!-- Grid View -->
            <div v-else-if="viewMode === 'grid'" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
              <div
                v-for="vehicle in filteredVehicles"
                :key="vehicle.id"
                class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-6 hover:-translate-y-1 transition-all duration-300 overflow-hidden"
              >
                <div class="flex items-start justify-between mb-4">
                  <div class="flex items-center gap-3">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-emerald-500 to-emerald-700 dark:from-[#2d4a2f] dark:to-[#1a2f23] text-white flex items-center justify-center shadow-inner">
                      <i class="fas fa-truck-moving"></i>
                    </div>
                    <div>
                      <div class="text-lg font-bold text-slate-900 dark:text-[#e6edf3] transition-colors duration-200">{{ vehicle.plate_number }}</div>
                      <div class="text-xs text-slate-500 dark:text-[#8b949e] transition-colors duration-200">{{ vehicle.vehicle_type?.toUpperCase() }} • {{ vehicle.year || 'N/A' }}</div>
                    </div>
                  </div>
                  <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold border"
                        :class="getStatusColor(vehicle.status, 'badge')">
                    <i :class="getStatusIcon(vehicle.status)"></i>
                    {{ formatStatus(vehicle.status) }}
                  </span>
                </div>

                <div class="flex flex-wrap gap-3 mb-4">
                  <span class="px-2.5 py-1 rounded-lg text-xs font-semibold bg-slate-100 dark:bg-[#1c2128] text-slate-600 dark:text-[#e6edf3] transition-colors duration-200">{{ vehicle.vehicle_id }}</span>
                  <span class="px-2.5 py-1 rounded-lg text-xs font-semibold bg-slate-100 dark:bg-[#1c2128] text-slate-600 dark:text-[#e6edf3] transition-colors duration-200">{{ vehicle.assigned_department || 'No Dept' }}</span>
                </div>

                <div class="grid grid-cols-2 gap-3 mb-4">
                  <div class="p-3 rounded-xl bg-slate-50 dark:bg-[#1c2128] transition-colors duration-200">
                    <div class="text-xs text-slate-500 dark:text-[#8b949e] mb-1 flex items-center gap-2 transition-colors duration-200">
                      <i class="fas fa-user text-slate-400 dark:text-[#6e7681]"></i>
                      Driver
                    </div>
                    <div class="text-sm font-semibold text-slate-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ getDriverName(vehicle.assigned_driver_code) || 'Unassigned' }}</div>
                  </div>
                  <div class="p-3 rounded-xl bg-slate-50 dark:bg-[#1c2128] transition-colors duration-200">
                    <div class="text-xs text-slate-500 dark:text-[#8b949e] mb-1 flex items-center gap-2 transition-colors duration-200">
                      <i class="fas fa-gauge text-slate-400 dark:text-[#6e7681]"></i>
                      Status Age
                    </div>
                    <div class="text-sm font-semibold text-slate-900 dark:text-[#e6edf3] transition-colors duration-200">{{ formatTime(vehicle.device_timestamp) }}</div>
                  </div>
                </div>

                <div class="flex items-center gap-1.5 sm:gap-2 flex-nowrap overflow-x-auto">
                  <button @click="viewVehicle(vehicle)" class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 hover:bg-blue-100 dark:hover:bg-blue-900/50 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="View Details">
                    <i class="fas fa-eye text-xs sm:text-sm"></i>
                    <span class="hidden sm:inline text-xs font-medium">View</span>
                  </button>
                  <button @click="viewHistory(vehicle)" class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-purple-50 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400 hover:bg-purple-100 dark:hover:bg-purple-900/50 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Trip History">
                    <i class="fas fa-history text-xs sm:text-sm"></i>
                    <span class="hidden sm:inline text-xs font-medium">History</span>
                  </button>
                  <button @click="viewLiveMap(vehicle)" class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-teal-50 dark:bg-teal-900/30 text-teal-600 dark:text-teal-400 hover:bg-teal-100 dark:hover:bg-teal-900/50 transition-all hover:scale-105 active:scale-95 shadow-sm hover:shadow-md flex-shrink-0" title="Live GPS Tracking">
                    <i class="fas fa-map-marked-alt text-xs sm:text-sm"></i>
                    <span class="hidden sm:inline text-xs font-medium">Live Map</span>
                  </button>
                  <button @click="confirmDelete(vehicle)" class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-semibold text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/30 hover:bg-red-100 dark:hover:bg-red-900/50 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Delete Vehicle">
                    <i class="fas fa-trash text-xs sm:text-sm"></i>
                    <span class="hidden sm:inline text-xs font-medium">Remove</span>
                  </button>
                </div>
              </div>
            </div>

            <!-- Table View -->
            <div v-else class="glass-card dark:bg-[#161b22] dark:border-[#30363d] overflow-hidden transition-colors duration-200">
              <div class="overflow-x-auto">
                <table class="w-full">
                  <thead class="bg-gradient-to-br from-emerald-800 to-emerald-600 dark:from-[#1a2f23] dark:to-[#0f1e13] border-b border-gray-200 dark:border-[#30363d]">
                    <tr>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Vehicle</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Year</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Type</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Status</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Driver</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Department</th>
                      <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="vehicle in filteredVehicles" :key="vehicle.id" class="border-b border-gray-100 dark:border-[#30363d] hover:bg-gray-50 dark:hover:bg-[#1c2128] transition-colors">
                      <td class="px-4 py-4">
                        <div class="font-semibold text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ vehicle.plate_number }}</div>
                        <div class="text-xs text-gray-500 dark:text-[#8b949e] transition-colors duration-200">{{ vehicle.vehicle_id }}</div>
                      </td>
                      <td class="px-4 py-4 text-sm text-gray-700 dark:text-[#e6edf3] transition-colors duration-200">{{ vehicle.year }}</td>
                      <td class="px-4 py-4 text-sm text-gray-700 dark:text-[#e6edf3] transition-colors duration-200">{{ vehicle.vehicle_type.toUpperCase() }}</td>
                      <td class="px-4 py-4">
                        <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold border"
                              :class="getStatusColor(vehicle.status, 'badge')">
                          <i :class="getStatusIcon(vehicle.status)"></i>
                          {{ formatStatus(vehicle.status) }}
                        </span>
                      </td>
                      <td class="px-4 py-4 text-sm text-gray-700 dark:text-[#e6edf3] transition-colors duration-200">{{ getDriverName(vehicle.assigned_driver_code) || '-' }}</td>
                      <td class="px-4 py-4 text-sm text-gray-700 dark:text-[#e6edf3] transition-colors duration-200">{{ vehicle.assigned_department || '-' }}</td>
                      <td class="px-3 sm:px-4 py-3 sm:py-4">
                        <div class="flex items-center gap-1.5 sm:gap-2 flex-nowrap overflow-x-auto">
                          <button @click="viewVehicle(vehicle)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg hover:bg-blue-50 dark:hover:bg-blue-900/30 text-blue-600 dark:text-blue-400 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="View Details">
                            <i class="fas fa-eye text-xs sm:text-sm"></i>
                            <span class="hidden lg:inline text-xs font-medium ml-0.5">View</span>
                          </button>
                          <button @click="editVehicle(vehicle)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg hover:bg-amber-50 dark:hover:bg-amber-900/30 text-amber-600 dark:text-amber-400 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Edit Vehicle">
                            <i class="fas fa-edit text-xs sm:text-sm"></i>
                            <span class="hidden lg:inline text-xs font-medium ml-0.5">Edit</span>
                          </button>
                          <button @click="viewHistory(vehicle)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg hover:bg-purple-50 dark:hover:bg-purple-900/30 text-purple-600 dark:text-purple-400 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Trip History">
                            <i class="fas fa-history text-xs sm:text-sm"></i>
                            <span class="hidden lg:inline text-xs font-medium ml-0.5">History</span>
                          </button>
                          <button @click="viewLiveMap(vehicle)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg hover:bg-teal-50 dark:hover:bg-teal-900/30 text-teal-600 dark:text-teal-400 transition-all hover:scale-105 active:scale-95 shadow-sm hover:shadow-md flex-shrink-0" title="Live GPS Tracking">
                            <i class="fas fa-map-marked-alt text-xs sm:text-sm"></i>
                            <span class="hidden lg:inline text-xs font-medium ml-0.5">Live Map</span>
                          </button>
                          <button @click="confirmDelete(vehicle)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/30 text-red-600 dark:text-red-400 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Delete Vehicle">
                            <i class="fas fa-trash text-xs sm:text-sm"></i>
                            <span class="hidden lg:inline text-xs font-medium ml-0.5">Delete</span>
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
          <KeepAlive>
            <DriverManagement 
              v-if="activeTab === 'drivers'"
              @driver-updated="loadDrivers" 
            />
          </KeepAlive>

          <!-- TRIPS TAB -->
          <KeepAlive>
            <TripManagement 
              v-if="activeTab === 'trips'"
              :vehicles="vehicles" 
              :drivers="drivers"
              @trip-added="loadTrips"
            />
          </KeepAlive>

        </div>
      </div>
    </main>

    <!-- Add/Edit Vehicle Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-[60] backdrop-blur-sm p-4 transition-colors duration-200" @click.self="closeModal">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden shadow-2xl animate-modalSlideIn transition-colors duration-200">
        <!-- Modal Header -->
        <div class="relative py-6 px-8 bg-gradient-to-br from-emerald-800 to-emerald-600 dark:from-[#1a2f23] dark:to-[#0f1e13] text-white">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-2xl font-bold">{{ editingVehicle ? 'Edit Vehicle' : 'Register New Vehicle' }}</h3>
              <p class="text-emerald-100 dark:text-emerald-200 text-sm mt-1">{{ editingVehicle ? 'Update vehicle information' : 'Add a new vehicle to your fleet' }}</p>
            </div>
            <button 
              @click="closeModal" 
              class="w-10 h-10 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
            >
              <i class="fas fa-times text-lg"></i>
            </button>
          </div>
          <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-emerald-400 via-emerald-400 to-teal-400"></div>
        </div>

        <!-- Modal Body -->
        <form @submit.prevent="submitVehicleForm" class="p-8 overflow-y-auto max-h-[calc(90vh-120px)] bg-white dark:bg-[#0d1117] transition-colors duration-200">
          <div class="space-y-6">
            
            <!-- Vehicle Identification Section -->
            <div class="bg-gray-50 dark:bg-[#1c2128] rounded-xl p-5 border border-gray-200 dark:border-[#30363d] transition-colors duration-200">
              <h4 class="text-sm font-semibold text-gray-700 dark:text-[#e6edf3] uppercase tracking-wide mb-4 flex items-center gap-2 transition-colors duration-200">
                <i class="fas fa-id-card text-emerald-600 dark:text-[#3fb950]"></i>
                Vehicle Identification
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm flex items-center gap-2 transition-colors duration-200">
                    Vehicle ID <span class="text-red-500">*</span>
                    <span v-if="editingVehicle" class="text-xs text-gray-500 dark:text-[#8b949e] font-normal">(Cannot be changed)</span>
                  </label>
                  <input
                    type="text"
                    v-model="vehicleForm.vehicle_id"
                    placeholder="e.g., MP-001"
                    required
                    :disabled="editingVehicle !== null"
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all disabled:bg-gray-100 dark:disabled:bg-[#1c2128] disabled:cursor-not-allowed bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                  />
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Plate Number <span class="text-red-500">*</span></label>
                  <input
                    type="text"
                    v-model="vehicleForm.plate_number"
                    placeholder="e.g., ABC-1234"
                    required
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all uppercase bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                  />
                </div>
              </div>
            </div>

            <!-- Vehicle Specifications Section -->
            <div class="bg-gray-50 dark:bg-[#1c2128] rounded-xl p-5 border border-gray-200 dark:border-[#30363d] transition-colors duration-200">
              <h4 class="text-sm font-semibold text-gray-700 dark:text-[#e6edf3] uppercase tracking-wide mb-4 flex items-center gap-2 transition-colors duration-200">
                <i class="fas fa-cog text-emerald-600 dark:text-[#3fb950]"></i>
                Vehicle Specifications
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Year <span class="text-red-500">*</span></label>
                  <input
                    type="number"
                    v-model="vehicleForm.year"
                    :min="1990"
                    :max="new Date().getFullYear() + 1"
                    required
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200"
                  />
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Vehicle Type <span class="text-red-500">*</span></label>
                  <select 
                    v-model="vehicleForm.vehicle_type" 
                    required 
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200"
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
            <div class="bg-gray-50 dark:bg-[#1c2128] rounded-xl p-5 border border-gray-200 dark:border-[#30363d] transition-colors duration-200">
              <h4 class="text-sm font-semibold text-gray-700 dark:text-[#e6edf3] uppercase tracking-wide mb-4 flex items-center gap-2 transition-colors duration-200">
                <i class="fas fa-users text-emerald-600 dark:text-[#3fb950]"></i>
                Driver & Department Assignment
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Assigned Driver</label>
                  <select
                    v-model="vehicleForm.assigned_driver_code"
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200"
                  >
                    <option value="">No driver assigned</option>
                    <option v-for="driver in drivers" :key="driver.id" :value="driver.employee_id">
                      {{ driver.full_name }} ({{ driver.employee_id }})
                    </option>
                  </select>
                  <p class="text-xs text-gray-500 dark:text-[#8b949e] mt-1 transition-colors duration-200">
                    <i class="fas fa-info-circle mr-1"></i>
                    {{ drivers.length }} registered driver(s) available
                  </p>
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Status</label>
                  <select 
                    v-model="vehicleForm.status" 
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200"
                  >
                    <option value="available">Available</option>
                    <option value="in_use">In Use</option>
                    <option value="maintenance">Under Maintenance</option>
                    <option value="out_of_service">Out of Service</option>
                  </select>
                </div>
              </div>
              
              <div class="flex flex-col gap-2 mt-5">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Department</label>
                <input 
                  v-model="vehicleForm.assigned_department" 
                  type="text"
                  placeholder="e.g., Administration, HR, Maintenance"
                  class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                />
              </div>
            </div>

            <!-- Additional Information Section -->
            <div class="bg-gray-50 dark:bg-[#1c2128] rounded-xl p-5 border border-gray-200 dark:border-[#30363d] transition-colors duration-200">
              <h4 class="text-sm font-semibold text-gray-700 dark:text-[#e6edf3] uppercase tracking-wide mb-4 flex items-center gap-2 transition-colors duration-200">
                <i class="fas fa-clipboard text-emerald-600 dark:text-[#3fb950]"></i>
                Additional Information
              </h4>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Notes</label>
                <textarea
                  v-model="vehicleForm.notes"
                  placeholder="Enter any additional notes, remarks, or special instructions about this vehicle..."
                  rows="4"
                  class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all resize-y bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                ></textarea>
              </div>
            </div>

          </div>

          <!-- Form Actions -->
          <div class="flex gap-4 justify-end mt-8 pt-6 border-t border-gray-200 dark:border-[#30363d] transition-colors duration-200">
            <button 
              type="button" 
              @click="closeModal" 
              class="px-6 py-3 border-2 border-gray-300 dark:border-[#30363d] text-gray-700 dark:text-[#e6edf3] rounded-lg hover:bg-gray-50 dark:hover:bg-[#1c2128] transition-all font-semibold"
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
    <div v-if="selectedVehicle" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-[60] backdrop-blur-sm p-4 transition-colors duration-200" @click.self="selectedVehicle = null">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-md max-h-[90vh] overflow-hidden shadow-2xl animate-modalSlideIn transition-colors duration-200">
        <!-- Modal Header -->
        <div class="relative py-4 px-6 bg-gradient-to-r from-emerald-800 to-emerald-600 dark:from-[#1a2f23] dark:to-[#0f1e13] text-white transition-colors duration-200">
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
            <div class="flex items-center justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
              <span class="text-xs text-gray-500 dark:text-[#8b949e] uppercase font-medium transition-colors duration-200">Year</span>
              <span class="text-sm font-bold text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedVehicle.year }}</span>
            </div>
            <div class="flex items-center justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
              <span class="text-xs text-gray-500 dark:text-[#8b949e] uppercase font-medium transition-colors duration-200">Type</span>
              <span class="text-sm font-bold text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedVehicle.vehicle_type.toUpperCase() }}</span>
            </div>
            <div class="flex items-center justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
              <span class="text-xs text-gray-500 dark:text-[#8b949e] uppercase font-medium transition-colors duration-200">Driver</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ getDriverName(selectedVehicle.assigned_driver_code) || 'Unassigned' }}</span>
            </div>
            <div class="flex items-center justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
              <span class="text-xs text-gray-500 dark:text-[#8b949e] uppercase font-medium transition-colors duration-200">Department</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedVehicle.assigned_department || 'Not assigned' }}</span>
            </div>
          </div>

          <!-- Notes Section -->
          <div v-if="selectedVehicle.notes" class="mb-4">
            <p class="text-xs text-gray-500 dark:text-[#8b949e] uppercase font-medium mb-2 transition-colors duration-200">Notes</p>
            <div class="bg-amber-50 dark:bg-amber-900/20 border-l-3 border-amber-400 dark:border-amber-600 rounded p-3 transition-colors duration-200">
              <p class="text-sm text-gray-700 dark:text-[#e6edf3] leading-relaxed transition-colors duration-200">{{ selectedVehicle.notes }}</p>
            </div>
          </div>

          <!-- Registration Info -->
          <div class="text-xs text-gray-500 dark:text-[#8b949e] space-y-1 mb-5 pt-3 border-t border-gray-100 dark:border-[#30363d] transition-colors duration-200">
            <p><i class="fas fa-calendar-plus text-green-600 dark:text-[#3fb950] mr-2"></i>Added: {{ formatDate(selectedVehicle.created_at) }}</p>
            <p v-if="selectedVehicle.updated_at !== selectedVehicle.created_at">
              <i class="fas fa-edit text-blue-600 dark:text-[#8fbc8f] mr-2"></i>Updated: {{ formatDate(selectedVehicle.updated_at) }}
            </p>
          </div>

          <!-- Action Button -->
          <button 
            @click="editVehicle(selectedVehicle); selectedVehicle = null" 
            class="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-gradient-to-r from-amber-500 to-amber-600 dark:from-amber-600 dark:to-amber-700 text-white rounded-lg hover:from-amber-600 hover:to-amber-700 dark:hover:from-amber-700 dark:hover:to-amber-800 transition-all font-semibold text-sm shadow-md"
          >
            <i class="fas fa-edit"></i>
            Edit Vehicle
          </button>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="vehicleToDelete" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-50 backdrop-blur-sm p-4 transition-colors duration-200">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-md shadow-2xl transition-colors duration-200">
        <div class="py-6 px-8 border-b border-gray-200 dark:border-[#30363d] flex justify-between items-center bg-gradient-to-br from-red-500 to-red-600 text-white rounded-t-2xl transition-colors duration-200">
          <h3 class="text-xl font-semibold">Confirm Deletion</h3>
          <button @click="vehicleToDelete = null" class="bg-white/10 hover:bg-white/20 w-8 h-8 rounded-lg flex items-center justify-center transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8 text-center">
          <p class="text-lg text-gray-700 dark:text-[#e6edf3] mb-6 transition-colors duration-200">Are you sure you want to delete vehicle <strong>{{ vehicleToDelete.plate_number }}</strong>? This action cannot be undone.</p>
          <div class="flex gap-4 justify-center">
            <button @click="vehicleToDelete = null" class="px-4 py-2 border border-gray-300 dark:border-[#30363d] rounded-lg hover:bg-gray-50 dark:hover:bg-[#1c2128] transition-colors text-gray-700 dark:text-[#e6edf3]">
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
import { useToast } from '../composables/useToast'
import { useSidebar } from '../composables/useSidebar'
import Navbar from './Navbar.vue'
import PageHeader from '../components/PageHeader.vue'
import DriverManagement from './DriverManagement.vue'
import TripManagement from './TripManagement.vue'

export default {
  name: 'VehicleManagement',
  components: {
    Navbar,
    PageHeader,
    DriverManagement,
    TripManagement
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    const { success, error } = useToast()
    const { sidebarCollapsed, sidebarOpen, toggleSidebar, closeSidebar, openSidebar, handleMenuClick } = useSidebar()
    
    // State
    const activeTab = computed(() => route.query.tab || 'vehicles')
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

    // Sidebar methods are now from useSidebar composable

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

    const formatTime = (timestamp) => {
      if (!timestamp) return 'N/A'
      const date = new Date(timestamp)
      if (Number.isNaN(date.getTime())) return 'N/A'
      const diffMs = Date.now() - date.getTime()
      const diffMinutes = Math.floor(diffMs / 60000)
      if (diffMinutes < 1) return 'Just now'
      if (diffMinutes < 60) return `${diffMinutes}m ago`
      if (diffMinutes < 1440) return `${Math.floor(diffMinutes / 60)}h ago`
      return date.toLocaleDateString()
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
      router.push({ 
        name: 'LiveMap', 
        query: { vehicle: vehicle.vehicle_id || vehicle.id } 
      })
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
          const { error: updateError } = await supabase
            .from('vehicles')
            .update(vehicleData)
            .eq('id', editingVehicle.value.id)
          
          if (updateError) throw updateError
          
          const index = vehicles.value.findIndex(v => v.id === editingVehicle.value.id)
          if (index !== -1) {
            vehicles.value[index] = {
              ...editingVehicle.value,
              ...vehicleData,
              updated_at: new Date().toISOString()
            }
          }
        } else {
          const { data, error: insertError } = await supabase
            .from('vehicles')
            .insert(vehicleData)
            .select()
            .single()
          
          if (insertError) throw insertError
          vehicles.value.unshift(data)
        }

        // Show success message BEFORE closing modal (so editingVehicle is still set)
        success(editingVehicle.value ? 'Vehicle updated successfully!' : 'Vehicle created successfully!')
        closeModal()
      } catch (err) {
        console.error('Error submitting form:', err)
        error('Error: ' + err.message)
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
        const { error: deleteError } = await supabase
          .from('vehicles')
          .delete()
          .eq('id', vehicleToDelete.value.id)
        
        if (deleteError) throw deleteError

        vehicles.value = vehicles.value.filter(v => v.id !== vehicleToDelete.value.id)
        vehicleToDelete.value = null
        success('Vehicle deleted successfully!')
      } catch (err) {
        console.error('Error deleting vehicle:', err)
        error('Error deleting vehicle: ' + err.message)
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
      formatTime,
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
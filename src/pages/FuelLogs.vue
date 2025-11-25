<template>
  <div class="flex h-screen bg-gradient-to-br from-green-50 to-green-100 dark:from-[#0d1117] dark:via-[#0d1117] dark:to-[#161b22] font-inter transition-colors duration-200">
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
      class="fixed inset-0 bg-black/50 dark:bg-black/70 z-40 lg:hidden transition-colors duration-200"
      @click="closeSidebar"
    ></div>

    <main class="main-content flex flex-1 flex-col transition-all duration-300 ease-in-out min-w-0" :class="{ '!ml-0': sidebarCollapsed || !sidebarOpen }">
      
      <div class="sticky top-0 z-10">
        <PageHeader
          icon="fas fa-gas-pump"
          title="Fuel Management"
          subtitle="Track and manage vehicle fuel consumption"
        >
          <template #leading>
            <button
              @click="openSidebar"
              class="lg:hidden btn btn-secondary py-2 px-3"
              v-if="!sidebarOpen"
            >
              <i class="fas fa-bars"></i>
            </button>
          </template>
          <template #actions>
            <div class="text-right hidden sm:block">
              <div class="text-xs text-green-100 uppercase tracking-wide">Entries (24h)</div>
              <div class="text-2xl font-bold">{{ fuelStats.totalLogs }}</div>
            </div>
          </template>
        </PageHeader>
      </div>

      <!-- Main Content -->
      <div class="flex-1 p-4 sm:p-6 lg:p-8 overflow-y-auto">
        <div class="max-w-7xl mx-auto">
          
          <!-- Toolbar -->
          <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 mb-6 transition-colors duration-200">
            <div class="flex flex-col lg:flex-row gap-4">
              <div class="flex-1 relative">
                <i class="fas fa-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 dark:text-[#8b949e]"></i>
                <input
                  type="text"
                  v-model="searchQuery"
                  placeholder="Search by vehicle, driver, or station..."
                  class="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] dark:focus:ring-[#3fb950] focus:border-transparent text-sm sm:text-base bg-white dark:bg-[#1c2128] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                />
              </div>

              <div class="flex items-center gap-2 flex-wrap">
                <button
                  @click="showFilters = !showFilters"
                  class="btn btn-outline text-sm dark:border-[#30363d] dark:text-[#e6edf3] dark:hover:bg-[#1c2128]"
                >
                  <i class="fas fa-filter"></i>
                  <span class="hidden sm:inline">Filters</span>
                </button>

                <button 
                  @click="clearFilters"
                  v-if="hasActiveFilters"
                  class="btn btn-outline text-sm dark:border-[#30363d] dark:text-[#e6edf3] dark:hover:bg-[#1c2128]"
                >
                  <i class="fas fa-times"></i>
                  <span class="hidden sm:inline">Clear</span>
                </button>

                <button 
                  @click="exportToCSV"
                  class="btn btn-outline text-sm hidden sm:flex"
                >
                  <i class="fas fa-download"></i>
                  <span>Export</span>
                </button>
                <button 
                  @click="openAddModal"
                  class="btn btn-primary whitespace-nowrap text-sm sm:text-base"
                >
                  <i class="fas fa-plus"></i>
                  <span class="hidden sm:inline">Add Fuel Log</span>
                  <span class="sm:hidden">Add</span>
                </button>
              </div>
            </div>

            <!-- Filters Panel -->
            <div v-if="showFilters" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3 sm:gap-4 mt-4 pt-4 border-t border-gray-200 dark:border-[#30363d] transition-colors duration-200">
              <select v-model="vehicleFilter" class="px-3 sm:px-4 py-2 text-sm sm:text-base border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] dark:focus:ring-[#3fb950] bg-white dark:bg-[#1c2128] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">
                <option value="">All Vehicles</option>
                <option v-for="vehicle in vehicles" :key="vehicle.id" :value="vehicle.id">
                  {{ vehicle.plate_number }}
                </option>
              </select>

              <select v-model="driverFilter" class="px-3 sm:px-4 py-2 text-sm sm:text-base border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] dark:focus:ring-[#3fb950] bg-white dark:bg-[#1c2128] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">
                <option value="">All Drivers</option>
                <option v-for="driver in drivers" :key="driver.id" :value="driver.id">
                  {{ driver.full_name }}
                </option>
              </select>

              <select v-model="dateRangeFilter" class="px-3 sm:px-4 py-2 text-sm sm:text-base border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0A400C] dark:focus:ring-[#3fb950] bg-white dark:bg-[#1c2128] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">
                <option value="">All Time</option>
                <option value="today">Today</option>
                <option value="week">This Week</option>
                <option value="month">This Month</option>
              </select>
            </div>
          </div>

          <!-- Advanced Statistics Cards -->
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-6">
              <div class="glass-card p-4 sm:p-5 hover:-translate-y-0.5 transition-all duration-300">
                <div class="flex items-center justify-between mb-3">
                  <div class="stat-card-icon bg-green-100 text-green-600">
                    <i class="fas fa-gas-pump"></i>
                  </div>
                  <span class="text-xs font-semibold text-green-600 bg-green-100 px-2 py-0.5 rounded-full">
                    {{ fuelStats.percentageChange }}%
                  </span>
                </div>
                <div class="text-2xl sm:text-3xl font-bold text-slate-900">{{ fuelStats.totalLogs }}</div>
                <p class="text-xs text-slate-500 mt-1 tracking-wide uppercase">Total Fuel Logs</p>
              </div>
              
              <div class="glass-card p-4 sm:p-5 hover:-translate-y-0.5 transition-all duration-300">
                <div class="flex items-center justify-between mb-3">
                  <div class="stat-card-icon bg-blue-100 text-blue-600">
                    <i class="fas fa-tint"></i>
                  </div>
                  <i class="fas fa-arrow-up text-blue-600 text-xs"></i>
                </div>
                <div class="text-2xl sm:text-3xl font-bold text-blue-600">{{ fuelStats.totalLiters }}L</div>
                <p class="text-xs text-slate-500 mt-1 tracking-wide uppercase">Total Fuel Volume</p>
              </div>
              
              <div class="glass-card p-4 sm:p-5 hover:-translate-y-0.5 transition-all duration-300">
                <div class="flex items-center justify-between mb-3">
                  <div class="stat-card-icon bg-green-100 text-green-600">
                    <i class="fas fa-peso-sign"></i>
                  </div>
                  <i class="fas fa-chart-line text-green-600 text-xs"></i>
                </div>
                <div class="text-2xl sm:text-3xl font-bold text-green-600">₱{{ fuelStats.totalCost }}</div>
                <p class="text-xs text-slate-500 mt-1 tracking-wide uppercase">Total Expenditure</p>
              </div>
              
              <div class="glass-card p-4 sm:p-5 hover:-translate-y-0.5 transition-all duration-300">
                <div class="flex items-center justify-between mb-3">
                  <div class="stat-card-icon bg-orange-100 text-orange-600">
                    <i class="fas fa-calculator"></i>
                  </div>
                  <span class="text-xs font-semibold text-orange-600">AVG</span>
                </div>
                <div class="text-2xl sm:text-3xl font-bold text-orange-600">₱{{ fuelStats.avgCostPerLiter }}</div>
                <p class="text-xs text-slate-500 mt-1 tracking-wide uppercase">Cost per Liter</p>
              </div>
            </div>

          <!-- View Toggle & Sort -->
          <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-4 sm:mb-6 gap-3 sm:gap-4">
            <div class="text-xs sm:text-sm text-gray-600 dark:text-[#8b949e] transition-colors duration-200">
              Showing <span class="font-semibold text-gray-900 dark:text-[#e6edf3]">{{ filteredLogs.length }}</span> of 
              <span class="font-semibold text-gray-900 dark:text-[#e6edf3]">{{ fuelLogs.length }}</span> fuel logs
            </div>
            
            <div class="flex gap-2 items-center w-full sm:w-auto">
              <div class="view-toggle flex bg-white/90 dark:bg-[#161b22] ml-auto sm:ml-0 transition-colors duration-200">
                <button @click="viewMode = 'table'" 
                        :class="viewMode === 'table' ? 'bg-green-600 dark:bg-[#238636] text-white' : 'text-slate-500 dark:text-[#8b949e] bg-transparent'"
                >
                  <i class="fas fa-table"></i>
                </button>
                <button @click="viewMode = 'grid'" 
                        :class="viewMode === 'grid' ? 'bg-green-600 dark:bg-[#238636] text-white' : 'text-slate-500 dark:text-[#8b949e] bg-transparent'"
                >
                  <i class="fas fa-th-large"></i>
                </button>
              </div>
            </div>
          </div>

          <!-- Fuel Logs Content -->
          <div v-if="loading" class="glass-card text-center py-12 sm:py-16">
            <i class="fas fa-spinner fa-spin text-4xl sm:text-5xl mb-4 sm:mb-5 text-[#0A400C]"></i>
            <span class="text-slate-600 text-sm sm:text-base font-medium">Loading fuel logs...</span>
          </div>

          <div v-else-if="filteredLogs.length === 0" class="glass-card text-center py-12 sm:py-16">
            <i class="fas fa-gas-pump text-5xl sm:text-7xl mb-4 sm:mb-5 text-green-200"></i>
            <h3 class="text-xl sm:text-2xl font-bold text-gray-900 mb-2 sm:mb-2.5">No fuel logs found</h3>
            <p class="text-slate-600 text-sm sm:text-base mb-4 sm:mb-6 px-4">{{ hasActiveFilters ? 'Try adjusting your search criteria' : 'No fuel logs recorded yet.' }}</p>
            <button
              v-if="!hasActiveFilters"
              @click="openAddModal"
              class="btn btn-primary text-sm sm:text-base"
            >
              <i class="fas fa-plus"></i>
              Add First Fuel Log
            </button>
          </div>

          <!-- Desktop Table View -->
          <div v-else-if="viewMode === 'table'" class="glass-card dark:bg-[#161b22] dark:border-[#30363d] overflow-hidden transition-colors duration-200">
            <div class="overflow-x-auto">
              <table class="w-full">
                <thead>
                  <tr class="bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] text-white">
                    <th class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-left text-xs font-semibold uppercase tracking-wider">
                      <div class="flex items-center gap-1.5 sm:gap-2">
                        <i class="fas fa-calendar text-xs"></i>
                        <span class="hidden sm:inline">Date & Time</span>
                        <span class="sm:hidden">Date</span>
                      </div>
                    </th>
                    <th class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-left text-xs font-semibold uppercase tracking-wider">
                      <div class="flex items-center gap-1.5 sm:gap-2">
                        <i class="fas fa-car text-xs"></i>
                        Vehicle
                      </div>
                    </th>
                    <th class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-left text-xs font-semibold uppercase tracking-wider hidden md:table-cell">
                      <div class="flex items-center gap-1.5 sm:gap-2">
                        <i class="fas fa-user text-xs"></i>
                        Driver
                      </div>
                    </th>
                    <th class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-left text-xs font-semibold uppercase tracking-wider">
                      <div class="flex items-center gap-1.5 sm:gap-2">
                        <i class="fas fa-tint text-xs"></i>
                        Volume
                      </div>
                    </th>
                    <th class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-left text-xs font-semibold uppercase tracking-wider">
                      <div class="flex items-center gap-1.5 sm:gap-2">
                        <i class="fas fa-peso-sign text-xs"></i>
                        Cost
                      </div>
                    </th>
                    <th class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-left text-xs font-semibold uppercase tracking-wider hidden lg:table-cell">
                      <div class="flex items-center gap-1.5 sm:gap-2">
                        <i class="fas fa-tachometer-alt text-xs"></i>
                        Odometer
                      </div>
                    </th>
                    <th class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-left text-xs font-semibold uppercase tracking-wider hidden xl:table-cell">
                      <div class="flex items-center gap-1.5 sm:gap-2">
                        <i class="fas fa-map-marker-alt text-xs"></i>
                        Station
                      </div>
                    </th>
                    <th class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-center text-xs font-semibold uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 dark:divide-[#30363d]">
                  <tr v-for="log in sortedLogs" :key="log.id" class="hover:bg-gray-50 dark:hover:bg-[#1c2128] transition-colors">
                    <td class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-xs sm:text-sm">
                      <div class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ formatDate(log.created_at) }}</div>
                      <div class="text-gray-500 dark:text-[#8b949e] text-xs transition-colors duration-200">{{ formatTime(log.created_at) }}</div>
                    </td>
                    <td class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-xs sm:text-sm">
                      <div class="flex items-center gap-2">
                        <div class="w-7 h-7 sm:w-8 sm:h-8 rounded-lg bg-green-100 dark:bg-green-900/30 flex items-center justify-center shrink-0">
                          <i class="fas fa-car text-green-600 dark:text-green-400 text-xs"></i>
                        </div>
                        <div class="min-w-0">
                          <div class="font-medium text-gray-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ getVehiclePlate(log.vehicle_id) }}</div>
                          <div class="text-gray-500 dark:text-[#8b949e] text-xs truncate hidden sm:block transition-colors duration-200">{{ getVehicleDetails(log.vehicle_id) }}</div>
                        </div>
                      </div>
                    </td>
                    <td class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-xs sm:text-sm hidden md:table-cell">
                      <div class="flex items-center gap-2">
                        <div class="w-7 h-7 sm:w-8 sm:h-8 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center shrink-0">
                          <i class="fas fa-user text-blue-600 dark:text-blue-400 text-xs"></i>
                        </div>
                        <span class="font-medium text-gray-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ log.driver_name || 'N/A' }}</span>
                      </div>
                    </td>
                    <td class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-xs sm:text-sm">
                      <span class="inline-flex items-center px-2 sm:px-2.5 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                        <i class="fas fa-tint mr-1"></i>
                        {{ log.liters }}L
                      </span>
                    </td>
                    <td class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-xs sm:text-sm">
                      <span class="inline-flex items-center px-2 sm:px-2.5 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        <i class="fas fa-peso-sign mr-1"></i>
                        {{ log.cost || 'N/A' }}
                      </span>
                    </td>
                    <td class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-xs sm:text-sm text-gray-900 hidden lg:table-cell">
                      <span class="font-mono text-xs">{{ log.odometer ? log.odometer.toLocaleString() + ' km' : 'N/A' }}</span>
                    </td>
                    <td class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-xs sm:text-sm hidden xl:table-cell">
                      <div class="flex items-center gap-1">
                        <i class="fas fa-map-marker-alt text-orange-600 text-xs shrink-0"></i>
                        <span class="text-gray-900 truncate">{{ log.station || 'N/A' }}</span>
                      </div>
                    </td>
                    <td class="px-3 sm:px-4 lg:px-6 py-3 sm:py-4 text-center">
                      <div class="flex items-center justify-center gap-1.5 sm:gap-2 flex-nowrap overflow-x-auto">
                        <button @click="viewLog(log)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 bg-blue-50 text-blue-600 rounded-lg hover:bg-blue-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="View Details">
                          <i class="fas fa-eye text-xs sm:text-sm"></i>
                          <span class="hidden lg:inline text-xs font-medium ml-0.5">View</span>
                        </button>
                        <button @click="editLog(log)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 bg-amber-50 text-amber-600 rounded-lg hover:bg-amber-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Edit">
                          <i class="fas fa-edit text-xs sm:text-sm"></i>
                          <span class="hidden lg:inline text-xs font-medium ml-0.5">Edit</span>
                        </button>
                        <button @click="confirmDelete(log)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 bg-red-50 text-red-600 rounded-lg hover:bg-red-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Delete">
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

          <!-- Grid View -->
          <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5">
            <div v-for="log in sortedLogs" :key="log.id" 
                 class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-5 sm:p-6 hover:-translate-y-1 transition-all duration-300 overflow-hidden">
                <div class="flex items-start mb-4">
                  <div class="flex items-center gap-3 min-w-0 flex-1">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-green-500 to-green-700 dark:from-[#2d4a2f] dark:to-[#1a2f23] text-white flex items-center justify-center shadow-inner shrink-0">
                      <i class="fas fa-gas-pump"></i>
                    </div>
                    <div class="min-w-0">
                      <div class="font-bold text-gray-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ getVehiclePlate(log.vehicle_id) }}</div>
                      <div class="text-xs text-gray-500 dark:text-[#8b949e] transition-colors duration-200">{{ formatDate(log.created_at) }}</div>
                    </div>
                  </div>
                </div>

                <div class="space-y-3 mb-4">
                  <div class="flex justify-between items-center p-3 sm:p-3.5 bg-blue-50 dark:bg-blue-900/30 rounded-lg transition-colors duration-200">
                    <div class="flex items-center gap-2">
                      <i class="fas fa-tint text-blue-600 dark:text-blue-400 text-sm"></i>
                      <span class="text-xs sm:text-sm text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Volume</span>
                    </div>
                    <span class="font-bold text-blue-600 dark:text-blue-400 text-sm sm:text-base transition-colors duration-200">{{ log.liters }}L</span>
                  </div>

                  <div class="flex justify-between items-center p-3 sm:p-3.5 bg-green-50 dark:bg-green-900/30 rounded-lg transition-colors duration-200">
                    <div class="flex items-center gap-2">
                      <i class="fas fa-peso-sign text-green-600 dark:text-green-400 text-sm"></i>
                      <span class="text-xs sm:text-sm text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Cost</span>
                    </div>
                    <span class="font-bold text-green-600 dark:text-green-400 text-sm sm:text-base transition-colors duration-200">₱{{ log.cost || 'N/A' }}</span>
                  </div>

                  <div class="grid grid-cols-2 gap-2 sm:gap-3">
                    <div class="p-2.5 sm:p-3 bg-gray-50 dark:bg-[#1c2128] rounded-lg transition-colors duration-200">
                      <div class="text-xs text-gray-500 dark:text-[#8b949e] mb-1 transition-colors duration-200">Driver</div>
                      <div class="text-xs sm:text-sm font-medium text-gray-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ log.driver_name || 'N/A' }}</div>
                    </div>
                    <div class="p-2.5 sm:p-3 bg-gray-50 dark:bg-[#1c2128] rounded-lg transition-colors duration-200">
                      <div class="text-xs text-gray-500 dark:text-[#8b949e] mb-1 transition-colors duration-200">Odometer</div>
                      <div class="text-xs sm:text-sm font-medium text-gray-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ log.odometer ? log.odometer.toLocaleString() + ' km' : 'N/A' }}</div>
                    </div>
                  </div>

                  <div v-if="log.station" class="flex items-center gap-2 p-2.5 sm:p-3 bg-orange-50 rounded-lg">
                    <i class="fas fa-map-marker-alt text-orange-600 text-xs shrink-0"></i>
                    <span class="text-xs sm:text-sm text-gray-900 truncate">{{ log.station }}</span>
                  </div>

                  <div v-if="log.trip_reference" class="flex items-center gap-2 p-2.5 sm:p-3 bg-purple-50 rounded-lg">
                    <i class="fas fa-route text-purple-600 text-xs shrink-0"></i>
                    <span class="text-xs sm:text-sm text-gray-900 truncate">{{ log.trip_reference }}</span>
                  </div>
                </div>

                <!-- Actions -->
                <div class="flex items-center gap-1.5 sm:gap-2 flex-nowrap overflow-x-auto pt-4 border-t border-gray-100">
                  <button @click.stop="viewLog(log)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="View Details">
                    <i class="fas fa-eye text-xs sm:text-sm"></i>
                    <span class="text-xs font-medium">View</span>
                  </button>
                  <button @click.stop="editLog(log)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-amber-50 text-amber-600 hover:bg-amber-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Edit">
                    <i class="fas fa-edit text-xs sm:text-sm"></i>
                    <span class="text-xs font-medium">Edit</span>
                  </button>
                  <button @click.stop="confirmDelete(log)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Delete">
                    <i class="fas fa-trash text-xs sm:text-sm"></i>
                    <span class="text-xs font-medium">Remove</span>
                  </button>
                </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Add/Edit Fuel Log Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-50 backdrop-blur-sm p-3 sm:p-4 transition-colors duration-200">
      <div class="bg-white dark:bg-[#161b22] rounded-xl sm:rounded-2xl w-full max-w-3xl max-h-[95vh] sm:max-h-[90vh] overflow-y-auto shadow-2xl transition-colors duration-200">
        <!-- Modal Header -->
        <div class="relative py-4 sm:py-6 px-4 sm:px-8 bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] text-white transition-colors duration-200">
          <div class="flex items-center justify-between">
            <div class="min-w-0 flex-1 pr-3">
              <h3 class="text-lg sm:text-2xl font-bold truncate">{{ editingLog ? 'Edit Fuel Log' : 'Add New Fuel Log' }}</h3>
              <p class="text-green-100 text-xs sm:text-sm mt-1 hidden sm:block">{{ editingLog ? 'Update fuel log information' : 'Record a new fuel entry' }}</p>
            </div>
            <button 
              @click="closeModal" 
              class="w-9 h-9 sm:w-10 sm:h-10 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors shrink-0"
            >
              <i class="fas fa-times text-base sm:text-lg"></i>
            </button>
          </div>
          <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400"></div>
        </div>

        <form @submit.prevent="submitForm" class="p-4 sm:p-6 lg:p-8 bg-white dark:bg-[#0d1117] transition-colors duration-200">
          <!-- Vehicle & Trip Selection -->
          <div class="mb-6">
            <h4 class="text-sm font-semibold text-gray-900 dark:text-[#e6edf3] mb-3 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-car text-green-600"></i>
              Vehicle & Trip Information
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">
                  Vehicle *
                  <span class="text-red-500">*</span>
                </label>
                <select v-model="form.vehicle_id" required class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg text-sm transition-colors duration-200 bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] focus:outline-none focus:ring-4 focus:ring-emerald-500 dark:focus:ring-[#3fb950]"
                        style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <option value="">Select Vehicle</option>
                  <option v-for="vehicle in vehicles" :key="vehicle.id" :value="vehicle.id">
                    {{ vehicle.plate_number }} - {{ vehicle.make }} {{ vehicle.model }}
                  </option>
                </select>
              </div>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">
                  Associated Trip
                  <span class="text-gray-500 dark:text-[#8b949e] text-xs font-normal">(Optional)</span>
                </label>
                <select v-model="form.trip_id" class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg text-sm transition-colors duration-200 bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] focus:outline-none focus:ring-4 focus:ring-emerald-500 dark:focus:ring-[#3fb950]"
                        style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <option value="">General Fuel</option>
                  <option v-for="trip in trips" :key="trip.id" :value="trip.id">
                    {{ getVehiclePlate(trip.vehicle_id) }} - {{ trip.origin }} → {{ trip.destination }}
                  </option>
                </select>
              </div>
            </div>
          </div>

          <!-- Fuel Details -->
          <div class="mb-6">
            <h4 class="text-sm font-semibold text-gray-900 dark:text-[#e6edf3] mb-3 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-gas-pump text-green-600 dark:text-[#3fb950]"></i>
              Fuel Details
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">
                  Liters <span class="text-red-500">*</span>
                </label>
                <div class="relative">
                  <input type="number" v-model.number="form.liters" step="0.01" required 
                         placeholder="50.5"
                         class="w-full py-3 pl-4 pr-10 border border-gray-300 dark:border-[#30363d] rounded-lg text-sm transition-colors duration-200 bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] focus:outline-none focus:ring-4 focus:ring-emerald-500 dark:focus:ring-[#3fb950]"
                         style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <span class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-[#8b949e] text-sm">L</span>
                </div>
              </div>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Total Cost</label>
                <div class="relative">
                  <span class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-[#8b949e] text-sm">₱</span>
                  <input type="number" v-model.number="form.cost" step="0.01"
                         placeholder="2500.00"
                         class="w-full py-3 pl-8 pr-4 border border-gray-300 dark:border-[#30363d] rounded-lg text-sm transition-colors duration-200 bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] focus:outline-none focus:ring-4 focus:ring-emerald-500 dark:focus:ring-[#3fb950]"
                         style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                </div>
              </div>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Price per Liter</label>
                <div class="relative">
                  <span class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-[#8b949e] text-sm">₱</span>
                  <input type="text" :value="pricePerLiter" readonly
                         class="w-full py-3 pl-8 pr-4 border border-gray-200 dark:border-[#30363d] rounded-lg text-sm bg-gray-50 dark:bg-[#1c2128] text-gray-600 dark:text-[#8b949e] transition-colors duration-200"
                         placeholder="Auto-calculated">
                </div>
              </div>
            </div>
          </div>

          <!-- Vehicle Status -->
          <div class="mb-6">
            <h4 class="text-sm font-semibold text-gray-900 dark:text-[#e6edf3] mb-3 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-tachometer-alt text-green-600 dark:text-[#3fb950]"></i>
              Vehicle Status
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Odometer Reading</label>
                <div class="relative">
                  <input type="number" v-model.number="form.odometer"
                         placeholder="45000"
                         class="w-full py-3 pl-4 pr-12 border border-gray-300 dark:border-[#30363d] rounded-lg text-sm transition-colors duration-200 bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] focus:outline-none focus:ring-4 focus:ring-emerald-500 dark:focus:ring-[#3fb950]"
                         style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <span class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-[#8b949e] text-sm">km</span>
                </div>
              </div>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Fuel Type</label>
                <select v-model="form.fuel_type" class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg text-sm transition-colors duration-200 bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] focus:outline-none focus:ring-4 focus:ring-emerald-500 dark:focus:ring-[#3fb950]"
                        style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <option value="">Select Fuel Type</option>
                  <option value="gasoline">Gasoline</option>
                  <option value="diesel">Diesel</option>
                  <option value="premium">Premium</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Driver & Location -->
          <div class="mb-6">
            <h4 class="text-sm font-semibold text-gray-900 dark:text-[#e6edf3] mb-3 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-map-marker-alt text-green-600 dark:text-[#3fb950]"></i>
              Driver & Location Information
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Driver</label>
                <select v-model="form.driver_id" class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg text-sm transition-colors duration-200 bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] focus:outline-none focus:ring-4 focus:ring-emerald-500 dark:focus:ring-[#3fb950]"
                        style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <option value="">Select Driver</option>
                  <option v-for="driver in drivers" :key="driver.id" :value="driver.id">
                    {{ driver.full_name }} ({{ driver.employee_id }})
                  </option>
                </select>
              </div>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Gas Station/Location</label>
                <input type="text" v-model="form.station"
                       placeholder="Shell Station EDSA"
                       class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg text-sm transition-colors duration-200 bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] focus:outline-none focus:ring-4 focus:ring-emerald-500 dark:focus:ring-[#3fb950]"
                       style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
              </div>
            </div>
          </div>

          <!-- Additional Information -->
          <div class="mb-6">
            <h4 class="text-sm font-semibold text-gray-900 dark:text-[#e6edf3] mb-3 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-sticky-note text-green-600 dark:text-[#3fb950]"></i>
              Additional Information
            </h4>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Notes & Remarks</label>
              <textarea v-model="form.notes" rows="4"
                        placeholder="Add any additional notes, observations, or remarks about this fuel transaction..."
                        class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg text-sm transition-colors duration-200 bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] resize-y min-h-20 focus:outline-none focus:ring-4 focus:ring-emerald-500 dark:focus:ring-[#3fb950]"
                        style="--tw-ring-color: rgba(10, 64, 12, 0.1);"></textarea>
            </div>
          </div>

          <!-- Form Actions -->
          <div class="flex flex-col sm:flex-row gap-3 sm:gap-4 justify-end pt-4 sm:pt-5 border-t border-gray-200 dark:border-[#30363d] transition-colors duration-200">
            <button type="button" @click="closeModal" class="btn btn-outline text-sm sm:text-base order-2 sm:order-1">
              <i class="fas fa-times"></i>
              Cancel
            </button>
            <button type="submit" class="btn btn-primary text-sm sm:text-base order-1 sm:order-2" 
                    :disabled="submitting">
              <i v-if="submitting" class="fas fa-spinner fa-spin"></i>
              <i v-else class="fas fa-save"></i>
              {{ editingLog ? 'Update Log' : 'Save Log' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- View Log Detail Modal -->
    <div v-if="viewingLog" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-50 backdrop-blur-sm p-4 transition-colors duration-200">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl transition-colors duration-200">
        <div class="py-6 px-8 border-b border-gray-200 dark:border-[#30363d] flex justify-between items-center bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] text-white rounded-t-2xl transition-colors duration-200">
          <div>
            <h3 class="m-0 text-xl font-semibold">Fuel Log Details</h3>
            <p class="text-sm text-white/80 mt-1">Complete transaction information</p>
          </div>
          <button class="bg-white/10 border-none text-white w-8 h-8 rounded-lg cursor-pointer flex items-center justify-center transition-colors duration-200 hover:bg-white/20" @click="viewingLog = null">
            <i class="fas fa-times"></i>
          </button>
        </div>

        <div class="p-8">
          <!-- Summary Cards -->
          <div class="grid grid-cols-2 gap-4 mb-6">
            <div class="p-4 bg-blue-50 rounded-lg">
              <div class="text-sm text-blue-600 mb-1">Total Volume</div>
              <div class="text-2xl font-bold text-blue-700">{{ viewingLog.liters }}L</div>
            </div>
            <div class="p-4 bg-green-50 rounded-lg">
              <div class="text-sm text-green-600 mb-1">Total Cost</div>
              <div class="text-2xl font-bold text-green-700">₱{{ viewingLog.cost || 'N/A' }}</div>
            </div>
          </div>

          <!-- Details Grid -->
          <div class="space-y-4">
            <div class="p-4 bg-gray-50 rounded-lg">
              <div class="text-xs font-semibold text-gray-500 uppercase mb-2">Vehicle Information</div>
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <div class="text-sm text-gray-600">Plate Number</div>
                  <div class="font-semibold text-gray-900">{{ getVehiclePlate(viewingLog.vehicle_id) }}</div>
                </div>
                <div>
                  <div class="text-sm text-gray-600">Vehicle</div>
                  <div class="font-semibold text-gray-900">{{ getVehicleDetails(viewingLog.vehicle_id) }}</div>
                </div>
              </div>
            </div>

            <div class="p-4 bg-gray-50 rounded-lg">
              <div class="text-xs font-semibold text-gray-500 uppercase mb-2">Transaction Details</div>
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <div class="text-sm text-gray-600">Date</div>
                  <div class="font-semibold text-gray-900">{{ formatDate(viewingLog.created_at) }}</div>
                </div>
                <div>
                  <div class="text-sm text-gray-600">Time</div>
                  <div class="font-semibold text-gray-900">{{ formatTime(viewingLog.created_at) }}</div>
                </div>
                <div>
                  <div class="text-sm text-gray-600">Price per Liter</div>
                  <div class="font-semibold text-gray-900">₱{{ calculatePricePerLiter(viewingLog) }}</div>
                </div>
                <div>
                  <div class="text-sm text-gray-600">Fuel Type</div>
                  <div class="font-semibold text-gray-900">{{ viewingLog.fuel_type || 'N/A' }}</div>
                </div>
              </div>
            </div>

            <div class="p-4 bg-gray-50 rounded-lg">
              <div class="text-xs font-semibold text-gray-500 uppercase mb-2">Personnel & Location</div>
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <div class="text-sm text-gray-600">Driver</div>
                  <div class="font-semibold text-gray-900">{{ viewingLog.driver_name || 'N/A' }}</div>
                </div>
                <div>
                  <div class="text-sm text-gray-600">Station</div>
                  <div class="font-semibold text-gray-900">{{ viewingLog.station || 'N/A' }}</div>
                </div>
                <div>
                  <div class="text-sm text-gray-600">Odometer</div>
                  <div class="font-semibold text-gray-900">{{ viewingLog.odometer ? viewingLog.odometer.toLocaleString() + ' km' : 'N/A' }}</div>
                </div>
                <div>
                  <div class="text-sm text-gray-600">Trip Reference</div>
                  <div class="font-semibold text-gray-900">{{ viewingLog.trip_reference || 'General' }}</div>
                </div>
              </div>
            </div>

            <div v-if="viewingLog.notes" class="p-4 bg-gray-50 rounded-lg">
              <div class="text-xs font-semibold text-gray-500 uppercase mb-2">Notes</div>
              <div class="text-sm text-gray-900">{{ viewingLog.notes }}</div>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex gap-3 justify-end mt-6 pt-5 border-t border-gray-200">
            <button @click="viewingLog = null" class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2.5 px-4 rounded-lg cursor-pointer font-medium flex items-center gap-2 transition-all duration-200 text-sm hover:bg-slate-500/20">
              Close
            </button>
            <button @click="editFromView" class="bg-gradient-to-br text-white border-none py-2.5 px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg text-sm hover:-translate-y-0.5"
                    style="background: linear-gradient(135deg, #0A400C, #155c1a);">
              <i class="fas fa-edit"></i>
              Edit Log
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="logToDelete" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-50 backdrop-blur-sm p-4 transition-colors duration-200">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-md shadow-2xl animate-scale-in transition-colors duration-200">
        <div class="py-6 px-8 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br from-red-500 to-red-600 text-white rounded-t-2xl">
          <div>
            <h3 class="m-0 text-xl font-semibold">Confirm Deletion</h3>
            <p class="text-sm text-white/80 mt-1">This action cannot be undone</p>
          </div>
          <button class="bg-white/10 border-none text-white w-8 h-8 rounded-lg cursor-pointer flex items-center justify-center transition-colors duration-200 hover:bg-white/20" @click="logToDelete = null">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8">
          <div class="text-center mb-6">
            <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <i class="fas fa-exclamation-triangle text-red-600 text-2xl"></i>
            </div>
            <p class="text-lg text-gray-700 font-medium">Are you sure you want to delete this fuel log?</p>
            <p class="text-sm text-gray-500 mt-2">This will permanently remove the record from the system.</p>
          </div>
          
          <div class="flex gap-3 justify-center">
            <button @click="logToDelete = null" class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2.5 px-5 rounded-lg cursor-pointer font-medium flex items-center gap-2 transition-all duration-200 text-sm hover:bg-slate-500/20 hover:text-slate-700">
              <i class="fas fa-times"></i>
              Cancel
            </button>
            <button @click="deleteLog" class="bg-gradient-to-br from-red-500 to-red-600 text-white border-none py-2.5 px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg shadow-red-500/30 text-sm hover:from-red-600 hover:to-red-700 hover:-translate-y-0.5 hover:shadow-xl hover:shadow-red-500/40">
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
import { useToast } from '../composables/useToast'
import { useSidebar } from '../composables/useSidebar'
import Navbar from './Navbar.vue'
import PageHeader from '../components/PageHeader.vue'

export default {
  name: 'FuelLogs',
  components: { Navbar, PageHeader },
  setup() {
    const router = useRouter()
    const route = useRoute()
    const { success, error } = useToast()
    const { sidebarCollapsed, sidebarOpen, toggleSidebar, closeSidebar, openSidebar, handleMenuClick } = useSidebar()

    // Data
    const fuelLogs = ref([])
    const vehicles = ref([])
    const trips = ref([])
    const drivers = ref([])
    const loading = ref(true)

    // View & Sort
    const viewMode = ref('table')
    const sortBy = ref('date-desc')

    // Filters
    const searchQuery = ref('')
    const vehicleFilter = ref('')
    const driverFilter = ref('')
    const dateRangeFilter = ref('')
    const showFilters = ref(false)

    // Modal state
    const showModal = ref(false)
    const editingLog = ref(null)
    const viewingLog = ref(null)
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
      fuel_type: '',
      notes: ''
    })

    // Computed
    const pricePerLiter = computed(() => {
      if (form.liters && form.cost) {
        return (form.cost / form.liters).toFixed(2)
      }
      return '0.00'
    })

    const filteredLogs = computed(() => {
      let filtered = fuelLogs.value

      // Search filter
      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        filtered = filtered.filter(log =>
          getVehiclePlate(log.vehicle_id).toLowerCase().includes(query) ||
          (log.driver_name && log.driver_name.toLowerCase().includes(query)) ||
          (log.station && log.station.toLowerCase().includes(query)) ||
          (log.trip_reference && log.trip_reference.toLowerCase().includes(query))
        )
      }

      // Vehicle filter
      if (vehicleFilter.value) {
        filtered = filtered.filter(log => log.vehicle_id === vehicleFilter.value)
      }

      // Driver filter
      if (driverFilter.value) {
        filtered = filtered.filter(log => log.driver_id === driverFilter.value)
      }

      // Date range filter
      if (dateRangeFilter.value) {
        const now = new Date()
        let startDate
        
        if (dateRangeFilter.value === 'today') {
          startDate = new Date(now.setHours(0, 0, 0, 0))
        } else if (dateRangeFilter.value === 'week') {
          startDate = new Date(now.setDate(now.getDate() - 7))
        } else if (dateRangeFilter.value === 'month') {
          startDate = new Date(now.setMonth(now.getMonth() - 1))
        }
        
        if (startDate) {
          filtered = filtered.filter(log => new Date(log.created_at) >= startDate)
        }
      }

      return filtered
    })

    const sortedLogs = computed(() => {
      const logs = [...filteredLogs.value]
      
      switch (sortBy.value) {
        case 'date-desc':
          return logs.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
        case 'date-asc':
          return logs.sort((a, b) => new Date(a.created_at) - new Date(b.created_at))
        case 'liters-desc':
          return logs.sort((a, b) => b.liters - a.liters)
        case 'liters-asc':
          return logs.sort((a, b) => a.liters - b.liters)
        case 'cost-desc':
          return logs.sort((a, b) => (b.cost || 0) - (a.cost || 0))
        case 'cost-asc':
          return logs.sort((a, b) => (a.cost || 0) - (b.cost || 0))
        default:
          return logs
      }
    })

    const hasActiveFilters = computed(() => {
      return searchQuery.value || vehicleFilter.value || driverFilter.value || dateRangeFilter.value
    })

    const activeFiltersCount = computed(() => {
      let count = 0
      if (vehicleFilter.value) count++
      if (driverFilter.value) count++
      if (dateRangeFilter.value) count++
      return count
    })

    const fuelStats = computed(() => {
      const logs = fuelLogs.value
      const totalLogs = logs.length
      const totalLiters = logs.reduce((sum, log) => sum + (log.liters || 0), 0).toFixed(1)
      const totalCost = logs.reduce((sum, log) => sum + (log.cost || 0), 0).toFixed(2)
      const avgCostPerLiter = totalLiters > 0 ? (totalCost / totalLiters).toFixed(2) : '0.00'
      const percentageChange = '+12.5' // Mock data - calculate actual in production
      
      return { totalLogs, totalLiters, totalCost, avgCostPerLiter, percentageChange }
    })

    // Methods
    // Sidebar methods are now from useSidebar composable

    const formatDate = (dateString) => {
      if (!dateString) return 'N/A'
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }

    const formatTime = (dateString) => {
      if (!dateString) return 'N/A'
      return new Date(dateString).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const getVehiclePlate = (vehicleId) => {
      const vehicle = vehicles.value.find(v => v.id === vehicleId)
      return vehicle ? vehicle.plate_number : 'Unknown'
    }

    const getVehicleDetails = (vehicleId) => {
      const vehicle = vehicles.value.find(v => v.id === vehicleId)
      return vehicle ? `${vehicle.make} ${vehicle.model}` : ''
    }

    const getDriverName = (driverId) => {
      const driver = drivers.value.find(d => d.id === driverId)
      return driver ? driver.full_name : 'Unknown'
    }

    const calculatePricePerLiter = (log) => {
      if (log.liters && log.cost) {
        return (log.cost / log.liters).toFixed(2)
      }
      return 'N/A'
    }

    const exportToCSV = () => {
      const headers = ['Date', 'Vehicle', 'Driver', 'Liters', 'Cost', 'Price/L', 'Odometer', 'Station', 'Trip']
      const rows = filteredLogs.value.map(log => [
        formatDate(log.created_at),
        getVehiclePlate(log.vehicle_id),
        log.driver_name || 'N/A',
        log.liters,
        log.cost || 'N/A',
        calculatePricePerLiter(log),
        log.odometer || 'N/A',
        log.station || 'N/A',
        log.trip_reference || 'General'
      ])

      const csvContent = [
        headers.join(','),
        ...rows.map(row => row.join(','))
      ].join('\n')

      const blob = new Blob([csvContent], { type: 'text/csv' })
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `fuel-logs-${new Date().toISOString().split('T')[0]}.csv`
      a.click()
      window.URL.revokeObjectURL(url)
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
        
        if (logsError) throw logsError
        
        fuelLogs.value = logsData.map(log => ({
          ...log,
          driver_name: log.drivers?.full_name || null
        }))

      } catch (err) {
        console.error('Error loading data:', err)
        error('Failed to load fuel logs. Please refresh the page.')
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
        fuel_type: '',
        notes: ''
      })
    }

    const viewLog = (log) => {
      viewingLog.value = log
    }

    const editFromView = () => {
      if (viewingLog.value) {
        editLog(viewingLog.value)
        viewingLog.value = null
      }
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
        fuel_type: log.fuel_type || '',
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
          fuel_type: form.fuel_type || null,
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

        // Show success message BEFORE closing modal (so editingLog is still set)
        success(editingLog.value ? 'Fuel log updated successfully!' : 'Fuel log created successfully!')
        closeModal()
      } catch (err) {
        console.error('Error submitting fuel log:', err)
        error('Error: ' + err.message)
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
        success('Fuel log deleted successfully!')
      } catch (err) {
        console.error('Error deleting fuel log:', err)
        error('Error deleting fuel log: ' + err.message)
      }
    }

    const clearFilters = () => {
      searchQuery.value = ''
      vehicleFilter.value = ''
      driverFilter.value = ''
      dateRangeFilter.value = ''
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
      viewMode,
      sortBy,
      searchQuery,
      vehicleFilter,
      driverFilter,
      dateRangeFilter,
      showFilters,
      filteredLogs,
      sortedLogs,
      hasActiveFilters,
      activeFiltersCount,
      fuelStats,
      showModal,
      editingLog,
      viewingLog,
      submitting,
      logToDelete,
      form,
      pricePerLiter,
      formatDate,
      formatTime,
      getVehiclePlate,
      getVehicleDetails,
      getDriverName,
      calculatePricePerLiter,
      exportToCSV,
      openAddModal,
      closeModal,
      viewLog,
      editFromView,
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
@keyframes scale-in {
  from {
    transform: scale(0.95);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

.animate-scale-in {
  animation: scale-in 0.2s ease-out;
}

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
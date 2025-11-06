<template>
  <div class="flex h-screen bg-gradient-to-br from-green-50 to-green-100 font-inter">
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
      
      <!-- Header with Actions -->
      <header class="bg-white/95 backdrop-blur-xl py-5 px-8 border-b border-white/20 flex flex-col sm:flex-row justify-between items-start sm:items-center shadow-sm sticky top-0 z-10 gap-4 sm:gap-0">
        <div class="flex items-center gap-4 w-full sm:w-auto">
          <button
            @click="openSidebar"
            class="bg-green-800 border-none text-white py-2.5 px-3 rounded-lg cursor-pointer transition-all duration-200 hover:bg-green-700 hover:scale-105 lg:hidden"
            v-if="!sidebarOpen"
            style="background-color: #0A400C;"
          >
            <i class="fas fa-bars"></i>
          </button>
          <div>
            <h1 class="m-0 text-xl sm:text-2xl lg:text-3xl font-bold tracking-tight" 
                style="color: #0A400C;">Fuel Management</h1>
            <p class="text-sm text-gray-600 mt-1">Track and manage vehicle fuel consumption</p>
          </div>
        </div>
        <div class="flex gap-2 sm:gap-3 w-full sm:w-auto">
          <button
            @click="exportToCSV"
            class="bg-white text-green-800 border-2 border-green-800 py-2 px-3 sm:py-2.5 sm:px-4 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 text-xs sm:text-sm hover:-translate-y-0.5 hover:shadow-lg flex-1 sm:flex-initial justify-center"
          >
            <i class="fas fa-download"></i>
            <span class="hidden sm:inline">Export</span>
          </button>
          <button
            @click="openAddModal"
            class="bg-gradient-to-br text-white border-none py-2 px-3 sm:py-2.5 sm:px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg text-xs sm:text-sm hover:-translate-y-0.5 hover:shadow-xl flex-1 sm:flex-initial justify-center"
            style="background: linear-gradient(135deg, #0A400C, #155c1a); box-shadow: 0 10px 25px rgba(10, 64, 12, 0.3);"
          >
            <i class="fas fa-plus"></i>
            <span>Add Log</span>
          </button>
        </div>
      </header>

      <!-- Main Content -->
      <div class="flex-1 p-4 sm:p-6 lg:p-8 overflow-y-auto">
        <div class="max-w-7xl mx-auto">
          
          <!-- Advanced Statistics Cards -->
          <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-6 sm:mb-8">
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 cursor-pointer group"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="flex items-center justify-between mb-3">
                <div class="w-12 h-12 rounded-lg bg-green-100 flex items-center justify-center group-hover:scale-110 transition-transform">
                  <i class="fas fa-gas-pump text-green-600 text-xl"></i>
                </div>
                <span class="text-xs font-semibold text-green-600 bg-green-100 px-2 py-1 rounded-full">
                  {{ fuelStats.percentageChange }}%
                </span>
              </div>
              <div class="text-2xl sm:text-3xl font-bold mb-1" style="color: #0A400C;">{{ fuelStats.totalLogs }}</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Total Fuel Logs</div>
            </div>
            
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 cursor-pointer group"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="flex items-center justify-between mb-3">
                <div class="w-12 h-12 rounded-lg bg-blue-100 flex items-center justify-center group-hover:scale-110 transition-transform">
                  <i class="fas fa-tint text-blue-600 text-xl"></i>
                </div>
                <i class="fas fa-arrow-up text-blue-600 text-xs"></i>
              </div>
              <div class="text-2xl sm:text-3xl font-bold mb-1 text-blue-600">{{ fuelStats.totalLiters }}L</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Total Fuel Volume</div>
            </div>
            
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 cursor-pointer group"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="flex items-center justify-between mb-3">
                <div class="w-12 h-12 rounded-lg bg-green-100 flex items-center justify-center group-hover:scale-110 transition-transform">
                  <i class="fas fa-peso-sign text-green-600 text-xl"></i>
                </div>
                <i class="fas fa-chart-line text-green-600 text-xs"></i>
              </div>
              <div class="text-2xl sm:text-3xl font-bold mb-1 text-green-600">₱{{ fuelStats.totalCost }}</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Total Expenditure</div>
            </div>
            
            <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-6 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 cursor-pointer group"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="flex items-center justify-between mb-3">
                <div class="w-12 h-12 rounded-lg bg-orange-100 flex items-center justify-center group-hover:scale-110 transition-transform">
                  <i class="fas fa-calculator text-orange-600 text-xl"></i>
                </div>
                <span class="text-xs font-semibold text-orange-600">AVG</span>
              </div>
              <div class="text-2xl sm:text-3xl font-bold mb-1 text-orange-600">₱{{ fuelStats.avgCostPerLiter }}</div>
              <div class="text-xs sm:text-sm text-slate-600 font-medium">Cost per Liter</div>
            </div>
          </div>

          <!-- Fuel Efficiency Insights -->
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 sm:gap-6 mb-6 sm:mb-8">
            <div class="bg-white/90 backdrop-blur-xl p-5 rounded-xl shadow-lg"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="flex items-center gap-3 mb-3">
                <div class="w-10 h-10 rounded-lg bg-purple-100 flex items-center justify-center">
                  <i class="fas fa-trophy text-purple-600"></i>
                </div>
                <div>
                  <h3 class="font-semibold text-gray-900 text-sm">Most Efficient Vehicle</h3>
                  <p class="text-xs text-gray-600">Best fuel economy</p>
                </div>
              </div>
              <div class="text-lg font-bold text-purple-600">{{ mostEfficientVehicle }}</div>
            </div>

            <div class="bg-white/90 backdrop-blur-xl p-5 rounded-xl shadow-lg"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="flex items-center gap-3 mb-3">
                <div class="w-10 h-10 rounded-lg bg-amber-100 flex items-center justify-center">
                  <i class="fas fa-calendar-week text-amber-600"></i>
                </div>
                <div>
                  <h3 class="font-semibold text-gray-900 text-sm">This Month</h3>
                  <p class="text-xs text-gray-600">Current period usage</p>
                </div>
              </div>
              <div class="text-lg font-bold text-amber-600">{{ monthlyStats.logs }} logs / ₱{{ monthlyStats.cost }}</div>
            </div>

            <div class="bg-white/90 backdrop-blur-xl p-5 rounded-xl shadow-lg"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="flex items-center gap-3 mb-3">
                <div class="w-10 h-10 rounded-lg bg-red-100 flex items-center justify-center">
                  <i class="fas fa-exclamation-triangle text-red-600"></i>
                </div>
                <div>
                  <h3 class="font-semibold text-gray-900 text-sm">High Consumption</h3>
                  <p class="text-xs text-gray-600">Needs attention</p>
                </div>
              </div>
              <div class="text-lg font-bold text-red-600">{{ highConsumptionVehicle }}</div>
            </div>
          </div>

          <!-- Advanced Filters Section -->
          <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-5 rounded-xl mb-6 sm:mb-8 shadow-lg"
               style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
            <div class="flex items-center justify-between mb-4">
              <h3 class="font-semibold text-gray-900 flex items-center gap-2">
                <i class="fas fa-filter text-green-600"></i>
                Filter & Search
              </h3>
              <button @click="toggleAdvancedFilters" class="text-sm text-green-600 hover:text-green-700 font-medium">
                {{ showAdvancedFilters ? 'Simple' : 'Advanced' }}
                <i :class="showAdvancedFilters ? 'fas fa-chevron-up' : 'fas fa-chevron-down'" class="ml-1"></i>
              </button>
            </div>

            <div class="flex flex-col gap-4">
              <!-- Basic Search -->
              <div class="relative flex-1">
                <i class="fas fa-search absolute left-4 top-1/2 transform -translate-y-1/2 text-slate-500"></i>
                <input
                  type="text"
                  v-model="searchQuery"
                  placeholder="Search by vehicle, driver, station, or trip..."
                  class="w-full py-3 pl-11 pr-4 border border-slate-300 rounded-lg text-sm bg-white transition-colors duration-200 focus:outline-none focus:ring-4"
                  style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                  :style="{ 'border-color': searchQuery ? '#0A400C' : '' }"
                >
              </div>

              <!-- Basic Filters -->
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <select v-model="vehicleFilter" class="py-2.5 px-3 border border-slate-300 rounded-lg bg-white text-sm text-gray-700 focus:outline-none focus:ring-4"
                        style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <option value="">All Vehicles</option>
                  <option v-for="vehicle in vehicles" :key="vehicle.id" :value="vehicle.id">
                    {{ vehicle.plate_number }}
                  </option>
                </select>

                <select v-model="driverFilter" class="py-2.5 px-3 border border-slate-300 rounded-lg bg-white text-sm text-gray-700 focus:outline-none focus:ring-4"
                        style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <option value="">All Drivers</option>
                  <option v-for="driver in drivers" :key="driver.id" :value="driver.id">
                    {{ driver.full_name }}
                  </option>
                </select>

                <select v-model="dateRangeFilter" @change="handleDateRangeChange" class="py-2.5 px-3 border border-slate-300 rounded-lg bg-white text-sm text-gray-700 focus:outline-none focus:ring-4"
                        style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <option value="">All Time</option>
                  <option value="today">Today</option>
                  <option value="week">This Week</option>
                  <option value="month">This Month</option>
                  <option value="custom">Custom Range</option>
                </select>

                <button @click="clearFilters" class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2.5 px-4 rounded-lg cursor-pointer font-medium flex items-center justify-center gap-1.5 transition-all duration-200 text-sm hover:bg-slate-500/20 hover:text-slate-700">
                  <i class="fas fa-times"></i>
                  Clear Filters
                </button>
              </div>

              <!-- Advanced Filters -->
              <div v-if="showAdvancedFilters" class="pt-4 border-t border-gray-200">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                  <div>
                    <label class="text-xs font-medium text-gray-700 mb-1 block">Min Liters</label>
                    <input type="number" v-model.number="minLiters" placeholder="0" 
                           class="w-full py-2 px-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-4"
                           style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  </div>

                  <div>
                    <label class="text-xs font-medium text-gray-700 mb-1 block">Max Liters</label>
                    <input type="number" v-model.number="maxLiters" placeholder="1000" 
                           class="w-full py-2 px-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-4"
                           style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  </div>

                  <div>
                    <label class="text-xs font-medium text-gray-700 mb-1 block">Min Cost</label>
                    <input type="number" v-model.number="minCost" placeholder="0" 
                           class="w-full py-2 px-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-4"
                           style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  </div>

                  <div>
                    <label class="text-xs font-medium text-gray-700 mb-1 block">Max Cost</label>
                    <input type="number" v-model.number="maxCost" placeholder="10000" 
                           class="w-full py-2 px-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-4"
                           style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  </div>

                  <div>
                    <label class="text-xs font-medium text-gray-700 mb-1 block">Start Date</label>
                    <input type="date" v-model="startDate" 
                           class="w-full py-2 px-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-4"
                           style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  </div>

                  <div>
                    <label class="text-xs font-medium text-gray-700 mb-1 block">End Date</label>
                    <input type="date" v-model="endDate" 
                           class="w-full py-2 px-3 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-4"
                           style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  </div>
                </div>
              </div>

              <!-- Active Filters Display -->
              <div v-if="activeFiltersCount > 0" class="flex flex-wrap gap-2">
                <span class="text-xs font-medium text-gray-600">Active filters:</span>
                <span v-if="vehicleFilter" class="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-medium flex items-center gap-1">
                  Vehicle: {{ getVehiclePlate(vehicleFilter) }}
                  <i @click="vehicleFilter = ''" class="fas fa-times cursor-pointer hover:text-green-900"></i>
                </span>
                <span v-if="driverFilter" class="px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-medium flex items-center gap-1">
                  Driver: {{ getDriverName(driverFilter) }}
                  <i @click="driverFilter = ''" class="fas fa-times cursor-pointer hover:text-blue-900"></i>
                </span>
                <span v-if="dateRangeFilter" class="px-2 py-1 bg-purple-100 text-purple-700 rounded-full text-xs font-medium flex items-center gap-1">
                  Period: {{ dateRangeFilter }}
                  <i @click="dateRangeFilter = ''" class="fas fa-times cursor-pointer hover:text-purple-900"></i>
                </span>
              </div>
            </div>
          </div>

          <!-- View Toggle & Sort -->
          <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-4 gap-4">
            <div class="text-sm text-gray-600">
              Showing <span class="font-semibold text-gray-900">{{ filteredLogs.length }}</span> of 
              <span class="font-semibold text-gray-900">{{ fuelLogs.length }}</span> fuel logs
            </div>
            
            <div class="flex gap-2 items-center w-full sm:w-auto">
              <select v-model="sortBy" class="py-2 px-3 border border-slate-300 rounded-lg bg-white text-sm text-gray-700 focus:outline-none focus:ring-4 flex-1 sm:flex-initial"
                      style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                <option value="date-desc">Newest First</option>
                <option value="date-asc">Oldest First</option>
                <option value="liters-desc">Highest Liters</option>
                <option value="liters-asc">Lowest Liters</option>
                <option value="cost-desc">Highest Cost</option>
                <option value="cost-asc">Lowest Cost</option>
              </select>

              <div class="hidden lg:flex bg-white border border-slate-300 rounded-lg overflow-hidden">
                <button @click="viewMode = 'table'" 
                        :class="viewMode === 'table' ? 'bg-green-600 text-white' : 'bg-white text-gray-600 hover:bg-gray-50'"
                        class="px-3 py-2 text-sm transition-colors">
                  <i class="fas fa-table"></i>
                </button>
                <button @click="viewMode = 'grid'" 
                        :class="viewMode === 'grid' ? 'bg-green-600 text-white' : 'bg-white text-gray-600 hover:bg-gray-50'"
                        class="px-3 py-2 text-sm transition-colors border-l border-slate-300">
                  <i class="fas fa-th"></i>
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

          <!-- Desktop Table View -->
          <div v-else-if="viewMode === 'table'" class="bg-white/90 backdrop-blur-xl rounded-2xl shadow-lg overflow-hidden"
               style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
            <div class="overflow-x-auto">
              <table class="w-full">
                <thead>
                  <tr class="bg-gradient-to-br text-white"
                      style="background: linear-gradient(135deg, #0A400C, #155c1a);">
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">
                      <div class="flex items-center gap-2">
                        <i class="fas fa-calendar"></i>
                        Date & Time
                      </div>
                    </th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">
                      <div class="flex items-center gap-2">
                        <i class="fas fa-car"></i>
                        Vehicle
                      </div>
                    </th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">
                      <div class="flex items-center gap-2">
                        <i class="fas fa-user"></i>
                        Driver
                      </div>
                    </th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">
                      <div class="flex items-center gap-2">
                        <i class="fas fa-tint"></i>
                        Volume
                      </div>
                    </th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">
                      <div class="flex items-center gap-2">
                        <i class="fas fa-peso-sign"></i>
                        Cost
                      </div>
                    </th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">
                      <div class="flex items-center gap-2">
                        <i class="fas fa-tachometer-alt"></i>
                        Odometer
                      </div>
                    </th>
                    <th class="px-6 py-4 text-left text-xs font-semibold uppercase tracking-wider">
                      <div class="flex items-center gap-2">
                        <i class="fas fa-map-marker-alt"></i>
                        Station
                      </div>
                    </th>
                    <th class="px-6 py-4 text-center text-xs font-semibold uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                  <tr v-for="log in sortedLogs" :key="log.id" class="hover:bg-gray-50 transition-colors">
                    <td class="px-6 py-4 text-sm">
                      <div class="font-medium text-gray-900">{{ formatDate(log.created_at) }}</div>
                      <div class="text-gray-500 text-xs">{{ formatTime(log.created_at) }}</div>
                    </td>
                    <td class="px-6 py-4 text-sm">
                      <div class="flex items-center gap-2">
                        <div class="w-8 h-8 rounded-lg bg-green-100 flex items-center justify-center">
                          <i class="fas fa-car text-green-600 text-xs"></i>
                        </div>
                        <div>
                          <div class="font-medium text-gray-900">{{ getVehiclePlate(log.vehicle_id) }}</div>
                          <div class="text-gray-500 text-xs">{{ getVehicleDetails(log.vehicle_id) }}</div>
                        </div>
                      </div>
                    </td>
                    <td class="px-6 py-4 text-sm">
                      <div class="flex items-center gap-2">
                        <div class="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center">
                          <i class="fas fa-user text-blue-600 text-xs"></i>
                        </div>
                        <span class="font-medium text-gray-900">{{ log.driver_name || 'N/A' }}</span>
                      </div>
                    </td>
                    <td class="px-6 py-4 text-sm">
                      <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                        <i class="fas fa-tint mr-1"></i>
                        {{ log.liters }}L
                      </span>
                    </td>
                    <td class="px-6 py-4 text-sm">
                      <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        <i class="fas fa-peso-sign mr-1"></i>
                        {{ log.cost || 'N/A' }}
                      </span>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-900">
                      <span class="font-mono">{{ log.odometer ? log.odometer.toLocaleString() + ' km' : 'N/A' }}</span>
                    </td>
                    <td class="px-6 py-4 text-sm">
                      <div class="flex items-center gap-1">
                        <i class="fas fa-map-marker-alt text-orange-600 text-xs"></i>
                        <span class="text-gray-900">{{ log.station || 'N/A' }}</span>
                      </div>
                    </td>
                    <td class="px-6 py-4 text-center">
                      <div class="flex items-center justify-center gap-2">
                        <button @click="viewLog(log)" class="w-8 h-8 bg-green-500/10 text-green-600 rounded-lg flex items-center justify-center hover:bg-green-500/20 transition-colors" title="View Details">
                          <i class="fas fa-eye text-xs"></i>
                        </button>
                        <button @click="editLog(log)" class="w-8 h-8 bg-amber-500/10 text-amber-600 rounded-lg flex items-center justify-center hover:bg-amber-500/20 transition-colors" title="Edit">
                          <i class="fas fa-edit text-xs"></i>
                        </button>
                        <button @click="confirmDelete(log)" class="w-8 h-8 bg-red-500/10 text-red-600 rounded-lg flex items-center justify-center hover:bg-red-500/20 transition-colors" title="Delete">
                          <i class="fas fa-trash text-xs"></i>
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Grid View -->
          <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div v-for="log in sortedLogs" :key="log.id" 
                 class="bg-white/90 backdrop-blur-xl rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-all duration-300 cursor-pointer group"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <div class="p-5">
                <div class="flex justify-between items-start mb-4">
                  <div class="flex items-center gap-3">
                    <div class="w-12 h-12 rounded-lg bg-gradient-to-br from-green-600 to-green-700 flex items-center justify-center">
                      <i class="fas fa-gas-pump text-white text-lg"></i>
                    </div>
                    <div>
                      <div class="font-bold text-gray-900">{{ getVehiclePlate(log.vehicle_id) }}</div>
                      <div class="text-xs text-gray-500">{{ formatDate(log.created_at) }}</div>
                    </div>
                  </div>
                  <div class="flex gap-1">
                    <button @click.stop="viewLog(log)" class="w-7 h-7 bg-green-500/10 text-green-600 rounded-lg flex items-center justify-center hover:bg-green-500/20 transition-colors">
                      <i class="fas fa-eye text-xs"></i>
                    </button>
                    <button @click.stop="editLog(log)" class="w-7 h-7 bg-amber-500/10 text-amber-600 rounded-lg flex items-center justify-center hover:bg-amber-500/20 transition-colors">
                      <i class="fas fa-edit text-xs"></i>
                    </button>
                    <button @click.stop="confirmDelete(log)" class="w-7 h-7 bg-red-500/10 text-red-600 rounded-lg flex items-center justify-center hover:bg-red-500/20 transition-colors">
                      <i class="fas fa-trash text-xs"></i>
                    </button>
                  </div>
                </div>

                <div class="space-y-3">
                  <div class="flex justify-between items-center p-3 bg-blue-50 rounded-lg">
                    <div class="flex items-center gap-2">
                      <i class="fas fa-tint text-blue-600"></i>
                      <span class="text-sm text-gray-600">Volume</span>
                    </div>
                    <span class="font-bold text-blue-600">{{ log.liters }}L</span>
                  </div>

                  <div class="flex justify-between items-center p-3 bg-green-50 rounded-lg">
                    <div class="flex items-center gap-2">
                      <i class="fas fa-peso-sign text-green-600"></i>
                      <span class="text-sm text-gray-600">Cost</span>
                    </div>
                    <span class="font-bold text-green-600">₱{{ log.cost || 'N/A' }}</span>
                  </div>

                  <div class="grid grid-cols-2 gap-2">
                    <div class="p-2 bg-gray-50 rounded-lg">
                      <div class="text-xs text-gray-500 mb-1">Driver</div>
                      <div class="text-sm font-medium text-gray-900 truncate">{{ log.driver_name || 'N/A' }}</div>
                    </div>
                    <div class="p-2 bg-gray-50 rounded-lg">
                      <div class="text-xs text-gray-500 mb-1">Odometer</div>
                      <div class="text-sm font-medium text-gray-900">{{ log.odometer || 'N/A' }}</div>
                    </div>
                  </div>

                  <div v-if="log.station" class="flex items-center gap-2 p-2 bg-orange-50 rounded-lg">
                    <i class="fas fa-map-marker-alt text-orange-600 text-xs"></i>
                    <span class="text-sm text-gray-900 truncate">{{ log.station }}</span>
                  </div>

                  <div v-if="log.trip_reference" class="flex items-center gap-2 p-2 bg-purple-50 rounded-lg">
                    <i class="fas fa-route text-purple-600 text-xs"></i>
                    <span class="text-sm text-gray-900 truncate">{{ log.trip_reference }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Add/Edit Fuel Log Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm p-4">
      <div class="bg-white rounded-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto shadow-2xl">
        <div class="py-6 px-8 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br text-white rounded-t-2xl sticky top-0 z-10"
             style="background: linear-gradient(135deg, #0A400C, #155c1a);">
          <div>
            <h3 class="m-0 text-xl font-semibold">{{ editingLog ? 'Edit Fuel Log' : 'Add New Fuel Log' }}</h3>
            <p class="text-sm text-white/80 mt-1">{{ editingLog ? 'Update fuel consumption details' : 'Record new fuel transaction' }}</p>
          </div>
          <button class="bg-white/10 border-none text-white w-8 h-8 rounded-lg cursor-pointer flex items-center justify-center transition-colors duration-200 hover:bg-white/20" @click="closeModal">
            <i class="fas fa-times"></i>
          </button>
        </div>

        <form @submit.prevent="submitForm" class="p-8">
          <!-- Vehicle & Trip Selection -->
          <div class="mb-6">
            <h4 class="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <i class="fas fa-car text-green-600"></i>
              Vehicle & Trip Information
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 text-sm">
                  Vehicle *
                  <span class="text-red-500">*</span>
                </label>
                <select v-model="form.vehicle_id" required class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                        style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <option value="">Select Vehicle</option>
                  <option v-for="vehicle in vehicles" :key="vehicle.id" :value="vehicle.id">
                    {{ vehicle.plate_number }} - {{ vehicle.make }} {{ vehicle.model }}
                  </option>
                </select>
              </div>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 text-sm">
                  Associated Trip
                  <span class="text-gray-500 text-xs font-normal">(Optional)</span>
                </label>
                <select v-model="form.trip_id" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
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
            <h4 class="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <i class="fas fa-gas-pump text-green-600"></i>
              Fuel Details
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 text-sm">
                  Liters <span class="text-red-500">*</span>
                </label>
                <div class="relative">
                  <input type="number" v-model.number="form.liters" step="0.01" required 
                         placeholder="50.5"
                         class="w-full py-3 pl-4 pr-10 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                         style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <span class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 text-sm">L</span>
                </div>
              </div>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 text-sm">Total Cost</label>
                <div class="relative">
                  <span class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 text-sm">₱</span>
                  <input type="number" v-model.number="form.cost" step="0.01"
                         placeholder="2500.00"
                         class="w-full py-3 pl-8 pr-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                         style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                </div>
              </div>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 text-sm">Price per Liter</label>
                <div class="relative">
                  <span class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 text-sm">₱</span>
                  <input type="text" :value="pricePerLiter" readonly
                         class="w-full py-3 pl-8 pr-4 border border-gray-200 rounded-lg text-sm bg-gray-50 text-gray-600"
                         placeholder="Auto-calculated">
                </div>
              </div>
            </div>
          </div>

          <!-- Vehicle Status -->
          <div class="mb-6">
            <h4 class="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <i class="fas fa-tachometer-alt text-green-600"></i>
              Vehicle Status
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 text-sm">Odometer Reading</label>
                <div class="relative">
                  <input type="number" v-model.number="form.odometer"
                         placeholder="45000"
                         class="w-full py-3 pl-4 pr-12 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                         style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                  <span class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 text-sm">km</span>
                </div>
              </div>
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 text-sm">Fuel Type</label>
                <select v-model="form.fuel_type" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
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
            <h4 class="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <i class="fas fa-map-marker-alt text-green-600"></i>
              Driver & Location Information
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
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
              <div class="flex flex-col gap-2">
                <label class="font-semibold text-gray-700 text-sm">Gas Station/Location</label>
                <input type="text" v-model="form.station"
                       placeholder="Shell Station EDSA"
                       class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                       style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
              </div>
            </div>
          </div>

          <!-- Additional Information -->
          <div class="mb-6">
            <h4 class="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <i class="fas fa-sticky-note text-green-600"></i>
              Additional Information
            </h4>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Notes & Remarks</label>
              <textarea v-model="form.notes" rows="4"
                        placeholder="Add any additional notes, observations, or remarks about this fuel transaction..."
                        class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white resize-y min-h-20 focus:outline-none focus:ring-4"
                        style="--tw-ring-color: rgba(10, 64, 12, 0.1);"></textarea>
            </div>
          </div>

          <!-- Form Actions -->
          <div class="flex gap-4 justify-end pt-5 border-t border-gray-200">
            <button type="button" @click="closeModal" class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-3 px-5 rounded-lg cursor-pointer font-medium flex items-center gap-2 transition-all duration-200 text-sm hover:bg-slate-500/20 hover:text-slate-700">
              <i class="fas fa-times"></i>
              Cancel
            </button>
            <button type="submit" class="bg-gradient-to-br text-white border-none py-3 px-6 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg text-sm hover:-translate-y-0.5 hover:shadow-xl disabled:opacity-60 disabled:cursor-not-allowed disabled:transform-none" 
                    style="background: linear-gradient(135deg, #0A400C, #155c1a); box-shadow: 0 10px 25px rgba(10, 64, 12, 0.3);"
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
    <div v-if="viewingLog" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm p-4">
      <div class="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl">
        <div class="py-6 px-8 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br text-white rounded-t-2xl"
             style="background: linear-gradient(135deg, #0A400C, #155c1a);">
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
    <div v-if="logToDelete" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm p-4">
      <div class="bg-white rounded-2xl w-full max-w-md shadow-2xl animate-scale-in">
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

    // View & Sort
    const viewMode = ref('table')
    const sortBy = ref('date-desc')

    // Filters
    const searchQuery = ref('')
    const vehicleFilter = ref('')
    const driverFilter = ref('')
    const dateRangeFilter = ref('')
    const showAdvancedFilters = ref(false)
    const minLiters = ref(null)
    const maxLiters = ref(null)
    const minCost = ref(null)
    const maxCost = ref(null)
    const startDate = ref('')
    const endDate = ref('')

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
      if (dateRangeFilter.value && dateRangeFilter.value !== 'custom') {
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

      // Custom date range
      if (startDate.value) {
        filtered = filtered.filter(log => new Date(log.created_at) >= new Date(startDate.value))
      }
      if (endDate.value) {
        filtered = filtered.filter(log => new Date(log.created_at) <= new Date(endDate.value + 'T23:59:59'))
      }

      // Liters filter
      if (minLiters.value !== null) {
        filtered = filtered.filter(log => log.liters >= minLiters.value)
      }
      if (maxLiters.value !== null) {
        filtered = filtered.filter(log => log.liters <= maxLiters.value)
      }

      // Cost filter
      if (minCost.value !== null) {
        filtered = filtered.filter(log => log.cost >= minCost.value)
      }
      if (maxCost.value !== null) {
        filtered = filtered.filter(log => log.cost <= maxCost.value)
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
      return searchQuery.value || vehicleFilter.value || driverFilter.value || 
             dateRangeFilter.value || minLiters.value !== null || maxLiters.value !== null ||
             minCost.value !== null || maxCost.value !== null || startDate.value || endDate.value
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

    const monthlyStats = computed(() => {
      const now = new Date()
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)
      const monthLogs = fuelLogs.value.filter(log => new Date(log.created_at) >= startOfMonth)
      const cost = monthLogs.reduce((sum, log) => sum + (log.cost || 0), 0).toFixed(2)
      
      return { logs: monthLogs.length, cost }
    })

    const mostEfficientVehicle = computed(() => {
      if (fuelLogs.value.length === 0) return 'N/A'
      // Mock calculation - implement actual efficiency logic
      return 'ABC-1234'
    })

    const highConsumptionVehicle = computed(() => {
      if (fuelLogs.value.length === 0) return 'N/A'
      // Mock calculation - implement actual consumption logic
      return 'XYZ-7890'
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

    const toggleAdvancedFilters = () => {
      showAdvancedFilters.value = !showAdvancedFilters.value
    }

    const handleDateRangeChange = () => {
      if (dateRangeFilter.value !== 'custom') {
        startDate.value = ''
        endDate.value = ''
      }
    }

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
          .from('profiles')
          .select('id, full_name, employee_id')
          .eq('role', 'driver')
          .order('full_name')
        
        if (driversError) throw driversError
        drivers.value = driversData

        // Load fuel logs
        const { data: logsData, error: logsError } = await supabase
          .from('fuel_logs')
          .select(`
            *,
            profiles:driver_id (full_name)
          `)
          .order('created_at', { ascending: false })
        
        if (logsError) throw logsError
        
        fuelLogs.value = logsData.map(log => ({
          ...log,
          driver_name: log.profiles?.full_name || null
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
            driver_id: 'driver1',
            driver_name: 'John Doe',
            station: 'Shell EDSA',
            fuel_type: 'gasoline',
            created_at: new Date().toISOString(),
            trip_reference: 'Main Office → Branch Office',
            notes: 'Regular refueling'
          },
          {
            id: 2,
            vehicle_id: 2,
            liters: 75.0,
            cost: 3750.00,
            odometer: 32000,
            driver_id: 'driver2',
            driver_name: 'Jane Smith',
            station: 'Petron BGC',
            fuel_type: 'diesel',
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
      driverFilter.value = ''
      dateRangeFilter.value = ''
      minLiters.value = null
      maxLiters.value = null
      minCost.value = null
      maxCost.value = null
      startDate.value = ''
      endDate.value = ''
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
      showAdvancedFilters,
      minLiters,
      maxLiters,
      minCost,
      maxCost,
      startDate,
      endDate,
      filteredLogs,
      sortedLogs,
      hasActiveFilters,
      activeFiltersCount,
      fuelStats,
      monthlyStats,
      mostEfficientVehicle,
      highConsumptionVehicle,
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
      toggleAdvancedFilters,
      handleDateRangeChange,
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
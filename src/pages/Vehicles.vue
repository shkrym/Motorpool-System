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

    <main class="flex-1 flex flex-col transition-all duration-300 ease-out min-w-0"
          :class="{ 
            'lg:ml-20': sidebarCollapsed && sidebarOpen,
            'lg:ml-[280px]': !sidebarCollapsed && sidebarOpen,
            'ml-0': !sidebarOpen
          }"
          :style="{
            marginLeft: !sidebarOpen ? '0' : (sidebarCollapsed ? '80px' : '280px')
          }"
    >
      
      <!-- Header -->
      <header class="bg-white/95 backdrop-blur-xl py-5 px-8 border-b border-white/20 flex justify-between items-center shadow-sm sticky top-0 z-10">
        <div class="flex items-center gap-4">
          <button
            @click="openSidebar"
            class="bg-green-800 border-none text-white py-2.5 px-3 rounded-lg cursor-pointer transition-all duration-200 hover:bg-green-700 hover:scale-105 lg:hidden"
            v-if="!sidebarOpen"
            style="background-color: #0A400C;"
          >
            <i class="fas fa-bars"></i>
          </button>
          <h1 class="m-0 text-xl sm:text-2xl lg:text-3xl font-bold tracking-tight" 
              style="color: #0A400C;">Vehicle Management</h1>
        </div>
        <div class="flex items-center gap-4">
          <button
            @click="openAddModal"
            class="bg-gradient-to-br text-white border-none py-2 px-3 sm:py-3 sm:px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg text-xs sm:text-sm hover:-translate-y-0.5 hover:shadow-xl"
            style="background: linear-gradient(135deg, #0A400C, #155c1a); box-shadow: 0 10px 25px rgba(10, 64, 12, 0.3);"
          >
            <i class="fas fa-plus"></i>
            <span class="hidden sm:inline">Add Vehicle</span>
          </button>
        </div>
      </header>

      <!-- Main Content -->
      <div class="flex-1 p-4 sm:p-6 lg:p-8 overflow-y-auto">
        <div class="max-w-7xl mx-auto">
          <!-- Filters Section -->
          <div class="bg-white/90 backdrop-blur-xl p-4 sm:p-5 rounded-xl mb-6 sm:mb-8 shadow-lg flex flex-col sm:flex-row gap-4 sm:gap-5 items-stretch sm:items-center"
               style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
            <div class="relative flex-1 min-w-0">
              <i class="fas fa-search absolute left-4 top-1/2 transform -translate-y-1/2 text-slate-500"></i>
              <input
                type="text"
                v-model="searchQuery"
                placeholder="Search by plate number, make, model, vehicle ID..."
                class="w-full py-3 pl-11 pr-4 border border-slate-300 rounded-lg text-sm bg-white transition-colors duration-200 focus:outline-none focus:ring-4"
                style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                :style="{ 'border-color': searchQuery ? '#0A400C' : '' }"
              >
            </div>

            <div class="flex flex-col sm:flex-row gap-4 items-stretch sm:items-center">
              <select v-model="statusFilter" class="py-2.5 px-3 border border-slate-300 rounded-lg bg-white text-sm text-gray-700 min-w-0 sm:min-w-36 focus:outline-none focus:ring-4"
                      style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                      :style="{ 'border-color': statusFilter ? '#0A400C' : '' }">
                <option value="">All Status</option>
                <option value="available">Available</option>
                <option value="in_use">In Use</option>
                <option value="maintenance">Maintenance</option>
                <option value="out_of_service">Out of Service</option>
              </select>

              <select v-model="typeFilter" class="py-2.5 px-3 border border-slate-300 rounded-lg bg-white text-sm text-gray-700 min-w-0 sm:min-w-36 focus:outline-none focus:ring-4"
                      style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                      :style="{ 'border-color': typeFilter ? '#0A400C' : '' }">
                <option value="">All Types</option>
                <option value="car">Car</option>
                <option value="van">Van</option>
                <option value="truck">Truck</option>
                <option value="suv">SUV</option>
                <option value="motorcycle">Motorcycle</option>
                <option value="bus">Bus</option>
              </select>

              <button @click="clearFilters" class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2.5 px-4 rounded-lg cursor-pointer font-medium flex items-center justify-center gap-1.5 transition-all duration-200 text-sm hover:bg-slate-500/20 hover:text-slate-700 whitespace-nowrap">
                <i class="fas fa-times"></i>
                <span class="hidden sm:inline">Clear</span>
              </button>
            </div>
          </div>

          <!-- Vehicles Content -->
          <div class="vehicles-content">
            <!-- Loading State -->
            <div v-if="loading" class="text-center py-16 bg-white/90 backdrop-blur-xl rounded-2xl shadow-lg"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <i class="fas fa-spinner fa-spin text-5xl mb-5" style="color: #0A400C;"></i>
              <span class="text-slate-600 text-base font-medium">Loading vehicles...</span>
            </div>

            <!-- Empty State -->
            <div v-else-if="filteredVehicles.length === 0" class="text-center py-16 bg-white/90 backdrop-blur-xl rounded-2xl shadow-lg"
                 style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);">
              <i class="fas fa-car text-7xl mb-5" style="color: rgba(10, 64, 12, 0.3);"></i>
              <h3 class="text-2xl mb-2.5" style="color: #0A400C;">No vehicles found</h3>
              <p v-if="hasActiveFilters" class="text-slate-600 mb-6">Try adjusting your search criteria</p>
              <p v-else class="text-slate-600 mb-6">No vehicles have been registered yet.</p>
              <button
                v-if="!hasActiveFilters"
                @click="openAddModal"
                class="bg-gradient-to-br text-white border-none py-3 px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg text-sm hover:-translate-y-0.5 hover:shadow-xl mx-auto"
                style="background: linear-gradient(135deg, #0A400C, #155c1a); box-shadow: 0 10px 25px rgba(10, 64, 12, 0.3);"
              >
                <i class="fas fa-plus"></i>
                Add First Vehicle
              </button>
            </div>

            <!-- Vehicles Grid -->
            <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4 sm:gap-6">
              <div
                v-for="vehicle in filteredVehicles"
                :key="vehicle.id"
                class="bg-white/95 backdrop-blur-xl rounded-2xl p-4 sm:p-6 shadow-lg border border-white/30 transition-all duration-300 relative overflow-hidden hover:-translate-y-1 hover:shadow-xl"
                style="box-shadow: 0 10px 25px rgba(10, 64, 12, 0.1);"
              >
                <!-- Status indicator bar -->
                <div class="absolute top-0 left-0 right-0 h-1 transition-all duration-300"
                     :class="{
                       'bg-green-500': vehicle.status === 'available',
                       'bg-amber-500': vehicle.status === 'in_use',
                       'bg-red-500': vehicle.status === 'maintenance',
                       'bg-gray-500': vehicle.status === 'out_of_service'
                     }"></div>

                <!-- Card Header -->
                <div class="flex justify-between items-start mb-5">
                  <div class="flex flex-col gap-1">
                    <span class="text-lg font-bold" style="color: #0A400C;">{{ vehicle.plate_number }}</span>
                    <span class="text-xs text-slate-600 font-medium">{{ vehicle.vehicle_id }}</span>
                  </div>
                  <div class="py-1.5 px-3 rounded-2xl text-xs font-semibold flex items-center gap-1.5 uppercase"
                       :class="{
                         'bg-green-500/10 text-green-600': vehicle.status === 'available',
                         'bg-amber-500/10 text-amber-700': vehicle.status === 'in_use',
                         'bg-red-500/10 text-red-600': vehicle.status === 'maintenance',
                         'bg-gray-500/10 text-gray-600': vehicle.status === 'out_of_service'
                       }">
                    <i :class="getStatusIcon(vehicle.status)"></i>
                    {{ formatStatus(vehicle.status) }}
                  </div>
                </div>

                <!-- Vehicle Details -->
                <div class="mb-5">
                  <h3 class="text-xl font-semibold text-gray-800 m-0 mb-4">{{ vehicle.year }} {{ vehicle.make }} {{ vehicle.model }}</h3>
                  <div class="flex flex-col gap-2">
                    <div class="flex items-center gap-2 text-sm text-slate-600">
                      <i class="fas fa-tag w-4 text-gray-400"></i>
                      <span>{{ vehicle.vehicle_type.toUpperCase() }}</span>
                    </div>
                    <div v-if="vehicle.assigned_driver_name" class="flex items-center gap-2 text-sm text-slate-600">
                      <i class="fas fa-user w-4 text-gray-400"></i>
                      <span>{{ vehicle.assigned_driver_name }}</span>
                    </div>
                    <div v-if="vehicle.assigned_department" class="flex items-center gap-2 text-sm text-slate-600">
                      <i class="fas fa-building w-4 text-gray-400"></i>
                      <span>{{ vehicle.assigned_department }}</span>
                    </div>
                  </div>
                </div>

                <!-- Action Buttons -->
                <div class="flex gap-2 justify-end">
                  <button @click="viewVehicle(vehicle)" class="w-9 h-9 border-none rounded-lg cursor-pointer flex items-center justify-center transition-all duration-200 text-sm bg-blue-500/10 text-blue-600 hover:bg-blue-500/20 hover:scale-105">
                    <i class="fas fa-eye"></i>
                  </button>
                  <button
                    @click="editVehicle(vehicle)"
                    class="w-9 h-9 border-none rounded-lg cursor-pointer flex items-center justify-center transition-all duration-200 text-sm bg-amber-500/10 text-amber-600 hover:bg-amber-500/20 hover:scale-105"
                  >
                    <i class="fas fa-edit"></i>
                  </button>
                  <button
                    @click="confirmDelete(vehicle)"
                    class="w-9 h-9 border-none rounded-lg cursor-pointer flex items-center justify-center transition-all duration-200 text-sm bg-red-500/10 text-red-600 hover:bg-red-500/20 hover:scale-105"
                  >
                    <i class="fas fa-trash"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Add/Edit Vehicle Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm">
      <div class="bg-white rounded-2xl p-0 w-11/12 max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl">
        <div class="py-6 px-8 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br text-white rounded-t-2xl"
             style="background: linear-gradient(135deg, #0A400C, #155c1a);">
          <h3 class="m-0 text-xl font-semibold">{{ editingVehicle ? 'Edit Vehicle' : 'Add New Vehicle' }}</h3>
          <button class="bg-white/10 border-none text-white w-8 h-8 rounded-lg cursor-pointer flex items-center justify-center transition-colors duration-200 hover:bg-white/20" @click="closeModal">
            <i class="fas fa-times"></i>
          </button>
        </div>

        <form @submit.prevent="submitForm" class="p-8">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Vehicle ID *</label>
              <input
                type="text"
                v-model="form.vehicle_id"
                placeholder="e.g., MP-001"
                required
                class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4 disabled:bg-gray-50 disabled:text-gray-600 disabled:cursor-not-allowed"
                style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                :style="{ 'border-color': form.vehicle_id ? '#0A400C' : '' }"
                :disabled="editingVehicle !== null"
              >
            </div>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Plate Number *</label>
              <input
                type="text"
                v-model="form.plate_number"
                placeholder="e.g., ABC-1234"
                required
                class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                :style="{ 'border-color': form.plate_number ? '#0A400C' : '' }"
              >
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Make *</label>
              <input
                type="text"
                v-model="form.make"
                placeholder="e.g., Toyota"
                required
                class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                :style="{ 'border-color': form.make ? '#0A400C' : '' }"
              >
            </div>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Model *</label>
              <input
                type="text"
                v-model="form.model"
                placeholder="e.g., Camry"
                required
                class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                :style="{ 'border-color': form.model ? '#0A400C' : '' }"
              >
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Year *</label>
              <input
                type="number"
                v-model="form.year"
                :min="1990"
                :max="new Date().getFullYear() + 1"
                required
                class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                :style="{ 'border-color': form.year ? '#0A400C' : '' }"
              >
            </div>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Vehicle Type *</label>
              <select v-model="form.vehicle_type" required class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                      style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                      :style="{ 'border-color': form.vehicle_type ? '#0A400C' : '' }">
                <option value="">Select Type</option>
                <option value="car">Car</option>
                <option value="van">Van</option>
                <option value="truck">Truck</option>
                <option value="suv">SUV</option>
                <option value="motorcycle">Motorcycle</option>
                <option value="bus">Bus</option>
              </select>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-5">
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Status</label>
              <select v-model="form.status" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                      style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
                      :style="{ 'border-color': form.status ? '#0A400C' : '' }">
                <option value="available">Available</option>
                <option value="in_use">In Use</option>
                <option value="maintenance">Under Maintenance</option>
                <option value="out_of_service">Out of Service</option>
              </select>
            </div>
            <div class="flex flex-col gap-2">
              <label class="font-semibold text-gray-700 text-sm">Assigned Driver</label>
              <select v-model="form.assigned_driver_id" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                      style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
                <option value="">Unassigned</option>
                <option v-for="driver in drivers" :key="driver.id" :value="driver.id">
                  {{ driver.full_name }} ({{ driver.employee_id }})
                </option>
              </select>
            </div>
          </div>

          <div class="flex flex-col gap-2 mb-5">
            <label class="font-semibold text-gray-700 text-sm">Department</label>
            <select v-model="form.assigned_department" class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white focus:outline-none focus:ring-4"
                    style="--tw-ring-color: rgba(10, 64, 12, 0.1);">
              <option value="">No Department</option>
              <option value="Admin">Admin</option>
              <option value="Finance">Finance</option>
              <option value="IT">IT</option>
              <option value="Transport">Transport</option>
              <option value="Maintenance">Maintenance</option>
            </select>
          </div>

          <div class="flex flex-col gap-2 mb-5">
            <label class="font-semibold text-gray-700 text-sm">Notes</label>
            <textarea
              v-model="form.notes"
              placeholder="Additional notes or remarks..."
              class="py-3 px-4 border border-gray-300 rounded-lg text-sm transition-colors duration-200 bg-white resize-y min-h-20 focus:outline-none focus:ring-4"
              style="--tw-ring-color: rgba(10, 64, 12, 0.1);"
              rows="3"
            ></textarea>
          </div>

          <div class="flex gap-4 justify-end mt-8 pt-5 border-t border-gray-200">
            <button type="button" @click="closeModal" class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2.5 px-4 rounded-lg cursor-pointer font-medium flex items-center gap-1.5 transition-all duration-200 text-sm hover:bg-slate-500/20 hover:text-slate-700">
              Cancel
            </button>
            <button type="submit" class="bg-gradient-to-br text-white border-none py-3 px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg text-sm hover:-translate-y-0.5 hover:shadow-xl disabled:opacity-60 disabled:cursor-not-allowed disabled:transform-none" 
                    style="background: linear-gradient(135deg, #0A400C, #155c1a); box-shadow: 0 10px 25px rgba(10, 64, 12, 0.3);"
                    :disabled="submitting">
              <i v-if="submitting" class="fas fa-spinner fa-spin"></i>
              {{ editingVehicle ? 'Update Vehicle' : 'Add Vehicle' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Vehicle Details Modal -->
    <div v-if="selectedVehicle" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm">
      <div class="bg-white rounded-2xl p-0 w-11/12 max-w-3xl max-h-[90vh] overflow-y-auto shadow-2xl">
        <div class="py-6 px-8 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br text-white rounded-t-2xl"
             style="background: linear-gradient(135deg, #0A400C, #155c1a);">
          <h3 class="m-0 text-xl font-semibold">Vehicle Details - {{ selectedVehicle.plate_number }}</h3>
          <button class="bg-white/10 border-none text-white w-8 h-8 rounded-lg cursor-pointer flex items-center justify-center transition-colors duration-200 hover:bg-white/20" @click="selectedVehicle = null">
            <i class="fas fa-times"></i>
          </button>
        </div>

        <div class="p-8">
          <div class="mb-8">
            <h4 class="text-lg font-semibold m-0 mb-5 pb-2.5 border-b-2 border-gray-200" style="color: #0A400C;">Basic Information</h4>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              <div class="flex flex-col gap-1 p-4 bg-gray-50 rounded-lg">
                <strong class="text-gray-700 text-xs uppercase font-semibold tracking-wider">Vehicle ID:</strong>
                <span class="text-gray-900 text-sm font-medium">{{ selectedVehicle.vehicle_id }}</span>
              </div>
              <div class="flex flex-col gap-1 p-4 bg-gray-50 rounded-lg">
                <strong class="text-gray-700 text-xs uppercase font-semibold tracking-wider">Plate Number:</strong>
                <span class="text-gray-900 text-sm font-medium">{{ selectedVehicle.plate_number }}</span>
              </div>
              <div class="flex flex-col gap-1 p-4 bg-gray-50 rounded-lg">
                <strong class="text-gray-700 text-xs uppercase font-semibold tracking-wider">Make:</strong>
                <span class="text-gray-900 text-sm font-medium">{{ selectedVehicle.make }}</span>
              </div>
              <div class="flex flex-col gap-1 p-4 bg-gray-50 rounded-lg">
                <strong class="text-gray-700 text-xs uppercase font-semibold tracking-wider">Model:</strong>
                <span class="text-gray-900 text-sm font-medium">{{ selectedVehicle.model }}</span>
              </div>
              <div class="flex flex-col gap-1 p-4 bg-gray-50 rounded-lg">
                <strong class="text-gray-700 text-xs uppercase font-semibold tracking-wider">Year:</strong>
                <span class="text-gray-900 text-sm font-medium">{{ selectedVehicle.year }}</span>
              </div>
              <div class="flex flex-col gap-1 p-4 bg-gray-50 rounded-lg">
                <strong class="text-gray-700 text-xs uppercase font-semibold tracking-wider">Type:</strong>
                <span class="text-gray-900 text-sm font-medium">{{ selectedVehicle.vehicle_type.toUpperCase() }}</span>
              </div>
            </div>
          </div>

          <div class="mb-8">
            <h4 class="text-lg font-semibold m-0 mb-5 pb-2.5 border-b-2 border-gray-200" style="color: #0A400C;">Status & Assignment</h4>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              <div class="flex flex-col gap-1 p-4 bg-gray-50 rounded-lg">
                <strong class="text-gray-700 text-xs uppercase font-semibold tracking-wider">Current Status:</strong>
                <span class="py-1.5 px-3 rounded-2xl text-xs font-semibold flex items-center gap-1.5 uppercase w-fit"
                     :class="{
                       'bg-green-500/10 text-green-600': selectedVehicle.status === 'available',
                       'bg-amber-500/10 text-amber-700': selectedVehicle.status === 'in_use',
                       'bg-red-500/10 text-red-600': selectedVehicle.status === 'maintenance',
                       'bg-gray-500/10 text-gray-600': selectedVehicle.status === 'out_of_service'
                     }">
                  <i :class="getStatusIcon(selectedVehicle.status)"></i>
                  {{ formatStatus(selectedVehicle.status) }}
                </span>
              </div>
              <div class="flex flex-col gap-1 p-4 bg-gray-50 rounded-lg">
                <strong class="text-gray-700 text-xs uppercase font-semibold tracking-wider">Assigned Driver:</strong>
                <span class="text-gray-900 text-sm font-medium">{{ selectedVehicle.assigned_driver_name || 'Unassigned' }}</span>
              </div>
              <div class="flex flex-col gap-1 p-4 bg-gray-50 rounded-lg">
                <strong class="text-gray-700 text-xs uppercase font-semibold tracking-wider">Department:</strong>
                <span class="text-gray-900 text-sm font-medium">{{ selectedVehicle.assigned_department || 'Not assigned' }}</span>
              </div>
            </div>
          </div>

          <div class="mb-8" v-if="selectedVehicle.notes">
            <h4 class="text-lg font-semibold m-0 mb-5 pb-2.5 border-b-2 border-gray-200" style="color: #0A400C;">Notes</h4>
            <p class="text-gray-700 leading-relaxed py-4 px-4 bg-gray-50 rounded-lg border-l-4" style="border-left-color: #0A400C;">{{ selectedVehicle.notes }}</p>
          </div>

          <div>
            <h4 class="text-lg font-semibold m-0 mb-5 pb-2.5 border-b-2 border-gray-200" style="color: #0A400C;">Registration Info</h4>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div class="flex flex-col gap-1 p-4 bg-gray-50 rounded-lg">
                <strong class="text-gray-700 text-xs uppercase font-semibold tracking-wider">Added:</strong>
                <span class="text-gray-900 text-sm font-medium">{{ formatDate(selectedVehicle.created_at) }}</span>
              </div>
              <div v-if="selectedVehicle.updated_at !== selectedVehicle.created_at" class="flex flex-col gap-1 p-4 bg-gray-50 rounded-lg">
                <strong class="text-gray-700 text-xs uppercase font-semibold tracking-wider">Last Updated:</strong>
                <span class="text-gray-900 text-sm font-medium">{{ formatDate(selectedVehicle.updated_at) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="vehicleToDelete" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm">
      <div class="bg-white rounded-2xl p-0 w-11/12 max-w-md shadow-2xl">
        <div class="py-6 px-8 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br from-red-500 to-red-600 text-white rounded-t-2xl">
          <h3 class="m-0 text-xl font-semibold">Confirm Deletion</h3>
          <button class="bg-white/10 border-none text-white w-8 h-8 rounded-lg cursor-pointer flex items-center justify-center transition-colors duration-200 hover:bg-white/20" @click="vehicleToDelete = null">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8 text-center">
          <p class="text-lg text-gray-700 mb-6">Are you sure you want to delete vehicle <strong class="font-semibold">{{ vehicleToDelete.plate_number }}</strong>? This action cannot be undone.</p>
          <div class="flex gap-4 justify-center">
            <button @click="vehicleToDelete = null" class="bg-slate-500/10 text-slate-600 border border-slate-500/20 py-2.5 px-4 rounded-lg cursor-pointer font-medium flex items-center gap-1.5 transition-all duration-200 text-sm hover:bg-slate-500/20 hover:text-slate-700">
              Cancel
            </button>
            <button @click="deleteVehicle" class="bg-gradient-to-br from-red-500 to-red-600 text-white border-none py-3 px-5 rounded-xl cursor-pointer font-semibold flex items-center gap-2 transition-all duration-300 shadow-lg shadow-red-500/30 text-sm hover:from-red-600 hover:to-red-700 hover:-translate-y-0.5 hover:shadow-xl hover:shadow-red-500/40">
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
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../lib/supabase'
import Navbar from './Navbar.vue'

export default {
  name: 'VehicleManagement',
  components: {
    Navbar
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    
    // Sidebar state
    const sidebarCollapsed = ref(false)
    const sidebarOpen = ref(true)

    const userProfile = ref(null)

    // Vehicle data and filters
    const vehicles = ref([])
    const loading = ref(true)
    const searchQuery = ref('')
    const statusFilter = ref('')
    const typeFilter = ref('')

    // Modal and form state
    const showModal = ref(false)
    const editingVehicle = ref(null)
    const submitting = ref(false)
    const vehicleToDelete = ref(null)
    const selectedVehicle = ref(null)

    const form = reactive({
      vehicle_id: '',
      plate_number: '',
      make: '',
      model: '',
      year: null,
      vehicle_type: '',
      status: 'available',
      assigned_driver_id: null,
      assigned_department: '',
      notes: ''
    })

    const drivers = ref([])

    // Computed properties
    const filteredVehicles = computed(() => {
      let filtered = vehicles.value

      if (searchQuery.value) {
        const lowerCaseQuery = searchQuery.value.toLowerCase()
        filtered = filtered.filter(v =>
          v.plate_number.toLowerCase().includes(lowerCaseQuery) ||
          v.make.toLowerCase().includes(lowerCaseQuery) ||
          v.model.toLowerCase().includes(lowerCaseQuery) ||
          v.vehicle_id.toLowerCase().includes(lowerCaseQuery)
        )
      }

      if (statusFilter.value) {
        filtered = filtered.filter(v => v.status === statusFilter.value)
      }

      if (typeFilter.value) {
        filtered = filtered.filter(v => v.vehicle_type === typeFilter.value)
      }

      return filtered
    })

    const hasActiveFilters = computed(() => {
      return searchQuery.value || statusFilter.value || typeFilter.value
    })

    // Sidebar methods
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

    // Utility methods
    const formatDate = (dateString) => {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    }

    const loadUserProfile = async () => {
      try {
        const { data: { user } } = await supabase.auth.getUser()
        if (user) {
          const { data: profile, error } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .single()

          if (error) {
            console.error('Error loading profile:', error)
            // Set default admin profile
            userProfile.value = {
              full_name: 'Admin User',
              role: 'admin'
            }
          } else {
            userProfile.value = profile
          }
        } else {
          // Default admin profile if no user
          userProfile.value = {
            full_name: 'Admin User',
            role: 'admin'
          }
        }
      } catch (error) {
        console.error('Error loading user profile:', error)
        userProfile.value = {
          full_name: 'Admin User',
          role: 'admin'
        }
      }
    }

    const loadVehicles = async () => {
      loading.value = true
      try {
        const { data, error } = await supabase
          .from('vehicles')
          .select(`
            *,
            profiles (full_name, employee_id)
          `)
          .order('created_at', { ascending: false })
        
        if (error) throw error

        vehicles.value = data.map(v => ({
          ...v,
          assigned_driver_name: v.profiles?.full_name || null,
          assigned_driver_employee_id: v.profiles?.employee_id || null,
        }))

      } catch (error) {
        console.error('Error loading vehicles:', error)
        // Sample data for demo purposes
        vehicles.value = [
          {
            id: 1,
            vehicle_id: 'MP-001',
            plate_number: 'ABC-1234',
            make: 'Toyota',
            model: 'Camry',
            year: 2022,
            vehicle_type: 'car',
            status: 'available',
            assigned_driver_name: 'John Doe',
            assigned_department: 'Transport',
            notes: 'Regularly serviced vehicle in good condition.',
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          },
          {
            id: 2,
            vehicle_id: 'MP-002',
            plate_number: 'XYZ-7890',
            make: 'Ford',
            model: 'Transit',
            year: 2021,
            vehicle_type: 'van',
            status: 'in_use',
            assigned_driver_name: 'Jane Smith',
            assigned_department: 'Transport',
            notes: 'Currently assigned for delivery operations.',
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          },
          {
            id: 3,
            vehicle_id: 'MP-003',
            plate_number: 'DEF-5678',
            make: 'Honda',
            model: 'CR-V',
            year: 2023,
            vehicle_type: 'suv',
            status: 'maintenance',
            assigned_driver_name: null,
            assigned_department: 'Maintenance',
            notes: 'Scheduled for engine maintenance and oil change.',
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          }
        ]
      } finally {
        loading.value = false
      }
    }

    const loadDrivers = async () => {
      try {
        const { data, error } = await supabase
          .from('profiles')
          .select('id, full_name, employee_id')
          .eq('role', 'driver')
          .order('full_name')
        
        if (error) throw error
        drivers.value = data
      } catch (error) {
        console.error('Error loading drivers:', error)
        // Sample drivers for demo
        drivers.value = [
          { id: 'driver1', full_name: 'John Doe', employee_id: 'EMP001' },
          { id: 'driver2', full_name: 'Jane Smith', employee_id: 'EMP002' },
          { id: 'driver3', full_name: 'Mike Johnson', employee_id: 'EMP003' }
        ]
      }
    }

    // CRUD operations
    const openAddModal = () => {
      editingVehicle.value = null
      resetForm()
      showModal.value = true
    }

    const closeModal = () => {
      showModal.value = false
      editingVehicle.value = null
      resetForm()
    }

    const editVehicle = (vehicle) => {
      editingVehicle.value = vehicle
      Object.assign(form, { 
        ...vehicle,
        assigned_driver_id: vehicle.assigned_driver_id || null
      })
      showModal.value = true
    }

    const viewVehicle = (vehicle) => {
      selectedVehicle.value = vehicle
    }

    const resetForm = () => {
      Object.assign(form, {
        vehicle_id: '',
        plate_number: '',
        make: '',
        model: '',
        year: null,
        vehicle_type: '',
        status: 'available',
        assigned_driver_id: null,
        assigned_department: '',
        notes: ''
      })
    }

    const submitForm = async () => {
      submitting.value = true
      try {
        const vehicleData = {
          vehicle_id: form.vehicle_id,
          plate_number: form.plate_number,
          make: form.make,
          model: form.model,
          year: parseInt(form.year),
          vehicle_type: form.vehicle_type,
          status: form.status,
          assigned_driver_id: form.assigned_driver_id || null,
          assigned_department: form.assigned_department || null,
          notes: form.notes || null
        }

        if (editingVehicle.value) {
          // Update existing vehicle
          const { error } = await supabase
            .from('vehicles')
            .update(vehicleData)
            .eq('id', editingVehicle.value.id)
          
          if (error) throw error
          
          // Update local list
          const index = vehicles.value.findIndex(v => v.id === editingVehicle.value.id)
          if (index !== -1) {
            const driver = drivers.value.find(d => d.id === form.assigned_driver_id)
            vehicles.value[index] = {
              ...editingVehicle.value,
              ...vehicleData,
              assigned_driver_name: driver ? driver.full_name : null,
              updated_at: new Date().toISOString()
            }
          }
        } else {
          // Add new vehicle
          const { data, error } = await supabase
            .from('vehicles')
            .insert(vehicleData)
            .select()
            .single()
          
          if (error) throw error
          
          // Add to local list
          const driver = drivers.value.find(d => d.id === form.assigned_driver_id)
          const newVehicle = {
            ...data,
            assigned_driver_name: driver ? driver.full_name : null
          }
          vehicles.value.unshift(newVehicle)
        }

        closeModal()
        console.log(editingVehicle.value ? 'Vehicle updated successfully!' : 'Vehicle added successfully!')
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
        console.log('Vehicle deleted successfully!')
      } catch (error) {
        console.error('Error deleting vehicle:', error)
        alert('Error deleting vehicle: ' + error.message)
      }
    }

    const clearFilters = () => {
      searchQuery.value = ''
      statusFilter.value = ''
      typeFilter.value = ''
    }

    const getStatusIcon = (status) => {
      switch (status) {
        case 'available': return 'fas fa-check-circle'
        case 'in_use': return 'fas fa-road'
        case 'maintenance': return 'fas fa-wrench'
        case 'out_of_service': return 'fas fa-times-circle'
        default: return 'fas fa-question-circle'
      }
    }

    const formatStatus = (status) => {
      switch (status) {
        case 'available': return 'Available'
        case 'in_use': return 'In Use'
        case 'maintenance': return 'Maintenance'
        case 'out_of_service': return 'Out of Service'
        default: return 'Unknown'
      }
    }

    const handleResize = () => {
      const width = window.innerWidth
      if (width <= 1024) {
        // Mobile/tablet: sidebar should overlay, not push content
        sidebarOpen.value = false
        sidebarCollapsed.value = false
      } else {
        // Desktop: sidebar should be visible and can be collapsed
        sidebarOpen.value = true
        // Keep current collapsed state
      }
    }

    // Lifecycle
    onMounted(async () => {
      await loadUserProfile()
      await loadVehicles()
      await loadDrivers()

      window.addEventListener('resize', handleResize)
      handleResize()
    })

    return {
      // Sidebar
      sidebarCollapsed,
      sidebarOpen,
      toggleSidebar,
      closeSidebar,
      openSidebar,
      handleMenuClick,
      
      // Data
      userProfile,
      vehicles,
      loading,
      searchQuery,
      statusFilter,
      typeFilter,
      filteredVehicles,
      hasActiveFilters,
      drivers,
      
      // Modals
      showModal,
      editingVehicle,
      submitting,
      vehicleToDelete,
      selectedVehicle,
      form,
      
      // Methods
      formatDate,
      openAddModal,
      closeModal,
      editVehicle,
      viewVehicle,
      submitForm,
      confirmDelete,
      deleteVehicle,
      clearFilters,
      getStatusIcon,
      formatStatus
    }
  }
}
</script>

<style scoped>
/* Custom scrollbar */
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

/* Smooth transitions */
.transition-all {
  transition-property: all;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
  transition-duration: 300ms;
}

/* Font Awesome icons */
.fas, .far, .fal, .fab {
  font-family: "Font Awesome 6 Free";
}

</style>
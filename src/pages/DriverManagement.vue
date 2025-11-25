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
            placeholder="Search drivers by name, ID, or department..."
            class="w-full pl-10 pr-4 py-2.5 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent bg-white dark:bg-[#1c2128] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
          />
        </div>
        <select v-model="statusFilter" class="px-4 py-2 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] bg-white dark:bg-[#1c2128] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">
          <option value="">All Status</option>
          <option value="true">Active</option>
          <option value="false">Inactive</option>
        </select>
        <button 
          @click="openAddModal"
          class="btn btn-primary whitespace-nowrap"
        >
          <i class="fas fa-plus"></i>
          Register Driver
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 transition-colors duration-200">
        <div class="flex items-center justify-between mb-3">
          <div class="stat-card-icon bg-emerald-100 dark:bg-[#1a2f23] text-emerald-600 dark:text-[#3fb950]">
            <i class="fas fa-id-card"></i>
          </div>
        </div>
        <div class="text-2xl sm:text-3xl font-bold text-slate-900 dark:text-[#e6edf3] transition-colors duration-200">{{ drivers.length }}</div>
        <p class="text-xs uppercase tracking-wide text-slate-500 dark:text-[#8b949e] mt-1 transition-colors duration-200">Total Drivers</p>
      </div>
      <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 transition-colors duration-200">
        <div class="flex items-center justify-between mb-3">
          <div class="stat-card-icon bg-green-100 dark:bg-[#2d4a2f] text-green-600 dark:text-[#6fc276]">
            <i class="fas fa-bolt"></i>
          </div>
        </div>
        <div class="text-2xl sm:text-3xl font-bold text-green-600 dark:text-[#6fc276] transition-colors duration-200">{{ activeDriversCount }}</div>
        <p class="text-xs uppercase tracking-wide text-slate-500 dark:text-[#8b949e] mt-1 transition-colors duration-200">Active</p>
      </div>
      <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 transition-colors duration-200">
        <div class="flex items-center justify-between mb-3">
          <div class="stat-card-icon bg-blue-100 dark:bg-[#1a2a1f] text-blue-600 dark:text-[#8fbc8f]">
            <i class="fas fa-car-side"></i>
          </div>
        </div>
        <div class="text-2xl sm:text-3xl font-bold text-blue-600 dark:text-[#8fbc8f] transition-colors duration-200">{{ assignedDriversCount }}</div>
        <p class="text-xs uppercase tracking-wide text-slate-500 dark:text-[#8b949e] mt-1 transition-colors duration-200">With Vehicle</p>
      </div>
      <div class="glass-card dark:bg-[#161b22] dark:border-[#30363d] p-4 sm:p-5 transition-colors duration-200">
        <div class="flex items-center justify-between mb-3">
          <div class="stat-card-icon bg-amber-100 dark:bg-[#1a2f23] text-amber-600 dark:text-[#3fb950]">
            <i class="fas fa-user-check"></i>
          </div>
        </div>
        <div class="text-2xl sm:text-3xl font-bold text-amber-600 dark:text-amber-400 transition-colors duration-200">{{ availableDriversCount }}</div>
        <p class="text-xs uppercase tracking-wide text-slate-500 dark:text-slate-400 mt-1 transition-colors duration-200">Available</p>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="glass-card dark:bg-[#161b22] dark:border-[#30363d] text-center py-16 transition-colors duration-200">
      <i class="fas fa-spinner fa-spin text-5xl mb-5 text-emerald-600 dark:text-[#3fb950]"></i>
      <p class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Loading drivers...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredDrivers.length === 0" class="glass-card dark:bg-[#161b22] dark:border-[#30363d] text-center py-16 transition-colors duration-200">
      <i class="fas fa-user-tie text-7xl mb-5 text-emerald-100 dark:text-[#1a2f23]"></i>
      <h3 class="text-2xl font-bold text-gray-900 dark:text-[#e6edf3] mb-2 transition-colors duration-200">No drivers found</h3>
      <p class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">{{ searchQuery || statusFilter ? 'Try adjusting your filters' : 'Start by registering your first driver' }}</p>
    </div>

    <!-- Drivers Grid -->
    <div v-else>
      <div class="flex justify-between items-center mb-4">
        <div class="text-sm text-gray-600 dark:text-[#8b949e] transition-colors duration-200">
          Showing <span class="font-semibold text-gray-900 dark:text-[#e6edf3]">{{ filteredDrivers.length }}</span> of 
          <span class="font-semibold text-gray-900 dark:text-[#e6edf3]">{{ drivers.length }}</span> drivers
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
            :class="viewMode === 'list' ? 'bg-emerald-600 dark:bg-emerald-500 text-white' : 'text-slate-500 dark:text-slate-400 bg-transparent'"
          >
            <i class="fas fa-table"></i>
          </button>
        </div>
      </div>

      <div v-if="viewMode === 'grid'" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        <div
          v-for="driver in filteredDrivers"
          :key="driver.id"
          class="glass-card p-6 hover:-translate-y-1 transition-all duration-300"
        >
        <div class="flex items-start justify-between mb-4">
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-green-500 to-green-700 text-white flex items-center justify-center shadow-inner">
              <i class="fas fa-user-tie"></i>
            </div>
            <div>
              <div class="text-lg font-bold text-slate-900 dark:text-[#e6edf3] transition-colors duration-200">{{ driver.full_name }}</div>
              <div class="text-xs text-slate-500 dark:text-[#8b949e] transition-colors duration-200">{{ driver.employee_id }}</div>
            </div>
          </div>
          <span 
            class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold border"
            :class="driver.is_active ? 'bg-emerald-50 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-400 border-emerald-200 dark:border-emerald-800' : 'bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400 border-gray-200 dark:border-gray-700'"
          >
            <i :class="driver.is_active ? 'fas fa-check-circle' : 'fas fa-pause-circle'"></i>
            {{ driver.is_active ? 'Active' : 'Inactive' }}
          </span>
        </div>

        <div class="flex flex-wrap gap-3 mb-4">
          <span class="px-2.5 py-1 rounded-lg text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 transition-colors duration-200">{{ driver.department || 'No Dept' }}</span>
          <span class="px-2.5 py-1 rounded-lg text-xs font-semibold bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 transition-colors duration-200">{{ driver.position || 'No Position' }}</span>
        </div>

        <div class="grid grid-cols-2 gap-3 mb-4">
          <div class="p-3 rounded-xl bg-slate-50 dark:bg-[#1c2128] transition-colors duration-200">
            <div class="text-xs text-slate-500 dark:text-[#8b949e] mb-1 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-phone text-slate-400 dark:text-[#6e7681]"></i>
              Phone
            </div>
            <div class="text-sm font-semibold text-slate-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ driver.phone || 'N/A' }}</div>
          </div>
          <div class="p-3 rounded-xl bg-slate-50 dark:bg-[#1c2128] transition-colors duration-200">
            <div class="text-xs text-slate-500 dark:text-[#8b949e] mb-1 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-id-card text-slate-400 dark:text-[#6e7681]"></i>
              License
            </div>
            <div class="text-sm font-semibold text-slate-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ driver.license_number || 'N/A' }}</div>
          </div>
          <div v-if="getAssignedVehicle(driver.id)" class="p-3 rounded-xl bg-slate-50 dark:bg-[#1c2128] col-span-2 transition-colors duration-200">
            <div class="text-xs text-slate-500 dark:text-[#8b949e] mb-1 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-car text-slate-400 dark:text-[#6e7681]"></i>
              Assigned Vehicle
            </div>
            <div class="text-sm font-semibold text-slate-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ getAssignedVehicle(driver.id) }}</div>
          </div>
        </div>

        <div class="flex items-center gap-1.5 sm:gap-2 flex-nowrap overflow-x-auto">
          <button @click="viewDriver(driver)" class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="View">
            <i class="fas fa-eye text-xs sm:text-sm"></i>
            <span class="hidden sm:inline text-xs font-medium">View</span>
          </button>
          <button @click="editDriver(driver)" class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-amber-50 text-amber-600 hover:bg-amber-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Edit">
            <i class="fas fa-edit text-xs sm:text-sm"></i>
            <span class="hidden sm:inline text-xs font-medium">Edit</span>
          </button>
          <button @click="confirmDelete(driver)" class="flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-semibold text-red-600 bg-red-50 hover:bg-red-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Delete">
            <i class="fas fa-trash text-xs sm:text-sm"></i>
            <span class="hidden sm:inline text-xs font-medium">Delete</span>
          </button>
        </div>
      </div>
      </div>

      <div v-else class="glass-card overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gradient-to-br from-green-800 to-green-600 border-b border-gray-200">
            <tr>
              <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Driver</th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Department</th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Phone</th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">License</th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-white uppercase">Actions</th>
            </tr>
          </thead>
          <tbody class="text-sm text-slate-700 divide-y">
            <tr v-for="driver in filteredDrivers" :key="driver.id" class="hover:bg-slate-50/60 transition-colors">
              <td class="py-3 px-4">
                <div class="font-semibold text-slate-900">{{ driver.full_name }}</div>
                <div class="text-xs text-slate-500">{{ driver.employee_id }}</div>
              </td>
              <td class="py-3 px-4">{{ driver.department || 'No department' }}</td>
              <td class="py-3 px-4">{{ driver.phone || 'No phone' }}</td>
              <td class="py-3 px-4">{{ driver.license_number || 'N/A' }}</td>
              <td class="py-3 px-4">
                <div class="flex items-center gap-1.5 sm:gap-2 flex-nowrap overflow-x-auto justify-end">
                  <button @click="viewDriver(driver)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="View">
                    <i class="fas fa-eye text-xs sm:text-sm"></i>
                    <span class="hidden lg:inline text-xs font-medium ml-0.5">View</span>
                  </button>
                  <button @click="editDriver(driver)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-amber-50 text-amber-600 hover:bg-amber-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Edit">
                    <i class="fas fa-edit text-xs sm:text-sm"></i>
                    <span class="hidden lg:inline text-xs font-medium ml-0.5">Edit</span>
                  </button>
                  <button @click="confirmDelete(driver)" class="flex items-center gap-1 px-2 sm:px-2.5 py-1.5 sm:py-2 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 transition-all hover:scale-105 active:scale-95 flex-shrink-0" title="Delete">
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

    <!-- Add/Edit Driver Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-[60] backdrop-blur-sm p-4 transition-colors duration-200" @click.self="closeModal">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden shadow-2xl animate-modalSlideIn transition-colors duration-200">
        <!-- Modal Header -->
        <div class="relative py-6 px-8 bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] text-white transition-colors duration-200">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-2xl font-bold">{{ editingDriver ? 'Edit Driver' : 'Register New Driver' }}</h3>
              <p class="text-green-100 dark:text-emerald-200 text-sm mt-1">{{ editingDriver ? 'Update driver information' : 'Add a new driver to your fleet' }}</p>
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
        <form @submit.prevent="submitForm" class="p-8 overflow-y-auto max-h-[calc(90vh-120px)] bg-white dark:bg-[#0d1117] transition-colors duration-200">
          <div class="space-y-6">
            
            <!-- Driver Identification Section -->
            <div class="bg-gray-50 dark:bg-[#1c2128] rounded-xl p-5 border border-gray-200 dark:border-[#30363d] transition-colors duration-200">
              <h4 class="text-sm font-semibold text-gray-700 dark:text-[#e6edf3] uppercase tracking-wide mb-4 flex items-center gap-2 transition-colors duration-200">
                <i class="fas fa-id-card text-emerald-600 dark:text-[#3fb950]"></i>
                Driver Identification
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm flex items-center gap-2 transition-colors duration-200">
                    Employee ID <span class="text-red-500">*</span>
                    <span v-if="editingDriver" class="text-xs text-gray-500 dark:text-[#8b949e] font-normal">(Cannot be changed)</span>
                  </label>
                  <input
                    type="text"
                    v-model="form.employee_id"
                    placeholder="e.g., EMP-001"
                    required
                    :disabled="editingDriver !== null"
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all disabled:bg-gray-100 dark:disabled:bg-[#1c2128] disabled:cursor-not-allowed bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                  />
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Full Name <span class="text-red-500">*</span></label>
                  <input
                    type="text"
                    v-model="form.full_name"
                    placeholder="e.g., Juan Dela Cruz"
                    required
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                  />
                </div>
              </div>
            </div>

            <!-- License Information Section -->
            <div class="bg-gray-50 dark:bg-[#1c2128] rounded-xl p-5 border border-gray-200 dark:border-[#30363d] transition-colors duration-200">
              <h4 class="text-sm font-semibold text-gray-700 dark:text-[#e6edf3] uppercase tracking-wide mb-4 flex items-center gap-2 transition-colors duration-200">
                <i class="fas fa-id-badge text-emerald-600 dark:text-[#3fb950]"></i>
                License Information
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">License Number <span class="text-red-500">*</span></label>
                  <input
                    type="text"
                    v-model="form.license_number"
                    placeholder="e.g., N01-12-123456"
                    required
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all uppercase bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                  />
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">License Expiry <span class="text-red-500">*</span></label>
                  <input
                    type="date"
                    v-model="form.license_expiry"
                    required
                    :min="new Date().toISOString().split('T')[0]"
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] transition-colors duration-200"
                  />
                </div>
              </div>
            </div>

            <!-- Contact Information Section -->
            <div class="bg-gray-50 dark:bg-[#1c2128] rounded-xl p-5 border border-gray-200 dark:border-[#30363d] transition-colors duration-200">
              <h4 class="text-sm font-semibold text-gray-700 dark:text-[#e6edf3] uppercase tracking-wide mb-4 flex items-center gap-2 transition-colors duration-200">
                <i class="fas fa-phone text-emerald-600 dark:text-[#3fb950]"></i>
                Contact Information
              </h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Phone Number</label>
                  <input
                    type="tel"
                    v-model="form.phone"
                    placeholder="e.g., 09123456789"
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                  />
                </div>
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Email <span class="text-red-500" v-if="!editingDriver">*</span></label>
                  <input
                    type="email"
                    v-model="form.email"
                    placeholder="e.g., driver@example.com"
                    :required="!editingDriver"
                    class="py-3 px-4 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                  />
                </div>
              </div>
              <!-- Password field (only for new drivers) -->
              <div v-if="!editingDriver" class="mt-4">
                <div class="flex flex-col gap-2">
                  <label class="font-semibold text-gray-700 dark:text-[#e6edf3] text-sm transition-colors duration-200">Password <span class="text-red-500">*</span></label>
                  <div class="relative">
                    <input
                      :type="showPassword ? 'text' : 'password'"
                      v-model="form.password"
                      placeholder="Enter password for driver account"
                      required
                      class="w-full py-3 px-4 pr-10 border border-gray-300 dark:border-[#30363d] rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] focus:border-transparent transition-all bg-white dark:bg-[#0d1117] text-gray-900 dark:text-[#e6edf3] placeholder-gray-400 dark:placeholder-[#6e7681] transition-colors duration-200"
                    />
                    <button
                      type="button"
                      @click="showPassword = !showPassword"
                      class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 dark:text-[#8b949e] hover:text-emerald-600 dark:hover:text-[#3fb950] transition-colors"
                    >
                      <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                    </button>
                  </div>
                  <p class="text-xs text-gray-500 dark:text-[#8b949e] mt-1 transition-colors duration-200">
                    Password must be at least 8 characters with 1 uppercase letter and 1 special character
                  </p>
                </div>
              </div>
            </div>

            <!-- Status Section -->
            <div class="bg-gray-50 dark:bg-[#1c2128] rounded-xl p-5 border border-gray-200 dark:border-[#30363d] transition-colors duration-200">
              <h4 class="text-sm font-semibold text-gray-700 dark:text-[#e6edf3] uppercase tracking-wide mb-4 flex items-center gap-2 transition-colors duration-200">
                <i class="fas fa-toggle-on text-emerald-600 dark:text-[#3fb950]"></i>
                Status
              </h4>
              <div class="flex items-center gap-3">
                <input
                  type="checkbox"
                  id="is_active"
                  v-model="form.is_active"
                  class="w-5 h-5 text-emerald-600 dark:text-[#3fb950] border-gray-300 dark:border-[#30363d] rounded focus:ring-2 focus:ring-emerald-500 dark:focus:ring-[#3fb950] transition-colors duration-200"
                />
                <label for="is_active" class="text-sm text-gray-700 dark:text-[#e6edf3] cursor-pointer transition-colors duration-200">
                  Driver is active and available for assignments
                </label>
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
              <i v-else class="fas" :class="editingDriver ? 'fa-check' : 'fa-plus'"></i>
              {{ editingDriver ? 'Update Driver' : 'Add Driver' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- View Driver Modal -->
    <div v-if="selectedDriver" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-[60] backdrop-blur-sm p-4 transition-colors duration-200" @click.self="selectedDriver = null">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden shadow-2xl transition-colors duration-200">
        <div class="py-6 px-8 bg-gradient-to-r from-emerald-800 to-emerald-600 dark:from-[#1a2f23] dark:to-[#0f1e13] text-white flex items-center justify-between transition-colors duration-200">
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 rounded-full bg-white/10 flex items-center justify-center text-xl font-bold">
              {{ selectedDriver.full_name.charAt(0) }}
            </div>
            <div>
              <h3 class="text-xl font-bold">{{ selectedDriver.full_name }}</h3>
              <p class="text-green-100 text-sm">{{ selectedDriver.employee_id }}</p>
            </div>
          </div>
          <button @click="selectedDriver = null" class="w-10 h-10 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors">
            <i class="fas fa-times text-lg"></i>
          </button>
        </div>

        <div class="p-8 overflow-y-auto max-h-[calc(90vh-120px)]">
          <div class="mb-6">
            <span 
              class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold"
              :class="selectedDriver.is_active ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' : 'bg-gray-100 text-gray-600'"
            >
              <i :class="selectedDriver.is_active ? 'fas fa-check-circle' : 'fas fa-pause-circle'"></i>
              {{ selectedDriver.is_active ? 'Active' : 'Inactive' }}
            </span>
          </div>

          <div class="space-y-6">
            <div>
              <h4 class="text-sm font-semibold text-gray-500 dark:text-[#8b949e] uppercase mb-3 transition-colors duration-200">Contact Information</h4>
              <div class="space-y-2">
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Email</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedDriver.email }}</span>
                </div>
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Phone</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedDriver.phone || 'Not provided' }}</span>
                </div>
              </div>
            </div>

            <div>
              <h4 class="text-sm font-semibold text-gray-500 dark:text-[#8b949e] uppercase mb-3 transition-colors duration-200">License Information</h4>
              <div class="space-y-2">
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">License Number</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedDriver.license_number || 'Not provided' }}</span>
                </div>
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Expiry Date</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200" :class="isLicenseExpiring(selectedDriver.license_expiry) ? 'text-red-600 dark:text-red-400' : ''">
                    {{ formatDate(selectedDriver.license_expiry) || 'Not provided' }}
                  </span>
                </div>
              </div>
            </div>

            <div>
              <h4 class="text-sm font-semibold text-gray-500 dark:text-[#8b949e] uppercase mb-3 transition-colors duration-200">Work Information</h4>
              <div class="space-y-2">
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Position</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedDriver.position || 'Not specified' }}</span>
                </div>
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Department</span>
                  <span class="font-medium text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">{{ selectedDriver.department || 'Not assigned' }}</span>
                </div>
                <div class="flex justify-between py-2 border-b border-gray-100 dark:border-[#30363d] transition-colors duration-200">
                  <span class="text-gray-600 dark:text-[#8b949e] transition-colors duration-200">Assigned Vehicle</span>
                  <span class="font-medium text-blue-600 dark:text-[#8fbc8f] transition-colors duration-200">{{ getAssignedVehicle(selectedDriver.id) || 'Not assigned' }}</span>
                </div>
              </div>
            </div>

            <div class="text-xs text-gray-500 dark:text-[#8b949e] space-y-1 pt-4 border-t border-gray-200 dark:border-[#30363d] transition-colors duration-200">
              <p><i class="fas fa-calendar-plus text-green-600 dark:text-[#3fb950] mr-2"></i>Registered: {{ formatDate(selectedDriver.created_at) }}</p>
              <p v-if="selectedDriver.updated_at !== selectedDriver.created_at">
                <i class="fas fa-edit text-blue-600 dark:text-[#8fbc8f] mr-2"></i>Last Updated: {{ formatDate(selectedDriver.updated_at) }}
              </p>
            </div>
          </div>

          <button 
            @click="editDriver(selectedDriver); selectedDriver = null" 
            class="w-full mt-6 flex items-center justify-center gap-2 px-4 py-3 bg-gradient-to-r from-amber-500 to-amber-600 dark:from-amber-600 dark:to-amber-700 text-white rounded-lg hover:from-amber-600 hover:to-amber-700 dark:hover:from-amber-700 dark:hover:to-amber-800 transition-all font-semibold shadow-md"
          >
            <i class="fas fa-edit"></i>
            Edit Driver
          </button>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="driverToDelete" class="fixed inset-0 bg-black/60 dark:bg-black/80 flex items-center justify-center z-[60] backdrop-blur-sm p-4 transition-colors duration-200">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl w-full max-w-md shadow-2xl transition-colors duration-200">
        <div class="py-6 px-8 border-b border-gray-200 dark:border-[#30363d] flex justify-between items-center bg-gradient-to-br from-red-500 to-red-600 text-white rounded-t-2xl transition-colors duration-200">
          <h3 class="text-xl font-semibold">Confirm Deletion</h3>
          <button @click="driverToDelete = null" class="bg-white/10 hover:bg-white/20 w-8 h-8 rounded-lg flex items-center justify-center transition-colors">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8 text-center">
          <p class="text-lg text-gray-700 dark:text-[#e6edf3] mb-6 transition-colors duration-200">
            Are you sure you want to delete driver <strong>{{ driverToDelete.full_name }}</strong>? 
            This action cannot be undone.
          </p>
          <div class="flex gap-4 justify-center">
            <button @click="driverToDelete = null" class="px-4 py-2 border border-gray-300 dark:border-[#30363d] rounded-lg hover:bg-gray-50 dark:hover:bg-[#1c2128] transition-colors text-gray-700 dark:text-[#e6edf3]">
              Cancel
            </button>
            <button @click="deleteDriver" class="flex items-center gap-2 bg-gradient-to-br from-red-500 to-red-600 text-white px-5 py-2.5 rounded-lg font-semibold hover:scale-105 transition-all shadow-lg">
              <i class="fas fa-trash"></i>
              Delete Driver
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { useToast } from '../composables/useToast'

export default {
  name: 'DriverManagement',
  emits: ['driver-updated'],
  setup(props, { emit }) {
    const { success, error, warning } = useToast()
    const drivers = ref([])
    const viewMode = ref('grid')
    const vehicles = ref([])
    const loading = ref(true)
    const submitting = ref(false)
    
    const searchQuery = ref('')
    const statusFilter = ref('')
    
    const showModal = ref(false)
    const editingDriver = ref(null)
    const selectedDriver = ref(null)
    const driverToDelete = ref(null)
    const showPassword = ref(false)
    
    const form = reactive({
      employee_id: '',
      full_name: '',
      email: '',
      password: '',
      phone: '',
      license_number: '',
      license_expiry: '',
      position: 'Driver',
      department: '',
      is_active: true
    })

    // Computed
    const filteredDrivers = computed(() => {
      let filtered = drivers.value

      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        filtered = filtered.filter(d =>
          d.full_name.toLowerCase().includes(query) ||
          d.employee_id.toLowerCase().includes(query) ||
          d.department?.toLowerCase().includes(query) ||
          d.email?.toLowerCase().includes(query)
        )
      }

      if (statusFilter.value !== '') {
        const isActive = statusFilter.value === 'true'
        filtered = filtered.filter(d => d.is_active === isActive)
      }

      return filtered
    })

    const activeDriversCount = computed(() => 
      drivers.value.filter(d => d.is_active).length
    )

    const assignedDriversCount = computed(() => {
      const assignedDriverIds = vehicles.value
        .map(v => v.assigned_driver_id)
        .filter(Boolean)
      return drivers.value.filter(d => assignedDriverIds.includes(d.id)).length
    })

    const availableDriversCount = computed(() => 
      activeDriversCount.value - assignedDriversCount.value
    )

    // Methods
    const loadDrivers = async () => {
      loading.value = true
      try {
        const { data, error } = await supabase
          .from('drivers')
          .select('*')
          .order('created_at', { ascending: false })

        if (error) throw error
        drivers.value = data || []
      } catch (err) {
        console.error('Error loading drivers:', err)
        error('Failed to load drivers: ' + err.message)
      } finally {
        loading.value = false
      }
    }

    const loadVehicles = async () => {
      try {
        const { data, error } = await supabase
          .from('vehicles')
          .select('id, plate_number, vehicle_id, assigned_driver_code')

        if (error) throw error
        vehicles.value = data || []
      } catch (error) {
        console.error('Error loading vehicles:', error)
      }
    }

    const getAssignedVehicle = (driverId) => {
      const driver = drivers.value.find(d => d.id === driverId)
      if (!driver) return null
      const vehicle = vehicles.value.find(v => v.assigned_driver_code === driver.employee_id)
      return vehicle ? `${vehicle.vehicle_id} (${vehicle.plate_number})` : null
    }

    const formatDate = (dateString) => {
      if (!dateString) return null
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric' 
      })
    }

    const isLicenseExpiring = (expiryDate) => {
      if (!expiryDate) return false
      const expiry = new Date(expiryDate)
      const today = new Date()
      const daysUntilExpiry = (expiry - today) / (1000 * 60 * 60 * 24)
      return daysUntilExpiry <= 30 && daysUntilExpiry >= 0
    }

    const openAddModal = () => {
      editingDriver.value = null
      resetForm()
      showModal.value = true
    }

    const closeModal = () => {
      showModal.value = false
      editingDriver.value = null
      resetForm()
    }

    const resetForm = () => {
      Object.assign(form, {
        employee_id: '',
        full_name: '',
        email: '',
        password: '',
        phone: '',
        license_number: '',
        license_expiry: '',
        position: 'Driver',
        department: '',
        is_active: true
      })
    }

    const editDriver = (driver) => {
      editingDriver.value = driver
      Object.assign(form, {
        employee_id: driver.employee_id,
        full_name: driver.full_name,
        email: driver.email,
        password: '',
        phone: driver.phone || '',
        license_number: driver.license_number || '',
        license_expiry: driver.license_expiry || '',
        position: driver.position || 'Driver',
        department: driver.department || '',
        is_active: driver.is_active ?? true
      })
      showModal.value = true
    }

    const viewDriver = (driver) => {
      selectedDriver.value = driver
    }

    const submitForm = async () => {
      submitting.value = true
      try {
        // Validate password for new drivers
        if (!editingDriver.value) {
          if (!form.password || form.password.trim() === '') {
            warning('Password is required for new drivers')
            submitting.value = false
            return
          }
          
          if (form.password.length < 8) {
            warning('Password must be at least 8 characters long')
            submitting.value = false
            return
          }
          
          // Password validation: at least 1 uppercase and 1 special character
          const passwordRegex = /^(?=.*[A-Z])(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]).{8,}$/
          if (!passwordRegex.test(form.password)) {
            warning('Password must contain at least 8 characters, 1 uppercase letter, and 1 special character')
            submitting.value = false
            return
          }
          
          if (!form.email || form.email.trim() === '') {
            warning('Email is required for new drivers')
            submitting.value = false
            return
          }
        }
        
        if (editingDriver.value) {
          // Update existing driver
          const updateData = {
            full_name: form.full_name,
            phone: form.phone || null,
            license_number: form.license_number || null,
            license_expiry: form.license_expiry || null,
            position: form.position,
            department: form.department || null,
            is_active: form.is_active
          }

          const { error } = await supabase
            .from('drivers')
            .update(updateData)
            .eq('id', editingDriver.value.id)

          if (error) throw error

          const index = drivers.value.findIndex(d => d.id === editingDriver.value.id)
          if (index !== -1) {
            drivers.value[index] = {
              ...editingDriver.value,
              ...updateData,
              updated_at: new Date().toISOString()
            }
          }

          success('Driver updated successfully!')
        } else {
          // Create new driver with auth account
          console.log('Creating auth user...')
          const { data: authData, error: authError } = await supabase.auth.signUp({
            email: form.email,
            password: form.password,
            options: {
              data: {
                employee_id: form.employee_id,
                full_name: form.full_name,
                position: form.position,
                department: form.department,
                phone: form.phone,
                role: 'driver' // Drivers have 'driver' role
              }
            }
          })

          if (authError) {
            console.error('Auth error:', authError)
            throw new Error(`Authentication failed: ${authError.message}`)
          }
          
          if (!authData.user) {
            throw new Error('Failed to create user account - no user returned')
          }

          console.log('Auth user created successfully:', authData.user.id)

          // Wait a moment for auth to complete
          await new Promise(resolve => setTimeout(resolve, 300))

          // Insert into drivers table
          console.log('Inserting into drivers table...')
          const { data: driverData, error: driverError } = await supabase
            .from('drivers')
            .insert({
              user_id: authData.user.id,
              employee_id: form.employee_id,
              full_name: form.full_name,
              email: form.email,
              phone: form.phone || null,
              license_number: form.license_number || null,
              license_expiry: form.license_expiry || null,
              position: form.position,
              department: form.department || null,
              is_active: form.is_active
            })
            .select()
            .single()

          if (driverError) {
            console.error('Driver insert error:', driverError)
            throw new Error(`Failed to save driver data: ${driverError.message}`)
          }

          console.log('Driver created successfully:', driverData)
          drivers.value.unshift(driverData)
          success('Driver registered successfully!')
        }

        emit('driver-updated')
        closeModal()
      } catch (err) {
        console.error('Error saving driver:', err)
        error('Error: ' + (err.message || 'Failed to save driver'))
      } finally {
        submitting.value = false
      }
    }

    const confirmDelete = (driver) => {
      driverToDelete.value = driver
    }

    const deleteDriver = async () => {
      if (!driverToDelete.value) return
      
      try {
        // Check if driver is assigned to a vehicle
        const assignedVehicle = vehicles.value.find(v => v.assigned_driver_code === driverToDelete.value.employee_id)
        if (assignedVehicle) {
          warning(`Cannot delete driver. They are currently assigned to vehicle ${assignedVehicle.plate_number}. Please reassign the vehicle first.`)
          driverToDelete.value = null
          return
        }

        const { error: deleteError } = await supabase
          .from('drivers')
          .delete()
          .eq('id', driverToDelete.value.id)
        
        if (deleteError) throw deleteError

        drivers.value = drivers.value.filter(d => d.id !== driverToDelete.value.id)
        emit('driver-updated')
        success('Driver deleted successfully')
        driverToDelete.value = null
      } catch (err) {
        console.error('Error deleting driver:', err)
        error('Error deleting driver: ' + err.message)
      }
    }

    // Lifecycle
    onMounted(async () => {
      await loadDrivers()
      await loadVehicles()
    })

    return {
      viewMode,
      drivers,
      loading,
      submitting,
      searchQuery,
      statusFilter,
      filteredDrivers,
      activeDriversCount,
      assignedDriversCount,
      availableDriversCount,
      showModal,
      editingDriver,
      selectedDriver,
      driverToDelete,
      showPassword,
      form,
      getAssignedVehicle,
      formatDate,
      isLicenseExpiring,
      openAddModal,
      closeModal,
      editDriver,
      viewDriver,
      submitForm,
      confirmDelete,
      deleteDriver
    }
  }
}
</script>
<template>
  <div class="profile-settings space-y-6">
    <!-- Profile Header Card -->
    <div class="bg-white dark:bg-[#161b22] rounded-2xl shadow-lg overflow-hidden border border-gray-100 dark:border-[#30363d] transition-colors duration-200">
      <!-- Cover Background with Pattern -->
      <div class="h-40 bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] relative transition-colors duration-200">
        <div class="absolute inset-0 opacity-10">
          <div class="absolute inset-0" style="background-image: url('data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fill-rule=\'evenodd\'%3E%3Cg fill=\'%23ffffff\' fill-opacity=\'1\'%3E%3Cpath d=\'M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E');"></div>
        </div>
        <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400"></div>
      </div>
      
      <!-- Profile Info Section -->
      <div class="px-8 pb-8 -mt-20 relative">
        <div class="flex flex-col md:flex-row md:items-end gap-6">
          <!-- Profile Picture -->
          <div class="relative">
            <div class="w-36 h-36 rounded-2xl overflow-hidden border-4 border-white dark:border-gray-700 shadow-2xl bg-gradient-to-br from-gray-100 to-gray-200 dark:from-gray-700 dark:to-gray-800 transition-colors duration-200">
              <img
                v-if="profilePictureUrl"
                :src="profilePictureUrl"
                alt="Profile Picture"
                class="w-full h-full object-cover"
              />
              <div v-else class="w-full h-full flex items-center justify-center bg-gradient-to-br from-green-800 to-green-600 dark:from-[#238636] dark:to-[#2ea043]">
                <span class="text-5xl font-bold text-white">
                  {{ getInitials(profileForm.full_name) }}
                </span>
              </div>
            </div>
            <button
              @click="showPhotoModal = true"
              class="absolute -bottom-2 -right-2 w-12 h-12 rounded-full bg-gradient-to-br from-green-800 to-green-600 dark:from-[#238636] dark:to-[#2ea043] text-white shadow-xl hover:scale-110 transition-all duration-200 flex items-center justify-center group"
            >
              <i class="fas fa-camera text-base group-hover:rotate-12 transition-transform"></i>
            </button>
          </div>
          
          <!-- User Details -->
          <div class="flex-1 min-w-0">
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
              <div>
                <h2 class="text-3xl md:text-4xl mb-3 font-bold text-white truncate">
                  {{ profileForm.full_name || 'No Name Set' }}
                </h2>
                <p class="text-sm text-gray-500 dark:text-gray-400 mt-1 flex items-center gap-2 transition-colors duration-200">
                  <i class="fas fa-envelope text-gray-400"></i>
                  {{ currentUser?.email?.split('@')[0] || 'N/A' }}
                </p>
                <div class="flex flex-wrap items-center gap-2 mt-3">
                  <span v-if="profileForm.position" class="inline-flex items-center px-3 py-1.5 rounded-lg text-xs font-semibold bg-gradient-to-r from-green-50 to-emerald-50 text-green-800 border border-green-200">
                    <i class="fas fa-briefcase mr-1.5"></i>
                    {{ profileForm.position }}
                  </span>
                  <span v-if="profileForm.department" class="inline-flex items-center px-3 py-1.5 rounded-lg text-xs font-semibold bg-gradient-to-r from-blue-50 to-cyan-50 text-blue-800 border border-blue-200">
                    <i class="fas fa-building mr-1.5"></i>
                    {{ profileForm.department }}
                  </span>
                  <span v-if="profileForm.employee_id" class="inline-flex items-center px-3 py-1.5 rounded-lg text-xs font-semibold bg-gradient-to-r from-purple-50 to-pink-50 text-purple-800 border border-purple-200">
                    <i class="fas fa-id-badge mr-1.5"></i>
                    {{ profileForm.employee_id }}
                  </span>
                </div>
              </div>
              
              <div class="flex items-center gap-3 px-4 py-2.5 bg-gradient-to-br from-green-50 to-emerald-50 rounded-xl border-2 border-green-200 shadow-sm">
                <div class="w-2.5 h-2.5 bg-green-500 rounded-full animate-pulse"></div>
                <span class="text-sm font-bold text-green-700 uppercase tracking-wide">{{ profileForm.role || 'User' }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Quick Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div class="bg-white dark:bg-[#161b22] rounded-xl shadow-md p-4 border border-gray-100 dark:border-[#30363d] hover:shadow-lg transition-shadow">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-lg flex-shrink-0">
            <i class="fas fa-calendar-check text-white text-sm"></i>
          </div>
          <div class="min-w-0">
            <p class="text-xs text-gray-500 dark:text-[#8b949e] font-medium uppercase tracking-wide transition-colors duration-200">Member Since</p>
            <p class="text-base font-bold text-gray-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ formatDate(currentUser?.created_at) }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white dark:bg-[#161b22] rounded-xl shadow-md p-4 border border-gray-100 dark:border-[#30363d] hover:shadow-lg transition-all duration-200">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-green-500 to-green-600 dark:from-[#238636] dark:to-[#2ea043] flex items-center justify-center shadow-lg flex-shrink-0">
            <i class="fas fa-clock text-white text-sm"></i>
          </div>
          <div class="min-w-0">
            <p class="text-xs text-gray-500 dark:text-[#8b949e] font-medium uppercase tracking-wide transition-colors duration-200">Last Login</p>
            <p class="text-base font-bold text-gray-900 dark:text-[#e6edf3] truncate transition-colors duration-200">{{ formatDate(currentUser?.last_sign_in_at) }}</p>
          </div>
        </div>
      </div>

      <div class="bg-white dark:bg-[#161b22] rounded-xl shadow-md p-4 border border-gray-100 dark:border-[#30363d] hover:shadow-lg transition-all duration-200">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center shadow-lg flex-shrink-0">
            <i class="fas fa-shield-alt text-white text-sm"></i>
          </div>
          <div class="min-w-0">
            <p class="text-xs text-gray-500 dark:text-[#8b949e] font-medium uppercase tracking-wide transition-colors duration-200">Account Status</p>
            <p class="text-base font-bold text-green-600 dark:text-[#3fb950]">Active</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Profile Information Form -->
    <div class="bg-white dark:bg-[#161b22] rounded-2xl shadow-lg overflow-hidden border border-gray-100 dark:border-[#30363d] transition-colors duration-200">
      <div class="px-8 py-6 border-b border-gray-200 dark:border-[#30363d] bg-gradient-to-r from-gray-50 to-white dark:from-[#0d1117] dark:to-[#161b22] transition-colors duration-200">
        <div class="flex items-center gap-4">
          <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-green-800 to-green-600 dark:from-[#238636] dark:to-[#2ea043] flex items-center justify-center shadow-lg">
            <i class="fas fa-user-edit text-white text-xl"></i>
          </div>
          <div>
            <h3 class="text-2xl font-bold text-gray-900 dark:text-white transition-colors duration-200">Personal Information</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1 transition-colors duration-200">Update your personal and employment details</p>
          </div>
        </div>
      </div>

      <form @submit.prevent="updateProfile" class="p-8">
        <div class="space-y-8">
          <!-- Basic Information -->
          <div class="bg-gradient-to-br from-gray-50 to-white dark:from-gray-800 dark:to-gray-900 rounded-xl p-6 border border-gray-200 dark:border-gray-700 transition-colors duration-200">
            <h4 class="text-sm font-bold text-gray-700 dark:text-gray-300 uppercase tracking-wider mb-5 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-user text-green-600"></i>
              Basic Information
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
              <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 transition-colors duration-200">
                  <i class="fas fa-id-badge text-gray-400 mr-2"></i>Employee ID
                </label>
                <input
                  v-model="profileForm.employee_id"
                  type="text"
                  class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all shadow-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="e.g., EMP-001"
                />
              </div>

              <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 transition-colors duration-200">
                  <i class="fas fa-user text-gray-400 mr-2"></i>Full Name <span class="text-red-500">*</span>
                </label>
                <input
                  v-model="profileForm.full_name"
                  type="text"
                  required
                  class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all shadow-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="Enter your full name"
                />
              </div>

              <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 transition-colors duration-200">
                  <i class="fas fa-phone text-gray-400 mr-2"></i>Phone Number
                </label>
                <input
                  v-model="profileForm.phone"
                  type="tel"
                  class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all shadow-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="+63 XXX XXX XXXX"
                />
              </div>

              <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 transition-colors duration-200">
                  <i class="fas fa-envelope text-gray-400 mr-2"></i>Email Address
                </label>
                <input
                  :value="currentUser?.email"
                  type="email"
                  readonly
                  class="w-full px-4 py-3 bg-gray-100 dark:bg-gray-600 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-600 dark:text-gray-300 cursor-not-allowed shadow-sm transition-colors duration-200"
                />
              </div>
            </div>
          </div>

          <!-- Employment Details -->
          <div class="bg-gradient-to-br from-gray-50 to-white dark:from-gray-800 dark:to-gray-900 rounded-xl p-6 border border-gray-200 dark:border-gray-700 transition-colors duration-200">
            <h4 class="text-sm font-bold text-gray-700 dark:text-gray-300 uppercase tracking-wider mb-5 flex items-center gap-2 transition-colors duration-200">
              <i class="fas fa-briefcase text-green-600"></i>
              Employment Details
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
              <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 transition-colors duration-200">
                  <i class="fas fa-user-tie text-gray-400 mr-2"></i>Position
                </label>
                <input
                  v-model="profileForm.position"
                  type="text"
                  class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all shadow-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                  placeholder="Enter your position"
                />
              </div>

              <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 transition-colors duration-200">
                  <i class="fas fa-building text-gray-400 mr-2"></i>Department
                </label>
                <select 
                  v-model="profileForm.department" 
                  class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all shadow-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                >
                  <option value="">Select Department</option>
                  <option value="Admin">Admin</option>
                  <option value="Finance">Finance</option>
                  <option value="IT">IT</option>
                  <option value="Transport">Transport</option>
                  <option value="Maintenance">Maintenance</option>
                  <option value="Operations">Operations</option>
                  <option value="Human Resources">Human Resources</option>
                </select>
              </div>

              <div class="space-y-2 md:col-span-2">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 transition-colors duration-200">
                  <i class="fas fa-user-shield text-gray-400 mr-2"></i>Role
                </label>
                <input
                  :value="profileForm.role"
                  type="text"
                  readonly
                  class="w-full px-4 py-3 bg-gray-100 dark:bg-gray-600 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-600 dark:text-gray-300 cursor-not-allowed shadow-sm transition-colors duration-200"
                  placeholder="Role (managed by system administrator)"
                />
              </div>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="flex flex-col sm:flex-row justify-end gap-3 pt-4">
            <button
              type="button"
              @click="loadUserProfile"
              class="px-6 py-3 border-2 border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 font-semibold rounded-xl transition-all duration-200 hover:bg-gray-50 dark:hover:bg-gray-700 hover:scale-105"
            >
              <i class="fas fa-redo mr-2"></i>
              Reset Changes
            </button>
            <button
              type="submit"
              :disabled="profileLoading"
              class="px-6 py-3 text-white font-semibold rounded-xl transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed bg-gradient-to-br from-green-800 to-green-600 dark:from-[#238636] dark:to-[#2ea043] shadow-lg shadow-green-800/30"
            >
              <i class="fas fa-save mr-2"></i>
              {{ profileLoading ? 'Updating...' : 'Save Changes' }}
            </button>
          </div>
        </div>
      </form>
    </div>

    <!-- Photo Upload Modal -->
    <div v-if="showPhotoModal" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm p-4">
      <div class="bg-white dark:bg-[#161b22] rounded-2xl shadow-2xl w-full max-w-md overflow-hidden transition-colors duration-200">
        <div class="relative py-6 px-8 bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] text-white">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-2xl font-bold">Profile Photo</h3>
              <p class="text-green-100 text-sm mt-1">Upload or delete your profile picture</p>
            </div>
            <button 
              @click="showPhotoModal = false" 
              class="w-10 h-10 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
            >
              <i class="fas fa-times text-lg"></i>
            </button>
          </div>
          <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400"></div>
        </div>

        <div class="p-8 bg-white dark:bg-[#161b22] transition-colors duration-200">
          <div class="flex flex-col items-center space-y-6">
            <!-- Current Photo Preview -->
            <div class="relative">
              <div class="w-40 h-40 rounded-2xl overflow-hidden border-4 border-gray-200 shadow-xl">
                <img 
                  v-if="profilePictureUrl"
                  :src="profilePictureUrl" 
                  alt="Current Profile Photo" 
                  class="w-full h-full object-cover" 
                />
                <div v-else class="w-full h-full flex items-center justify-center bg-gradient-to-br from-green-800 to-green-600 dark:from-[#238636] dark:to-[#2ea043]">
                  <span class="text-6xl font-bold text-white">
                    {{ getInitials(profileForm.full_name) }}
                  </span>
                </div>
              </div>
            </div>

            <!-- File Input -->
            <div class="w-full">
              <label class="block text-sm font-semibold text-gray-700 dark:text-[#e6edf3] mb-2 transition-colors duration-200">
                <i class="fas fa-image mr-2"></i>Choose New Photo
              </label>
              <input 
                type="file" 
                @change="handleFileChange" 
                accept="image/*" 
                class="w-full text-sm text-gray-500 dark:text-[#8b949e] file:mr-4 file:py-2.5 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-green-50 dark:file:bg-[#1c2128] file:text-green-700 dark:file:text-[#3fb950] hover:file:bg-green-100 dark:hover:file:bg-[#1a2f23] cursor-pointer border border-gray-300 dark:border-[#30363d] rounded-lg transition-colors duration-200" 
              />
              <p class="text-xs text-gray-500 mt-2">
                <i class="fas fa-info-circle mr-1"></i>
                Recommended: Square image, at least 400x400px
              </p>
            </div>

            <!-- Action Buttons -->
            <div class="flex gap-3 w-full pt-2">
              <button 
                @click="uploadProfilePicture" 
                :disabled="photoLoading || !profilePictureFile" 
                class="flex-1 px-6 py-3 font-semibold rounded-xl transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed text-white bg-gradient-to-br from-green-800 to-green-600 dark:from-[#238636] dark:to-[#2ea043] shadow-lg shadow-green-800/30"
              >
                <i class="fas fa-upload mr-2"></i>
                {{ photoLoading ? 'Uploading...' : 'Upload' }}
              </button>
              <button 
                @click="deleteProfilePicture" 
                :disabled="photoLoading || !profilePictureUrl" 
                class="flex-1 px-6 py-3 bg-gradient-to-br from-red-500 to-red-600 text-white font-semibold rounded-xl transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-red-500/30"
              >
                <i class="fas fa-trash-alt mr-2"></i>
                Delete
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, inject } from 'vue'
import { supabase } from '../../lib/supabase'

const showNotification = inject('showNotification')
const currentUser = ref(null)
const profileLoading = ref(false)
const showPhotoModal = ref(false)
const profilePictureUrl = ref('')
const profilePictureFile = ref(null)
const photoLoading = ref(false)
    
const storageBucket = 'avatars'

const profileForm = reactive({
  employee_id: '',
  full_name: '',
  position: '',
  department: '',
  phone: '',
  role: ''
})

const getInitials = (name) => {
  if (!name) return 'U'
  const names = name.split(' ')
  if (names.length >= 2) {
    return (names[0][0] + names[names.length - 1][0]).toUpperCase()
  }
  return name.substring(0, 2).toUpperCase()
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric' 
  })
}

const handleFileChange = (event) => {
  profilePictureFile.value = event.target.files[0]
}

const loadUserProfile = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    currentUser.value = user

    if (user) {
      const { data: profile, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single()

      if (error && error.code !== 'PGRST116') {
        throw error
      }
      
      if (profile) {
        profileForm.employee_id = profile.employee_id || ''
        profileForm.full_name = profile.full_name || ''
        profileForm.position = profile.position || ''
        profileForm.department = profile.department || ''
        profileForm.phone = profile.phone || ''
        profileForm.role = profile.role || 'user'
        
        if (profile.avatar_url) {
          const { data: imageUrl } = supabase.storage.from(storageBucket).getPublicUrl(profile.avatar_url)
          if (imageUrl) {
            profilePictureUrl.value = imageUrl.publicUrl
          }
        }
      }
      
      // Set up real-time subscription
      const channel = supabase
        .channel('profile-changes')
        .on(
          'postgres_changes',
          {
            event: '*',
            schema: 'public',
            table: 'profiles',
            filter: `id=eq.${user.id}`
          },
          (payload) => {
            if (payload.new) {
              profileForm.employee_id = payload.new.employee_id || ''
              profileForm.full_name = payload.new.full_name || ''
              profileForm.position = payload.new.position || ''
              profileForm.department = payload.new.department || ''
              profileForm.phone = payload.new.phone || ''
              profileForm.role = payload.new.role || 'user'
              
              if (payload.new.avatar_url) {
                const { data: imageUrl } = supabase.storage.from(storageBucket).getPublicUrl(payload.new.avatar_url)
                if (imageUrl) {
                  profilePictureUrl.value = imageUrl.publicUrl
                }
              } else {
                profilePictureUrl.value = ''
              }
            }
          }
        )
        .subscribe()
    }
  } catch (error) {
    console.error('Error loading user profile:', error)
    showNotification('Failed to load profile. Please try again.', 'error')
  }
}

const updateProfile = async () => {
  try {
    profileLoading.value = true
    const { data: { user } } = await supabase.auth.getUser()

    if (user) {
      const { error } = await supabase
        .from('profiles')
        .update({
          employee_id: profileForm.employee_id,
          full_name: profileForm.full_name,
          position: profileForm.position,
          department: profileForm.department,
          phone: profileForm.phone
        })
        .eq('id', user.id)

      if (error) throw error
      showNotification('Profile updated successfully!')
    }
  } catch (error) {
    console.error('Error updating profile:', error)
    showNotification('Failed to update profile. Please try again.', 'error')
  } finally {
    profileLoading.value = false
  }
}

const uploadProfilePicture = async () => {
  if (!profilePictureFile.value) {
    showNotification('Please select a file to upload.', 'error')
    return
  }

  photoLoading.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const file = profilePictureFile.value
    const fileExt = file.name.split('.').pop()
    const filePath = `${user.id}/${Date.now()}.${fileExt}`
    
    const { error: uploadError } = await supabase.storage
      .from(storageBucket)
      .upload(filePath, file, { upsert: true })

    if (uploadError) throw uploadError

    const { data: { publicUrl } } = supabase.storage
      .from(storageBucket)
      .getPublicUrl(filePath)

    const { error: updateError } = await supabase
      .from('profiles')
      .update({ avatar_url: filePath })
      .eq('id', user.id)

    if (updateError) throw updateError

    profilePictureUrl.value = publicUrl
    showNotification('Profile picture uploaded successfully!')
    showPhotoModal.value = false
    profilePictureFile.value = null
  } catch (error) {
    console.error('Error uploading profile picture:', error)
    showNotification('Failed to upload profile picture.', 'error')
  } finally {
    photoLoading.value = false
  }
}

const deleteProfilePicture = async () => {
  photoLoading.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data: profile } = await supabase.from('profiles').select('avatar_url').eq('id', user.id).single()
    if (!profile || !profile.avatar_url) {
      showNotification('No profile picture to delete.', 'error')
      photoLoading.value = false
      return
    }

    const { error: removeError } = await supabase.storage
      .from(storageBucket)
      .remove([profile.avatar_url])

    if (removeError) throw removeError
    
    const { error: updateError } = await supabase
      .from('profiles')
      .update({ avatar_url: null })
      .eq('id', user.id)

    if (updateError) throw updateError

    profilePictureUrl.value = ''
    showNotification('Profile picture deleted successfully!')
    showPhotoModal.value = false
  } catch (error) {
    console.error('Error deleting profile picture:', error)
    showNotification('Failed to delete profile picture.', 'error')
  } finally {
    photoLoading.value = false
  }
}

onMounted(async () => {
  await loadUserProfile()
})
</script>

<style scoped>
.profile-settings {
  animation: fadeIn 0.5s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
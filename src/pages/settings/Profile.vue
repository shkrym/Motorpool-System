<template>
  <div class="profile-settings space-y-6">
    <!-- User Profile Display Section -->
    <div class="bg-white/90 backdrop-blur-xl rounded-2xl p-8 shadow-lg shadow-csu-green-dark/10">
      <div class="flex flex-col items-center justify-center text-center">
        <!-- Profile Picture -->
        <div class="relative w-32 h-32 mb-4">
          <img
            :src="profilePictureUrl || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(profileForm.full_name || 'User') + '&size=128&background=0A400C&color=fff'"
            alt="Profile Picture"
            class="w-full h-full object-cover rounded-full border-4 border-csu-green-dark shadow-lg transition-all duration-300"
          />
        </div>
        <button
          @click="showPhotoModal = true"
          class="flex items-center justify-center px-6 py-3 mb-6 font-semibold rounded-xl text-white bg-gradient-to-br from-csu-green-dark to-csu-green-light transition-all duration-200 hover:scale-105 shadow-lg shadow-csu-green-dark/30"
        >
          <i class="fas fa-camera mr-2"></i>
          Change Photo
        </button>

        <!-- User Info -->
        <h2 class="text-3xl font-bold text-csu-green-dark">{{ profileForm.full_name || 'Your Name' }}</h2>
        <p class="text-lg text-gray-600">{{ profileForm.position || 'Position Not Set' }}</p>
        <p class="text-sm text-gray-500 mt-1">ID: {{ profileForm.employee_id || 'N/A' }}</p>
      </div>
    </div>

    <!-- Profile Update Form -->
    <div class="bg-white/90 backdrop-blur-xl rounded-2xl p-8 shadow-lg shadow-csu-green-dark/10">
      <div class="flex items-center mb-6">
        <div class="w-16 h-16 bg-gradient-to-br from-csu-green-dark to-csu-green-light rounded-xl flex items-center justify-center mr-4 shadow-lg">
          <i class="fas fa-edit text-white text-2xl"></i>
        </div>
        <div>
          <h2 class="text-2xl font-bold text-csu-green-dark">Update Profile</h2>
          <p class="text-gray-600">Edit your personal and employment details</p>
        </div>
      </div>
      <form @submit.prevent="updateProfile" class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Employee ID</label>
            <input
              v-model="profileForm.employee_id"
              type="text"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-4 focus:ring-csu-green-dark/10 focus:border-csu-green-dark transition-all duration-200"
              placeholder="Enter employee ID"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Full Name *</label>
            <input
              v-model="profileForm.full_name"
              type="text"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-4 focus:ring-csu-green-dark/10 focus:border-csu-green-dark transition-all duration-200"
              placeholder="Enter your full name"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Position</label>
            <input
              v-model="profileForm.position"
              type="text"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-4 focus:ring-csu-green-dark/10 focus:border-csu-green-dark transition-all duration-200"
              placeholder="Enter your position"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Department</label>
            <select v-model="profileForm.department" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-4 focus:ring-csu-green-dark/10 focus:border-csu-green-dark transition-all duration-200">
              <option value="">Select Department</option>
              <option value="Admin">Admin</option>
              <option value="Finance">Finance</option>
              <option value="IT">IT</option>
              <option value="Transport">Transport</option>
              <option value="Maintenance">Maintenance</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Phone Number</label>
            <input
              v-model="profileForm.phone"
              type="tel"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-4 focus:ring-csu-green-dark/10 focus:border-csu-green-dark transition-all duration-200"
              placeholder="Enter your phone number"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Role</label>
            <input
              :value="profileForm.role"
              type="text"
              readonly
              class="w-full px-4 py-3 bg-gray-100 border border-gray-300 rounded-lg text-gray-600 cursor-not-allowed"
              placeholder="Role (read-only)"
            />
          </div>
        </div>

        <div class="flex justify-end pt-4">
          <button
            type="submit"
            :disabled="profileLoading"
            class="px-6 py-3 text-white font-semibold rounded-xl transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed bg-gradient-to-br from-csu-green-dark to-csu-green-light shadow-lg shadow-csu-green-dark/30"
          >
            <i class="fas fa-save mr-2"></i>
            {{ profileLoading ? 'Updating...' : 'Update Profile' }}
          </button>
        </div>
      </form>
    </div>

    <!-- Photo Upload Modal -->
    <div v-if="showPhotoModal" class="fixed inset-0 bg-black/60 flex items-center justify-center z-50 backdrop-blur-sm p-4">
      <div class="bg-white rounded-2xl shadow-2xl p-0 w-full max-w-md">
        <div class="py-6 px-8 border-b border-gray-200 flex justify-between items-center bg-gradient-to-br from-csu-green-dark to-csu-green-light text-white rounded-t-2xl">
          <h3 class="text-xl font-bold">Manage Profile Photo</h3>
          <button @click="showPhotoModal = false" class="bg-white/10 border-none text-white w-8 h-8 rounded-lg cursor-pointer flex items-center justify-center transition-colors duration-200 hover:bg-white/20">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="p-8">
          <div class="flex flex-col items-center space-y-4">
            <img 
              :src="profilePictureUrl || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(profileForm.full_name || 'User') + '&size=144&background=0A400C&color=fff'" 
              alt="Current Profile Photo" 
              class="w-36 h-36 rounded-full object-cover border-4 border-gray-200 shadow-lg" 
            />
            <input 
              type="file" 
              @change="handleFileChange" 
              accept="image/*" 
              class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-csu-green-dark/10 file:text-csu-green-dark hover:file:bg-csu-green-dark/20 cursor-pointer" 
            />
            <div class="flex flex-col sm:flex-row gap-3 pt-2 w-full">
              <button 
                @click="uploadProfilePicture" 
                :disabled="photoLoading || !profilePictureFile" 
                class="flex-1 px-6 py-3 font-semibold rounded-xl transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed text-white bg-gradient-to-br from-csu-green-dark to-csu-green-light shadow-lg shadow-csu-green-dark/30"
              >
                <i class="fas fa-upload mr-2"></i>
                {{ photoLoading ? 'Uploading...' : 'Upload' }}
              </button>
              <button 
                @click="deleteProfilePicture" 
                :disabled="photoLoading || !profilePictureUrl" 
                class="flex-1 px-6 py-3 bg-red-500 text-white font-semibold rounded-xl transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-red-500/30"
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
        Object.assign(profileForm, profile)
        if (profile.avatar_url) {
          const { data: imageUrl } = supabase.storage.from(storageBucket).getPublicUrl(profile.avatar_url)
          if (imageUrl) {
            profilePictureUrl.value = imageUrl.publicUrl
          }
        }
      }
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
    const filePath = `${user.id}/${Date.now()}-${file.name}`
    
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
<template>
  <div class="profile-settings space-y-8 p-4 sm:p-8">
    <!-- User Profile Display Section -->
    <div class="bg-white rounded-xl shadow-lg p-8">
      <div class="flex flex-col items-center justify-center text-center">
        <!-- Profile Picture and Photo Change Button -->
        <div class="relative w-36 h-36 mb-4">
          <img
            :src="profilePictureUrl || 'https://placehold.co/144x144/9CA3AF/FFFFFF?text=P'"
            alt="Profile Picture"
            class="w-full h-full object-cover rounded-full border-4 border-yellow-500 hover:border-green-600 transition-all duration-300"
          />
        </div>
        <button
          @click="openPhotoModal"
          class="flex items-center justify-center px-6 py-3 mb-6 font-semibold rounded-full text-white bg-gradient-to-r from-green-500 to-green-600 hover:from-green-700 hover:to-green-500 transition-all duration-200 hover:scale-105"
          :style="{ 'background-color': '#0A400C' }"
        >
          <i class="fas fa-camera mr-2"></i>
          Change Photo
        </button>

        <!-- User Info -->
        <h2 class="text-3xl font-bold text-green-800" :style="{ color: '#0A400C' }">{{ profileForm.full_name || 'Your Name' }}</h2>
        <p class="text-lg text-gray-600">{{ profileForm.position || 'Position Not Set' }}</p>
        <p class="text-sm text-gray-500 mt-1">ID: {{ profileForm.employee_id || 'N/A' }}</p>
      </div>
    </div>

    <!-- Profile Update Form -->
    <div class="bg-white rounded-xl shadow-lg p-8">
      <div class="flex items-center mb-6">
        <div class="w-16 h-16 bg-gradient-to-br from-yellow-500 via-yellow-400 to-green-600 rounded-full flex items-center justify-center mr-4">
          <i class="fas fa-edit text-white text-2xl"></i>
        </div>
        <div>
          <h2 class="text-2xl font-bold text-green-800" :style="{ color: '#0A400C' }">Update Profile</h2>
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
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent transition-all duration-200"
              placeholder="Enter employee ID"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Full Name *</label>
            <input
              v-model="profileForm.full_name"
              type="text"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent transition-all duration-200"
              placeholder="Enter your full name"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Position</label>
            <input
              v-model="profileForm.position"
              type="text"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent transition-all duration-200"
              placeholder="Enter your position"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Department</label>
            <input
              v-model="profileForm.department"
              type="text"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent transition-all duration-200"
              placeholder="Enter your department"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Phone Number</label>
            <input
              v-model="profileForm.phone"
              type="tel"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent transition-all duration-200"
              placeholder="Enter your phone number"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Role</label>
            <input
              :value="profileForm.role"
              type="text"
              readonly
              class="w-full px-4 py-3 bg-gray-100 border border-gray-300 rounded-lg text-gray-600"
              placeholder="Role (read-only)"
            />
          </div>
        </div>

        <div class="flex justify-end pt-4">
          <button
            type="submit"
            :disabled="profileLoading"
            class="px-6 py-3 text-white font-semibold rounded-lg transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
            :style="{ 'background-color': '#0A400C' }"
          >
            <i class="fas fa-save mr-2"></i>
            {{ profileLoading ? 'Updating...' : 'Update Profile' }}
          </button>
        </div>
      </form>
    </div>

    <!-- Photo Upload Modal -->
    <div v-if="showPhotoModal" class="fixed inset-0 bg-gray-900 bg-opacity-75 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-lg p-8 w-full max-w-md">
        <h3 class="text-xl font-bold text-green-800 mb-4" :style="{ color: '#0A400C' }">Manage Profile Photo</h3>
        <div class="flex flex-col items-center space-y-4">
          <img :src="profilePictureUrl || 'https://placehold.co/144x144/9CA3AF/FFFFFF?text=P'" alt="Current Profile Photo" class="w-36 h-36 rounded-full object-cover border-4 border-gray-200" />
          <input type="file" @change="handleFileChange" accept="image/*" class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-yellow-50 file:text-yellow-600 hover:file:bg-yellow-100" />
          <div class="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-4 pt-2 w-full">
            <button @click="uploadProfilePicture" :disabled="photoLoading || !profilePictureFile" class="flex-1 px-6 py-3 font-semibold rounded-lg transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed text-white" :style="{ 'background-color': '#0A400C' }">
              <i class="fas fa-upload mr-2"></i>
              {{ photoLoading ? 'Uploading...' : 'Upload/Change' }}
            </button>
            <button @click="deleteProfilePicture" :disabled="photoLoading || !profilePictureUrl" class="flex-1 px-6 py-3 bg-red-500 text-white font-semibold rounded-lg transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed">
              <i class="fas fa-trash-alt mr-2"></i>
              Delete
            </button>
            <button @click="showPhotoModal = false" class="flex-1 px-6 py-3 bg-gray-300 text-gray-800 font-semibold rounded-lg transition-all duration-200 hover:scale-105">
              Cancel
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Notification Messages -->
    <div
      v-if="notification.show"
      :class="[
        'fixed top-4 right-4 p-4 rounded-lg shadow-lg z-50 transition-all duration-300',
        notification.type === 'success' ? 'bg-green-500 text-white' : 'bg-red-500 text-white'
      ]"
    >
      <div class="flex items-center">
        <i :class="notification.type === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-circle'" class="mr-2"></i>
        {{ notification.message }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { supabase } from '../../lib/supabase'

const currentUser = ref(null)
const profileLoading = ref(false)
const showPhotoModal = ref(false)
const profilePictureUrl = ref('')
const profilePictureFile = ref(null)
const photoLoading = ref(false)
    
const storageBucket = 'avatars';

const profileForm = reactive({
  employee_id: '',
  full_name: '',
  position: '',
  department: '',
  phone: '',
  role: ''
})

const notification = reactive({
  show: false,
  message: '',
  type: 'success'
})

const showNotification = (message, type = 'success') => {
  notification.message = message
  notification.type = type
  notification.show = true
  setTimeout(() => {
    notification.show = false
  }, 4000)
}

const openPhotoModal = () => {
  showPhotoModal.value = true;
}

const handleFileChange = (event) => {
  profilePictureFile.value = event.target.files[0];
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
      } else {
        // If profile does not exist, create a new one
        const { error: insertError } = await supabase
          .from('profiles')
          .insert([
            { id: user.id, full_name: user.user_metadata.full_name || 'New User' }
          ])
        if (insertError) throw insertError
        profileForm.full_name = user.user_metadata.full_name || 'New User'
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

      if (error) {
        throw error
      }

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
    showNotification('Please select a file to upload.', 'error');
    return;
  }

  photoLoading.value = true;
  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const file = profilePictureFile.value;
    const filePath = `${user.id}/${Date.now()}-${file.name}`;
    
    // Upload the file
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from(storageBucket)
      .upload(filePath, file, {
        upsert: true
      });

    if (uploadError) throw uploadError;

    // Get the public URL
    const { data: { publicUrl }, error: publicUrlError } = supabase.storage
      .from(storageBucket)
      .getPublicUrl(filePath);

    if (publicUrlError) throw publicUrlError;

    // Update the profile record with the new URL
    const { error: updateError } = await supabase
      .from('profiles')
      .update({ avatar_url: filePath })
      .eq('id', user.id);

    if (updateError) throw updateError;

    profilePictureUrl.value = publicUrl;
    showNotification('Profile picture uploaded successfully!');
    showPhotoModal.value = false;
    profilePictureFile.value = null;

  } catch (error) {
    console.error('Error uploading profile picture:', error);
    showNotification('Failed to upload profile picture.', 'error');
  } finally {
    photoLoading.value = false;
  }
};

const deleteProfilePicture = async () => {
  photoLoading.value = true;
  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const { data: profile } = await supabase.from('profiles').select('avatar_url').eq('id', user.id).single();
    if (!profile || !profile.avatar_url) {
      showNotification('No profile picture to delete.', 'error');
      return;
    }

    const { error: removeError } = await supabase.storage
      .from(storageBucket)
      .remove([profile.avatar_url]);

    if (removeError) throw removeError;
    
    const { error: updateError } = await supabase
      .from('profiles')
      .update({ avatar_url: null })
      .eq('id', user.id);

    if (updateError) throw updateError;

    profilePictureUrl.value = '';
    showNotification('Profile picture deleted successfully!');
    showPhotoModal.value = false;

  } catch (error) {
    console.error('Error deleting profile picture:', error);
    showNotification('Failed to delete profile picture.', 'error');
  } finally {
    photoLoading.value = false;
  }
};

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

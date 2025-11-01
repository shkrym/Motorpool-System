<template>
  <div class="account-security space-y-6">
    <!-- Email Update Section -->
    <div class="bg-white/90 backdrop-blur-xl rounded-2xl p-8 shadow-lg shadow-csu-green-dark/10">
      <div class="flex items-center mb-6">
        <div class="w-16 h-16 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center mr-4 shadow-lg">
          <i class="fas fa-envelope text-white text-2xl"></i>
        </div>
        <div>
          <h2 class="text-2xl font-bold text-csu-green-dark">Update Email Address</h2>
          <p class="text-gray-600">Change your account email address</p>
        </div>
      </div>

      <form @submit.prevent="updateEmail" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Current Email</label>
          <input
            :value="currentUser?.email"
            type="email"
            readonly
            class="w-full px-4 py-3 bg-gray-100 border border-gray-300 rounded-lg text-gray-600 cursor-not-allowed"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">New Email Address *</label>
          <input
            v-model="emailForm.newEmail"
            type="email"
            required
            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-4 focus:ring-csu-green-dark/10 focus:border-csu-green-dark transition-all duration-200"
            placeholder="Enter new email address"
          />
        </div>
        <div class="flex justify-end pt-2">
          <button
            type="submit"
            :disabled="emailLoading"
            class="px-6 py-3 bg-gradient-to-br from-blue-500 to-blue-600 text-white font-semibold rounded-xl transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-blue-500/30"
          >
            <i class="fas fa-envelope mr-2"></i>
            {{ emailLoading ? 'Updating...' : 'Update Email' }}
          </button>
        </div>
      </form>
    </div>

    <!-- Password Update Section -->
    <div class="bg-white/90 backdrop-blur-xl rounded-2xl p-8 shadow-lg shadow-csu-green-dark/10">
      <div class="flex items-center mb-6">
        <div class="w-16 h-16 bg-gradient-to-br from-red-500 to-red-600 rounded-xl flex items-center justify-center mr-4 shadow-lg">
          <i class="fas fa-lock text-white text-2xl"></i>
        </div>
        <div>
          <h2 class="text-2xl font-bold text-csu-green-dark">Change Password</h2>
          <p class="text-gray-600">Update your account password</p>
        </div>
      </div>

      <form @submit.prevent="updatePassword" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">New Password *</label>
          <div class="relative">
            <input
              v-model="passwordForm.newPassword"
              :type="showPassword ? 'text' : 'password'"
              required
              minlength="6"
              class="w-full px-4 py-3 pr-12 border border-gray-300 rounded-lg focus:ring-4 focus:ring-csu-green-dark/10 focus:border-csu-green-dark transition-all duration-200"
              placeholder="Enter new password (min. 6 characters)"
            />
            <button
              type="button"
              @click="showPassword = !showPassword"
              class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700"
            >
              <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
            </button>
          </div>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Confirm New Password *</label>
          <div class="relative">
            <input
              v-model="passwordForm.confirmPassword"
              :type="showConfirmPassword ? 'text' : 'password'"
              required
              minlength="6"
              class="w-full px-4 py-3 pr-12 border border-gray-300 rounded-lg focus:ring-4 focus:ring-csu-green-dark/10 focus:border-csu-green-dark transition-all duration-200"
              placeholder="Confirm new password"
            />
            <button
              type="button"
              @click="showConfirmPassword = !showConfirmPassword"
              class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700"
            >
              <i :class="showConfirmPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
            </button>
          </div>
        </div>
        <div v-if="passwordForm.newPassword && passwordForm.confirmPassword && passwordForm.newPassword !== passwordForm.confirmPassword" class="text-red-500 text-sm">
          Passwords do not match
        </div>
        <div class="flex justify-end pt-2">
          <button
            type="submit"
            :disabled="passwordLoading || passwordForm.newPassword !== passwordForm.confirmPassword"
            class="px-6 py-3 bg-gradient-to-br from-red-500 to-red-600 text-white font-semibold rounded-xl transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-red-500/30"
          >
            <i class="fas fa-lock mr-2"></i>
            {{ passwordLoading ? 'Updating...' : 'Change Password' }}
          </button>
        </div>
      </form>
    </div>

    <!-- Security Tips -->
    <div class="bg-white/90 backdrop-blur-xl rounded-2xl p-8 shadow-lg shadow-csu-green-dark/10">
      <div class="flex items-center mb-6">
        <div class="w-16 h-16 bg-gradient-to-br from-amber-500 to-amber-600 rounded-xl flex items-center justify-center mr-4 shadow-lg">
          <i class="fas fa-shield-alt text-white text-2xl"></i>
        </div>
        <div>
          <h2 class="text-2xl font-bold text-csu-green-dark">Security Tips</h2>
          <p class="text-gray-600">Keep your account secure</p>
        </div>
      </div>

      <div class="space-y-4">
        <div class="flex items-start gap-3 p-4 bg-gray-50 rounded-lg">
          <i class="fas fa-check-circle text-green-500 text-xl mt-1"></i>
          <div>
            <h4 class="font-semibold text-gray-800 mb-1">Use a strong password</h4>
            <p class="text-sm text-gray-600">Include letters, numbers, and special characters</p>
          </div>
        </div>
        <div class="flex items-start gap-3 p-4 bg-gray-50 rounded-lg">
          <i class="fas fa-check-circle text-green-500 text-xl mt-1"></i>
          <div>
            <h4 class="font-semibold text-gray-800 mb-1">Don't share your password</h4>
            <p class="text-sm text-gray-600">Keep your credentials private and secure</p>
          </div>
        </div>
        <div class="flex items-start gap-3 p-4 bg-gray-50 rounded-lg">
          <i class="fas fa-check-circle text-green-500 text-xl mt-1"></i>
          <div>
            <h4 class="font-semibold text-gray-800 mb-1">Update regularly</h4>
            <p class="text-sm text-gray-600">Change your password periodically for better security</p>
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
const emailLoading = ref(false)
const passwordLoading = ref(false)
const showPassword = ref(false)
const showConfirmPassword = ref(false)

const emailForm = reactive({
  newEmail: ''
})

const passwordForm = reactive({
  newPassword: '',
  confirmPassword: ''
})

const updateEmail = async () => {
  try {
    emailLoading.value = true
    const { error } = await supabase.auth.updateUser({
      email: emailForm.newEmail
    })

    if (error) throw error

    showNotification('Email update requested! Please check your new email for confirmation.')
    emailForm.newEmail = ''
  } catch (error) {
    console.error('Error updating email:', error)
    showNotification(error.message || 'Failed to update email. Please try again.', 'error')
  } finally {
    emailLoading.value = false
  }
}

const updatePassword = async () => {
  try {
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      showNotification('New passwords do not match!', 'error')
      return
    }

    passwordLoading.value = true
    const { error } = await supabase.auth.updateUser({
      password: passwordForm.newPassword
    })

    if (error) throw error

    showNotification('Password updated successfully!')
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
  } catch (error) {
    console.error('Error updating password:', error)
    showNotification(error.message || 'Failed to update password. Please try again.', 'error')
  } finally {
    passwordLoading.value = false
  }
}

onMounted(async () => {
  const { data: { user } } = await supabase.auth.getUser()
  currentUser.value = user
})
</script>

<style scoped>
.account-security {
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
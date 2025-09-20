<template>
  <div class="account-security space-y-8">
    <div class="bg-white rounded-xl shadow-lg p-8">
      <div class="flex items-center mb-6">
        <div class="w-16 h-16 bg-gradient-to-br from-red-500 to-red-600 rounded-full flex items-center justify-center mr-4">
          <i class="fas fa-shield-alt text-white text-2xl"></i>
        </div>
        <div>
          <h2 class="text-2xl font-bold text-green-800">Account Security</h2>
          <p class="text-gray-600">Update your email and password to keep your account secure</p>
        </div>
      </div>

      <!-- Email Update Form -->
      <div class="mb-8 p-6 bg-gray-50 rounded-lg">
        <h3 class="text-lg font-semibold text-gray-800 mb-4">Update Email Address</h3>
        <form @submit.prevent="updateEmail" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Current Email</label>
            <input
              :value="currentUser?.email"
              type="email"
              readonly
              class="w-full px-4 py-3 bg-gray-100 border border-gray-300 rounded-lg text-gray-600"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">New Email Address *</label>
            <input
              v-model="emailForm.newEmail"
              type="email"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent transition-all duration-200"
              placeholder="Enter new email address"
            />
          </div>
          <button
            type="submit"
            :disabled="emailLoading"
            class="px-6 py-3 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-semibold rounded-lg transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <i class="fas fa-envelope mr-2"></i>
            {{ emailLoading ? 'Updating...' : 'Update Email' }}
          </button>
        </form>
      </div>

      <!-- Password Update Form -->
      <div class="p-6 bg-gray-50 rounded-lg">
        <h3 class="text-lg font-semibold text-gray-800 mb-4">Change Password</h3>
        <form @submit.prevent="updatePassword" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Current Password *</label>
            <input
              v-model="passwordForm.currentPassword"
              type="password"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent transition-all duration-200"
              placeholder="Enter current password"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">New Password *</label>
            <input
              v-model="passwordForm.newPassword"
              type="password"
              required
              minlength="6"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent transition-all duration-200"
              placeholder="Enter new password (min. 6 characters)"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Confirm New Password *</label>
            <input
              v-model="passwordForm.confirmPassword"
              type="password"
              required
              minlength="6"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent transition-all duration-200"
              placeholder="Confirm new password"
            />
          </div>
          <button
            type="submit"
            :disabled="passwordLoading || passwordForm.newPassword !== passwordForm.confirmPassword"
            class="px-6 py-3 bg-gradient-to-r from-red-500 to-red-600 hover:from-red-600 hover:to-red-700 text-white font-semibold rounded-lg transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <i class="fas fa-lock mr-2"></i>
            {{ passwordLoading ? 'Updating...' : 'Change Password' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { supabase } from '../../lib/supabase'

const currentUser = ref(null)
const emailLoading = ref(false)
const passwordLoading = ref(false)

const emailForm = reactive({
  newEmail: ''
})

const passwordForm = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
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

const updateEmail = async () => {
  try {
    emailLoading.value = true
    const { error } = await supabase.auth.updateUser({
      email: emailForm.newEmail
    })

    if (error) {
      throw error
    }

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

    if (error) {
      throw error
    }

    showNotification('Password updated successfully!')
    passwordForm.currentPassword = ''
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

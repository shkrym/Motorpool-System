<template>
  <div class="security-settings space-y-6">
    <!-- Header Card -->
    <div class="bg-white dark:bg-[#161b22] rounded-2xl shadow-lg overflow-hidden border border-gray-100 dark:border-[#30363d] transition-colors duration-200">
      <div class="h-32 bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] relative transition-colors duration-200">
        <div class="absolute inset-0 opacity-10">
          <div class="absolute inset-0" style="background-image: url('data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fill-rule=\'evenodd\'%3E%3Cg fill=\'%23ffffff\' fill-opacity=\'1\'%3E%3Cpath d=\'M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zM36 6V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E');"></div>
        </div>
        <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-green-400 via-emerald-400 to-teal-400"></div>
      </div>
      
      <div class="px-8 py-6">
        <div class="flex items-center gap-4">
          <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-green-800 to-green-600 dark:from-[#1a2f23] dark:to-[#0f1e13] flex items-center justify-center shadow-lg">
            <i class="fas fa-shield-alt text-white dark:text-[#3fb950] text-2xl"></i>
          </div>
          <div>
            <h1 class="text-3xl font-bold text-gray-900 dark:text-white transition-colors duration-200">Account Security</h1>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1 transition-colors duration-200">Manage your account credentials and security settings</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Current Account Info -->
    <div class="bg-white dark:bg-[#161b22] rounded-2xl shadow-lg overflow-hidden border border-gray-100 dark:border-[#30363d] transition-colors duration-200">
      <div class="px-8 py-6 border-b border-gray-200 dark:border-[#30363d] bg-gradient-to-r from-gray-50 to-white dark:from-[#0d1117] dark:to-[#161b22] transition-colors duration-200">
        <div class="flex items-center gap-4">
          <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 dark:from-[#2d4a2f] dark:to-[#1a2f23] flex items-center justify-center shadow-lg">
            <i class="fas fa-user-shield text-white text-xl"></i>
          </div>
          <div>
            <h3 class="text-2xl font-bold text-gray-900 dark:text-[#e6edf3] transition-colors duration-200">Current Account</h3>
            <p class="text-sm text-gray-500 dark:text-[#8b949e] mt-1 transition-colors duration-200">Your current login credentials</p>
          </div>
        </div>
      </div>

      <div class="p-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="bg-gradient-to-br from-gray-50 to-white dark:from-[#161b22] dark:to-[#1c2128] rounded-xl p-5 border border-gray-200 dark:border-[#30363d] transition-colors duration-200">
            <div class="flex items-center gap-3 mb-2">
              <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 dark:from-[#2d4a2f] dark:to-[#1a2f23] flex items-center justify-center shadow-md">
                <i class="fas fa-envelope text-white text-sm"></i>
              </div>
              <div>
                <p class="text-xs text-gray-500 dark:text-gray-400 font-medium uppercase tracking-wide transition-colors duration-200">Email Address</p>
                <p class="text-base font-bold text-gray-900 dark:text-white transition-colors duration-200">{{ currentUser?.email || 'Not set' }}</p>
              </div>
            </div>
          </div>

          <div class="bg-gradient-to-br from-gray-50 to-white dark:from-[#161b22] dark:to-[#1c2128] rounded-xl p-5 border border-gray-200 dark:border-[#30363d] transition-colors duration-200">
            <div class="flex items-center gap-3 mb-2">
              <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-green-500 to-green-600 dark:from-[#1a2a1f] dark:to-[#0f1a13] flex items-center justify-center shadow-md">
                <i class="fas fa-calendar text-white text-sm"></i>
              </div>
              <div>
                <p class="text-xs text-gray-500 dark:text-gray-400 font-medium uppercase tracking-wide transition-colors duration-200">Last Updated</p>
                <p class="text-base font-bold text-gray-900 dark:text-white transition-colors duration-200">{{ formatDate(currentUser?.updated_at) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Email Update Section -->
    <div class="bg-white dark:bg-[#161b22] rounded-2xl shadow-lg overflow-hidden border border-gray-100 dark:border-[#30363d] transition-colors duration-200">
      <div class="px-8 py-6 border-b border-gray-200 dark:border-[#30363d] bg-gradient-to-r from-gray-50 to-white dark:from-[#0d1117] dark:to-[#161b22] transition-colors duration-200">
        <div class="flex items-center gap-4">
          <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 dark:from-[#2d4a2f] dark:to-[#1a2f23] flex items-center justify-center shadow-lg">
            <i class="fas fa-envelope text-white text-xl"></i>
          </div>
          <div>
            <h3 class="text-2xl font-bold text-gray-900 dark:text-white transition-colors duration-200">Update Email Address</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1 transition-colors duration-200">Change your account email address</p>
          </div>
        </div>
      </div>

      <form @submit.prevent="updateEmail" class="p-8">
        <div class="space-y-6">
          <div class="bg-gradient-to-br from-gray-50 to-white rounded-xl p-6 border border-gray-200">
            <div class="space-y-5">
              <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 transition-colors duration-200">
                  <i class="fas fa-envelope text-gray-400 mr-2"></i>Current Email
                </label>
                <input
                  :value="currentUser?.email"
                  type="email"
                  readonly
                  class="w-full px-4 py-3 bg-gray-100 dark:bg-gray-600 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-600 dark:text-gray-300 cursor-not-allowed shadow-sm transition-colors duration-200"
                />
              </div>

              <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 transition-colors duration-200">
                  <i class="fas fa-envelope text-gray-400 mr-2"></i>New Email Address <span class="text-red-500">*</span>
                </label>
                <input
                  v-model="emailForm.newEmail"
                  type="email"
                  required
                  class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all shadow-sm"
                  placeholder="Enter new email address"
                />
                <p class="text-xs text-gray-500 mt-2">
                  <i class="fas fa-info-circle mr-1"></i>
                  You'll need to verify your new email address
                </p>
              </div>
            </div>
          </div>

          <div class="flex justify-end">
            <button
              type="submit"
              :disabled="emailLoading || !emailForm.newEmail"
              class="px-6 py-3 text-white font-semibold rounded-xl transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed bg-gradient-to-br from-blue-500 to-blue-600 shadow-lg shadow-blue-500/30"
            >
              <i :class="emailLoading ? 'fas fa-spinner fa-spin' : 'fas fa-paper-plane'" class="mr-2"></i>
              {{ emailLoading ? 'Sending...' : 'Update Email' }}
            </button>
          </div>
        </div>
      </form>
    </div>

    <!-- Password Update Section -->
    <div class="bg-white dark:bg-[#161b22] rounded-2xl shadow-lg overflow-hidden border border-gray-100 dark:border-[#30363d] transition-colors duration-200">
      <div class="px-8 py-6 border-b border-gray-200 dark:border-[#30363d] bg-gradient-to-r from-gray-50 to-white dark:from-[#0d1117] dark:to-[#161b22] transition-colors duration-200">
        <div class="flex items-center gap-4">
          <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-red-500 to-red-600 dark:from-[#1a2a1f] dark:to-[#0f1a13] flex items-center justify-center shadow-lg">
            <i class="fas fa-lock text-white text-xl"></i>
          </div>
          <div>
            <h3 class="text-2xl font-bold text-gray-900 dark:text-white transition-colors duration-200">Change Password</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1 transition-colors duration-200">Update your account password for better security</p>
          </div>
        </div>
      </div>

      <form @submit.prevent="updatePassword" class="p-8">
        <div class="space-y-6">
          <div class="bg-gradient-to-br from-gray-50 to-white dark:from-gray-800 dark:to-gray-900 rounded-xl p-6 border border-gray-200 dark:border-gray-700 transition-colors duration-200">
            <div class="space-y-5">
              <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 transition-colors duration-200">
                  <i class="fas fa-key text-gray-400 mr-2"></i>New Password <span class="text-red-500">*</span>
                </label>
                <div class="relative">
                  <input
                    v-model="passwordForm.newPassword"
                    :type="showPassword ? 'text' : 'password'"
                    required
                    minlength="8"
                    class="w-full px-4 py-3 pr-12 border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all shadow-sm"
                    placeholder="Enter new password (min. 8 characters)"
                  />
                  <button
                    type="button"
                    @click="showPassword = !showPassword"
                    class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700 transition-colors"
                  >
                    <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                  </button>
                </div>
                <!-- Password Strength Indicator -->
                <div v-if="passwordForm.newPassword" class="mt-3 space-y-2">
                  <div class="flex items-center gap-2">
                    <div class="flex-1 h-2 bg-gray-200 rounded-full overflow-hidden">
                      <div 
                        :class="getPasswordStrengthClass()"
                        class="h-full transition-all duration-300"
                        :style="{ width: getPasswordStrengthWidth() }"
                      ></div>
                    </div>
                    <span :class="getPasswordStrengthTextClass()" class="text-xs font-semibold">
                      {{ getPasswordStrengthText() }}
                    </span>
                  </div>
                  <div class="space-y-1">
                    <p :class="hasMinLength() ? 'text-green-600' : 'text-gray-400'" class="text-xs flex items-center gap-1">
                      <i :class="hasMinLength() ? 'fas fa-check-circle' : 'fas fa-circle'" class="text-xs"></i>
                      At least 8 characters
                    </p>
                    <p :class="hasUppercase() ? 'text-green-600' : 'text-gray-400'" class="text-xs flex items-center gap-1">
                      <i :class="hasUppercase() ? 'fas fa-check-circle' : 'fas fa-circle'" class="text-xs"></i>
                      Contains uppercase letter
                    </p>
                    <p :class="hasNumber() ? 'text-green-600' : 'text-gray-400'" class="text-xs flex items-center gap-1">
                      <i :class="hasNumber() ? 'fas fa-check-circle' : 'fas fa-circle'" class="text-xs"></i>
                      Contains number
                    </p>
                    <p :class="hasSpecialChar() ? 'text-green-600' : 'text-gray-400'" class="text-xs flex items-center gap-1">
                      <i :class="hasSpecialChar() ? 'fas fa-check-circle' : 'fas fa-circle'" class="text-xs"></i>
                      Contains special character
                    </p>
                  </div>
                </div>
              </div>

              <div class="space-y-2">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 transition-colors duration-200">
                  <i class="fas fa-lock text-gray-400 mr-2"></i>Confirm New Password <span class="text-red-500">*</span>
                </label>
                <div class="relative">
                  <input
                    v-model="passwordForm.confirmPassword"
                    :type="showConfirmPassword ? 'text' : 'password'"
                    required
                    minlength="8"
                    class="w-full px-4 py-3 pr-12 border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all shadow-sm"
                    placeholder="Confirm new password"
                  />
                  <button
                    type="button"
                    @click="showConfirmPassword = !showConfirmPassword"
                    class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700 transition-colors"
                  >
                    <i :class="showConfirmPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                  </button>
                </div>
                <p v-if="passwordForm.newPassword && passwordForm.confirmPassword && passwordForm.newPassword !== passwordForm.confirmPassword" class="text-red-500 text-sm flex items-center gap-1 mt-2">
                  <i class="fas fa-exclamation-circle"></i>
                  Passwords do not match
                </p>
                <p v-else-if="passwordForm.newPassword && passwordForm.confirmPassword && passwordForm.newPassword === passwordForm.confirmPassword" class="text-green-600 text-sm flex items-center gap-1 mt-2">
                  <i class="fas fa-check-circle"></i>
                  Passwords match
                </p>
              </div>
            </div>
          </div>

          <div class="flex justify-end">
            <button
              type="submit"
              :disabled="passwordLoading || passwordForm.newPassword !== passwordForm.confirmPassword || !isPasswordStrong()"
              class="px-6 py-3 text-white font-semibold rounded-xl transition-all duration-200 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed bg-gradient-to-br from-red-500 to-red-600 shadow-lg shadow-red-500/30"
            >
              <i :class="passwordLoading ? 'fas fa-spinner fa-spin' : 'fas fa-shield-alt'" class="mr-2"></i>
              {{ passwordLoading ? 'Updating...' : 'Change Password' }}
            </button>
          </div>
        </div>
      </form>
    </div>

    <!-- Security Best Practices -->
    <div class="bg-white dark:bg-[#161b22] rounded-2xl shadow-lg overflow-hidden border border-gray-100 dark:border-[#30363d] transition-colors duration-200">
      <div class="px-8 py-6 border-b border-gray-200 dark:border-[#30363d] bg-gradient-to-r from-gray-50 to-white dark:from-[#0d1117] dark:to-[#161b22] transition-colors duration-200">
        <div class="flex items-center gap-4">
          <div class="w-14 h-14 rounded-xl bg-gradient-to-br from-amber-500 to-amber-600 dark:from-[#6fc276] dark:to-[#3fb950] flex items-center justify-center shadow-lg">
            <i class="fas fa-lightbulb text-white text-xl"></i>
          </div>
          <div>
            <h3 class="text-2xl font-bold text-gray-900 dark:text-white transition-colors duration-200">Security Best Practices</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1 transition-colors duration-200">Tips to keep your account secure</p>
          </div>
        </div>
      </div>

      <div class="p-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="bg-gradient-to-br from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20 rounded-xl p-5 border border-green-200 dark:border-green-800 transition-colors duration-200">
            <div class="flex items-start gap-3">
              <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-green-500 to-green-600 flex items-center justify-center shadow-md flex-shrink-0">
                <i class="fas fa-key text-white text-sm"></i>
              </div>
              <div>
                <h4 class="font-bold text-gray-900 dark:text-white mb-1 transition-colors duration-200">Strong Password</h4>
                <p class="text-sm text-gray-600 dark:text-gray-300 transition-colors duration-200">Use a mix of letters, numbers, and special characters (min. 8 characters)</p>
              </div>
            </div>
          </div>

          <div class="bg-gradient-to-br from-blue-50 to-cyan-50 dark:from-blue-900/20 dark:to-cyan-900/20 rounded-xl p-5 border border-blue-200 dark:border-blue-800 transition-colors duration-200">
            <div class="flex items-start gap-3">
              <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-md flex-shrink-0">
                <i class="fas fa-user-lock text-white text-sm"></i>
              </div>
              <div>
                <h4 class="font-bold text-gray-900 dark:text-white mb-1 transition-colors duration-200">Keep it Private</h4>
                <p class="text-sm text-gray-600 dark:text-gray-300 transition-colors duration-200">Never share your password with anyone, including support staff</p>
              </div>
            </div>
          </div>

          <div class="bg-gradient-to-br from-purple-50 to-pink-50 dark:from-purple-900/20 dark:to-pink-900/20 rounded-xl p-5 border border-purple-200 dark:border-purple-800 transition-colors duration-200">
            <div class="flex items-start gap-3">
              <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center shadow-md flex-shrink-0">
                <i class="fas fa-sync-alt text-white text-sm"></i>
              </div>
              <div>
                <h4 class="font-bold text-gray-900 dark:text-white mb-1 transition-colors duration-200">Regular Updates</h4>
                <p class="text-sm text-gray-600 dark:text-gray-300 transition-colors duration-200">Change your password every 3-6 months for optimal security</p>
              </div>
            </div>
          </div>

          <div class="bg-gradient-to-br from-red-50 to-orange-50 dark:from-red-900/20 dark:to-orange-900/20 rounded-xl p-5 border border-red-200 dark:border-red-800 transition-colors duration-200">
            <div class="flex items-start gap-3">
              <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-red-500 to-red-600 flex items-center justify-center shadow-md flex-shrink-0">
                <i class="fas fa-ban text-white text-sm"></i>
              </div>
              <div>
                <h4 class="font-bold text-gray-900 dark:text-white mb-1 transition-colors duration-200">Avoid Reuse</h4>
                <p class="text-sm text-gray-600 dark:text-gray-300 transition-colors duration-200">Don't use the same password across multiple accounts</p>
              </div>
            </div>
          </div>

          <div class="bg-gradient-to-br from-teal-50 to-cyan-50 dark:from-teal-900/20 dark:to-cyan-900/20 rounded-xl p-5 border border-teal-200 dark:border-teal-800 transition-colors duration-200">
            <div class="flex items-start gap-3">
              <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-teal-500 to-teal-600 flex items-center justify-center shadow-md flex-shrink-0">
                <i class="fas fa-desktop text-white text-sm"></i>
              </div>
              <div>
                <h4 class="font-bold text-gray-900 dark:text-white mb-1 transition-colors duration-200">Secure Devices</h4>
                <p class="text-sm text-gray-600 dark:text-gray-300 transition-colors duration-200">Always log out from shared or public computers</p>
              </div>
            </div>
          </div>

          <div class="bg-gradient-to-br from-indigo-50 to-purple-50 dark:from-indigo-900/20 dark:to-purple-900/20 rounded-xl p-5 border border-indigo-200 dark:border-indigo-800 transition-colors duration-200">
            <div class="flex items-start gap-3">
              <div class="w-10 h-10 rounded-lg bg-gradient-to-br from-indigo-500 to-indigo-600 flex items-center justify-center shadow-md flex-shrink-0">
                <i class="fas fa-bell text-white text-sm"></i>
              </div>
              <div>
                <h4 class="font-bold text-gray-900 dark:text-white mb-1 transition-colors duration-200">Stay Alert</h4>
                <p class="text-sm text-gray-600 dark:text-gray-300 transition-colors duration-200">Report any suspicious activity immediately to IT support</p>
              </div>
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

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Password validation helpers
const hasMinLength = () => passwordForm.newPassword.length >= 8
const hasUppercase = () => /[A-Z]/.test(passwordForm.newPassword)
const hasNumber = () => /[0-9]/.test(passwordForm.newPassword)
const hasSpecialChar = () => /[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(passwordForm.newPassword)

const getPasswordStrength = () => {
  const password = passwordForm.newPassword
  let strength = 0
  
  if (password.length >= 8) strength++
  if (password.length >= 12) strength++
  if (/[a-z]/.test(password)) strength++
  if (/[A-Z]/.test(password)) strength++
  if (/[0-9]/.test(password)) strength++
  if (/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(password)) strength++
  
  return strength
}

const getPasswordStrengthWidth = () => {
  const strength = getPasswordStrength()
  return `${(strength / 6) * 100}%`
}

const getPasswordStrengthClass = () => {
  const strength = getPasswordStrength()
  if (strength <= 2) return 'bg-red-500'
  if (strength <= 4) return 'bg-yellow-500'
  return 'bg-green-500'
}

const getPasswordStrengthText = () => {
  const strength = getPasswordStrength()
  if (strength <= 2) return 'Weak'
  if (strength <= 4) return 'Medium'
  return 'Strong'
}

const getPasswordStrengthTextClass = () => {
  const strength = getPasswordStrength()
  if (strength <= 2) return 'text-red-600'
  if (strength <= 4) return 'text-yellow-600'
  return 'text-green-600'
}

const isPasswordStrong = () => {
  return getPasswordStrength() >= 4
}

const updateEmail = async () => {
  try {
    emailLoading.value = true
    
    const { error } = await supabase.auth.updateUser({
      email: emailForm.newEmail
    })

    if (error) throw error

    showNotification('Email update confirmation sent! Please check your new email inbox to verify.', 'success')
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
      showNotification('Passwords do not match!', 'error')
      return
    }

    if (!isPasswordStrong()) {
      showNotification('Please use a stronger password!', 'error')
      return
    }

    passwordLoading.value = true
    
    const { error } = await supabase.auth.updateUser({
      password: passwordForm.newPassword
    })

    if (error) throw error

    showNotification('Password updated successfully!', 'success')
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
.security-settings {
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
<template>
  <div class="min-h-screen bg-gradient-to-br from-green-900 to-green-600 flex items-center justify-center p-5 font-sans">
    <div class="w-full max-w-lg">
      <!-- Logo/Header Section -->
      <div class="text-center mb-8">
        <div class="w-16 h-16 bg-white/10 rounded-full flex items-center justify-center mx-auto mb-4">
          <i class="fas fa-car text-yellow-500 text-2xl"></i>
        </div>
        <h1 class="text-white text-3xl font-bold mb-3 drop-shadow-md">
          {{ isLogin ? 'Welcome Back' : 'Create Account' }}
        </h1>
        <p class="text-white/80 text-base font-normal">
          CSU Motorpool Management System
        </p>
      </div>

      <div class="bg-white/95 backdrop-blur-xl rounded-2xl p-8 shadow-2xl border border-white/20">
        <form @submit.prevent="handleSubmit" class="flex flex-col gap-5">
          <!-- Registration-only fields -->
          <div v-if="!isLogin" class="flex flex-col gap-4 pb-4 border-b border-gray-200 mb-2">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="flex flex-col">
                <label for="employeeId" class="font-semibold text-gray-700 mb-1.5 text-sm">Employee ID *</label>
                <input 
                  id="employeeId"
                  v-model="form.employeeId" 
                  type="text" 
                  placeholder="e.g. EMP-001" 
                  required 
                  class="p-3 border-2 border-gray-300 rounded-lg text-sm transition-all duration-300 bg-white hover:border-gray-400 focus:outline-none focus:border-green-800 focus:ring-2 focus:ring-green-800/10"
                />
              </div>
              
              <div class="flex flex-col">
                <label for="fullName" class="font-semibold text-gray-700 mb-1.5 text-sm">Full Name *</label>
                <input 
                  id="fullName"
                  v-model="form.fullName" 
                  type="text" 
                  placeholder="Enter your full name" 
                  required 
                  class="p-3 border-2 border-gray-300 rounded-lg text-sm transition-all duration-300 bg-white hover:border-gray-400 focus:outline-none focus:border-green-800 focus:ring-2 focus:ring-green-800/10"
                />
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="flex flex-col">
                <label for="position" class="font-semibold text-gray-700 mb-1.5 text-sm">Position *</label>
                <select 
                  id="position" 
                  v-model="form.position" 
                  required
                  class="p-3 border-2 border-gray-300 rounded-lg text-sm transition-all duration-300 bg-white hover:border-gray-400 focus:outline-none focus:border-green-800 focus:ring-2 focus:ring-green-800/10"
                >
                  <option disabled value="">Select Position</option>
                  <option value="staff">Staff</option>
                  <option value="admin">Admin</option>
                </select>
              </div>
              
              <div class="flex flex-col">
                <label for="department" class="font-semibold text-gray-700 mb-1.5 text-sm">Department *</label>
                <select 
                  id="department" 
                  v-model="form.department" 
                  required
                  class="p-3 border-2 border-gray-300 rounded-lg text-sm transition-all duration-300 bg-white hover:border-gray-400 focus:outline-none focus:border-green-800 focus:ring-2 focus:ring-green-800/10"
                >
                  <option disabled value="">Select Department</option>
                  <option value="Admin">Admin</option>
                  <option value="Finance">Finance</option>
                  <option value="IT">IT</option>
                </select>
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="flex flex-col">
                <label for="phone" class="font-semibold text-gray-700 mb-1.5 text-sm">Phone Number</label>
                <input 
                  id="phone"
                  v-model="form.phone" 
                  type="tel" 
                  placeholder="09XX-XXX-XXXX" 
                  class="p-3 border-2 border-gray-300 rounded-lg text-sm transition-all duration-300 bg-white hover:border-gray-400 focus:outline-none focus:border-green-800 focus:ring-2 focus:ring-green-800/10"
                />
              </div>
              
              <div class="flex flex-col">
                <label for="officePhone" class="font-semibold text-gray-700 mb-1.5 text-sm">Office Phone</label>
                <input 
                  id="officePhone"
                  v-model="form.officePhone" 
                  type="tel" 
                  placeholder="Office extension" 
                  class="p-3 border-2 border-gray-300 rounded-lg text-sm transition-all duration-300 bg-white hover:border-gray-400 focus:outline-none focus:border-green-800 focus:ring-2 focus:ring-green-800/10"
                />
              </div>
            </div>
          </div>

          <!-- Login fields -->
          <div class="flex flex-col">
            <label for="email" class="font-semibold text-gray-700 mb-1.5 text-sm">University Email *</label>
            <div class="relative flex items-center">
              <i class="fas fa-envelope absolute left-3 text-gray-500 text-sm"></i>
              <input 
                id="email"
                v-model="form.email" 
                type="email" 
                placeholder="your.name@carsu.edu.ph" 
                required 
                class="pl-10 pr-4 py-3 border-2 border-gray-300 rounded-lg text-sm transition-all duration-300 bg-white hover:border-gray-400 focus:outline-none focus:border-green-800 focus:ring-2 focus:ring-green-800/10 w-full"
              />
            </div>
          </div>

          <!-- Password Field -->
          <div class="flex flex-col">
            <label for="password" class="font-semibold text-gray-700 mb-1.5 text-sm">Password *</label>
            <div class="relative flex items-center">
              <i class="fas fa-lock absolute left-3 text-gray-500 text-sm"></i>
              <input
                id="password"
                :type="showPassword ? 'text' : 'password'"
                v-model="form.password"
                placeholder="Enter your password"
                required
                class="pl-10 pr-10 py-3 border-2 border-gray-300 rounded-lg text-sm transition-all duration-300 bg-white hover:border-gray-400 focus:outline-none focus:border-green-800 focus:ring-2 focus:ring-green-800/10 w-full"
              />
              <button 
                type="button"
                class="absolute right-3 text-gray-500 hover:text-green-600 transition-colors duration-200"
                @click="showPassword = !showPassword"
              >
                <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'" class="text-sm"></i>
              </button>
            </div>
            <div v-if="!isLogin" class="text-xs text-gray-500 mt-1.5 leading-relaxed">
              Password must be at least 8 characters with 1 uppercase letter and 1 special character
            </div>
          </div>

          <button 
            type="submit" 
            :disabled="loading"
            class="w-full py-3 px-6 bg-gradient-to-r from-green-800 to-green-600 hover:from-green-700 hover:to-green-500 text-white border-none rounded-lg text-sm font-semibold cursor-pointer transition-all duration-300 flex items-center justify-center gap-2 shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
            style="background: linear-gradient(135deg, #0A400C, #155c1a);"
          >
            <i v-if="loading" class="fas fa-spinner fa-spin"></i>
            <i v-else :class="isLogin ? 'fas fa-sign-in-alt' : 'fas fa-user-plus'"></i>
            {{ loading ? 'Please wait...' : (isLogin ? 'Sign In' : 'Create Account') }}
          </button>
        </form>

        <!-- Forgot password link -->
        <div v-if="isLogin" class="text-center my-4">
          <button 
            @click="resetPassword" 
            class="bg-transparent border-none text-gray-700 cursor-pointer text-sm font-medium py-2 px-4 rounded-lg transition-all duration-200 inline-flex items-center gap-2 hover:bg-gray-50 hover:text-green-700"
          >
            <i class="fas fa-key text-xs"></i>
            Forgot your password?
          </button>
        </div>

        <!-- Toggle between login/register -->
        <div class="text-center pt-4 border-t border-gray-200 mt-4">
          <p class="text-sm text-gray-600 m-0">
            <span v-if="isLogin">Don't have an account?</span>
            <span v-else>Already have an account?</span>
            <button 
              @click="toggleMode" 
              class="bg-transparent border-none text-green-700 cursor-pointer font-semibold text-sm py-1 px-2 rounded-md transition-all duration-200 ml-1 hover:bg-green-50"
              style="color: #0A400C;"
            >
              {{ isLogin ? 'Register here' : 'Sign in instead' }}
            </button>
          </p>
        </div>

        <!-- Error/Success message -->
        <div 
          v-if="message" 
          class="mt-4 p-3 rounded-lg flex items-center gap-2 text-sm font-medium transition-all duration-300"
          :class="messageType === 'error' 
            ? 'bg-red-50 text-red-700 border border-red-200' 
            : 'bg-green-50 text-green-700 border border-green-200'"
        >
          <i :class="messageType === 'error' ? 'fas fa-exclamation-triangle' : 'fas fa-check-circle'" class="text-sm"></i>
          <span>{{ message }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'  
import { supabase } from '../lib/supabase.js'

export default {
  name: 'Auth',
  setup() {
    const router = useRouter()
    const isLogin = ref(true)
    const showPassword = ref(false)
    const loading = ref(false)
    const message = ref('')
    const messageType = ref('error')

    const form = reactive({
      email: '',
      password: '',
      employeeId: '',
      fullName: '',
      position: '',
      department: '',
      phone: '',
      officePhone: ''
    })

    // Password validation regex
    const passwordRegex = /^(?=.*[A-Z])(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]).{8,}$/

    const resetForm = () => {
      Object.assign(form, {
        email: '',
        password: '',
        employeeId: '',
        fullName: '',
        position: '',
        department: '',
        phone: '',
        officePhone: ''
      })
    }

    const showMessage = (msg, type = 'error') => {
      message.value = msg
      messageType.value = type
      setTimeout(() => {
        message.value = ''
      }, 5000)
    }

    const toggleMode = () => {
      isLogin.value = !isLogin.value
      message.value = ''
      // Keep email but reset other fields when switching modes
      const currentEmail = form.email
      resetForm()
      form.email = currentEmail
    }

    const handleLogin = async () => {
      const { data, error } = await supabase.auth.signInWithPassword({
        email: form.email,
        password: form.password
      })

      if (error) {
        showMessage(error.message, 'error')
        return false
      }

      showMessage('Login successful! Welcome back.', 'success')
      setTimeout(() => {
        router.push('/dashboard')
      }, 1000)
      return true
    }

    const handleRegistration = async () => {
      // Validate password
      if (!passwordRegex.test(form.password)) {
        showMessage('Password must be at least 8 characters with 1 uppercase letter and 1 special character', 'error')
        return false
      }

      const { data, error } = await supabase.auth.signUp({
        email: form.email,
        password: form.password,
        options: {
          data: {
            employee_id: form.employeeId,
            full_name: form.fullName,
            position: form.position,
            department: form.department,
            phone: form.phone,
            office_phone: form.officePhone,
            role: form.position === 'admin' ? 'admin' : 'staff'
          }
        }
      })

      if (error) {
        showMessage(error.message, 'error')
        return false
      }

      if (data.user && !data.user.email_confirmed_at) {
        showMessage('Registration successful! Please check your email to confirm your account.', 'success')
      } else {
        showMessage('Registration successful! You can now sign in.', 'success')
        setTimeout(() => {
          toggleMode() // Switch to login mode
        }, 2000)
      }
      return true
    }

    const handleSubmit = async () => {
      if (loading.value) return

      loading.value = true
      message.value = ''

      try {
        if (isLogin.value) {
          await handleLogin()
        } else {
          await handleRegistration()
        }
      } catch (error) {
        console.error('Auth error:', error)
        showMessage('An unexpected error occurred. Please try again.', 'error')
      } finally {
        loading.value = false
      }
    }

    const resetPassword = async () => {
      if (!form.email) {
        showMessage('Please enter your email address first.', 'error')
        return
      }

      loading.value = true
      try {
        const { error } = await supabase.auth.resetPasswordForEmail(form.email, {
          redirectTo: `${window.location.origin}/reset-password`
        })

        if (error) {
          showMessage(error.message, 'error')
        } else {
          showMessage('Password reset email sent! Check your inbox.', 'success')
        }
      } catch (error) {
        showMessage('Error sending reset email. Please try again.', 'error')
      } finally {
        loading.value = false
      }
    }

    return {
      isLogin,
      showPassword,
      loading,
      message,
      messageType,
      form,
      toggleMode,
      handleSubmit,
      resetPassword
    }
  }
}
</script>

<style scoped>
/* Animations */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.bg-white\/95 {
  animation: fadeIn 0.6s ease-out;
}

/* Focus states */
input:focus, select:focus {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(10, 64, 12, 0.15);
}

button:hover:not(:disabled) {
  transform: translateY(-1px);
}

button:active:not(:disabled) {
  transform: translateY(0);
}
</style>
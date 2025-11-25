<template>
  <div class="flex h-screen bg-gradient-to-br from-green-50 via-emerald-100 to-teal-100 dark:from-[#0d1117] dark:via-[#0d1117] dark:to-[#161b22] font-sanscan transition-colors duration-200">
    <Navbar 
      :sidebarCollapsed="sidebarCollapsed"
      :sidebarOpen="sidebarOpen"
      @toggle-sidebar="toggleSidebar"
      @close-sidebar="closeSidebar"
      @open-sidebar="openSidebar"
      @menu-click="handleMenuClick"
    />

    <main class="flex flex-1 flex-col transition-all duration-300 ease-in-out min-w-0" :class="{ '!ml-0': sidebarCollapsed || !sidebarOpen }">
      <div class="sticky top-0 z-50">
        <PageHeader
          icon="fas fa-cog"
          title="Settings"
          subtitle="Manage your account and preferences"
        >
          <template #leading>
            <button 
              @click="openSidebar" 
              class="btn btn-secondary lg:hidden"
              v-if="!sidebarOpen"
            >
              <i class="fas fa-bars"></i>
            </button>
          </template>
          <template #actions>
            <div class="hidden sm:flex items-center gap-3">
              <div class="flex items-center gap-2 px-3 py-2 bg-white/10 rounded-lg">
                <div class="w-2 h-2 bg-green-300 rounded-full animate-pulse"></div>
                <span class="text-xs text-green-100 font-medium">System Active</span>
              </div>
              <div class="flex items-center py-2 px-3 bg-white/15 rounded-lg font-semibold text-xs text-white">
                <i class="fas fa-user-circle mr-2 text-sm text-emerald-300"></i>
                {{ userProfile?.full_name || 'Admin' }}
              </div>
            </div>
          </template>
        </PageHeader>
      </div>
      
      <!-- Tab Navigation -->
      <div class="bg-white dark:bg-[#0d1117] border-b border-gray-200 dark:border-[#30363d] px-8 pt-2 transition-colors duration-200">
        <div class="flex gap-2 overflow-x-auto">
          <button
            @click="activeTab = 'profile'"
            :class="['px-6 py-3 font-semibold text-sm transition-all duration-200 flex items-center justify-center gap-2 rounded-t-lg',
                      activeTab === 'profile' ? 'bg-gradient-to-br from-green-800 to-green-600 dark:from-[#238636] dark:to-[#2ea043] text-white' : 'text-gray-600 dark:text-[#8b949e] hover:bg-gray-50 dark:hover:bg-[#161b22]']"
          >
            <i class="fas fa-user-circle text-lg"></i>
            Profile
          </button>
          <button
            @click="activeTab = 'security'"
            :class="['px-6 py-3 font-semibold text-sm transition-all duration-200 flex items-center justify-center gap-2 rounded-t-lg',
                      activeTab === 'security' ? 'bg-gradient-to-br from-green-800 to-green-600 dark:from-[#238636] dark:to-[#2ea043] text-white' : 'text-gray-600 dark:text-[#8b949e] hover:bg-gray-50 dark:hover:bg-[#161b22]']"
          >
            <i class="fas fa-shield-alt text-lg"></i>
            Security
          </button>
          <button
            @click="activeTab = 'theme'"
            :class="['px-6 py-3 font-semibold text-sm transition-all duration-200 flex items-center justify-center gap-2 rounded-t-lg',
                      activeTab === 'theme' ? 'bg-gradient-to-br from-green-800 to-green-600 dark:from-[#238636] dark:to-[#2ea043] text-white' : 'text-gray-600 dark:text-[#8b949e] hover:bg-gray-50 dark:hover:bg-[#161b22]']"
          >
            <i class="fas fa-palette text-lg"></i>
            Theme
          </button>
        </div>
      </div>
    
      <!-- Content -->
      <div class="flex-1 p-8 overflow-y-auto bg-green-100/80 dark:bg-[#0d1117] transition-colors duration-200">
        <div class="max-w-7xl mx-auto">
          <div class="tab-content">
            <div v-if="activeTab === 'profile'" class="space-y-6">
              <ProfileSettings />
            </div>
            <div v-if="activeTab === 'security'" class="space-y-6">
              <SecuritySettings />
            </div>
            <div v-if="activeTab === 'theme'" class="space-y-6">
              <ThemeSettings />
            </div>
          </div>
        </div>
      </div>
    </main>

    <div
      v-if="notification.show"
      :class="[
        'fixed bottom-4 right-4 p-4 rounded-lg shadow-xl z-50 transition-all duration-300 flex items-center gap-3',
        notification.type === 'success' ? 'bg-green-500 text-white' : 'bg-red-500 text-white'
      ]"
    >
      <i :class="notification.type === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-circle'" class="text-xl"></i>
      <span class="font-medium">{{ notification.message }}</span>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted, provide } from 'vue'
import { supabase } from '../lib/supabase'
import Navbar from './Navbar.vue'
import PageHeader from '../components/PageHeader.vue'
import ProfileSettings from './settings/Profile.vue'
import SecuritySettings from './settings/Security.vue'
import ThemeSettings from './settings/Theme.vue'

export default {
  name: 'Settings',
  components: {
    Navbar,
    PageHeader,
    ProfileSettings,
    SecuritySettings,
    ThemeSettings
  },
  setup() {
    const sidebarCollapsed = ref(false)
    const sidebarOpen = ref(true)
    const userProfile = ref(null)
    const activeTab = ref('profile')

    const notification = reactive({
      show: false,
      message: '',
      type: 'success'
    })

    // Provide notification function to child components
    const showNotification = (message, type = 'success') => {
      notification.message = message
      notification.type = type
      notification.show = true
      setTimeout(() => {
        notification.show = false
      }, 4000)
    }

    provide('showNotification', showNotification)

    // Sidebar methods
    const toggleSidebar = () => {
      sidebarCollapsed.value = !sidebarCollapsed.value
    }

    const closeSidebar = () => {
      if (window.innerWidth <= 768) {
        sidebarOpen.value = false
      } else {
        sidebarCollapsed.value = true
      }
    }

    const openSidebar = () => {
      sidebarOpen.value = true
      if (window.innerWidth > 768) {
        sidebarCollapsed.value = false
      }
    }

    const handleMenuClick = () => {
      if (window.innerWidth <= 768) {
        sidebarOpen.value = false
      }
    }

    const handleResize = () => {
      if (window.innerWidth > 768) {
        sidebarOpen.value = true
      } else if (window.innerWidth <= 768) {
        sidebarCollapsed.value = false
      }
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
          } else {
            userProfile.value = profile
          }
        }
      } catch (error) {
        console.error('Error loading user profile:', error)
      }
    }

    onMounted(async () => {
      await loadUserProfile()
      window.addEventListener('resize', handleResize)
      handleResize()
    })

    return {
      sidebarCollapsed,
      sidebarOpen,
      userProfile,
      activeTab,
      notification,
      toggleSidebar,
      closeSidebar,
      openSidebar,
      handleMenuClick
    }
  }
}
</script>

<style scoped>
.tab-content {
  animation: fadeIn 0.3s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
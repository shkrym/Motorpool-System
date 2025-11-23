<template>
  <div class="flex h-screen bg-gradient-to-br from-green-50 to-green-100 font-inter overflow-hidden">
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

    <!-- Main Content -->
    <main class="flex flex-1 flex-col overflow-hidden transition-all duration-300 ease-in-out min-w-0" :class="{ '!ml-0': sidebarCollapsed || !sidebarOpen }">
      <div class="sticky top-0 z-10">
        <PageHeader
          icon="fas fa-cog"
          title="Settings"
          subtitle="Manage your account preferences"
        >
          <template #leading>
            <button
              @click="openSidebar"
              class="lg:hidden btn btn-secondary py-2 px-3"
              v-if="!sidebarOpen"
            >
              <i class="fas fa-bars"></i>
            </button>
          </template>
          <template #actions>
            <div class="chip text-xs sm:text-sm">
              Currently viewing: <span class="font-semibold ml-1 capitalize">{{ activeTab }}</span>
            </div>
          </template>
        </PageHeader>

        <!-- Tab Navigation (Desktop) -->
        <div class="hidden sm:flex items-center bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden mx-4 mt-2 mb-0">
          <button
            @click="activeTab = 'profile'"
            :class="[
              'px-6 py-3 font-semibold text-sm transition-all duration-200 flex items-center justify-center gap-2 border-r border-gray-200',
              activeTab === 'profile' ? 'bg-green-800 text-white' : 'text-gray-600 hover:bg-gray-50'
            ]"
          >
            <i class="fas fa-user-circle text-lg"></i>
            Profile
          </button>
          <button
            @click="activeTab = 'security'"
            :class="[
              'px-6 py-3 font-semibold text-sm transition-all duration-200 flex items-center justify-center gap-2 border-r border-gray-200',
              activeTab === 'security' ? 'bg-green-800 text-white' : 'text-gray-600 hover:bg-gray-50'
            ]"
          >
            <i class="fas fa-shield-alt text-lg"></i>
            Security
          </button>
          <button
            @click="activeTab = 'theme'"
            :class="[
              'px-6 py-3 font-semibold text-sm transition-all duration-200 flex items-center justify-center gap-2',
              activeTab === 'theme' ? 'bg-green-800 text-white' : 'text-gray-600 hover:bg-gray-50'
            ]"
          >
            <i class="fas fa-palette text-lg"></i>
            Theme
          </button>
        </div>
      </div>

      <!-- Mobile Tab Navigation -->
      <div class="sm:hidden bg-white border-b border-gray-200 px-4 py-2 mx-4 mt-2 mb-0 rounded-xl">
        <div class="flex gap-2">
          <button
            @click="activeTab = 'profile'"
            :class="[
              'flex-1 px-4 py-3 font-semibold text-sm rounded-lg transition-all duration-200 flex items-center justify-center gap-2',
              activeTab === 'profile' ? 'bg-green-800 text-white shadow-md' : 'text-gray-600 hover:bg-gray-50'
            ]"
            :style="activeTab === 'profile' ? 'background-color: #0A400C;' : ''"
          >
            <i class="fas fa-user-circle"></i>
            <span class="hidden xs:inline">Profile</span>
          </button>
          <button
            @click="activeTab = 'security'"
            :class="[
              'flex-1 px-4 py-3 font-semibold text-sm rounded-lg transition-all duration-200 flex items-center justify-center gap-2',
              activeTab === 'security' ? 'bg-green-800 text-white shadow-md' : 'text-gray-600 hover:bg-gray-50'
            ]"
            :style="activeTab === 'security' ? 'background-color: #0A400C;' : ''"
          >
            <i class="fas fa-shield-alt"></i>
            <span class="hidden xs:inline">Security</span>
          </button>
          <button
            @click="activeTab = 'theme'"
            :class="[
              'flex-1 px-4 py-3 font-semibold text-sm rounded-lg transition-all duration-200 flex items-center justify-center gap-2',
              activeTab === 'theme' ? 'bg-green-800 text-white shadow-md' : 'text-gray-600 hover:bg-gray-50'
            ]"
            :style="activeTab === 'theme' ? 'background-color: #0A400C;' : ''"
          >
            <i class="fas fa-palette"></i>
            <span class="hidden xs:inline">Theme</span>
          </button>
        </div>
      </div>
      
      <!-- Content Area -->
      <div class="flex-1 p-4 sm:p-6 lg:p-8 overflow-y-auto">
        <div class="max-w-6xl mx-auto">
          <div class="tab-content">
            <transition name="fade" mode="out-in">
              <div v-if="activeTab === 'profile'" key="profile" class="space-y-6">
                <ProfileSettings />
              </div>
              <div v-else-if="activeTab === 'security'" key="security" class="space-y-6">
                <SecuritySettings />
              </div>
              <div v-else-if="activeTab === 'theme'" key="theme" class="space-y-6">
                <ThemeSettings />
              </div>
            </transition>
          </div>
        </div>
      </div>
    </main>

    <!-- Notification Toast -->
    <div
      v-if="notification.show"
      :class="[
        'fixed bottom-4 right-4 p-4 rounded-xl shadow-2xl z-50 transition-all duration-300 flex items-center gap-3 min-w-[280px] backdrop-blur-xl',
        notification.type === 'success' ? 'bg-green-500/95 text-white border border-green-400' : 'bg-red-500/95 text-white border border-red-400'
      ]"
    >
      <div :class="[
        'w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0',
        notification.type === 'success' ? 'bg-white/20' : 'bg-white/20'
      ]">
        <i :class="notification.type === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-circle'" class="text-xl"></i>
      </div>
      <div class="flex-1">
        <p class="font-semibold text-sm">{{ notification.type === 'success' ? 'Success!' : 'Error!' }}</p>
        <p class="text-sm opacity-90">{{ notification.message }}</p>
      </div>
      <button 
        @click="notification.show = false"
        class="text-white/80 hover:text-white transition-colors p-2 rounded-lg hover:bg-white/10"
      >
        <i class="fas fa-times"></i>
      </button>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted, provide } from 'vue'
import { useSidebar } from '../composables/useSidebar'
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
    const { sidebarCollapsed, sidebarOpen, toggleSidebar, closeSidebar, openSidebar, handleMenuClick } = useSidebar()
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

    // Sidebar methods are now from useSidebar composable

    const handleResize = () => {
      if (window.innerWidth >= 1024) {
        sidebarOpen.value = true
      }
    }

    onMounted(() => {
      window.addEventListener('resize', handleResize)
      handleResize()
    })

    return {
      sidebarCollapsed,
      sidebarOpen,
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
/* Tab fade transition */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* Tab content animation */
.tab-content {
  animation: slideUp 0.4s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Responsive breakpoint for extra small screens */
@media (min-width: 400px) {
  .xs\:inline {
    display: inline;
  }
}
</style>

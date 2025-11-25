// Sidebar state management with localStorage persistence
import { ref, watch } from 'vue'

const SIDEBAR_COLLAPSED_KEY = 'motorpool_sidebar_collapsed'
const SIDEBAR_OPEN_KEY = 'motorpool_sidebar_open'

// Initialize from localStorage or defaults
const getInitialCollapsed = () => {
  const stored = localStorage.getItem(SIDEBAR_COLLAPSED_KEY)
  return stored !== null ? stored === 'true' : true // Default to collapsed
}

const getInitialOpen = () => {
  const stored = localStorage.getItem(SIDEBAR_OPEN_KEY)
  return stored !== null ? stored === 'true' : false // Default to closed on mobile
}

export function useSidebar() {
  const sidebarCollapsed = ref(getInitialCollapsed())
  const sidebarOpen = ref(getInitialOpen())

  // Watch for changes and persist to localStorage
  watch(sidebarCollapsed, (newValue) => {
    localStorage.setItem(SIDEBAR_COLLAPSED_KEY, String(newValue))
  })

  watch(sidebarOpen, (newValue) => {
    localStorage.setItem(SIDEBAR_OPEN_KEY, String(newValue))
  })

  const toggleSidebar = () => {
    sidebarCollapsed.value = !sidebarCollapsed.value
  }

  const closeSidebar = () => {
    if (window.innerWidth <= 1024) {
      sidebarOpen.value = false
    } else {
      // On desktop, just collapse it
      sidebarCollapsed.value = true
    }
  }

  const openSidebar = () => {
    sidebarOpen.value = true
    if (window.innerWidth > 1024) {
      sidebarCollapsed.value = false
    }
  }

  const handleMenuClick = () => {
    // Only close sidebar on mobile/tablet
    // On desktop, keep sidebar state (open/closed, collapsed/expanded) as is
    if (window.innerWidth <= 1024) {
      sidebarOpen.value = false
    }
    // Don't change sidebarCollapsed - let user control it with toggle button
  }

  return {
    sidebarCollapsed,
    sidebarOpen,
    toggleSidebar,
    closeSidebar,
    openSidebar,
    handleMenuClick
  }
}



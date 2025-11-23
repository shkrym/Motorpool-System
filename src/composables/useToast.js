// Toast management composable
import { ref } from 'vue'

const toasts = ref([])
let toastIdCounter = 0

export function useToast() {
  const showToast = (message, type = 'info', duration = 4000, description = null) => {
    const id = ++toastIdCounter
    const toast = {
      id,
      message,
      type,
      description,
      duration
    }
    
    toasts.value.push(toast)
    
    // Auto-remove after duration
    if (duration > 0) {
      setTimeout(() => {
        const index = toasts.value.findIndex(t => t.id === id)
        if (index > -1) {
          toasts.value.splice(index, 1)
        }
      }, duration)
    }
    
    return id
  }

  const removeToast = (id) => {
    const index = toasts.value.findIndex(t => t.id === id)
    if (index > -1) {
      toasts.value.splice(index, 1)
    }
  }

  const clearAllToasts = () => {
    toasts.value = []
  }

  // Convenience methods
  const success = (message, description = null, duration = 4000) => 
    showToast(message, 'success', duration, description)
  
  const error = (message, description = null, duration = 5000) => 
    showToast(message, 'error', duration, description)
  
  const warning = (message, description = null, duration = 4000) => 
    showToast(message, 'warning', duration, description)
  
  const info = (message, description = null, duration = 3000) => 
    showToast(message, 'info', duration, description)

  return {
    toasts,
    showToast,
    removeToast,
    clearAllToasts,
    success,
    error,
    warning,
    info
  }
}

// Export toasts ref for the Toast component
export { toasts }



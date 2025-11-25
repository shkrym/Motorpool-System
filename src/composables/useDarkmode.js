import { ref } from 'vue'

// Shared state across all components
const isDark = ref(false)

export function useDarkMode() {
  const toggleDarkMode = () => {
    isDark.value = !isDark.value
    updateDOM()
    savePreference()
  }

  const setDarkMode = (value) => {
    isDark.value = value
    updateDOM()
    savePreference()
  }

  const updateDOM = () => {
    if (isDark.value) {
      document.documentElement.setAttribute('data-theme', 'forest')
    } else {
      document.documentElement.setAttribute('data-theme', 'light')
    }
  }

  const savePreference = () => {
    try {
      localStorage.setItem('darkMode', isDark.value ? 'true' : 'false')
    } catch (error) {
      console.error('Failed to save dark mode preference:', error)
    }
  }

  const loadPreference = () => {
    try {
      const saved = localStorage.getItem('darkMode')
      if (saved !== null) {
        isDark.value = saved === 'true'
        updateDOM()
      }
    } catch (error) {
      console.error('Failed to load dark mode preference:', error)
    }
  }

  return {
    isDark,
    toggleDarkMode,
    setDarkMode,
    loadPreference
  }
}

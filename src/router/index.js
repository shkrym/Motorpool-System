import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '../lib/supabase'
import Auth from '../pages/Auth.vue'
import Dashboard from '../pages/Dashboard.vue'
import Settings from '../pages/Settings.vue'
import Vehicles from '../pages/Vehicles.vue'
import FuelLogs from '../pages/FuelLogs.vue'

// Import the sub-pages for settings
import Profile from '../pages/settings/Profile.vue'
import Security from '../pages/settings/Security.vue'
import Theme from '../pages/settings/Theme.vue'

const routes = [
  {
    path: '/',
    name: 'Auth',
    component: Auth,
    meta: { requiresGuest: true }
  },
  {
    path: '/dashboard',
    name: 'Dashboard', 
    component: Dashboard,
    meta: { requiresAuth: true }
  },
  {
    path: '/vehicles',
    name: 'Vehicles',
    component: Vehicles,
    meta: { requiresAuth: true }
  },
  {
    path: '/fuel',
    name: 'FuelLogs', 
    component: FuelLogs,
    meta: { requiresAuth: true }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: Settings,
    meta: { requiresAuth: true },
    redirect: '/settings/profile', // Add this line to redirect to a default child route
    children: [
      {
        path: 'profile',
        name: 'ProfileSettings',
        component: Profile,
      },
      {
        path: 'security',
        name: 'SecuritySettings',
        component: Security,
      },
      {
        path: 'theme',
        name: 'ThemeSettings',
        component: Theme,
      }
    ]
  },
  // Catch all route - redirect to dashboard if authenticated, auth if not
  {
    path: '/:pathMatch(.*)*',
    redirect: (to) => {
      // This will be handled by the navigation guard
      return '/dashboard'
    }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Global navigation guard
router.beforeEach(async (to, from, next) => {
  try {
    // Check if user is authenticated
    const { data: { session }, error } = await supabase.auth.getSession()
    
    if (error) {
      console.error('Error checking session:', error)
    }
    
    const isAuthenticated = !!session?.user
    const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
    const requiresGuest = to.matched.some(record => record.meta.requiresGuest)

    if (requiresAuth && !isAuthenticated) {
      // Route requires auth but user is not authenticated
      next('/')
    } else if (requiresGuest && isAuthenticated) {
      // Route is for guests only but user is authenticated
      next('/dashboard')
    } else {
      // Route is accessible
      next()
    }
  } catch (error) {
    console.error('Navigation guard error:', error)
    next('/')
  }
})

// Listen for auth changes
supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_OUT' || event === 'TOKEN_REFRESHED') {
    // Redirect to auth page on logout
    if (event === 'SIGNED_OUT') {
      router.push('/')
    }
  } else if (event === 'SIGNED_IN') {
    // Redirect to dashboard on login
    router.push('/dashboard')
  }
})

export default router

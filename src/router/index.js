import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '../lib/supabase'
import Auth from '../pages/Auth.vue'
import Dashboard from '../pages/Dashboard.vue'
import Settings from '../pages/Settings.vue'
import Vehicles from '../pages/Vehicles.vue'
import Drivers from '../pages/DriverManagement.vue'
import Trips from '../pages/Trips.vue'
import Trimap from '../pages/TriMap.vue'
import FuelLogs from '../pages/FuelLogs.vue'
import Maintenance from '../pages/Maintenance.vue'

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
    path: '/drivers',
    name: 'Drivers',
    component: Drivers,
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/trips/:id',
    name: 'TripHistory',
    component: Trips
  },
  {
    path: '/tripmap/:id',
    name: 'LiveMap',
    component: Trimap
  },
  {
    path: '/fuel',
    name: 'FuelLogs', 
    component: FuelLogs,
    meta: { requiresAuth: true }
  },
  {
    path: '/maintenance',
    name: 'Maintenance', 
    component: Maintenance,
    meta: { requiresAuth: true }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: Settings,
    meta: { requiresAuth: true },
    redirect: '/settings/profile',
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
    const { data: { session }, error } = await supabase.auth.getSession()
    
    if (error) {
      console.error('Error checking session:', error)
    }
    
    const isAuthenticated = !!session?.user
    const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
    const requiresGuest = to.matched.some(record => record.meta.requiresGuest)
    const requiresAdmin = to.matched.some(record => record.meta.requiresAdmin)

    // Check admin role if required
    if (requiresAdmin && isAuthenticated) {
      const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', session.user.id)
        .single()
      
      if (profile?.role !== 'admin') {
        alert('Access denied. Admin privileges required.')
        next('/dashboard')
        return
      }
    }

    if (requiresAuth && !isAuthenticated) {
      next('/')
    } else if (requiresGuest && isAuthenticated) {
      next('/dashboard')
    } else {
      next()
    }
  } catch (error) {
    console.error('Navigation guard error:', error)
    next('/')
  }
})

export default router
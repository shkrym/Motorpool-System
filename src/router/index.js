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
import LiveMap from '../pages/LiveMap.vue'  // Leaflet - Free & Simple!

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
    name: 'TripMap',
    component: Trimap
  },
  {
    path: '/livemap',
    name: 'LiveMap',
    component: LiveMap,  // Leaflet - Default!
    meta: { requiresAuth: true }
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
    meta: { requiresAuth: true }
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
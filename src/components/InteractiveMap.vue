<template>
  <div class="map-container h-full w-full relative">
    <!-- Map Element -->
    <div ref="mapContainer" class="h-full w-full"></div>
    
    <!-- Map Controls Overlay -->
    <div class="absolute top-4 right-4 flex flex-col gap-2 z-[1000]">
      <button 
        @click="centerOnUserLocation"
        class="w-10 h-10 bg-white shadow-lg rounded-lg flex items-center justify-center hover:bg-gray-50 transition-colors"
        title="Center on my location"
      >
        <i class="fas fa-crosshairs text-gray-600"></i>
      </button>
      <button 
        @click="zoomIn"
        class="w-10 h-10 bg-white shadow-lg rounded-lg flex items-center justify-center hover:bg-gray-50 transition-colors"
      >
        <i class="fas fa-plus text-gray-600"></i>
      </button>
      <button 
        @click="zoomOut"
        class="w-10 h-10 bg-white shadow-lg rounded-lg flex items-center justify-center hover:bg-gray-50 transition-colors"
      >
        <i class="fas fa-minus text-gray-600"></i>
      </button>
    </div>

    <!-- Location Info Card -->
    <div 
      v-if="selectedVehicle" 
      class="absolute bottom-4 left-4 bg-white/95 backdrop-blur-xl rounded-xl p-4 shadow-lg min-w-64 z-[1000]"
    >
      <div class="flex items-center gap-3 mb-2">
        <div class="w-3 h-3 rounded-full animate-pulse" :class="{
          'bg-green-500': selectedVehicle.status === 'available',
          'bg-red-500': selectedVehicle.status === 'in_use',
          'bg-yellow-500': selectedVehicle.status === 'maintenance'
        }"></div>
        <h4 class="font-semibold text-gray-800">{{ selectedVehicle.plate_number }}</h4>
      </div>
      <div class="space-y-1 text-sm text-gray-600">
        <div>{{ selectedVehicle.make }} {{ selectedVehicle.model }} ({{ selectedVehicle.year }})</div>
        <div class="flex items-center gap-1">
          <i class="fas fa-map-marker-alt text-xs"></i>
          <span>{{ selectedVehicle.location || 'Location updating...' }}</span>
        </div>
        <div class="flex items-center gap-1">
          <i class="fas fa-tachometer-alt text-xs"></i>
          <span>{{ selectedVehicle.speed || 0 }} km/h</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useToast } from '../composables/useToast'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

// Fix Leaflet default markers
delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png'
})

export default {
  name: 'InteractiveMap',
  props: {
    vehicles: {
      type: Array,
      default: () => []
    },
    centerLat: {
      type: Number,
      default: 14.5995 // Manila coordinates
    },
    centerLng: {
      type: Number,
      default: 120.9842
    },
    zoom: {
      type: Number,
      default: 13
    }
  },
  emits: ['vehicle-selected', 'location-updated'],
  setup(props, { emit }) {
    const { warning } = useToast()
    const mapContainer = ref(null)
    const map = ref(null)
    const vehicleMarkers = ref(new Map())
    const selectedVehicle = ref(null)
    const userLocationMarker = ref(null)
    const watchId = ref(null)

    // Vehicle icons for different statuses including IoT status
    const vehicleIcons = {
      available: L.divIcon({
        html: '<i class="fas fa-car text-green-600"></i>',
        iconSize: [20, 20],
        className: 'vehicle-marker available'
      }),
      in_use: L.divIcon({
        html: '<i class="fas fa-car text-red-600"></i>',
        iconSize: [20, 20],
        className: 'vehicle-marker in-use'
      }),
      maintenance: L.divIcon({
        html: '<i class="fas fa-wrench text-yellow-600"></i>',
        iconSize: [20, 20],
        className: 'vehicle-marker maintenance'
      }),
      out_of_service: L.divIcon({
        html: '<i class="fas fa-times-circle text-gray-600"></i>',
        iconSize: [20, 20],
        className: 'vehicle-marker out-of-service'
      }),
      offline: L.divIcon({
        html: '<i class="fas fa-car-crash text-gray-500"></i>',
        iconSize: [20, 20],
        className: 'vehicle-marker offline'
      })
    }

    const initMap = () => {
      if (!mapContainer.value) return

      // Initialize map
      map.value = L.map(mapContainer.value).setView([props.centerLat, props.centerLng], props.zoom)

      // Add OpenStreetMap tiles
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        maxZoom: 19
      }).addTo(map.value)

      // Initialize vehicle markers
      updateVehicleMarkers()

      // Start location tracking
      startLocationTracking()
    }

    const updateVehicleMarkers = () => {
      if (!map.value) return

      // Clear existing markers
      vehicleMarkers.value.forEach(marker => {
        map.value.removeLayer(marker)
      })
      vehicleMarkers.value.clear()

      // Add markers for each vehicle with real IoT data
      props.vehicles.forEach(vehicle => {
        // Only show vehicles with valid GPS coordinates
        if (!vehicle.current_latitude || !vehicle.current_longitude) {
          console.log(`Vehicle ${vehicle.plate_number} has no GPS coordinates`)
          return
        }
        
        const lat = parseFloat(vehicle.current_latitude)
        const lng = parseFloat(vehicle.current_longitude)
        
        // Validate coordinates
        if (isNaN(lat) || isNaN(lng) || Math.abs(lat) > 90 || Math.abs(lng) > 180) {
          console.warn(`Invalid coordinates for vehicle ${vehicle.plate_number}:`, lat, lng)
          return
        }
        
        // Choose icon based on device status and vehicle status
        let iconType = vehicle.status || 'available'
        if (vehicle.device_status === 'offline') {
          iconType = 'offline'
        }
        
        const marker = L.marker([lat, lng], {
          icon: vehicleIcons[iconType] || vehicleIcons.available
        })
        
        // Enhanced popup with IoT data
        const lastUpdate = vehicle.last_ping ? new Date(vehicle.last_ping).toLocaleString() : 'Never'
        const speed = vehicle.current_speed ? `${vehicle.current_speed} km/h` : 'Stationary'
        const batteryLevel = vehicle.battery_level ? `${vehicle.battery_level}%` : 'Unknown'
        const deviceStatus = vehicle.device_status || 'Unknown'
        
        marker.bindPopup(`
          <div class="p-3 min-w-[200px]">
            <div class="flex items-center gap-2 mb-2">
              <div class="w-3 h-3 rounded-full ${getStatusColor(vehicle.device_status)}"></div>
              <h3 class="font-semibold text-lg">${vehicle.plate_number}</h3>
            </div>
            <p class="text-sm text-gray-700 mb-2">${vehicle.make} ${vehicle.model} (${vehicle.year || 'N/A'})</p>
            
            <div class="space-y-1 text-xs">
              <div class="flex justify-between">
                <span class="text-gray-600">Status:</span>
                <span class="font-medium">${formatVehicleStatus(vehicle.status)}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-600">Device:</span>
                <span class="font-medium ${deviceStatus === 'online' ? 'text-green-600' : 'text-red-600'}">${deviceStatus}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-600">Speed:</span>
                <span class="font-medium">${speed}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-600">Battery:</span>
                <span class="font-medium">${batteryLevel}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-600">Updated:</span>
                <span class="font-medium text-xs">${lastUpdate}</span>
              </div>
            </div>
            
            <div class="mt-3 pt-2 border-t">
              <div class="text-xs text-gray-500">
                📍 ${lat.toFixed(6)}, ${lng.toFixed(6)}
              </div>
            </div>
          </div>
        `)
        
        // Add click handler
        marker.on('click', () => {
          selectedVehicle.value = {
            ...vehicle,
            location: `${lat.toFixed(6)}, ${lng.toFixed(6)}`,
            speed: vehicle.current_speed || 0
          }
          emit('vehicle-selected', vehicle)
        })
        
        marker.addTo(map.value)
        vehicleMarkers.value.set(vehicle.id, marker)
      })
    }

    // Helper functions for IoT data display
    const getStatusColor = (deviceStatus) => {
      switch (deviceStatus) {
        case 'online': return 'bg-green-500'
        case 'offline': return 'bg-red-500'
        case 'error': return 'bg-yellow-500'
        default: return 'bg-gray-500'
      }
    }

    const formatVehicleStatus = (status) => {
      switch (status) {
        case 'available': return 'Available'
        case 'in_use': return 'In Use'
        case 'maintenance': return 'Maintenance'
        case 'out_of_service': return 'Out of Service'
        default: return 'Unknown'
      }
    }

    const startLocationTracking = () => {
      if ('geolocation' in navigator) {
        watchId.value = navigator.geolocation.watchPosition(
          (position) => {
            const { latitude, longitude } = position.coords
            updateUserLocation(latitude, longitude)
            emit('location-updated', { latitude, longitude })
          },
          (error) => {
            console.warn('Geolocation error:', error)
          },
          {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 60000
          }
        )
      }
    }

    const updateUserLocation = (lat, lng) => {
      if (!map.value) return

      if (userLocationMarker.value) {
        map.value.removeLayer(userLocationMarker.value)
      }

      userLocationMarker.value = L.marker([lat, lng], {
        icon: L.divIcon({
          html: '<div class="w-4 h-4 bg-blue-500 rounded-full border-2 border-white shadow-lg"></div>',
          iconSize: [16, 16],
          className: 'user-location-marker'
        })
      })
      
      userLocationMarker.value.bindPopup('Your Location').addTo(map.value)
    }

    const centerOnUserLocation = () => {
      if ('geolocation' in navigator) {
        navigator.geolocation.getCurrentPosition(
          (position) => {
            const { latitude, longitude } = position.coords
            map.value?.setView([latitude, longitude], 16)
            updateUserLocation(latitude, longitude)
          },
          (error) => {
            console.error('Error getting location:', error)
            warning('Unable to get your location. Please check location permissions.')
          }
        )
      } else {
        warning('Geolocation is not supported by this browser.')
      }
    }

    const zoomIn = () => {
      map.value?.zoomIn()
    }

    const zoomOut = () => {
      map.value?.zoomOut()
    }

    const centerOnVehicle = (vehicleId) => {
      const vehicle = props.vehicles.find(v => v.id === vehicleId)
      if (vehicle && map.value) {
        const lat = vehicle.latitude || props.centerLat
        const lng = vehicle.longitude || props.centerLng
        map.value.setView([lat, lng], 16)
        selectedVehicle.value = vehicle
      }
    }

    // Watch for vehicle updates
    watch(() => props.vehicles, updateVehicleMarkers, { deep: true })

    onMounted(() => {
      initMap()
    })

    onUnmounted(() => {
      if (watchId.value) {
        navigator.geolocation.clearWatch(watchId.value)
      }
      if (map.value) {
        map.value.remove()
      }
    })

    return {
      mapContainer,
      selectedVehicle,
      centerOnUserLocation,
      zoomIn,
      zoomOut,
      centerOnVehicle
    }
  }
}
</script>

<style scoped>
.map-container {
  font-family: 'Inter', sans-serif;
}

:deep(.vehicle-marker) {
  background: white;
  border-radius: 50%;
  width: 30px !important;
  height: 30px !important;
  display: flex !important;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.3);
  border: 2px solid white;
}

:deep(.vehicle-marker.available) {
  background: #10B981;
}

:deep(.vehicle-marker.in-use) {
  background: #EF4444;
}

:deep(.vehicle-marker.maintenance) {
  background: #F59E0B;
}

:deep(.vehicle-marker.out-of-service) {
  background: #6B7280;
}

:deep(.vehicle-marker.offline) {
  background: #9CA3AF;
  border: 2px dashed #6B7280 !important;
}

:deep(.user-location-marker) {
  background: transparent !important;
  border: none !important;
}

/* Leaflet popup customization */
:deep(.leaflet-popup-content-wrapper) {
  border-radius: 8px;
}
</style>
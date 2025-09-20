<template>
  <div style="max-width:1000px;margin:0 auto;">
    <h1>Trips</h1>

    <!-- Create trip -->
    <form @submit.prevent="createTrip" style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin:12px 0;">
      <select v-model="newTrip.vehicle_id" required>
        <option value="" disabled>Select vehicle</option>
        <option v-for="v in vehicles" :key="v.id" :value="v.id">{{ v.plate }}</option>
      </select>
      <select v-model="newTrip.driver_id">
        <option value="" disabled>Select driver</option>
        <option v-for="d in drivers" :key="d.id" :value="d.id">{{ d.name }}</option>
      </select>
      <input v-model="newTrip.origin" placeholder="Origin" />
      <input v-model="newTrip.destination" placeholder="Destination" />
      <input v-model.number="newTrip.odometer_start" type="number" placeholder="Odometer start" />
      <button style="grid-column: span 4;">Create Trip</button>
    </form>

    <table border="1" cellpadding="6" cellspacing="0" width="100%">
      <thead>
        <tr>
          <th>Vehicle</th><th>Driver</th><th>Status</th><th>Odo</th><th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="t in trips" :key="t.id">
          <td>{{ plateById(t.vehicle_id) }}</td>
          <td>{{ driverById(t.driver_id) }}</td>
          <td>{{ t.status }}</td>
          <td>{{ t.odometer_start }} → {{ t.odometer_end ?? '-' }}</td>
          <td style="display:flex; gap:6px;">
            <button v-if="t.status==='pending'" @click="startTrip(t)">Start</button>
            <button v-if="t.status==='ongoing'" @click="finishTrip(t)">Finish</button>
            <button @click="viewMap(t)">Map</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="selectedTrip" style="margin-top:16px;">
      <h3>Trip Map ({{ plateById(selectedTrip.vehicle_id) }})</h3>
      <TripMap :trip="selectedTrip" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase.js'
import TripMap from '../shared/TripMap.vue'

const vehicles = ref([])
const drivers = ref([])
const trips = ref([])
const selectedTrip = ref(null)

const newTrip = ref({
  vehicle_id: '', driver_id: '', origin: '', destination: '',
  odometer_start: null
})

function plateById(id) { return vehicles.value.find(v => v.id === id)?.plate || '—' }
function driverById(id) { return drivers.value.find(d => d.id === id)?.name || '—' }

async function loadAll() {
  const [v, d, t] = await Promise.all([
    supabase.from('vehicles').select('*').order('plate'),
    supabase.from('drivers').select('*').order('name'),
    supabase.from('trips').select('*').order('created_at', { ascending: false })
  ])
  if (v.error) alert(v.error.message); else vehicles.value = v.data
  if (d.error) alert(d.error.message); else drivers.value = d.data
  if (t.error) alert(t.error.message); else trips.value = t.data
}

async function createTrip() {
  const { error } = await supabase.from('trips').insert([{
    ...newTrip.value, status: 'pending', start_time: null, end_time: null
  }])
  if (error) return alert(error.message)
  newTrip.value = { vehicle_id: '', driver_id: '', origin: '', destination: '', odometer_start: null }
  loadAll()
}

async function startTrip(t) {
  const { error } = await supabase.from('trips')
    .update({ status: 'ongoing', start_time: new Date().toISOString() })
    .eq('id', t.id)
  if (error) return alert(error.message)
  loadAll()
}

async function finishTrip(t) {
  const odo = prompt('Enter odometer end:')
  if (!odo) return
  const { error } = await supabase.from('trips')
    .update({ status: 'completed', end_time: new Date().toISOString(), odometer_end: Number(odo) })
    .eq('id', t.id)
  if (error) return alert(error.message)
  loadAll()
}

function viewMap(t) { selectedTrip.value = t }

onMounted(loadAll)
</script>

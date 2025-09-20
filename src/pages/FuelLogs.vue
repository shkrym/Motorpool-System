<template>
  <div style="max-width:900px;margin:0 auto;">
    <h1>Fuel Logs</h1>

    <form @submit.prevent="addFuel" style="display:grid;grid-template-columns:repeat(5,1fr);gap:8px;margin:12px 0;">
      <select v-model="form.vehicle_id" required>
        <option value="" disabled>Select vehicle</option>
        <option v-for="v in vehicles" :key="v.id" :value="v.id">{{ v.plate }}</option>
      </select>
      <select v-model="form.trip_id">
        <option value="">(Optional) Trip</option>
        <option v-for="t in trips" :key="t.id" :value="t.id">
          {{ plateById(t.vehicle_id) }} — {{ t.origin }} → {{ t.destination }}
        </option>
      </select>
      <input v-model.number="form.liters" type="number" step="0.01" placeholder="Liters" required />
      <input v-model.number="form.cost" type="number" step="0.01" placeholder="Cost ₱" />
      <input v-model.number="form.odometer" type="number" placeholder="Odometer" />
      <button style="grid-column: span 5;">Add Fuel Log</button>
    </form>

    <table border="1" cellpadding="6" cellspacing="0" width="100%">
      <thead>
        <tr>
          <th>Date</th><th>Vehicle</th><th>Liters</th><th>Cost</th><th>Odometer</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="f in logs" :key="f.id">
          <td>{{ f.date }}</td>
          <td>{{ plateById(f.vehicle_id) }}</td>
          <td>{{ f.liters }}</td>
          <td>{{ f.cost }}</td>
          <td>{{ f.odometer ?? '—' }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase.js'

const vehicles = ref([])
const trips = ref([])
const logs = ref([])
const form = ref({ vehicle_id: '', trip_id: '', liters: null, cost: null, odometer: null })

function plateById(id) { return vehicles.value.find(v => v.id === id)?.plate || '—' }

async function load() {
  const [v, t, f] = await Promise.all([
    supabase.from('vehicles').select('*').order('plate'),
    supabase.from('trips').select('*').order('created_at', { ascending: false }),
    supabase.from('fuel_logs').select('*').order('created_at', { ascending: false }).limit(50)
  ])
  if (v.error) alert(v.error.message); else vehicles.value = v.data
  if (t.error) alert(t.error.message); else trips.value = t.data
  if (f.error) alert(f.error.message); else logs.value = f.data
}

async function addFuel() {
  const payload = { ...form.value }
  if (!payload.trip_id) payload.trip_id = null
  const { error } = await supabase.from('fuel_logs').insert([payload])
  if (error) return alert(error.message)
  form.value = { vehicle_id: '', trip_id: '', liters: null, cost: null, odometer: null }
  load()
}

onMounted(load)
</script>

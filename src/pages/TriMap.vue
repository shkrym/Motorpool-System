<template>
  <div style="height:360px;">
    <l-map v-if="center" :zoom="13" :center="center" style="height:100%;">
      <l-tile-layer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
      <l-polyline v-if="polyline.length" :lat-lngs="polyline" />
    </l-map>
    <div v-else style="padding:8px;border:1px solid #ddd;border-radius:8px;">
      No route found. Add coordinates to the trip’s <code>route</code> field.
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { LMap, LTileLayer, LPolyline } from 'vue-leaflet'

const props = defineProps({ trip: { type: Object, required: true } })

const points = computed(() => {
  // route can be [{lat,lng,ts}, ...] or [[lat,lng], ...]
  const r = props.trip?.route
  if (!r) return []
  if (Array.isArray(r) && r.length && Array.isArray(r[0])) {
    return r.map(p => ({ lat: p[0], lng: p[1] }))
  }
  if (Array.isArray(r) && r.length && r[0]?.lat != null) {
    return r
  }
  return []
})

const polyline = computed(() => points.value.map(p => [p.lat, p.lng]))
const center = computed(() => (points.value[0] ? [points.value[0].lat, points.value[0].lng] : null))
</script>

<script>
export default {
  components: { LMap, LTileLayer, LPolyline }
}
</script>

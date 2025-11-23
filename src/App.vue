<script setup>
import { ref } from "vue";
import Toast from './components/Toast.vue'

const isAuthenticated = ref(false); // later we'll set this to true after login
</script>

<template>
  <!-- Navbar shows only when logged in -->
  <nav v-if="isAuthenticated">
    <router-link to="/">Dashboard</router-link>
    <router-link to="/vehicles">Vehicles</router-link>
    <router-link to="/trips">Trips</router-link>
    <router-link to="/fuel-logs">Fuel Logs</router-link>
  </nav>

  <!-- Everything else -->
  <router-view
    @logged-in="isAuthenticated = true"
  />
  
  <!-- Toast notifications -->
  <Toast />
</template>

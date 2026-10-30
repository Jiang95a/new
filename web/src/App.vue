<script setup lang="ts">
import { onMounted } from 'vue'
import { RouterView } from 'vue-router'
import ToastHost from '@/components/ui/ToastHost.vue'
import { useAuthStore } from '@/stores/auth'
import { usePreferences } from '@/composables/usePreferences'

const auth = useAuthStore()
usePreferences()

onMounted(() => {
  void auth.fetchMe()
})
</script>

<template>
  <RouterView />
  <ToastHost />
</template>

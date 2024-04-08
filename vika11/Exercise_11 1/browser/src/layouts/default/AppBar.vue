<template>
  <v-app-bar flat color="blue-darken-3">
    <v-app-bar-title @click="handleClick" class="main-icon">
      <v-icon icon="mdi-basketball" />
      Sports DB
    </v-app-bar-title>
  </v-app-bar>
</template>

<script lang="ts" setup>
import router from '@/router';
import { useAppStore } from '@/store/app';


const appStore = useAppStore()

const handleClick = () => {
  if (appStore.getUser() === '')
    router.push('/')
  else
    router.push('/main')
}

</script>

<style scoped>
.main-icon {
  cursor: pointer;
}
</style>
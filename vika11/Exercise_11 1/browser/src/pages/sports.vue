<template>
  <v-container>
    <v-row align="center" class="mb-2">
      <v-col>
        <h1>Sports</h1>
      </v-col>
    </v-row>
    <v-data-table 
      :items="sportsStore.sports"
    />
  </v-container>
</template>

<script lang="ts" setup>
import { useSportsStore } from '@/store/sports';
import { onMounted } from 'vue';

const sportsStore = useSportsStore()

const getSports = async() => {
  await sportsStore.fetch_sports()
}

onMounted(getSports)
</script>

<style scoped>

</style>
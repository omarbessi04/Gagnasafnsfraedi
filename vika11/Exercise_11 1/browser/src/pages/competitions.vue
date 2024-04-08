<template>
  <v-container>
    <v-row align="center" class="mb-2">
      <v-col>
        <h1>Competitions</h1>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="5">
        <competition-places-dropdown @selected="updateChosenPlace" />
      </v-col>
      <v-col cols="2">
        <v-btn
         icon="" 
         color="green"
         @click="triggerFetch">
          GO!
        </v-btn>
      </v-col>
    </v-row>
    <v-data-table-server 
      v-model:items-per-page="itemsPerPage"
      :headers="headers"
      :items="competitions"
      :items-length="totalItems"
      :loading="loading"
      :search="search"
      @update:options="loadItems"
    />
  </v-container>
</template>

<script lang="ts" setup>
import { Competition, useCompetitionsStore } from '@/store/competitions';
import SortItem from '@/types/sort';
import { reactive, ref } from 'vue';

const competitionsStore = useCompetitionsStore()
const competitions = reactive<Competition[]>(competitionsStore.competitions)

const itemsPerPage = ref(10)
const search = ref('')
const headers = [
  {
    title: 'ID',
    align: 'start',
    key: 'id'
  },
  {
    title: 'Place',
    align: 'center',
    key: 'place'
  },
  {
    title: 'Held',
    align: 'center',
    key: 'held'
  }
] as const
const loading = ref(true)
const totalItems = ref(0)

const place = ref('')

const updateChosenPlace = (chosen: string) => {
  console.log(chosen)
  place.value = chosen
}

const triggerFetch = () => {
    search.value = String(Date.now())
}

const loadItems = async ({page, itemsPerPage, sortBy}: {page: number, itemsPerPage: number, sortBy: SortItem[]}) => {
  if (place.value === '') {
    loading.value = false
    return
  }
  loading.value = true
  console.log(place.value, page, itemsPerPage, sortBy)
  await competitionsStore.fetch_competitions_page(place.value, page, itemsPerPage, sortBy).then((rows) => {
    totalItems.value = rows
    loading.value = false
  })
}
</script>

<style scoped>

</style>
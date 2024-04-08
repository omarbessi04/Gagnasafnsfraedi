<template>
  <v-container>
    <v-row align="center">
      <v-col>
        <h1>Results</h1>
      </v-col>
    </v-row>
    <v-row align="center" class="mb-2">
      <v-col cols="5">
        <competition-places-dropdown @selected="updateChosenPlaces" ismultiple />
      </v-col>
      <v-col cols="5">
        <sports-dropdown @selected="updateChosenSports" />
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
      :items="results"
      :items-length="totalItems"
      :loading="loading"
      :search="search"
      @update:options="loadResults"
    />
  </v-container>
</template>

<script lang="ts" setup>
import CompetitionPlacesDropdown from '@/components/CompetitionPlacesDropdown.vue'
import SportsDropdown from '@/components/SportsDropdown.vue'
import { reactive, ref } from 'vue'
import axios from 'axios'
import Result from '@/types/result';
import SortItem from '@/types/sort';

const places = reactive<string[]>([])
const sports = reactive<string[]>([])

const totalItems = ref(0)
const loading = ref(false)
const itemsPerPage = ref(10)
const search = ref('')

const updateChosenPlaces = (chosen: string[]) => {
  console.log(chosen)
  places.length = 0
  chosen.forEach((v) => places.push(v))
}

const updateChosenSports = (chosen: string[]) => {
  console.log(chosen)
  sports.length = 0
  chosen.forEach((v) => sports.push(v))
}

const results = reactive<Result[]>([])

const headers = [
  {
    title: 'Place',
    align: 'start',
    key: 'place'
  },
  {
    title: 'Held',
    align: 'start',
    key: 'held'
  },
  {
    title: 'Sport',
    align: 'start',
    key: 'sport'
  },
  {
    title: 'AthleteID',
    align: 'center',
    key: 'athleteid'
  },
  {
    title: 'Name',
    align: 'start',
    key: 'name'
  },
  {
    title: 'Result',
    align: 'end',
    key: 'result'
  }
] as const

const triggerFetch = () => {
  search.value = String(Date.now())
}

const loadResults = async ({page, itemsPerPage, sortBy}: {page: number, itemsPerPage: number, sortBy: SortItem[]}) => {
  if (places.length === 0 && sports.length === 0) {
    loading.value = false
    return
  }
  loading.value = true
  const response = await axios.post("http://localhost:5001/resultsPage", {
    places, sports, page, itemsPerPage, sortBy
  })
  const rows: Result[] = response.data.results
  totalItems.value = response.data.total
  results.length = 0
  rows.forEach((a) => results.push(a))
  loading.value = false
}

</script>

<style scoped>
.v-col :deep(.v-input__details) {
  display: none;
}
</style>
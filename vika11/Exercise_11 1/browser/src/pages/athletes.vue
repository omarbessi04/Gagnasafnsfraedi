<template>
  <v-container>
    <v-row align="center" class="mb-2">
      <v-col>
        <h1>Athletes</h1>
      </v-col>
    </v-row>
    <v-data-table-server 
      v-model:items-per-page="itemsPerPage"
      :headers="headers"
      :items="athletes"
      :items-length="totalItems"
      :loading="loading"
      :search="search"
      @update:options="loadItems"
    />
  </v-container>
</template>

<script lang="ts" setup>
import { Athlete, useAthletesStore } from '@/store/athletes';
import SortItem from '@/types/sort';
import { reactive, ref } from 'vue';

const athletesStore = useAthletesStore()
const athletes = reactive<Athlete[]>(athletesStore.athletes)

const itemsPerPage = ref(10)
const search = ''
const headers = [
  {
    title: 'ID',
    align: 'start',
    key: 'id'
  },
  {
    title: 'Name',
    align: 'center',
    key: 'name'
  },
  {
    title: 'Gender',
    align: 'center',
    key: 'gender'
  },
  {
    title: 'Height',
    align: 'center',
    key: 'height'
  }
] as const
const loading = ref(true)
const totalItems = ref(0)

const loadItems = async ({page, itemsPerPage, sortBy}: {page: number, itemsPerPage: number, sortBy: SortItem[]}) => {
  loading.value = true
  await athletesStore.fetch_athletes_page(page, itemsPerPage, sortBy).then((rows) => {
    totalItems.value = rows
    loading.value = false
  })
}
</script>

<style scoped>

</style>
<template>
  <v-container class="fill-height custom-width">
    <v-row class="fill-height">
      <v-col v-for="(sheet, index) in sheets" :key="index" cols="6">
        <v-card 
         @click="handleSheetClick(sheet)"
         :class="{
          'purple-sheet': sheet.title === 'Athletes', 
          'green-sheet': sheet.title === 'Sports', 
          'red-sheet': sheet.title === 'Competitions',
          'gold-sheet': sheet.title === 'Results',
          'teal-sheet': sheet.id > 4
         }"
         class="fill-height"
        >
          <v-card-title>{{ sheet.title }}</v-card-title>
          <v-card-text>{{ sheet.description }}</v-card-text>
        </v-card>
      </v-col>
    </v-row>
    <add-athlete-dialog
     v-model="openAddAthleteDialog"
     @success="snackSuccess"
     @failure="snackFailure"/>
    <add-competition-dialog
     v-model="openAddCompetitionDialog"
     @success="snackSuccess"
     @failure="snackFailure" />
    <delete-sport-dialog
     v-model="openDeleteSportDialog"
     @success="snackSuccess"
     @failure="snackFailure"/>
    <v-snackbar
      v-model="snackbar"
      :color="snackColor"
      :timeout="timeout"
      :style="{ 'left': '50%' }"
    >
      {{ snackText }}

      <template v-slot:actions>
        <v-btn
          variant="text"
          @click="snackbar = false"
        >
          Close
        </v-btn>
      </template>
    </v-snackbar>
  </v-container>
</template>

<script setup lang="ts">
import AddAthleteDialog from '@/components/AddAthleteDialog.vue';
import AddCompetitionDialog from '@/components/AddCompetitionDialog.vue';
import DeleteSportDialog from '@/components/DeleteSportDialog.vue';
import router from '@/router';
import { useAppStore } from '@/store/app';
import { Ref, ref } from 'vue';

interface Sheet {
  id: number,
  title: string;
  description: string;
}

const role = ref(useAppStore().getRole())
const snackbar = ref(false)
const snackText = ref('')
const snackColor = ref('pink')
const timeout = ref(6000)

const openAddCompetitionDialog = ref(false)
const openAddAthleteDialog = ref(false)
const openDeleteSportDialog = ref(false)

const snackSuccess = (msg: string) => {
  snackbar.value = true
  snackText.value = msg
  snackColor.value = 'success'
}

const snackFailure = (error: string) => {
  snackbar.value = true
  snackText.value = error
  snackColor.value = 'red'
}

const snackNoAcces = () => {
  snackbar.value = true
  snackText.value = 'Your user cannot access this page/functionality!'
  snackColor.value = 'red'
}


const sheets: Ref<Sheet[]> = ref([
  { id: 1, title: 'Sports', description: 'View all the sports' },
  { id: 2, title: 'Athletes', description: 'These athletes have taken part in the competitions' },
  { id: 3, title: 'Competitions', description: 'Take a look at all these competitions that have taken place' },
  { id: 4, title: 'Results', description: 'Glance at the results from specific places and sports' },
  { id: 5, title: 'Add a new Athlete', description: 'Uses a function from SQL' },
  { id: 6, title: 'Add a new Competition', description: 'Uses INSERT INTO from psycopg' },
  { id: 7, title: 'Delete a Sport', description: 'Better reset the DB at some point' },
  { id: 8, title: 'Do your own thing!', description: 'FFA FAFO' }
]);

const handleSheetClick = (sheet: Sheet) => {
  console.log('Clicked on sheet:', sheet.title);
  if (sheet.id === 1) router.push('/sports')
  if (sheet.id === 2) router.push('/athletes')
  if (sheet.id === 3) router.push('/competitions')
  if (sheet.id === 4) router.push('/results')
  if (sheet.id === 5) openAddAthleteDialog.value = !openAddAthleteDialog.value
  if (sheet.id === 6) if (role.value !== "viewer") {
    console.log('Role:', role.value)
    openAddCompetitionDialog.value = !openAddCompetitionDialog.value
  } else {
    snackNoAcces()
  }
  if (sheet.id === 7) openDeleteSportDialog.value = !openDeleteSportDialog.value
  if (sheet.id === 8) router.push('/ffa')
};
</script>

<style scoped>
.teal-sheet {
  background-color: #00897B;
}

.green-sheet {
  background-color: #43A047;
}

.red-sheet {
  background-color: #E53935;
}

.purple-sheet {
  background-color: #AB47BC;
}

.gold-sheet {
  background-color: #F57F17;
}

</style>
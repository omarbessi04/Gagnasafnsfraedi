<template>
  <v-dialog max-width="800px" :model-value="modelValue">
    <v-card title="Add an Athlete">
      <v-card-text>
        <v-row>
          <v-col cols="5">
            <v-text-field 
             v-model="fullname"
             label="Full name"
             required
             outlined
            />
          </v-col>
          <v-col cols="5">
            <v-text-field 
             v-model="height"
             label="Height"
             required
             inputmode="decimal"
             step="0.1"
             type="number"
             outlined
            />
          </v-col>
          <v-col cols="2">
            <v-select
             v-model="gender"
             :items="genders"
             outlined
            />
          </v-col>
        </v-row>
      </v-card-text>
      <v-card-actions class="justify-center">
        <v-btn color="success" @click="addAthlete">
          Add
        </v-btn>
        <v-btn color="error" @click="close">
          Cancel
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue';
import axios from 'axios'
import { useAppStore } from '@/store/app';


defineProps<{modelValue: boolean}>()
const emit = defineEmits(['success', 'failure', 'update:modelValue'])

const close = () => {
  emit('update:modelValue', false)
}
const username: string = useAppStore().getUser()
const fullname = ref('')
const gender = ref('M')
const height = ref(0.0)

const genders = ref<string[]>([])

const loadGenders = async () => {
  const response = await axios.get("http://localhost:5001/genders")
  genders.value.length = 0
  genders.value = response.data.genders
}

const addAthlete = async () => {
  const response = await axios.post("http://localhost:5001/addAthlete", {
    username, 'fullname': fullname.value, 'gender': gender.value, 'height': height.value
  })
  if (response.data.success) {
    console.log(response)
    emit('success', 'Succesfully added new Athlete with ID ' + response.data.id)
    fullname.value = ''
    height.value = 0.0
    gender.value = 'M'
  }
  else {
    emit('failure', 'Failed to insert Athlete. Error: ' + response.data.error)
  }
}

onMounted(async () => {
  await loadGenders()
})
</script>
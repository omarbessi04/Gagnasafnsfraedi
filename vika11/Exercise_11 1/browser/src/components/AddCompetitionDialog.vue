<template>
  <v-dialog max-width="800px" :model-value="modelValue">
    <v-card title="Add a Competition">
      <v-card-text>
        <v-row align="center">
          <v-col cols="6">
            <v-text-field 
             v-model="place"
             label="Place"
             required
             outlined
            />
          </v-col>
          <v-col cols="6">
            <v-date-picker
             v-model="held"
             show-adjacent-months
             title="Competition Date"
            />
          </v-col>
        </v-row>
      </v-card-text>
      <v-card-actions class="justify-center">
        <v-btn color="success" @click="addCompetition">
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
const place = ref('')
const held = ref(new Date())

const addCompetition = async () => {
  const response = await axios.post("http://localhost:5001/addCompetition", {
    username, 'place': place.value, 'held': held.value.toISOString().split('T')[0]
  })
  if (response.data.success) {
    console.log(response)
    emit('success', 'Succesfully added new Competition with ID ' + response.data.id)
    place.value = ''
    held.value = new Date()
  }
  else {
    emit('failure', 'Failed to insert Competition. Error: ' + response.data.error)
  }
}
</script>

<style scoped>
.v-date-picker :deep(.v-date-picker-header__content) {
  display: none;
}
</style>
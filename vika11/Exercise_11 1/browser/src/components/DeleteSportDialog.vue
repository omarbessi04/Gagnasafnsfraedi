<template>
  <v-dialog max-width="800px" :model-value="modelValue">
    <v-card title="Delete a Sport">
      <v-card-text>
        <v-select
         v-model="chosen"
         :items="sports"
         label="Choose a sport to remove"
         variant="solo"
        />
      </v-card-text>
      <v-card-actions class="justify-center">
        <v-btn color="error" @click="deleteSport">
          Delete
        </v-btn>
        <v-btn color="white" @click="close">
          Cancel
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script lang="ts" setup>
import { onMounted, ref, watch } from 'vue';
import axios from 'axios'
import { useAppStore } from '@/store/app';
import { useSportsStore } from '@/store/sports';


const props = defineProps<{modelValue: boolean}>()
const emit = defineEmits(['success', 'failure', 'update:modelValue'])

const sportsStore = useSportsStore()

const close = () => {
  emit('update:modelValue', false)
}

const username: string = useAppStore().getUser()

const sports = ref<string[]>([])

const chosen = ref('')

const fetch_sport_list = async () => {
    await sportsStore.fetch_sports()
    sports.value = sportsStore.sports.map((v) => v.name)
}

const deleteSport = async () => {
  const response = await axios.post("http://localhost:5001/deleteSport", {
    username, 'sport': chosen.value
  })
  if (response.data.success) {
    emit('success', 'Succesfully deleted Sport: ' + chosen.value)
    chosen.value = ''
    await fetch_sport_list()
  }
  else {
    emit('failure', 'Failed to delete Sport. Error: ' + response.data.error)
    await fetch_sport_list()
  }
}

watch(() => props.modelValue, async (_, newValue) => {
  if (newValue) {
    await fetch_sport_list()
  }
})

onMounted(async () => {
  await fetch_sport_list()
})

</script>
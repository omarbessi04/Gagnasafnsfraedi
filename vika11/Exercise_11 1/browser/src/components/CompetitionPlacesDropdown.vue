<template>
  <v-select
    v-model="chosen"
    :items="places"
    label="Choose one or more Places"
    :multiple="ismultiple"
    variant="solo"
    @update:model-value="emitSelected"
  />
</template>

<script lang="ts" setup>
import { useCompetitionsStore } from '@/store/competitions';
import { onMounted, ref } from 'vue';

defineProps<{
  ismultiple?: boolean
}>()

const competitionsStore = useCompetitionsStore()
const chosen = ref<string[]>([])

const places = ref<string[]>([])

const emit = defineEmits(['selected'])

const emitSelected = () => {
  emit('selected', chosen.value)
}

onMounted(async () => {
  const rows = await competitionsStore.fetch_competition_places()
  places.value.length = 0
  places.value = rows
})

</script>

<style scoped>
</style>
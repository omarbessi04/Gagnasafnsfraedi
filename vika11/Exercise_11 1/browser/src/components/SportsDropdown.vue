<template>
  <v-select
    v-model="chosen"
    :items="sports"
    label="Choose one or more Sports"
    multiple
    variant="solo"
    @update:model-value="emitSelected"
  />
</template>

<script lang="ts" setup>
import { useSportsStore } from '@/store/sports';
import { onMounted, reactive, ref } from 'vue';

const sportsStore = useSportsStore()
const chosen = ref<string[]>([])

const sports = ref<string[]>([])

const emit = defineEmits(['selected'])

const emitSelected = () => {
  emit('selected', chosen.value)
}

onMounted(async () => {
  await sportsStore.fetch_sports()
  sports.value = sportsStore.sports.map((v) => v.name)
})

</script>

<style scoped>
</style>
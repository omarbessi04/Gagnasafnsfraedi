<template>
  <v-container>
    <v-row justify="center" align="center">
      <v-col cols="12" sm="8" md="4">
        <v-card>
          <v-card-title class="headline">Login</v-card-title>
          <v-card-text>
            <v-form @submit.prevent="login">
              <v-text-field v-model="username" label="Username" required></v-text-field>
              <v-text-field v-model="password" label="Password" type="password" required></v-text-field>
              <v-btn type="submit" color="primary">Login</v-btn>
            </v-form>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup lang="ts">
import { useAppStore } from '@/store/app';
import { ref } from 'vue'

const emit = defineEmits(['success'])
const appStore = useAppStore()

const username = ref('')
const password = ref('')

const login = async () => {
  console.log('Login Clicked!')
  const success: boolean = await appStore.login(username.value, password.value)
  if (success)
    emit('success')
}
</script>

<style scoped>

</style>

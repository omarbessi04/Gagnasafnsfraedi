// Utilities
import { defineStore } from 'pinia'
import { ref } from 'vue'
import axios from 'axios'

export const useAppStore = defineStore('app', () => {
  const username = ref('')  
  const role = ref('')

  const login = async (user: string, pass: string) => {
    const response = await axios.post("http://localhost:5001/login", {'username': user, 'password': pass})
    if (response.status === 200) {
      username.value = user
      role.value = response.data.role
      return true
    }
    return false
  }
  const getUser = () => { return username.value }
  const getRole = () => { return role.value }

  return {
    login,
    getRole,
    getUser
  }
})

import { defineStore } from "pinia";
import { reactive } from "vue";
import axios from 'axios'

export interface Sports {
    id: number,
    name: string,
    record: number
}
export const useSportsStore = defineStore('sports', () => {
    const sports = reactive<Sports[]>([])

    const fetch_sports = async () => {
        const response = await axios.get("http://localhost:5001/sports")
        const rows: Sports[] = response.data.sports
        sports.length = 0
        rows.forEach((a) => sports.push(a))
    }

    return {
        sports,
        fetch_sports
    }
})
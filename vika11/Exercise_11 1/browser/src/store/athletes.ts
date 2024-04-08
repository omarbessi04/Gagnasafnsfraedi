import { defineStore } from "pinia";
import { reactive } from "vue";
import axios from 'axios'
import SortItem from "@/types/sort";

export interface Athlete {
    id: number,
    name: string,
    gender: string,
    height: number
}


export const useAthletesStore = defineStore('athletes', () => {
    const athletes = reactive<Athlete[]>([])

    const fetch_athletes_page = async (page: number, itemsPerPage: number, sortBy: SortItem[]): Promise<number> => {
        const response = await axios.post("http://localhost:5001/athletesPage", {
            page, itemsPerPage, sortBy
        })
        const rows: Athlete[] = response.data.athletes
        const total: number = response.data.total
        athletes.length = 0
        rows.forEach((a) => athletes.push(a))
        return total
    }

    return {
        athletes,
        fetch_athletes_page
    }
})
import { defineStore } from "pinia";
import { reactive } from "vue";
import axios from 'axios'
import SortItem from "@/types/sort";

export interface Competition {
    id: number,
    place: string,
    held: string
}

export const useCompetitionsStore = defineStore('competitions', () => {
    const competitions = reactive<Competition[]>([])

    const fetch_competitions_page = async (place:string, page: number, itemsPerPage: number, sortBy: SortItem[]): Promise<number> => {
        const response = await axios.post("http://localhost:5001/competitionsPage", {
            place, page, itemsPerPage, sortBy
        })
        const rows: Competition[] = response.data.competitions
        const total: number = response.data.total
        competitions.length = 0
        rows.forEach((a) => competitions.push(a))
        return total
    }

    const fetch_competition_places = async () => {
        const response = await axios.get("http://localhost:5001/competitions/places")
        const rows: string[] = response.data.places
        return rows
    }

    return {
        competitions,
        fetch_competitions_page,
        fetch_competition_places
    }
})
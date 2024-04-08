from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from psql_api.DatabaseAPI import DatabaseAPI
from pathlib import Path
import click
import uvicorn

from psycopg import errors as pgerrors

class Login(BaseModel):
    username: str
    password: str

class AthletesItemsPerPage(BaseModel):
    page: int # The current page being viewed (1-indexed)
    itemsPerPage: int # Number of items to return
    sortBy: list[dict] # A list that may contain a single dict element

class CompetitionsItemsPerPage(BaseModel):
    place: str # The place of the competitions
    page: int # The current page being viewed (1-indexed)
    itemsPerPage: int # Number of items to return
    sortBy: list[dict] # A list that may contain a single dict element

class ResultsItemsPerPage(BaseModel):
    places: list[str]
    sports: list[str]
    page: int # The current page being viewed (1-indexed)
    itemsPerPage: int # Number of items to return
    sortBy: list[dict] # A list that may contain a single dict element

class AddAthlete(BaseModel):
    username: str
    fullname: str
    gender: str
    height: float

class AddCompetition(BaseModel):
    username: str
    place: str
    held: str

class DeleteSport(BaseModel):
    username: str
    sport: str

origins = ["*"]

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

db: DatabaseAPI = None
    
@app.get("/")
async def read_root():
    return {'message': 'Hello, World!'}
        

@app.post("/login")
async def login(login_info: Login):
    role = db.check_user_credentials(login_info.username, login_info.password)
    if role is not None:
        return {"role": role, "message": "Login Succesful!"}
    else:
        raise HTTPException(status_code=401, detail='Invalid username or password!')


@app.get("/sports")
async def sports():
    sports = db.retrieve_all_sports()
    return {"sports": sports, "message": "All athletes fetched"}


@app.post("/athletesPage")
async def athletes(page_info: AthletesItemsPerPage):
    if len(page_info.sortBy) > 0:
        (athletes, total) = db.retrieve_athletes_page(page_info.page, page_info.itemsPerPage,
                                                      page_info.sortBy[0])
    else:
        (athletes, total) = db.retrieve_athletes_page(page_info.page, page_info.itemsPerPage)

    return {"athletes": athletes, "total": total, "message": "Page athletes fetched"}


@app.post("/competitionsPage")
async def competitions(query_page_info: CompetitionsItemsPerPage):
    print(query_page_info)
    if len(query_page_info.sortBy) > 0:
        (competitions, total) = db.retrieve_competitions_from_place_page(query_page_info.place,
                                                                         query_page_info.page,
                                                                         query_page_info.itemsPerPage,
                                                                         query_page_info.sortBy[0])
    else:
        (competitions, total) = db.retrieve_competitions_from_place_page(query_page_info.place,
                                                                         query_page_info.page,
                                                                         query_page_info.itemsPerPage)

    return {"competitions": competitions, "total": total, "message": "Page competitions fetched"}


@app.get("/competitions/places")
async def competition_places():
    places = db.retrieve_competition_places()
    return {"places": places, "message": "Page competitions fetched"}


@app.post("/resultsPage")
async def results_from_sport_and_place(query_page_info: ResultsItemsPerPage):
    if len(query_page_info.sortBy) > 0:
        (results, total) = db.retrieve_results_from_sports_and_places_page(query_page_info.places,
                                                                           query_page_info.sports,
                                                                           query_page_info.page,
                                                                           query_page_info.itemsPerPage,
                                                                           query_page_info.sortBy[0])
    else:
        (results, total) = db.retrieve_results_from_sports_and_places_page(query_page_info.places,
                                                                           query_page_info.sports,
                                                                           query_page_info.page,
                                                                           query_page_info.itemsPerPage)
    return {"results": results, "total": total, "message": "Results for the given parameters"}


@app.get("/genders")
async def genders():
    genders = db.retrieve_all_genders()
    return {"genders": [g['gender'] for g in genders], "message": "All genders"}


@app.post("/addAthlete")
async def addAthlete(new: AddAthlete):
    try:
        new_id = db.add_athlete_sql_function(new.username, new.fullname, new.gender, new.height)
        return {"success": True, "id": new_id, "message": "New athlete has been added!"}
    except pgerrors.InsufficientPrivilege as e:
        return {"success": False,
                "error": "This user is not allowed to use the NewAthlete() function. " + str(e),
                "message": "Adding new athlete failed :("}
    except Exception as e:
        return {"success": False, "error": str(e), "message": "Adding new athlete failed :("}


@app.post("/addCompetition")
async def addCompetition(new: AddCompetition):
    try:
        new_id = db.add_competition(new.username, new.place, new.held)
        # new_id = db.add_competition_sql_function(new.username, new.place, new.held)
        return {"success": True, "id": new_id, "message": "New competition has been added!"}
    except pgerrors.InsufficientPrivilege as e:
        return {"success": False, 
                "error": "This user is not allowed to insert to Competitions table.",
                "message": "Adding new competition failed :("}
    except Exception as e:
        return {"success": False, "error": str(e), "message": "Adding new competition failed :("}


@app.post("/deleteSport")
async def deleteSport(delete: DeleteSport):
    try:
        db.delete_sport(delete.username, delete.sport)
        return {"success": True, "message": f"Deleted sport {delete.sport}"}
    except pgerrors.InsufficientPrivilege as e:
        return {"success": False, "error": "This user is not allowed to delete on Sports table.",
                "message": "Deleting sport failed :("}
    except Exception as e:
        return {"success": False, "error": str(e), "message": "Deleting sport failed :("}




@click.command()
@click.argument('db_file', type=Path)
def run_server(db_file):
    """
    Starts the server on localhost port 5001

    Args:
    -----
    db_file: str
        The database config file
    """
    global db
    db = DatabaseAPI(db_file)
    uvicorn.run(app, host="localhost", port=5001)


if __name__ == "__main__":
    run_server()
import psycopg as pg
from psycopg.rows import dict_row
from pathlib import Path
from configparser import ConfigParser
import bcrypt

from datetime import date

class DatabaseAPI:
    def __init__(self, db_init: Path, section='postgresql') -> None:
        """
        Constructor
        """
        cfg = self.__config(db_init, section)
        self.main_role = cfg['user']
        self.conn_string = "host=%(host)s dbname=%(database)s user=%(user)s password=%(password)s" % (cfg)
        self.connection = pg.connect(self.conn_string, autocommit=True, row_factory=dict_row)
    

    def __del__(self) -> None:
        """
        Destructor. Ensures the connection gets closed.
        """
        if self.connection is not None:
            self.connection.close()


    def __config(self, file: Path, section='postgresql') -> dict:
        """
        Read the values from a database config file that has a section [postgresql]

        Parameters
        ----------
        file: Path
            The database config file in the following format:
                [section]
                host=
                database=
                user=
                password=
        section: str
            The section name in the config file.
            Default = 'postgresql'
        Returns
        -------
        dict
            Dictionary where key-value matches the config file
        """
        # create a parser
        parser = ConfigParser()
        # read config file
        parser.read(file)
        # get section, default to postgresql
        db = {}
        if parser.has_section(section):
            params = parser.items(section)
            for param in params:
                db[param[0]] = param[1]
        else:
            raise Exception('Section {0} not found in the {1} file'.format(section, file))
        return db


    def open(self) -> None:
        """
        Opens a new connection.
        
        If a previous connection was established it is closed before opening the new connection.
        """
        if self.connection is not None:
            self.connection.close()
        self.connection = pg.connect(self.conn_string)


    def close(self) -> None:
        """
        Closes the connection to the database.
        """
        self.connection.close()


    def __get_current_role__(self) -> str:
        """
        Get current database role

        Returns
        -------
        str:
            Returns the current role used in the database.
        """
        try:
            return self.connection.execute("SELECT current_user AS user;").fetchone()['user']
        except Exception as e:
            print(e)
            raise e

    def check_user_credentials(self, username:str, password:str) -> str:
        """
        Check a user's login information.

        If a user with the given username exists, check if the password matches the stored hashed password with bcrypt.

        Parameters
        ----------
        username: str
        password: str

        Returns
        -------
        str
            The role of the user or None if they do not exist or the password is incorrect.
        """
        try:
            user = self.connection.execute("SELECT * FROM Users WHERE username=%s", [username]).fetchone()
            if bcrypt.checkpw(password.encode('utf-8'), user['password_hashed'].encode('utf-8')):
                return user['role_name']
        except Exception as e:
            print(e)
            return None


    def retrieve_all_sports(self) -> list[dict_row]:
        """
        Get all rows from the Sports table.

        Returns
        -------
        list[dict_row]
            A list of rows, where each row is a dict with the table columns as keys.
        """
        try:
            rows = self.connection.execute("SELECT * FROM Sports").fetchall()
            return rows
        except Exception as e:
            print(e)
            raise e
    

    def add_sport(self, username: str, name: str, record: float | None=None) -> None:
        """
        Add a new sport to the Sports table.

        Parameters
        ----------
        username: str
        name: str
            Name of the new sport
        record: float | None
            The current record for the new sport
        """
        query = """
                INSERT INTO Sports (name, record)
                VALUES (%s, %s)
                """
        try:
            with self.connection.transaction():
                with self.connection.cursor() as cur:
                    role = cur.execute("SELECT role_name FROM Users WHERE username=%s", [username]).fetchone()['role_name']
                    cur.execute("SET LOCAL ROLE %s" % role) # Not prone to SQL Injection since role is retrieved from the database
                    cur.execute(query, [name, record])
        except Exception as e:
            print(e)
            raise e


    def delete_sport(self, username: str, sport:str) -> None:
        """
        Delete a given sport from the Sports table

        Parameters
        ----------
        username: str
            The user attempting to delete a sport row
        sport: str
            The name of the sport
        """
        query = """
                DELETE FROM Sports WHERE name = %s;
                """
        try:
            with self.connection.transaction():
                with self.connection.cursor() as cur:
                    role = cur.execute("SELECT role_name FROM Users WHERE username=%s", [username]).fetchone()['role_name']
                    cur.execute("SET LOCAL ROLE %s" % role) # Not prone to SQL Injection since role is retrieved from the database
                    cur.execute(query, [sport])
        except Exception as e:
            print(e)
            raise e


    def retrieve_all_athletes(self) -> list[dict_row]:
        """
        Get all rows from the Athletes table.

        Returns
        -------
        list[dict_row]
            A list of rows, where each row is a dict with the table columns as keys.
        """
        try:
            rows = self.connection.execute("SELECT * FROM Athletes").fetchall()
            return rows
        except Exception as e:
            print(e)
            raise e


    def retrieve_athletes_page(self, page: int, items_per_page: int, sort_by: dict | None=None) -> tuple[list[dict_row], int]:
        """
        Get paginated rows from the Athletes table.

        Parameters
        ----------
        page: int
            Current page number (1-indexed)
        items_per_page: int
            Number of items to return
        sort_by: dict | None
            A dict in the following format: {'key': column_name, 'order': 'asc' | 'desc'}

        Returns
        -------
        tuple[list[dict_row], int]
            A tuple with the list of rows for the page and the amount of rows there are in total in the table
        """
        try:
            # TODO: Task 1: Add your code here
            start = (page-1) * items_per_page
            end = start + items_per_page
            rows = []
            if sort_by is not None:
                columns = set(["id", "name", "gender", "height"])
                key = sort_by['key']
                if key not in columns:
                    raise pg.errors.DataError(f'The provided sort key does not match any columns of the Athletes table! Key: {key}')
                if sort_by['order'] == 'desc':
                    rows = self.connection.execute(f"SELECT * FROM Athletes ORDER BY {key} DESC").fetchall()
                else:
                    rows = self.connection.execute(f"SELECT * FROM Athletes ORDER BY {key}").fetchall()
            else:
                rows = self.connection.execute(f"SELECT * FROM Athletes").fetchall()
            return (rows[start:end], len(rows))
        except Exception as e:
            print(e)
            raise e


    def add_athlete(self, username:str, name: str, gender: str, height: float) -> None:
        """
        Add a new athlete to the Athletes table. Uses INSERT INTO

        Parameters
        ----------
        username: str
        name: str
            Full name of the athlete
        gender: str
            Gender of the athlete
        height: float
            Height of the athlete
        """
        query = """
                INSERT INTO Athletes (name, gender, height)
                VALUES (%s, %s, %s)
                """
        try:
            with self.connection.transaction():
                with self.connection.cursor() as cur:
                    role = cur.execute("SELECT role_name FROM Users WHERE username=%s", [username]).fetchone()['role_name']
                    cur.execute(f"SET LOCAL ROLE {role}") # Not prone to SQL Injection since role is retrieved from the database
                    cur.execute(query, [name, gender, height])
        except Exception as e:
            print(e)
            raise e


    def add_athlete_sql_function(self, username:str, name:str, gender: str, height: float) -> int:
        """
        Add a new athlete to the Athletes table. Uses NewAthlete SQL function

        Parameters
        ----------
        username: str
        name: str
            Full name of the athlete
        gender: str
            Gender of the athlete
        height: float
            Height of the athlete
        
        Returns
        -------
        str:
            ID of the newly inserted row
        """
        query = "SELECT NewAthlete(%s, %s, %s) AS ID;"
        try:
            print(self.connection.execute("SELECT current_user;").fetchone())
            with self.connection.transaction():
                with self.connection.cursor() as cur:
                    role = cur.execute("SELECT role_name FROM Users WHERE username=%s", [username]).fetchone()['role_name']
                    cur.execute(f"SET LOCAL ROLE {role}") # Not prone to SQL Injection since role is retrieved from the database
                    id = cur.execute(query, [name, gender, height]).fetchone()['id']
            return id
        except Exception as e:
            print(e)
            raise e
 

    def retrieve_all_competitions(self) -> list[dict_row]:
        """
        Get all rows from the Competitions table.

        Returns
        -------
        list[dict_row]
            A list of rows, where each row is a dict with the table columns as keys.
        """
        try:
            rows = self.connection.execute("SELECT * FROM Competitions").fetchall()
            return rows
        except Exception as e:
            print(e)
            raise e


    def retrieve_competitions_from_place_page(self, place:str, page: int, items_per_page: int, sort_by: dict | None=None) -> tuple[list[dict_row], int]:
        """
        Get paginated rows from the Competitions table.

        Parameters
        ----------
        page: int
            Current page number (1-indexed)
        items_per_page: int
            Number of items to return
        sort_by: dict | None
            A dict in the following format: {'key': column_name, 'order': 'asc' | 'desc'}

        Returns
        -------
        tuple[list[dict_row], int]
            A tuple with the list of rows for the page and the amount of rows there are in total in the table
        """
        try:
            start = (page-1) * items_per_page
            end = start + items_per_page
            rows = []
            if sort_by is not None:
                columns = set(['id', 'place', 'held'])
                key = sort_by['key']
                if key not in columns:
                    raise pg.errors.DataError(f'The provided sort key does not match any columns of the Competitions table! Key: {key}')
                if sort_by['order'] == 'desc':
                    rows = self.connection.execute(f"SELECT * FROM Competitions WHERE place=%s ORDER BY {key} DESC", [place]).fetchall()
                else:
                    rows = self.connection.execute(f"SELECT * FROM Competitions WHERE place=%s ORDER BY {key}", [place]).fetchall()
            else:
                rows = self.connection.execute("SELECT * FROM Competitions WHERE place=%s", [place]).fetchall()
            return (rows[start:end], len(rows))
        except Exception as e:
            print(e)
            raise e


    def retrieve_competition_places(self) -> list[str]:
        """
        Return all distinct places

        Returns
        -------
        list[str]
            List of places
        """
        try:
            rows = self.connection.execute("SELECT DISTINCT place FROM Competitions").fetchall()
            return [p['place'] for p in rows]
        except Exception as e:
            print(e)
            raise e


    def add_competition(
        self, username: str, place: str, held: date | None = None
    ) -> int:
        """
        Add a new competition to the Competitions table.

        Parameters
        ----------
        username: str
        place: str
            Name of the place where the competition is held
        held: date | None
            Date when the competition is held

        Returns
        -------
        str:
            ID of the newly inserted row

        """
        # TODO: Task 3: This is bad how about rewriting this to use an SQL function instead similar to NewAthlete().
        query = "SELECT NewCompetition(%s, %s) AS ID;"
        try:
            print(self.connection.execute("SELECT current_user;").fetchone())
            with self.connection.transaction():
                with self.connection.cursor() as cur:
                    role = cur.execute(
                        "SELECT role_name FROM Users WHERE username=%s", [username]
                    ).fetchone()["role_name"]
                    cur.execute(
                        f"SET LOCAL ROLE {role}"
                    )  # Not prone to SQL Injection since role is retrieved from the database
                    print("place:", place, type(place))
                    print("held:", held, type(held))
                    id = cur.execute(query, [place, held]).fetchone()["id"]
            return id

            # with self.connection.transaction():
            #     with self.connection.cursor() as cur:
            #         role = cur.execute("SELECT role_name FROM Users WHERE username=%s", [username]).fetchone()['role_name']
            #         cur.execute(f"SET LOCAL ROLE {role}") # Not prone to SQL Injection since role is retrieved from the database
            #         cur.execute(query, [place, str(held)])
            #         id = cur.execute("SELECT ID FROM Competitions ORDER BY ID DESC LIMIT 1;").fetchone()['id']
            #     return id
        except Exception as e:
            print(e)
            raise e

    def retrieve_all_results(self) -> list[dict_row]:
        """
        Get all rows from the Results table.

        Returns
        -------
        list[dict_row]
            A list of rows, where each row is a dict with the table columns as keys.
        """
        try:
            rows = self.connection.execute("SELECT * FROM Results").fetchall()
            return rows
        except Exception as e:
            print(e)
            raise e
    

    def retrieve_results_from_sports_and_places_page(self, places: list[str], sports: list[str],
                                                     page: int, items_per_page: int,
                                                     sort_by: dict | None=None) -> list[dict_row]:
        """
        Retrieve results based on specified places and sports (paginated)

        Parameters
        ----------
        places: list[str]
            List of selected places from the competitions table
        sports: list[str]
            List of selected sports from the Sports table
        page: int
            Current page number (1-indexed)
        items_per_page: int
            Number of items to return
        sort_by: dict | None
            A dict in the following format: {'key': column_name, 'order': 'asc' | 'desc'}

        Returns
        -------
        (list[dict_row], int)
            A list of rows for the page and the total number of rows.
            The format of the rows:
            [{
                place: str,
                held: date,
                sport: str,
                athleteid: str,
                name: str,
                result: float
            },...]
        """
        try:
            # TODO: Task 2
            # TODO: Remember to account for pages or if there is a sort order on a column.

            # HINT: Dynamically construct the query string with the correct number of %s placeholders (", ".join["%s"] * len(array))

            # TODO: We do also want to get results if only places or only sports have been specified.

            start = (page-1) * items_per_page
            end = start + items_per_page
            rows = []
            placeholders = ", ".join(['%s'] * len(places))
            sportholders = ", ".join(['%s'] * len(sports))
            if sort_by is not None:
                columns = set(['place', 'held', 'sport', 'athleteid', 'name', 'result'])
                key = sort_by['key']
                if key not in columns:
                    raise pg.errors.DataError(f'The provided sort key does not match any columns of the Results table! Key: {key}')
                
                if sort_by['order'] == 'desc':
                    rows = self.connection.execute(f"""select c.place, c.held, s.name as "sport", r.athleteID, a.name, r.result
                                                    from results r
                                                        join Athletes a on r.athleteID = a.id
                                                        join Competitions c on r.competitionID = c.id
                                                        join Sports s on r.sportID = s.id
                                                   where ('{'pass' if places else 'NULL'}' = 'NULL' or c.place in ({placeholders if places else 'NULL'})) and ('{'pass' if sports else 'NULL'}' = 'NULL' or s.name in ({sportholders if sports else 'NULL'}))
                                                   ORDER BY {key} DESC""", places+sports).fetchall()
                else:
                    rows = self.connection.execute(f"""select c.place, c.held, s.name as "sport", r.athleteID, a.name, r.result
                                                    from results r
                                                        join Athletes a on r.athleteID = a.id
                                                        join Competitions c on r.competitionID = c.id
                                                        join Sports s on r.sportID = s.id 
                                                   where ('{'pass' if places else 'NULL'}' = 'NULL' or c.place in ({placeholders if places else 'NULL'})) and ('{'pass' if sports else 'NULL'}' = 'NULL' or s.name in ({sportholders if sports else 'NULL'}))
                                                   ORDER BY {key}""", places+sports).fetchall()
            else:
                rows = self.connection.execute(f"""select c.place, c.held, s.name as "sport", r.athleteID, a.name, r.result
                                                    from results r
                                                        join Athletes a on r.athleteID = a.id
                                                        join Competitions c on r.competitionID = c.id
                                                        join Sports s on r.sportID = s.id
                                                    where ('{'pass' if places else 'NULL'}' = 'NULL' or c.place in ({placeholders if places else 'NULL'})) and ('{'pass' if sports else 'NULL'}' = 'NULL' or s.name in ({sportholders if sports else 'NULL'}))""", places+sports).fetchall()

            return (rows[start:end], len(rows))
        except Exception as e:
            print(e)
            raise e


    def add_result(self, username, athlete_id: int, competition_id: int, sport_id: int, result: float | None=None) -> None:
        """
        Add a new result for an athlete participating in a given sport and competition.

        Parameters
        ----------
        username: str
        athlete_id: int
            id of the athlete
        competition_id: int
            id of the competition the athlete is participating in
        sport_id: int
            id of the sport the athlete is playing
        result: float | None
            The result of the athletes attempt
        """
        query = """
                INSERT INTO Results (athleteID, competitionID, sportID, result)
                VALUES (%s, %s, %s, %s)
                """
        try:
            with self.connection.transaction():
                with self.connection.cursor() as cur:
                    role = cur.execute("SELECT role_name FROM Users WHERE username=%s", [username]).fetchone()['role_name']
                    cur.execute(f"SET LOCAL ROLE {role}") # Not prone to SQL Injection since role is retrieved from the database
                    cur.execute(query, [athlete_id, competition_id, sport_id, result])
        except Exception as e:
            print(e)
            raise e

    def retrieve_all_genders(self) -> list[dict_row]:
        """
        Get all rows from the Genders table.

        Returns
        -------
        list[dict_row]
            A list of rows, where each row is a dict with the table columns as keys.
        """
        try:
            rows = self.connection.execute("SELECT * FROM Gender").fetchall()
            return rows
        except Exception as e:
            print(e)
            raise e
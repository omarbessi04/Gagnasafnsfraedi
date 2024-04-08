import pytest
import psycopg as pg
import datetime
from psql_api.DatabaseAPI import DatabaseAPI

print("hello")
DBFILE = 'database.ini'

@pytest.fixture
def databaseapi():
    print("hello2: the reckoning")
    db = DatabaseAPI(db_init=DBFILE)
    yield db
    main_role = db.main_role
    conn_string = db.conn_string
    del db
    with pg.connect(conn_string, autocommit=True) as conn:
        conn.execute("DELETE FROM Sports WHERE name LIKE '%A Sport%' OR name LIKE '%CREATE TABLE%'")
        conn.execute("DELETE FROM Competitions WHERE place LIKE '%A Competition%' OR place LIKE '%CREATE TABLE%'")
        conn.execute("DELETE FROM Athletes WHERE name LIKE '%Nobody%' OR name LIKE '%CREATE TABLE%'")
        conn.execute("DELETE FROM Results WHERE result=0.1")
        conn.execute("DROP TABLE IF EXISTS injection")
        conn.execute(
            """
            SELECT setval(pg_get_serial_sequence('Athletes', 'id'),
                          (SELECT MAX(id) FROM Athletes));
            """
        )
        conn.execute(
            """
            SELECT setval(pg_get_serial_sequence('Sports', 'id'),
                         (SELECT MAX(id) FROM Sports));
            """
        )
        conn.execute(
            """
            SELECT setval(pg_get_serial_sequence('Competitions', 'id'),
                         (SELECT MAX(id) FROM Competitions));
            """
        )


### TEST CASES ###

def test_close_connection(databaseapi):
    databaseapi.close()


def test_open_connection(databaseapi):
    databaseapi.open()


# Sports
def test_retrieve_all_sports(databaseapi):
    rows = databaseapi.retrieve_all_sports()
    assert len(rows) > 0

def test_add_sport_as_viewer(databaseapi):
    with pytest.raises(pg.errors.InsufficientPrivilege):
        databaseapi.add_sport('Viewer', 'A Sport (viewer)', 1.2)

def test_add_sport_as_editor(databaseapi):
    databaseapi.add_sport('Editor', 'A Sport (editor)', 1.2)
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT * FROM Sports WHERE name=%s", ['A Sport (editor)']).fetchone()
        assert row is not None and row[1] == 'A Sport (editor)'

def test_add_sport_as_theone(databaseapi):
    databaseapi.add_sport('TheOne', 'A Sport (theone)', 1.2)
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT * FROM Sports WHERE name=%s", ['A Sport (theone)']).fetchone()
        assert row is not None and row[1] == 'A Sport (theone)'

def test_add_sport_sql_injection_safe(databaseapi):
    try:
        databaseapi.add_sport('TheOne', "''; CREATE TABLE Injection(id INT);--", 1.2)
    except:
        with pg.connect(databaseapi.conn_string) as conn:
            row = conn.execute("SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename='injection' );").fetchone()
            assert not row[0]

def test_delete_sport_as_viewer(databaseapi):
    databaseapi.add_sport('TheOne', 'A Sport (theone)', 1.2)
    with pytest.raises(pg.errors.InsufficientPrivilege):
        databaseapi.delete_sport('Viewer', 'A Sport (theone)')

def test_delete_sport_as_editor(databaseapi):
    databaseapi.add_sport('TheOne', 'A Sport (theone)', 1.2)
    with pytest.raises(pg.errors.InsufficientPrivilege):
        databaseapi.delete_sport('Editor', 'A Sport (theone)')

def test_delete_sport_as_theone(databaseapi):
    databaseapi.add_sport('TheOne', 'A Sport (theone)', 1.2)
    row_exists = True
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT * FROM Sports WHERE name=%s", ['A Sport (theone)']).fetchone()
        row_exists = row[1] == 'A Sport (theone)'
        if row_exists:
            databaseapi.delete_sport('TheOne', 'A Sport (theone)')
            row = conn.execute("SELECT * FROM Sports WHERE name=%s", ['A Sport (theone)']).fetchone()
            assert row is None
        else:
            assert False

def test_role_switch_to_main_user_after_add(databaseapi):
    databaseapi.add_sport('Editor', 'A Sport (editor)', 1.2)
    assert databaseapi.main_role == databaseapi.__get_current_role__()


# Athletes
def test_retrieve_all_athletes(databaseapi):
    rows = databaseapi.retrieve_all_athletes()
    assert len(rows) > 0

def test_retrieve_athletes_page_items_per_page(databaseapi):
    (rows, total) = databaseapi.retrieve_athletes_page(1, 10)
    assert len(rows) == 10

def test_retrieve_athletes_page_sort_asc(databaseapi):
    (rows, total) = databaseapi.retrieve_athletes_page(1, 10, {'key': 'id', 'order': 'asc'})
    assert rows[0]['id'] == 0

def test_retrieve_athletes_page_sort_desc(databaseapi):
    (rows, total) = databaseapi.retrieve_athletes_page(1, 10, {'key': 'id', 'order': 'desc'})
    assert rows[0]['id'] == total-1

def test_retrieve_athletes_page_sort_sql_injection_safe(databaseapi):
    try:
        (rows, total) = databaseapi.retrieve_athletes_page(1, 10, {'key': "id; CREATE TABLE Injection(id INT);--", 'order': 'desc'})
    except:
        print()
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename='injection' );").fetchone()
        assert not row[0]

def test_add_athletes_as_viewer(databaseapi):
    with pytest.raises(pg.errors.InsufficientPrivilege):
        databaseapi.add_athlete('Viewer', 'A Nobody (viewer)', 'M', 1.2)

def test_add_athletes_as_editor(databaseapi):
    databaseapi.add_athlete('Editor', 'A Nobody (editor)', 'F', 1.67)
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT * FROM Athletes WHERE name=%s", ['A Nobody (editor)']).fetchone()
        assert row is not None and row[1] == 'A Nobody (editor)'

def test_add_athletes_as_theone(databaseapi):
    databaseapi.add_athlete('TheOne', 'A Nobody (theone)', 'M', 1.77)
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT * FROM Athletes WHERE name=%s", ['A Nobody (theone)']).fetchone()
        assert row is not None and row[1] == 'A Nobody (theone)'

def test_add_athlete_sql_injection_safe_arg1(databaseapi):
    try:
        databaseapi.add_athlete('TheOne', "''; CREATE TABLE Injection(id INT PRIMARY KEY);--", 'M', 1.77)
    except:
        with pg.connect(databaseapi.conn_string) as conn:
            row = conn.execute("SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename='injection' );").fetchone()
            assert not row[0]

def test_add_athlete_sql_injection_safe_arg2(databaseapi):
    try:
        databaseapi.add_athlete('TheOne', 'Ghost', "'M'; CREATE TABLE Injection(id INT PRIMARY KEY);--", 1.77)
    except:
        with pg.connect(databaseapi.conn_string) as conn:
            row = conn.execute("SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename='injection' );").fetchone()
            assert not row[0]

def test_add_athlete_sql_function(databaseapi):
    with pytest.raises(pg.errors.InsufficientPrivilege):
        databaseapi.add_athlete('Viewer', 'A Nobody (viewer)', 'M', 1.2)


# Competitions
def test_retrieve_all_competitions(databaseapi):
    rows = databaseapi.retrieve_all_competitions()
    assert len(rows) > 0

def test_retrieve_competitions_page_items_per_page(databaseapi):
    (rows, total) = databaseapi.retrieve_competitions_from_place_page('Helsingoer', 1, 10)
    assert len(rows) == 10

def test_retrieve_competitions_page_sort_asc(databaseapi):
    (rows, total) = databaseapi.retrieve_competitions_from_place_page('Helsingoer', 1, 10, {'key': 'id', 'order': 'asc'})
    assert all(r['place'] == 'Helsingoer' for r in rows)

def test_retrieve_competitions_page_sort_desc(databaseapi):
    (rows, total) = databaseapi.retrieve_competitions_from_place_page('Helsingoer', 1, 10, {'key': 'id', 'order': 'desc'})
    assert rows[0]['id'] == 186

def test_retrieve_competitions_page_sort_sql_injection_safe_place(databaseapi):
    try:
        (rows, total) = databaseapi.retrieve_competitions_from_place_page("''; CREATE TABLE Injection(id INT PRIMARY KEY);--", 1, 10, {'key': 'id', 'order': 'desc'})
    except:
        print()
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename='injection' );").fetchone()
        assert not row[0]

def test_retrieve_competitions_page_sort_sql_injection_safe_key(databaseapi):
    try:
        (rows, total) = databaseapi.retrieve_competitions_from_place_page('Helsingoer', 1, 10, {'key': "id; CREATE TABLE Injection(id INT PRIMARY KEY);--", 'order': 'desc'})
    except:
        print()
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename='injection' );").fetchone()
        assert not row[0]

def test_add_competition_as_viewer(databaseapi):
    with pytest.raises(pg.errors.InsufficientPrivilege):
        databaseapi.add_competition('Viewer', 'A Competition (viewer)', datetime.datetime.strptime('2022-01-02', '%Y-%m-%d'))

def test_add_competition_as_editor(databaseapi):
    databaseapi.add_competition('Editor', 'A Competition (editor)', datetime.datetime.strptime('2022-01-02', '%Y-%m-%d'))
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT * FROM Competitions WHERE place=%s", ['A Competition (editor)']).fetchone()
        assert row is not None and row[1] == 'A Competition (editor)'

def test_add_competition_as_theone(databaseapi):
    databaseapi.add_competition('TheOne', 'A Competition (theone)', datetime.datetime.strptime('2022-01-02', '%Y-%m-%d'))
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT * FROM Competitions WHERE place=%s", ['A Competition (theone)']).fetchone()
        assert row is not None and row[1] == 'A Competition (theone)'

def test_add_competition_sql_injection_safe(databaseapi):
    databaseapi.add_competition('TheOne', "''; CREATE TABLE Injection(id INT PRIMARY KEY);--", datetime.datetime.strptime('2022-01-02', '%Y-%m-%d'))
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT EXISTS( SELECT 1 FROM pg_catalog.pg_tables WHERE tablename='injection' );").fetchone()
        assert not row[0]


# Results
def test_retrieve_all_results(databaseapi):
    rows = databaseapi.retrieve_all_results()
    assert len(rows) > 0

def test_add_results_as_viewer(databaseapi):
    with pytest.raises(pg.errors.InsufficientPrivilege):
        databaseapi.add_result('Viewer', 1, 1, 1, 0.1)

def test_add_results_as_editor(databaseapi):
    databaseapi.add_result('Editor', 1, 1, 1, 0.1)
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT * FROM Results WHERE result=%s", [0.1]).fetchone()
        assert row is not None and row[3] == 0.1

def test_add_results_as_theone(databaseapi):
    databaseapi.add_result('TheOne', 2, 2, 2, 0.1)
    with pg.connect(databaseapi.conn_string) as conn:
        row = conn.execute("SELECT * FROM Results WHERE result=%s", [0.1]).fetchone()
        assert row is not None and row[0] == 2

def test_retrieve_results_from_sports_and_places_page(databaseapi):
    (rows, total) = databaseapi.retrieve_results_from_sports_and_places_page(['Helsingoer'], ['High Jump'], 1, 10)
    assert len(rows) > 0 and total == 138

def test_retrieve_results_from_sports_and_places_page_places_asc(databaseapi):
    (rows, total) = databaseapi.retrieve_results_from_sports_and_places_page(['Helsingoer', 'Roskilde'], ['High Jump'], 1, 10, {'key': 'place', 'order': 'asc'})
    assert rows[0]['place'] == 'Helsingoer' and total == 282

def test_retrieve_results_from_sports_and_places_page_places_desc(databaseapi):
    (rows, total) = databaseapi.retrieve_results_from_sports_and_places_page(['Helsingoer', 'Roskilde'], ['High Jump'], 1, 10, {'key': 'place', 'order': 'desc'})
    assert rows[0]['place'] == 'Roskilde' and total == 282

def test_retrieve_results_from_sports_and_places_page_sports_asc(databaseapi):
    (rows, total) = databaseapi.retrieve_results_from_sports_and_places_page(['Helsingoer'], ['High Jump', 'Long Jump'], 1, 10, {'key': 'sport', 'order': 'asc'})
    assert rows[0]['sport'] == 'High Jump' and total == 287

def test_retrieve_results_from_sports_and_places_page_sports_desc(databaseapi):
    (rows, total) = databaseapi.retrieve_results_from_sports_and_places_page(['Helsingoer'], ['High Jump', 'Long Jump'], 1, 10, {'key': 'sport', 'order': 'desc'})
    assert rows[0]['sport'] == 'Long Jump'

def test_retrieve_results_from_sports_and_places_places_only(databaseapi):
    (rows, total) = databaseapi.retrieve_results_from_sports_and_places_page(['Helsingoer'], [], 1, 10)
    assert len(rows) > 0 and total == 668

def test_retrieve_results_from_sports_and_places_places_only_asc(databaseapi):
    (rows, total) = databaseapi.retrieve_results_from_sports_and_places_page(['Helsingoer', 'Roskilde'], [], 1, 10, {'key': 'place', 'order': 'asc'})
    assert rows[0]['place'] == 'Helsingoer' and total == 1362

def test_retrieve_results_from_sports_and_places_places_only_desc(databaseapi):
    (rows, total) = databaseapi.retrieve_results_from_sports_and_places_page(['Helsingoer', 'Roskilde'], [], 1, 10, {'key': 'place', 'order': 'desc'})
    assert rows[0]['place'] == 'Roskilde' and total == 1362

def test_retrieve_results_from_sports_and_places_sports_only(databaseapi):
    (rows, total) = databaseapi.retrieve_results_from_sports_and_places_page([], ['High Jump'], 1, 10)
    assert len(rows) > 0 and total == 1989

def test_retrieve_results_from_sports_and_places_sports_only_asc(databaseapi):
    (rows, total) = databaseapi.retrieve_results_from_sports_and_places_page([], ['High Jump', 'Long Jump'], 1, 10, {'key': 'sport', 'order': 'asc'})
    assert rows[0]['sport'] == 'High Jump' and total == 4071

def test_retrieve_results_from_sports_and_places_sports_only_desc(databaseapi):
    (rows, total) = databaseapi.retrieve_results_from_sports_and_places_page([], ['High Jump', 'Long Jump'], 1, 10, {'key': 'sport', 'order': 'desc'})
    assert rows[0]['sport'] == 'Long Jump' and total == 4071


def test_retrieve_results_from_sports_and_places_empty(databaseapi):
    with pytest.raises(pg.errors.DataError):
        databaseapi.retrieve_results_from_sports_and_places_page([], [], 1, 10)


# Genders
def test_retrieve_all_genders(databaseapi):
    rows = databaseapi.retrieve_all_genders()
    assert len(rows) > 0
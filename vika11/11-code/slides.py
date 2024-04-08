import psycopg as pg
from psycopg.rows import dict_row
from configparser import ConfigParser
from pathlib import Path
import click

def config(file: Path, section='postgresql') -> dict:
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


CONN_STRING = "host=%(host)s dbname=%(database)s user=%(user)s password=%(password)s" % config('database.ini')


@click.command('one')
def first_example():
    # Connect to the database
    # NOTE: autocommit is on
    conn: pg.Connection = pg.connect(CONN_STRING, autocommit=True, row_factory=dict_row)

    # Get all athletes
    athletes: list[dict] = conn.execute("SELECT * FROM Athletes;").fetchall()

    # Print every row
    [print(a) for a in athletes[0:10]]

    # Close the connection!
    conn.close()



@click.command('try')
def try_example():
    try:
        conn: pg.Connection = pg.connect(CONN_STRING, autocommit=True, row_factory=dict_row)
        # Get five athletes
        athletes: dict = conn.execute("SELECT * FROM Athletes;").fetchmany(5)
        [print(a) for a in athletes[0:10]]
    except Exception as e:
        print(e)
    finally:
        # Always closes the connection even if an exception is raised
        conn.close()



@click.command('context')
def context_example():
    try:
        # Instead of relying on the finally clause we can use with block
        # Anything created inside a with context block is always closed
        with pg.connect(CONN_STRING, autocommit=True, row_factory=dict_row) as conn:
            athletes: dict = conn.execute("SELECT * FROM Athletes").fetchone()
            print(athletes)
            # Hmm... what if I want to get the next athlete?
        # conn is closed!
    except Exception as e:
        print(e)



@click.command('cursors')
def cursors_example():
    try:
        with pg.connect(CONN_STRING, autocommit=True, row_factory=dict_row) as conn:
            # Instead of getting rows by chaining fetch{one,many,all}() we can return the cursor
            # Athletes cursor
            athletes_cur = conn.execute("SELECT * FROM Athletes")
            # Sports cursor
            sports_cur = conn.execute("SELECT * FROM Sports")
            # Get five athletes
            athletes = athletes_cur.fetchmany(5)
            # Get all sports
            sports = sports_cur.fetchall()
            print('First 5 athletes')
            [print(a) for a in athletes]
            print('All sports')
            [print(s) for s in sports]

            # Get the next five athletes
            athletes = athletes_cur.fetchmany(5)
            print('Next 5 athletes')
            [print(a) for a in athletes]
        # Since we have a with context, both cursors are closed along with the connection
    except Exception as e:
        print(e)



@click.command('create')
def create_table_example():
    try:
        with pg.connect(CONN_STRING, autocommit=True, row_factory=dict_row) as conn:
            conn.execute("DROP TABLE IF EXISTS Test")
            conn.execute(
                """
                CREATE TABLE Test (
                    x INT GENERATED ALWAYS AS IDENTITY,
                    y VARCHAR(250) NOT NULL
                )
                """
            )
    except Exception as e:
        print(e)



@click.command('insert')
@click.option('--open', is_flag=True, default=False)
def insert_example(open=False):
    try:
        conn = pg.connect(CONN_STRING, autocommit=True, row_factory=dict_row)
        if not open:
            with conn:
                conn.execute("INSERT INTO Test (y) VALUES ('I am Vengeance')")
                tests = conn.execute("SELECT * FROM Test").fetchall()
                [print(t) for t in tests]
            # Connection is closed
            nope = conn.execute("SELECT 42 as universe").fetchone()
            print(nope)
        else:
            with conn.cursor() as cur:
                cur.execute("INSERT INTO Test (y) VALUES ('I am the Night')")
                tests = cur.execute("SELECT * FROM Test").fetchall()
                [print(t) for t in tests]
            # Cursor is closed, Connection is alive
            yes = conn.execute("SELECT 42 as universe").fetchone()
            print(yes)
    except Exception as e:
        print(e)
    finally:
        conn.close()



@click.command('in_var')
@click.argument('y', type=str)
def insert_var_example(y):
    try:
        with pg.connect(CONN_STRING, autocommit=True, row_factory=dict_row) as conn:
            conn.execute("INSERT INTO Test (y) VALUES (%s)", [y])
            tests = conn.execute("SELECT * FROM Test").fetchall()
            [print(t) for t in tests]
    except Exception as e:
        print(e)



@click.command('select')
@click.argument('y', type=str)
@click.option('--safe', is_flag=True, default=False)
def select_example(y, safe=False):
    try:
        with pg.connect(CONN_STRING, autocommit=True, row_factory=dict_row) as conn:
            if not safe:
                tests_cur = conn.execute("SELECT * FROM Test WHERE y LIKE %s" % y)
                print('Query:', tests_cur._query.query)
                [print(t) for t in tests_cur.fetchall()]
            else:
                tests_cur = conn.execute("SELECT * FROM Test WHERE y LIKE %s", [y])
                print('Query:', tests_cur._query.query, 'Parameters:', tests_cur._query.params)
                [print(t) for t in tests_cur.fetchall()]
    except Exception as e:
        print(e)



@click.command('autocommit_off')
@click.option('--commit', is_flag=True, default=False)
@click.option('--err-commit', is_flag=True, default=False)
def autocommit_example(commit=False, err_commit=False):
    try:
        # autocommit is not set, by default it is OFF
        conn = pg.connect(CONN_STRING, row_factory=dict_row)
        autocommit_off(conn, commit, err_commit)
        tests = conn.execute("SELECT * FROM Test").fetchall()
        [print(t) for t in tests]
        if err_commit:
            conn.commit()
            # COMMIT;
    except Exception as e:
        print(e)
    finally:
        conn.close()

def autocommit_off(conn: pg.Connection, commit=False, err_commit=False):
    try:
        conn.execute("INSERT INTO Test (y) VALUES ('Somehow Palpatine returned...')")
        # BEGIN;
        # INSERT ...;
        # You could also have multiple cursors active from this connection creating, inserting, deleting, or updating the database
        if commit:
            # Need the connection to commit
            conn.commit()
            # COMMIT;
        else:
            raise pg.errors.Error('Somehow the database failed!')
    except Exception as e:
        # Need to remember to rollback, as currently it has no END; and since conn came from outside the function
        # the calling function may call conn.commit() at some later point leaving the database in an inconsistent state
        if not err_commit:
            conn.rollback()
            # ROLLBACK;
        print(e)



@click.command('transactions')
@click.option('--issue', is_flag=True, default=False)
def transactions_example(issue=False):
    conn = None
    try:
        # NOTE: autocommit is ON
        conn = pg.connect(CONN_STRING, autocommit=True, row_factory=dict_row)
        conn.execute("INSERT INTO Test (y) VALUES ('I am inevitable')")
        with conn.transaction():
            # BEGIN;
            with conn.cursor() as cur:
                cur.execute("INSERT INTO Test (y) VALUES ('I am Groot')")
                if issue:
                    raise pg.errors.Error("Transaction Failed")
                cur.execute("INSERT INTO Test (y) VALUES ('I am Iron Man')")
        # COMMIT/ROLLBACK;
    except Exception as e:
        print(e)
    finally:
        if conn is not None:
            # NOTE: This should probably also be nested in a try-except-finally
            #       but try to avoid firing off queries in a finally block
            tests = conn.execute("SELECT * FROM Test").fetchall()
            [print(t) for t in tests]
            conn.close()



# Command line stuff
@click.group()
def cli():
    pass

cli.add_command(first_example)
cli.add_command(try_example)
cli.add_command(context_example)
cli.add_command(cursors_example)
cli.add_command(create_table_example)
cli.add_command(insert_example)
cli.add_command(insert_var_example)
cli.add_command(select_example)
cli.add_command(autocommit_example)
cli.add_command(transactions_example)


if __name__ == '__main__':
    cli()
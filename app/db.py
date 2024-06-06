import oracledb
from flask import g
from config import Config

#define os parametros de conexão
username = Config.ORACLE_USER
password = Config.ORACLE_PASSWORD
dsn = Config.ORACLE_DSN  # Data Source Name, typically in the form of host:port/service_name

def get_db():
    if 'db' not in g:
        g.db = oracledb.connect(
            user=username,
            password=password,
            dsn=dsn
        )
    return g.db

def close_db(e=None):
    db = g.pop('db', None)

    if db is not None:
        db.close()

def init_app(app):
    app.teardown_appcontext(close_db)

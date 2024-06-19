import db

def call_insert_missing_leaders():
    conn = db.get_db()
    cursor = conn.cursor()
    try:
        cursor.callproc('insert_missing_leaders')
        conn.commit()
        print("insert_missing_leaders procedure executed successfully.")
    except Exception as e:
        print(f"Error executing insert_missing_leaders: {e}")
    finally:
        cursor.close()

def call_insert_missing_leaders():
    conn = db.get_db()
    cursor = conn.cursor()
    try:
        cursor.callproc('insert_missing_leaders')
        conn.commit()
        print("insert_missing_leaders procedure executed successfully.")
    except Exception as e:
        print(f"Error executing insert_missing_leaders: {e}")
    finally:
        cursor.close()

def call_alterar_nome_faccao(novo_nome):
    conn = db.get_db()
    cur = conn.cursor()
    try:
        cur.callproc('alterar_nome_faccao', [novo_nome])
        conn.commit()
        flash('Nome da facção alterado com sucesso!', 'success')
    except Exception as e:
        conn.rollback()
        flash(f'Erro ao alterar nome da facção: {e}', 'danger')
    finally:
        cur.close()
        conn.close()

def call_get_leader_info(conn, cpi):
    cursor = conn.cursor()
    cargo = cursor.var(cx_Oracle.STRING)
    e_lider = cursor.var(cx_Oracle.STRING)
    try:
        cursor.callproc('get_leader_info', [cpi, cargo, e_lider])
        return cargo.getvalue(), e_lider.getvalue()
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        print(f"Error calling get_leader_info: {error.message}")
        return None, None
    finally:
        cursor.close()
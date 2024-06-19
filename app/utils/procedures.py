import db

#Procedures gerais
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

#Procedures Lider de Facção
def call_alterar_nome_faccao(cpi, novo_nome):
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteLiderFaccao.alterar_nome_faccao', [cpi, novo_nome])
    conn.commit()

def call_indicar_novo_lider(cpi, novo_lider):
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteLiderFaccao.indicar_novo_lider', [cpi, novo_lider])
    conn.commit()

def call_cadastrar_nova_comunidade(cpi, comunidade):
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteLiderFaccao.cadastrar_nova_comunidade', [cpi, comunidade])
    conn.commit()

def call_remover_relacao_facao(cpi, nacao):
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteLiderFaccao.remover_relacao_facao', [cpi, nacao])
    conn.commit()

#Procedures Comandante
def call_incluir_federacao(cpi, federacao):
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteComandante.incluir_federacao', [cpi, federacao])
    conn.commit()

def call_excluir_federacao(cpi, federacao):
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteComandante.excluir_federacao', [cpi, federacao])
    conn.commit()

def call_criar_nova_federacao(cpi, nova_federacao, data_fundacao):
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteComandante.criar_nova_federacao', [cpi, nova_federacao, data_fundacao])
    conn.commit()

def call_inserir_dominancia_planeta(cpi, planeta):
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteComandante.inserir_dominancia_planeta', [cpi, planeta])
    conn.commit()

#Procedures Cientista
def call_criar_estrela(id_estrela, nome, classificacao, massa, x, y, z):
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteCientista.criar_estrela', [id_estrela, nome, classificacao, massa, x, y, z])
    conn.commit()

def call_atualizar_estrela(id_estrela, nome, classificacao, massa, x, y, z):
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteCientista.atualizar_estrela', [id_estrela, nome, classificacao, massa, x, y, z])
    conn.commit()

def call_deletar_estrela(id_estrela):
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteCientista.excluir_estrela', [id_estrela])
    conn.commit()

def call_listar_estrelas():
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.callproc('PacoteCientista.relatorio_estrelas')
    # Fetch and return results if needed
    stars = cursor.fetchall()
    return stars
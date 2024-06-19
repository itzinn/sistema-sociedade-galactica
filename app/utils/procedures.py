import db
import oracledb
from datetime import datetime

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
    cargo = cursor.var(oracledb.STRING)
    e_lider = cursor.var(oracledb.STRING)
    try:
        cursor.callproc('get_leader_info', [cpi, cargo, e_lider])
        return cargo.getvalue(), e_lider.getvalue()
    except oracledb.DatabaseError as e:
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

def call_get_planet_info(cpi, action):
    conn = db.get_db()
    cursor = conn.cursor()
    
    try:
        # Enable DBMS_OUTPUT
        cursor.callproc('DBMS_OUTPUT.ENABLE')
        
        # Call the procedure
        cursor.callproc('PacoteComandante.get_planet_info', [cpi, action])
        
        # Fetch DBMS_OUTPUT
        output = []
        line_var = cursor.arrayvar(oracledb.STRING, 32767)  # Large enough array to hold the output lines
        num_lines_var = cursor.var(oracledb.NUMBER)
        
        while True:
            num_lines_var.setvalue(0, 10000)  # Number of lines to fetch
            cursor.callproc("DBMS_OUTPUT.GET_LINES", (line_var, num_lines_var))
            num_lines = int(num_lines_var.getvalue())
            lines = line_var.getvalue()[:num_lines]
            output.extend(lines)
            if num_lines < 10000:
                break
        
        # Ensure lines are joined with proper line breaks for HTML
        formatted_output = "<br>".join(line.strip() for line in output)
        return formatted_output
    finally:
        # Ensure DBMS_OUTPUT is disabled
        cursor.callproc('DBMS_OUTPUT.DISABLE')
        cursor.close()

def call_monitor_planet_info(start_date='2023-01-01', end_date='2024-01-01'):
    conn = db.get_db()
    cursor = conn.cursor()

    # Convert string dates to datetime.date objects if necessary
    data_start = datetime.strptime(start_date, '%Y-%m-%d').date()
    data_end = datetime.strptime(end_date, '%Y-%m-%d').date()

    # Convert dates to the format expected by Oracle (e.g., 'DD-MON-YYYY')
    data_start_str = data_start.strftime('%d-%b-%Y').upper()
    data_end_str = data_end.strftime('%d-%b-%Y').upper()

    try:
        # Enable DBMS_OUTPUT
        cursor.callproc('DBMS_OUTPUT.ENABLE')
        
        # Call the procedure with or without date parameters
        if start_date and end_date:
            cursor.callproc('PacoteComandante.monitor_planet_info', [data_start_str, data_end_str])
        else:
            cursor.callproc('PacoteComandante.monitor_planet_info')
        
        # Fetch DBMS_OUTPUT
        output = []
        line_var = cursor.arrayvar(oracledb.STRING, 32767)  # Large enough array to hold the output lines
        num_lines_var = cursor.var(oracledb.NUMBER)
        
        while True:
            num_lines_var.setvalue(0, 10000)  # Number of lines to fetch
            cursor.callproc("DBMS_OUTPUT.GET_LINES", (line_var, num_lines_var))
            num_lines = int(num_lines_var.getvalue())
            lines = line_var.getvalue()[:num_lines]
            output.extend(lines)
            if num_lines < 10000:
                break
        
        # Ensure lines are joined with proper line breaks for HTML
        formatted_output = "<br>".join(line.strip() for line in output)
        return formatted_output
    finally:
        # Ensure DBMS_OUTPUT is disabled
        cursor.callproc('DBMS_OUTPUT.DISABLE')
        cursor.close()

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
    
    # Enable DBMS_OUTPUT
    cursor.callproc("DBMS_OUTPUT.ENABLE")
    
    # Call the procedure
    cursor.callproc('PacoteCientista.relatorio_estrelas')
    
    # Retrieve the DBMS_OUTPUT
    output = []
    while True:
        line = cursor.callproc("DBMS_OUTPUT.GET_LINE", (oracledb.STRING_VAR, 0))
        if line[1] != 0:
            break
        output.append(line[0])
    
    # Disable DBMS_OUTPUT
    cursor.callproc("DBMS_OUTPUT.DISABLE")
    
    print(output)

    return "\n".join(output)

def call_relatorio_estrelas():
    conn = db.get_db()
    cursor = conn.cursor()
    try:
        cursor.callproc('DBMS_OUTPUT.ENABLE')
        cursor.callproc('PacoteCientista.relatorio_estrelas')
        
        output = []
        line_var = cursor.arrayvar(oracledb.STRING, 32767)  # Large enough array to hold the output lines
        num_lines_var = cursor.var(oracledb.NUMBER)
        
        while True:
            num_lines_var.setvalue(0, 10000)  # Number of lines to fetch
            cursor.callproc("DBMS_OUTPUT.GET_LINES", (line_var, num_lines_var))
            num_lines = int(num_lines_var.getvalue())
            lines = line_var.getvalue()[:num_lines]
            output.extend(lines)
            if num_lines < 10000:
                break
        
        formatted_output = "<br>".join(line.strip() for line in output)
        return formatted_output
    except Exception as e:
        print(f"Erro ao gerar relatório de estrelas: {e}")
    finally:
        cursor.callproc('DBMS_OUTPUT.DISABLE')
        cursor.close()

def call_relatorio_planetas():
    conn = db.get_db()
    cursor = conn.cursor()
    try:
        cursor.callproc('DBMS_OUTPUT.ENABLE')
        cursor.callproc('PacoteCientista.relatorio_planetas')
        
        output = []
        while True:
            line = cursor.callproc("DBMS_OUTPUT.GET_LINE", (oracledb.STRING_VAR, 0))
            if line[1] != 0:
                break
            output.append(line[0])
        
        cursor.callproc('DBMS_OUTPUT.DISABLE')
        
        formatted_output = "<br>".join(line.strip() for line in output)
        return formatted_output
    except Exception as e:
        print(f"Erro ao gerar relatório de planetas: {e}")
    finally:
        cursor.close()

def call_relatorio_sistemas():
    conn = db.get_db()
    cursor = conn.cursor()
    try:
        cursor.callproc('DBMS_OUTPUT.ENABLE')
        cursor.callproc('PacoteCientista.relatorio_sistemas')
        
        output = []
        while True:
            line = cursor.callproc("DBMS_OUTPUT.GET_LINE", (oracledb.STRING_VAR, 0))
            if line[1] != 0:
                break
            output.append(line[0])
        
        cursor.callproc('DBMS_OUTPUT.DISABLE')
        
        formatted_output = "<br>".join(line.strip() for line in output)
        return formatted_output
    except Exception as e:
        print(f"Erro ao gerar relatório de sistemas: {e}")
    finally:
        cursor.close()

def call_relatorio_corpos_celestes(ref_id, ref_type, dist_min, dist_max):
    conn = db.get_db()
    cursor = conn.cursor()
    try:
        cursor.callproc('DBMS_OUTPUT.ENABLE')
        cursor.callproc('PacoteCientista.relatorio_corpos_celestes', [ref_id, ref_type, dist_min, dist_max])
        
        output = []
        while True:
            line = cursor.callproc("DBMS_OUTPUT.GET_LINE", (oracledb.STRING_VAR, 0))
            if line[1] != 0:
                break
            output.append(line[0])
        
        cursor.callproc('DBMS_OUTPUT.DISABLE')
        
        formatted_output = "<br>".join(line.strip() for line in output)
        return formatted_output
    except Exception as e:
        print(f"Erro ao gerar relatório de corpos celestes: {e}")
    finally:
        cursor.close()

def call_relatorio_cc_otimizado(ref_id, ref_type, dist_min, dist_max):
    conn = db.get_db()
    cursor = conn.cursor()
    try:
        cursor.callproc('DBMS_OUTPUT.ENABLE')
        cursor.callproc('PacoteCientista.relatorio_cc_otimizado', [ref_id, ref_type, dist_min, dist_max])
        
        output = []
        while True:
            line = cursor.callproc("DBMS_OUTPUT.GET_LINE", (oracledb.STRING_VAR, 0))
            if line[1] != 0:
                break
            output.append(line[0])
        
        cursor.callproc('DBMS_OUTPUT.DISABLE')
        
        formatted_output = "<br>".join(line.strip() for line in output)
        return formatted_output
    except Exception as e:
        print(f"Erro ao gerar relatório otimizado de corpos celestes: {e}")
    finally:
        cursor.close()
from flask import Blueprint, render_template, request, redirect, url_for, session
import hashlib
import db
from utils.procedures import call_get_leader_info
import oracledb


auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        lider = request.form['lider']
        password = request.form['password']

        print(f"Received lider: {lider}")
        print(f"Received password: {password}")

        md5_hashed_password = hashlib.md5(password.encode()).hexdigest().upper()
        print(f"Hashed password: {md5_hashed_password}")

        conn = db.get_db()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM USERS WHERE Lider = :lider", {'lider': lider})
        user = cursor.fetchone()
        print(f"Retrieved user: {user}")
        
        if user and user[2] == md5_hashed_password:
            # Armazena as informações do usuário na sessão
            session['user'] = user

            output_cursor = cursor.var(oracledb.CURSOR)

            # Chamada ao procedimento com o CPI do líder e o cursor de saída
            cpi_lider = user[1]  # Substitua pelo CPI do líder que deseja testar
            cursor.callproc("get_leader_info", [cpi_lider, output_cursor])

            # Processar os resultados do cursor de saída
            result_cursor = output_cursor.getvalue()

            row = result_cursor.fetchone()
            if row:
                # Desempacota as colunas retornadas
                cargo, e_lider, nome, nacao, especie = row
                session['cpi'] = lider
                session['e_lider'] = e_lider
                session['usertype'] = cargo.strip()
                session['name'] = nome
                session['nacao'] = nacao
                session['especie'] = especie
                print(session)
            else:
                print('Erro ao obter o tipo de usuário.', 'danger')
                return redirect(url_for('login'))

            print('Login successful!', 'success')
            return redirect(url_for('overview.overview'))
        else:
            print('Invalid credentials, please try again.', 'danger')

    return render_template('login.html')

# Define more auth-related routes here if needed

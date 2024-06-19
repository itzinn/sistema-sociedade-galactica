from flask import Blueprint, render_template, request, redirect, url_for, flash, session
import hashlib
import db
from utils.procedures import call_get_leader_info

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

            cursor.callproc('get_leader_info', [user[1]])
            result = cursor.fetchone()
            session['usertype'] = result[0] if result else None
            session['ehLider'] = result[1] if result else None

            #TODO: procedure get_leader_info trazer todas essas informações ao invés de só o cargo e se é lider ou não?
            cursor.execute("SELECT * FROM LIDER WHERE CPI = :cpi", {'cpi': user[1]})
            lider = cursor.fetchone()
            if lider:
                session['cpi'] = lider[0]
                session['name'] = lider[1]
                session['nacao'] = lider[3]
                session['especie'] = lider[4]
                print(session)
            else:
                flash('Erro ao obter o tipo de usuário.', 'danger')
                return redirect(url_for('login'))

            flash('Login successful!', 'success')
            return redirect(url_for('overview.overview'))
        else:
            flash('Invalid credentials, please try again.', 'danger')

    return render_template('login.html')

# Define more auth-related routes here if needed

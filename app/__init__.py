from flask import Flask, render_template, request, redirect, url_for, flash
import hashlib
import db
from utils.get_infos import get_overview_info, get_relatorios_info

app = Flask(__name__)

app.config['SECRET_KEY'] = '[hashgrandona]'

db.init_app(app)

@app.route('/')
def index():
    conn = db.get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT 'Hello, World!' FROM dual")
    result = cursor.fetchone()
    return result[0]

@app.route('/login', methods=['GET', 'POST'])
def login():

    if request.method == 'POST':
        lider = request.form['lider']
        password = request.form['password']

        print(f"Received lider: {lider}")
        print(f"Received password: {password}")
        
        # Hash the input password using MD5
        md5_hashed_password = hashlib.md5(password.encode()).hexdigest()
        print(f"Hashed password: {md5_hashed_password}")
        
        conn = db.get_db()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM USERS WHERE Lider = :lider", {'lider': lider})
        user = cursor.fetchone()
        print(f"Retrieved user: {user}")
        
        if user and user[0] == md5_hashed_password:
            session['user'] = user
            flash('Login successful!', 'success')
            return redirect(url_for('index'))
        else:
            flash('Invalid credentials, please try again.', 'danger')

    return render_template('login.html')

@app.route('/overview')
def overview():
    if 'user' not in session:
        return redirect(url_for('login'))

    user = session['user']
    #usertype = session['usertype'] como obter usertype?

    #overview_info = get_overview_info(usertype)

    return render_template('overview.html', user=user)

@app.route('/relatorios')
def relatorios():

    if 'user' not in session:
        return redirect(url_for('login'))

    #usertype = session['usertype']

    #relatorios_info = get_relatorios_info(usertype)

    return render_template('relatorios.html')


if __name__ == '__main__':
    app.run(debug=True)

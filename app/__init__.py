from flask import Flask, render_template, request, redirect, url_for, flash
import hashlib
import db

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

        # Hash the input password using MD5
        md5_hashed_password = hashlib.md5(password.encode()).hexdigest()

        conn = db.get_db()
        cursor = conn.cursor()

        cursor.execute("SELECT Password FROM USERS WHERE Lider = :lider", {'lider': lider})
        user = cursor.fetchone()

        if user and user[0] == md5_hashed_password:
            flash('Login successful!', 'success')
            return redirect(url_for('index'))
        else:
            flash('Invalid credentials, please try again.', 'danger')

    return render_template('login.html')

@app.route('/overview')
def overview():
    
    #lógica para obter infos de overview aqui

    return render_template('overview.html')

@app.route('/relatorios')
def relatorios():

    #lógica para gerar relatorios aqui

    return render_template('relatorios.html')


if __name__ == '__main__':
    app.run(debug=True)

from flask import Flask,render_template
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

    #logica de autenticação aqui
    
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

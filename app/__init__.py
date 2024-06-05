from flask import Flask,render_template

app = Flask(__name__)

app.config['SECRET_KEY'] = '[hashgrandona]'

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

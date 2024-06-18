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

# Líder de facção endpoints ---------------------------------------
@app.route('/alterar_nome_faccao', methods=['POST'])
def alterar_nome_faccao():
    novo_nome = request.form['novo_nome']
    # lógica para alterar o nome da facção
    flash('Nome da facção alterado com sucesso!', 'success')
    return redirect(url_for('overview'))

@app.route('/indicar_novo_lider', methods=['POST'])
def indicar_novo_lider():
    novo_lider = request.form['novo_lider']
    # lógica para indicar novo líder
    flash('Novo líder indicado com sucesso!', 'success')
    return redirect(url_for('overview'))

@app.route('/credenciar_comunidade', methods=['POST'])
def credenciar_comunidade():
    comunidade = request.form['comunidade']
    # lógica para credenciar comunidade
    flash('Comunidade credenciada com sucesso!', 'success')
    return redirect(url_for('overview'))

@app.route('/remover_faccao', methods=['POST'])
def remover_faccao():
    faccao = request.form['faccao']
    # lógica para remover facção
    flash('Facção removida com sucesso!', 'success')
    return redirect(url_for('overview'))

# Comandante endpoints ---------------------------------------
@app.route('/incluir_nacao_federacao', methods=['POST'])
def incluir_nacao_federacao():
    federacao = request.form['federacao']
    # lógica para incluir a nação na federação
    flash('Nação incluída na federação com sucesso!', 'success')
    return redirect(url_for('overview'))

@app.route('/excluir_nacao_federacao', methods=['POST'])
def excluir_nacao_federacao():
    federacao = request.form['federacao']
    # lógica para excluir a nação da federação
    flash('Nação excluída da federação com sucesso!', 'success')
    return redirect(url_for('overview'))

@app.route('/criar_nova_federacao', methods=['POST'])
def criar_nova_federacao():
    nova_federacao = request.form['nova_federacao']
    # lógica para criar nova federação
    flash('Nova federação criada com sucesso!', 'success')
    return redirect(url_for('overview'))

@app.route('/inserir_dominancia_planeta', methods=['POST'])
def inserir_dominancia_planeta():
    planeta = request.form['planeta']
    # lógica para inserir dominância do planeta
    flash('Dominância do planeta inserida com sucesso!', 'success')
    return redirect(url_for('overview'))

# Cientista endpoints ---------------------------------------
@app.route('/criar_estrela', methods=['POST'])
def criar_estrela():
    nome_estrela = request.form['nome_estrela']
    # lógica para criar estrela
    flash('Estrela criada com sucesso!', 'success')
    return redirect(url_for('overview'))

@app.route('/atualizar_estrela', methods=['POST'])
def atualizar_estrela():
    estrela_id = request.form['estrela_id']
    novo_nome = request.form['novo_nome']
    # lógica para atualizar estrela
    flash('Estrela atualizada com sucesso!', 'success')
    return redirect(url_for('overview'))

@app.route('/deletar_estrela', methods=['POST'])
def deletar_estrela():
    estrela_id = request.form['estrela_id']
    # lógica para deletar estrela
    flash('Estrela deletada com sucesso!', 'success')
    return redirect(url_for('overview'))

@app.route('/listar_estrelas', methods=['POST'])
def listar_estrelas():
    # lógica para listar estrelas
    flash('Lista de estrelas atualizada!', 'success')
    return redirect(url_for('overview'))

if __name__ == '__main__':
    app.run(debug=True)
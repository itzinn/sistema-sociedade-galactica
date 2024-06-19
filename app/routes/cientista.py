from flask import Blueprint, request, redirect, url_for, flash

cientista_bp = Blueprint('cientista', __name__)

@cientista_bp.route('/criar_estrela', methods=['POST'])
def criar_estrela():
    nome_estrela = request.form['nome_estrela']
    # logic to create star
    flash('Estrela criada com sucesso!', 'success')
    return redirect(url_for('overview.overview'))

@cientista_bp.route('/atualizar_estrela', methods=['POST'])
def atualizar_estrela():
    estrela_id = request.form['estrela_id']
    novo_nome = request.form['novo_nome']
    # logic to update star
    flash('Estrela atualizada com sucesso!', 'success')
    return redirect(url_for('overview.overview'))

@cientista_bp.route('/deletar_estrela', methods=['POST'])
def deletar_estrela():
    estrela_id = request.form['estrela_id']
    # logic to delete star
    flash('Estrela deletada com sucesso!', 'success')
    return redirect(url_for('overview.overview'))

@cientista_bp.route('/listar_estrelas', methods=['POST'])
def listar_estrelas():
    # logic to list stars
    flash('Lista de estrelas atualizada!', 'success')
    return redirect(url_for('overview.overview'))

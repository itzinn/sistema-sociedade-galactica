from flask import Blueprint, request, redirect, url_for, flash
from utils.procedures import (
    call_criar_estrela,
    call_atualizar_estrela,
    call_deletar_estrela,
    call_listar_estrelas
)

cientista_bp = Blueprint('cientista', __name__)

@cientista_bp.route('/criar_estrela', methods=['POST'])
def criar_estrela():
    id_estrela = request.form['id_estrela']
    nome = request.form['nome']
    classificacao = request.form['classificacao']
    massa = request.form['massa']
    x = request.form['x']
    y = request.form['y']
    z = request.form['z']

    try:
        call_criar_estrela(id_estrela, nome, classificacao, massa, x, y, z)
        flash('Estrela criada com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao criar estrela: {e}', 'danger')
    
    return redirect(url_for('overview.overview'))

@cientista_bp.route('/atualizar_estrela', methods=['POST'])
def atualizar_estrela():
    id_estrela = request.form['id_estrela']
    nome = request.form['nome']
    classificacao = request.form['classificacao']
    massa = request.form['massa']
    x = request.form['x']
    y = request.form['y']
    z = request.form['z']

    try:
        call_atualizar_estrela(id_estrela, nome, classificacao, massa, x, y, z)
        flash('Estrela atualizada com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao atualizar estrela: {e}', 'danger')
    
    return redirect(url_for('overview.overview'))

@cientista_bp.route('/deletar_estrela', methods=['POST'])
def deletar_estrela():
    id_estrela = request.form['id_estrela']

    try:
        call_deletar_estrela(id_estrela)
        flash('Estrela deletada com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao deletar estrela: {e}', 'danger')
    
    return redirect(url_for('overview.overview'))

@cientista_bp.route('/listar_estrelas', methods=['POST'])
def listar_estrelas():
    try:
        estrelas = call_listar_estrelas()
        # Do something with the results if needed
        flash('Lista de estrelas atualizada!', 'success')
    except Exception as e:
        flash(f'Erro ao listar estrelas: {e}', 'danger')
    
    return redirect(url_for('overview.overview'))

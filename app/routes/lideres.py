from flask import Blueprint, request, redirect, url_for, flash
from utils.procedures import call_alterar_nome_faccao

lideres_bp = Blueprint('lideres', __name__)

@lideres_bp.route('/alterar_nome_faccao', methods=['POST'])
def alterar_nome_faccao():
    novo_nome = request.form['novo_nome']
    call_alterar_nome_faccao(novo_nome)
    flash('Nome da facção alterado com sucesso!', 'success')
    return redirect(url_for('overview.overview'))

@lideres_bp.route('/indicar_novo_lider', methods=['POST'])
def indicar_novo_lider():
    novo_lider = request.form['novo_lider']
    # logic to indicate new leader
    flash('Novo líder indicado com sucesso!', 'success')
    return redirect(url_for('overview.overview'))

@lideres_bp.route('/credenciar_comunidade', methods=['POST'])
def credenciar_comunidade():
    comunidade = request.form['comunidade']
    # logic to credential community
    flash('Comunidade credenciada com sucesso!', 'success')
    return redirect(url_for('overview.overview'))

@lideres_bp.route('/remover_faccao', methods=['POST'])
def remover_faccao():
    faccao = request.form['faccao']
    # logic to remove faction
    flash('Facção removida com sucesso!', 'success')
    return redirect(url_for('overview.overview'))

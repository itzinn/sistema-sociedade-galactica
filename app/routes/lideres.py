from flask import Blueprint, request, redirect, url_for, session, flash
from utils.procedures import (
    call_alterar_nome_faccao,
    call_indicar_novo_lider,
    call_cadastrar_nova_comunidade,
    call_remover_relacao_facao
)

lideres_bp = Blueprint('lideres', __name__)

@lideres_bp.route('/alterar_nome_faccao', methods=['POST'])
def alterar_nome_faccao():
    novo_nome = request.form['novo_nome']
    cpi = session.get('cpi')
    
    if not cpi:
        flash('Usuário não autenticado', 'danger')
        return redirect(url_for('auth.login'))
    
    try:
        call_alterar_nome_faccao(cpi, novo_nome)
        flash('Nome da facção alterado com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao alterar nome da facção: {e}', 'danger')
    
    return redirect(url_for('overview.overview'))

@lideres_bp.route('/indicar_novo_lider', methods=['POST'])
def indicar_novo_lider():
    novo_lider = request.form['novo_lider']
    cpi = session.get('cpi')
    
    if not cpi:
        flash('Usuário não autenticado', 'danger')
        return redirect(url_for('auth.login'))
    
    try:
        call_indicar_novo_lider(cpi, novo_lider)
        flash('Novo líder indicado com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao indicar novo líder: {e}', 'danger')
    
    return redirect(url_for('overview.overview'))

@lideres_bp.route('/credenciar_comunidade', methods=['POST'])
def credenciar_comunidade():
    comunidade = request.form['comunidade']
    cpi = session.get('cpi')
    
    if not cpi:
        flash('Usuário não autenticado', 'danger')
        return redirect(url_for('auth.login'))
    
    try:
        call_cadastrar_nova_comunidade(cpi, comunidade)
        flash('Comunidade credenciada com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao credenciar comunidade: {e}', 'danger')
    
    return redirect(url_for('overview.overview'))

@lideres_bp.route('/remover_faccao', methods=['POST'])
def remover_faccao():
    faccao = request.form['faccao']
    cpi = session.get('cpi')
    
    if not cpi:
        flash('Usuário não autenticado', 'danger')
        return redirect(url_for('auth.login'))
    
    try:
        call_remover_relacao_facao(cpi, faccao)
        flash('Facção removida com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao remover facção: {e}', 'danger')
    
    return redirect(url_for('overview.overview'))

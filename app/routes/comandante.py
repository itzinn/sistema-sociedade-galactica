from flask import Blueprint, request, redirect, url_for, session, flash
from datetime import datetime

from utils.procedures import (
    call_incluir_federacao,
    call_excluir_federacao,
    call_criar_nova_federacao,
    call_inserir_dominancia_planeta
)

comandante_bp = Blueprint('comandante', __name__)

@comandante_bp.route('/incluir_nacao_federacao', methods=['POST'])
def incluir_nacao_federacao():
    federacao = request.form['federacao']
    cpi = session.get('cpi')
    
    if not cpi:
        flash('Usuário não autenticado', 'danger')
        return redirect(url_for('auth.login'))

    try:
        call_incluir_federacao(cpi, federacao)
        flash('Nação incluída na federação com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao incluir nação na federação: {e}', 'danger')
    
    return redirect(url_for('overview.overview'))

@comandante_bp.route('/excluir_nacao_federacao', methods=['POST'])
def excluir_nacao_federacao():
    federacao = request.form['federacao']
    cpi = session.get('cpi')

    if not cpi:
        flash('Usuário não autenticado', 'danger')
        return redirect(url_for('auth.login'))

    try:
        call_excluir_federacao(cpi, federacao)
        flash('Nação excluída da federação com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao excluir nação da federação: {e}', 'danger')

    return redirect(url_for('overview.overview'))

@comandante_bp.route('/criar_nova_federacao', methods=['POST'])
def criar_nova_federacao():
    nova_federacao = request.form['nova_federacao']
    data_fundacao = datetime.now().date()
    cpi = session.get('cpi')

    if not cpi:
        flash('Usuário não autenticado', 'danger')
        return redirect(url_for('auth.login'))

    try:
        call_criar_nova_federacao(cpi, nova_federacao, data_fundacao)
        flash('Nova federação criada com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao criar nova federação: {e}', 'danger')

    return redirect(url_for('overview.overview'))

@comandante_bp.route('/inserir_dominancia_planeta', methods=['POST'])
def inserir_dominancia_planeta():
    planeta = request.form['planeta']
    cpi = session.get('cpi')

    if not cpi:
        flash('Usuário não autenticado', 'danger')
        return redirect(url_for('auth.login'))

    try:
        call_inserir_dominancia_planeta(cpi, planeta)
        flash('Dominância do planeta inserida com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao inserir dominância do planeta: {e}', 'danger')

    return redirect(url_for('overview.overview'))

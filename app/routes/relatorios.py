from flask import Blueprint, render_template, session, redirect, url_for, request
import db
from utils.get_infos import get_relatorios_info, get_relatorios_lider_info


relatorios_bp = Blueprint('relatorios', __name__)

@relatorios_bp.route('/relatorios')
def relatorios():
    if 'cpi' not in session:
        return redirect(url_for('auth.login'))

    usertype = session['usertype']
    cpi = session['cpi']
    action = 'DOMINIO'
    ehLider = session['e_lider']

    # Extrair os parâmetros da URL
    data_inicio = request.args.get('data_inicio')
    data_fim = request.args.get('data_fim')

    # Se os parâmetros não foram fornecidos na URL
    if data_inicio is None:
        data_inicio = '2023-01-01'
    if data_fim is None:
        data_fim = '2024-01-01'

    relatorios_info = get_relatorios_info(usertype,cpi,action,data_inicio,data_fim)
    relatorios_lider_info = get_relatorios_lider_info(ehLider)

    return render_template('relatorios.html', relatorios_info=relatorios_info, relatorios_lider_info=relatorios_lider_info)

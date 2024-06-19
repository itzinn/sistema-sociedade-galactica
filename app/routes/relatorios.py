from flask import Blueprint, render_template, session, redirect, url_for
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

    relatorios_info = get_relatorios_info(usertype,cpi,action)
    relatorios_lider_info = get_relatorios_lider_info(ehLider)

    return render_template('relatorios.html', relatorios_info=relatorios_info, relatorios_lider_info=relatorios_lider_info)


# Define more relatorios-related routes here if needed

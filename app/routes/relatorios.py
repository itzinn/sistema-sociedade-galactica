from flask import Blueprint, render_template, session, redirect, url_for
import db

relatorios_bp = Blueprint('relatorios', __name__)

@relatorios_bp.route('/relatorios')
def relatorios():
    if 'user' not in session:
        return redirect(url_for('auth.login'))

    return render_template('relatorios.html')

# Define more relatorios-related routes here if needed

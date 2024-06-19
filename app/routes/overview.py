from flask import Blueprint, render_template, session, redirect, url_for
import db
from utils.get_infos import get_overview_info, get_faction_lider_info

overview_bp = Blueprint('overview', __name__)

@overview_bp.route('/overview')
def overview():
    if 'user' not in session:
        return redirect(url_for('auth.login'))

    usertype = session['usertype']
    ehLider = session['ehLider']

    overview_info = get_overview_info(usertype)
    faction_lider_info = get_faction_lider_info(ehLider)

    username = session['name']
    return render_template('overview.html', username=username, overview_info=overview_info, faction_lider_info=faction_lider_info)


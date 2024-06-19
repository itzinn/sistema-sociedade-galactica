from flask import Blueprint, request, redirect, url_for, flash

comandante_bp = Blueprint('comandante', __name__)

@comandante_bp.route('/incluir_nacao_federacao', methods=['POST'])
def incluir_nacao_federacao():
    federacao = request.form['federacao']
    # logic to include nation in federation
    flash('Nação incluída na federação com sucesso!', 'success')
    return redirect(url_for('overview.overview'))

@comandante_bp.route('/excluir_nacao_federacao', methods=['POST'])
def excluir_nacao_federacao():
    federacao = request.form['federacao']
    # logic to exclude nation from federation
    flash('Nação excluída da federação com sucesso!', 'success')
    return redirect(url_for('overview.overview'))

@comandante_bp.route('/criar_nova_federacao', methods=['POST'])
def criar_nova_federacao():
    nova_federacao = request.form['nova_federacao']
    # logic to create new federation
    flash('Nova federação criada com sucesso!', 'success')
    return redirect(url_for('overview.overview'))

@comandante_bp.route('/inserir_dominancia_planeta', methods=['POST'])
def inserir_dominancia_planeta():
    planeta = request.form['planeta']
    # logic to insert dominance of the planet
    flash('Dominância do planeta inserida com sucesso!', 'success')
    return redirect(url_for('overview.overview'))

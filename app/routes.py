from flask import render_template, request, redirect, url_for
from app import app

@app.route('/login', methods=['GET', 'POST'])
def login():

    #logica de autenticação aqui
    
    return render_template('login.html')

@app.route('/overview')
def overview():
    
    #lógica para obter infos de overview aqui

    return render_template('overview.html')

@app.route('/relatorios')
def relatorios():

    #lógica para gerar relatorios aqui

    return render_template('relatorios.html')

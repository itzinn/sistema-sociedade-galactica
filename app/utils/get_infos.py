from utils.procedures import call_get_planet_info, call_monitor_planet_info, call_relatorio_estrelas

def get_overview_info(usertype):
    forms = ''
    if usertype == 'OFICIAL':
        forms = '<p>Oficiais não têm funcionalidades de gerenciamento.</p>'
    elif usertype == 'COMANDANTE':
        forms = '''
        <form method="post" action="/incluir_nacao_federacao">
            <label for="federacao">Nome da federação:</label>
            <input type="text" id="federacao" name="federacao">
            <button type="submit">Incluir Nação na Federação</button>
        </form>
        <form method="post" action="/excluir_nacao_federacao">
            <label for="federacao">Nome da federação:</label>
            <input type="text" id="federacao" name="federacao">
            <button type="submit">Excluir Nação da Federação</button>
        </form>
        <form method="post" action="/criar_nova_federacao">
            <label for="nova_federacao">Nome da nova federação:</label>
            <input type="text" id="nova_federacao" name="nova_federacao">
            <button type="submit">Criar Nova Federação</button>
        </form>
        <form method="post" action="/inserir_dominancia_planeta">
            <label for="planeta">Nome do planeta:</label>
            <input type="text" id="planeta" name="planeta">
            <button type="submit">Inserir Dominância do Planeta</button>
        </form>
        '''
    elif usertype == 'CIENTISTA':
        forms = '''
    <form method="post" action="/criar_estrela">
        <label for="p_id_estrela">ID da estrela:</label>
        <input type="text" id="p_id_estrela" name="p_id_estrela">
        <label for="p_nome">Nome da estrela:</label>
        <input type="text" id="p_nome" name="p_nome">
        <label for="p_classificacao">Classificação:</label>
        <input type="text" id="p_classificacao" name="p_classificacao">
        <label for="p_massa">Massa:</label>
        <input type="number" id="p_massa" name="p_massa">
        <label for="p_x">Coordenada X:</label>
        <input type="number" id="p_x" name="p_x">
        <label for="p_y">Coordenada Y:</label>
        <input type="number" id="p_y" name="p_y">
        <label for="p_z">Coordenada Z:</label>
        <input type="number" id="p_z" name="p_z">
        <button type="submit">Criar Estrela</button>
    </form>
    <form method="post" action="/ler_estrela">
        <label for="p_id_estrela_leitura">ID da estrela:</label>
        <input type="text" id="p_id_estrela_leitura" name="p_id_estrela_leitura">
        <button type="submit">Ler Estrela</button>
    </form>
    <form method="post" action="/atualizar_estrela">
        <label for="p_id_estrela_atualizacao">ID da estrela:</label>
        <input type="text" id="p_id_estrela_atualizacao" name="p_id_estrela_atualizacao">
        <label for="p_novo_nome">Novo nome da estrela:</label>
        <input type="text" id="p_novo_nome" name="p_novo_nome">
        <label for="p_nova_classificacao">Nova classificação:</label>
        <input type="text" id="p_nova_classificacao" name="p_nova_classificacao">
        <label for="p_nova_massa">Nova massa:</label>
        <input type="number" id="p_nova_massa" name="p_nova_massa">
        <label for="p_nova_x">Nova coordenada X:</label>
        <input type="number" id="p_nova_x" name="p_nova_x">
        <label for="p_nova_y">Nova coordenada Y:</label>
        <input type="number" id="p_nova_y" name="p_nova_y">
        <label for="p_nova_z">Nova coordenada Z:</label>
        <input type="number" id="p_nova_z" name="p_nova_z">
        <button type="submit">Atualizar Estrela</button>
    </form>
    <form method="post" action="/excluir_estrela">
        <label for="p_id_estrela_exclusao">ID da estrela:</label>
        <input type="text" id="p_id_estrela_exclusao" name="p_id_estrela_exclusao">
        <button type="submit">Excluir Estrela</button>
    </form>
    '''
    return forms

def get_faction_lider_info(ehLider):
    forms = ''
    if(ehLider == 'TRUE'):
        forms = '''
        <form method="post" action="/alterar_nome_faccao">
            <label for="novo_nome">Novo nome da facção:</label>
            <input type="text" id="novo_nome" name="novo_nome">
            <button type="submit">Alterar Nome</button>
        </form>
        <form method="post" action="/indicar_novo_lider">
            <label for="novo_lider">Novo líder:</label>
            <input type="text" id="novo_lider" name="novo_lider">
            <button type="submit">Indicar Novo Líder</button>
        </form>
        <form method="post" action="/credenciar_comunidade">
            <label for="comunidade">Credenciar comunidade:</label>
            <input type="text" id="comunidade" name="comunidade">
            <button type="submit">Credenciar Comunidade</button>
        </form>
        <form method="post" action="/remover_faccao">
            <label for="faccao">Facção a remover:</label>
            <input type="text" id="faccao" name="faccao">
            <button type="submit">Remover Facção</button>
        </form>
        '''

    return forms

def get_relatorios_info(usertype, cpi, action):
    info = ''
    if usertype == 'OFICIAL':
        pass
    elif usertype == 'COMANDANTE':
        info = '<br><hr><br>'
        info += '<h2>Relatório de Comandante</h2><br>'
        planet_info = call_get_planet_info(cpi, action)
        info += planet_info

        info += '<br><br>'
        info += '''
        <form action="/relatorios" method="GET">
            <label for="data_inicio">Data Início:</label>
            <input type="date" id="data_inicio" name="data_inicio">
            <label for="data_fim">Data Fim:</label>
            <input type="date" id="data_fim" name="data_fim">
            <input type="submit" value="Submit">
        </form>
        '''

        monitor_info = call_monitor_planet_info()
        info += monitor_info
        
    elif usertype == 'CIENTISTA':
        info = '<br><hr><br>'
        info += '<h2>Relatório de Cientista</h2><br>'

        relatorio_estrelas = call_relatorio_estrelas()

        info += relatorio_estrelas

    return info

def get_relatorios_lider_info(ehLider):

    if(ehLider == 'TRUE'):
        info = '<br><hr><br>'
        info += '<br><h2>Relatório de Líder de Facção</h2><br>'
        info += '..vc é lider, parabens cara'

    return info
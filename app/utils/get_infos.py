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
            <label for="nome_estrela">Nome da estrela:</label>
            <input type="text" id="nome_estrela" name="nome_estrela">
            <button type="submit">Criar Estrela</button>
        </form>
        <form method="post" action="/atualizar_estrela">
            <label for="estrela_id">ID da estrela:</label>
            <input type="text" id="estrela_id" name="estrela_id">
            <label for="novo_nome">Novo nome da estrela:</label>
            <input type="text" id="novo_nome" name="novo_nome">
            <button type="submit">Atualizar Estrela</button>
        </form>
        <form method="post" action="/deletar_estrela">
            <label for="estrela_id">ID da estrela:</label>
            <input type="text" id="estrela_id" name="estrela_id">
            <button type="submit">Deletar Estrela</button>
        </form>
        <form method="post" action="/listar_estrelas">
            <button type="submit">Listar Estrelas</button>
        </form>
        '''
    return forms


def get_relatorios_info(usertype):
    if usertype == 'OFICIAL':
        pass
    elif usertype == 'COMANDANTE':
        pass
    elif usertype == 'CIENTISTA':
        pass

def get_faction_lider_info(ehLider):
    if(ehLider):
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
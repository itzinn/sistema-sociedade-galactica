--ESTA FUNCIONANDO!!! -angi
------------------
-- LIDER FACCAO --
------------------

--Este arquivo contem o pacote lider com todos seus procedimentos e relatirios. Possui tambem as coleções usadas e triggers usado pelos pacotes.

--Coleções usado  no procudere alterar_nome_faccao
CREATE TYPE nf_row_type AS OBJECT (
	nacao VARCHAR2(15),
	faccao VARCHAR2(15)
);
/
CREATE OR REPLACE TYPE participa_row_type AS OBJECT (
	faccao VARCHAR2(15),
	especie VARCHAR2(15),
	comunidade VARCHAR2(15)
);
/
CREATE OR REPLACE TYPE nf_table_type AS TABLE OF nf_row_type;
/
CREATE OR REPLACE TYPE participa_table_type AS TABLE OF participa_row_type;
/

	
--View e triggers

--View para gerenciamento de comunidade
-- A visão GERENCIAMENTO_FACCAO da uma visão consolidada das informações sobre facções, nações, planetas e comunidades. Facilita o gerenciamento e a análise desses dados. Ela mostra quais facções dominam quais planetas, quais nações estão associadas a essas facções e quais comunidades estão presentes nesses planetas. A visão também verifica se uma comunidade está credenciada com uma facção específica, indicando isso com um status de 'CREDENCIADA' ou 'NAO CREDENCIADA'. Este status de credenciamento é determinado pela presença ou ausência de registros na tabela PARTICIPA.
CREATE OR REPLACE VIEW GERENCIAMENTO_FACCAO AS
SELECT 
	F.LIDER,
	NF.FACCAO,
	NF.NACAO,
	P.ID_ASTRO AS PLANETA,
	C.NOME AS COMUNIDADE,
	CASE 
		WHEN PA.FACCAO IS NOT NULL THEN 'CREDENCIADA'
		ELSE 'NAO CREDENCIADA'
	END AS STATUS
FROM 
	FACCAO F JOIN 
	NACAO_FACCAO NF ON F.NOME = NF.FACCAO JOIN 
	DOMINANCIA D ON NF.NACAO = D.NACAO AND D.DATA_FIM IS NULL JOIN 
	PLANETA P ON D.PLANETA = P.ID_ASTRO JOIN 
	HABITACAO H ON P.ID_ASTRO = H.PLANETA AND H.DATA_FIM IS NULL JOIN 
	COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME LEFT JOIN 
	PARTICIPA PA ON C.ESPECIE = PA.ESPECIE AND C.NOME = PA.COMUNIDADE AND NF.FACCAO = PA.FACCAO;


--Trigger é utilizado para manter automaticamente atualizada a quantidade de planetas dominados por uma nação na tabela NACAO. Quando um novo planeta é dominado (inserido) ou deixa de ser dominado (atualizado ou deletado) na tabela DOMINANCIA, o trigger pega o nome da nação e quando a operação acaba ele recalcula a quantidade de planetas atualmente dominados por essa nação e atualiza a tabela NACAO com o valor correto. Isso garante que a tabela NACAO sempre tenha o número de planetas sob domínio de cada nação atualizado.

CREATE OR REPLACE TRIGGER GERENCIAR_PARTICIPA
	INSTEAD OF INSERT OR DELETE ON GERENCIAMENTO_FACCAO
	FOR EACH ROW
DECLARE
	v_especie VARCHAR2(15);
BEGIN
	IF INSERTING THEN
		BEGIN
			SELECT ESPECIE INTO v_especie FROM COMUNIDADE WHERE NOME = :NEW.COMUNIDADE;
			INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES (:NEW.FACCAO, v_especie, :NEW.COMUNIDADE);
		EXCEPTION
			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR(-20002, 'Erro ao inserir na tabela PARTICIPA: ' || SQLERRM);
		END;
	ELSIF DELETING THEN
		BEGIN
			SELECT ESPECIE INTO v_especie FROM COMUNIDADE WHERE NOME = :OLD.COMUNIDADE;
			DELETE FROM PARTICIPA WHERE FACCAO = :OLD.FACCAO AND ESPECIE = v_especie AND COMUNIDADE = :OLD.COMUNIDADE;
		EXCEPTION
			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR(-20004, 'Erro ao deletar da tabela PARTICIPA: ' || SQLERRM);
		END;
	END IF;
END;
/

--Trigger para fazer update de planetas na tabela Nacao quando um planeta novo é dominado ou deixa de ser dominado
CREATE OR replace TRIGGER trg_update_qtd_planetas
FOR INSERT OR UPDATE OR DELETE ON DOMINANCIA
COMPOUND TRIGGER

	v_nacao VARCHAR2(15);

	BEFORE EACH ROW IS
	BEGIN
		CASE
			WHEN INSERTING THEN
				IF :NEW.DATA_FIM IS NULL THEN
					v_nacao := :NEW.NACAO;
				END IF;
			WHEN UPDATING THEN
				IF :NEW.DATA_FIM IS NULL THEN
					v_nacao := :NEW.NACAO;
				END IF;
			WHEN DELETING THEN
				IF :OLD.DATA_FIM IS NULL THEN
					v_nacao := :OLD.NACAO;
				END IF;
		END CASE;
	END BEFORE EACH ROW;

	AFTER STATEMENT IS
	BEGIN
		DECLARE
			v_qtd_planetas NUMBER;
		BEGIN
			IF v_nacao IS NOT NULL THEN
	
				SELECT COUNT(*) INTO v_qtd_planetas
				FROM DOMINANCIA
				WHERE NACAO = v_nacao AND DATA_FIM IS NULL;

				UPDATE NACAO
				SET QTD_PLANETAS = v_qtd_planetas
				WHERE NOME = v_nacao;
			END IF;
		END;
	END AFTER STATEMENT;

END trg_update_qtd_planetas;
/

-- Este trigger é usado para atualizar automaticamente a quantidade de nações associadas a uma facção na tabela FACCAO toda vez que uma entrada é inserida, atualizada ou deletada na tabela NACAO_FACCAO. Quando uma operação de inserção, atualização ou exclusão ocorre, o trigger pega o nome da facção e recalcula a quantidade de nações associadas à facção e atualiza a tabela FACCAO. 
create or replace TRIGGER trg_update_qtd_nacoes
FOR INSERT OR UPDATE OR DELETE ON NACAO_FACCAO
COMPOUND TRIGGER

	v_faccao VARCHAR2(15);

	BEFORE EACH ROW IS
	BEGIN
		CASE
			WHEN INSERTING THEN
				v_faccao := :NEW.FACCAO;
			WHEN UPDATING THEN
				v_faccao := :NEW.FACCAO;
			WHEN DELETING THEN
				v_faccao := :OLD.FACCAO;
		END CASE;
	END BEFORE EACH ROW;

	AFTER STATEMENT IS
	BEGIN
		DECLARE
			v_qtd_nacoes NUMBER;
			chave_unica EXCEPTION;
			PRAGMA EXCEPTION_INIT(chave_unica, -00001);
		BEGIN
			SELECT COUNT(*) INTO v_qtd_nacoes FROM NACAO_FACCAO WHERE FACCAO = v_faccao;
			UPDATE FACCAO SET QTD_NACOES = v_qtd_nacoes WHERE NOME = v_faccao;
		EXCEPTION
		WHEN chave_unica THEN
			DBMS_OUTPUT.PUT_LINE('Chave unica violada');
		WHEN OTHERS THEN
			RAISE;
		END;
	END AFTER STATEMENT;

END trg_update_qtd_nacoes;
/










	
--Pacote
CREATE OR REPLACE PACKAGE PacoteLiderFaccao AS

	PROCEDURE alterar_nome_faccao(p_cpi IN CHAR, p_novo_nome IN VARCHAR2);
	PROCEDURE indicar_novo_lider(p_cpi IN CHAR, p_novo_lider IN CHAR);
	PROCEDURE cadastrar_nova_comunidade(p_cpi IN CHAR, p_comunidade IN VARCHAR2);
	PROCEDURE eliminar_comunidade(p_cpi IN CHAR, p_comunidade IN VARCHAR2);
	PROCEDURE remover_relacao_facao(cpi IN CHAR, nacao IN VARCHAR2);
	PROCEDURE get_communities_info(p_cpi IN LIDER.CPI%TYPE, p_group_by IN VARCHAR2);


END PacoteLiderFaccao;
/

	
CREATE OR REPLACE PACKAGE BODY PacoteLiderFaccao AS

	--Função para saber a facção do lider
	FUNCTION faccao_de_lider(p_cpi LIDER.CPI%TYPE) RETURN VARCHAR2 IS
		v_nome_facao FACCAO.NOME%TYPE;
	BEGIN
		SELECT NOME INTO v_nome_facao FROM FACCAO WHERE LIDER = p_cpi;
		RETURN v_nome_facao;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('usuario não é lider de uma facção');
		WHEN OTHERS THEN
			RAISE;
	END faccao_de_lider;


	-- O procedimento alterar_nome_faccao altera o nome de uma facção liderada pelo líder especificado através de seu CPI. Primeiro verifica se o usuário é de fato líder de alguma facção, caso contrário, lança uma exceção e exibe uma mensagem de erro. Depois coleta todas as associações atuais da facção nas tabelas NACAO_FACCAO e PARTICIPA, removendo-as temporariamente para evitar o erro de entradas filhas ao atualizar o nome da faccao. O nome da facção é então atualizado na tabela FACCAO, e as associações coletadas anteriormente são reatualizadas com o novo nome da facção. Por ultimo, o procedimento verifica se a operação foi bem-sucedida e confirma a alteração, ou, em caso de erro, exibe uma mensagem de erro e executa um rollback para garantir a integridade dos dados. 
	PROCEDURE alterar_nome_faccao(p_cpi IN CHAR, p_novo_nome IN VARCHAR2) IS
		v_nome_faccao FACCAO.NOME%TYPE;
		v_nf_linhas nf_table_type;
		v_participa_linhas participa_table_type;
		nao_lider EXCEPTION;
		erro_alterar EXCEPTION;

	BEGIN
		v_nome_faccao := faccao_de_lider(p_cpi);

		IF v_nome_faccao IS NULL THEN
			RAISE nao_lider;
			--RETURN;
		END IF;

		--DBMS_OUTPUT.PUT_LINE('1');
		SELECT CAST(COLLECT(nf_row_type(NACAO, FACCAO)) AS nf_table_type) INTO v_nf_linhas FROM NACAO_FACCAO WHERE FACCAO = v_nome_faccao;
		--DBMS_OUTPUT.PUT_LINE('2');
		SELECT CAST(COLLECT(participa_row_type(FACCAO, ESPECIE, COMUNIDADE)) AS participa_table_type) INTO v_participa_linhas FROM PARTICIPA WHERE FACCAO = v_nome_faccao;

		DELETE FROM NACAO_FACCAO WHERE FACCAO = v_nome_faccao;
		DELETE FROM PARTICIPA WHERE FACCAO = v_nome_faccao;

		UPDATE FACCAO SET NOME = p_novo_nome WHERE NOME = v_nome_faccao;

		FOR i IN 1..v_nf_linhas.COUNT LOOP
			v_nf_linhas(i).faccao := p_novo_nome;
		END LOOP;

		FOR i IN 1..v_participa_linhas.COUNT LOOP
			v_participa_linhas(i).faccao := p_novo_nome;
		END LOOP;


		FOR i IN 1..v_nf_linhas.COUNT LOOP
			INSERT INTO NACAO_FACCAO VALUES (v_nf_linhas(i).nacao, v_nf_linhas(i).faccao);
		END LOOP;

		FOR i IN 1..v_participa_linhas.COUNT LOOP
			INSERT INTO PARTICIPA VALUES (v_participa_linhas(i).faccao, v_participa_linhas(i).especie, v_participa_linhas(i).comunidade);
		END LOOP;


		IF SQL%ROWCOUNT = 0 THEN
			--DBMS_OUTPUT.PUT_LINE('Erro ao alterar o nome da facção.');
			RAISE erro_alterar;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Nome da facção alterado com sucesso de ' || v_nome_faccao || ' para ' || p_novo_nome);
			COMMIT;
		END IF;

		
	EXCEPTION
		WHEN erro_alterar THEN
			DBMS_OUTPUT.PUT_LINE('Erro ao alterar o nome da facção.');
		WHEN nao_lider THEN
			DBMS_OUTPUT.PUT_LINE('Usuário não é líder de nenhuma facção.');
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Erro ao alterar o nome da facção: ' || SQLERRM);
			ROLLBACK;
	END;


	-- O procedimento cadastrar_nova_comunidade associa uma nova comunidade à facção liderada pelo líder. Primeiramente, verifica se o usuário é de fato líder de alguma facção, caso contrário, exibe uma mensagem de erro e encerra a execução. Em seguida, verifica se a comunidade já está associada à facção na view GERENCIAMENTO_FACCAO para evitar duplicações. Se a comunidade não estiver associada, o procedimento recupera a espécie da comunidade e insere a nova associação na tabela GERENCIAMENTO_FACCAO. Caso a operação seja bem-sucedida, uma mensagem de confirmação é exibida e a transação é confirmada com um COMMIT.
	PROCEDURE cadastrar_nova_comunidade(p_cpi IN CHAR, p_comunidade IN VARCHAR2) IS
		v_nome_facao FACCAO.NOME%TYPE;
		v_especie ESPECIE.NOME%TYPE;
		v_check_faccao FACCAO.NOME%TYPE;

		faccao_errado EXCEPTION;
		erro_alterar EXCEPTION;

	BEGIN
		v_nome_facao := faccao_de_lider(p_cpi);

		IF v_nome_facao IS NULL THEN
			RAISE erro_alterar;
			--RETURN;
		END IF;

		SELECT FACCAO INTO v_check_faccao FROM GERENCIAMENTO_FACCAO WHERE COMUNIDADE = p_comunidade AND FACCAO = v_nome_facao;


		SELECT ESPECIE INTO v_especie FROM COMUNIDADE WHERE NOME = p_comunidade;
		DBMS_OUTPUT.PUT_LINE('Especie ' ||v_especie);

		INSERT INTO GERENCIAMENTO_FACCAO (FACCAO, COMUNIDADE) VALUES (v_nome_facao, p_comunidade);

		DBMS_OUTPUT.PUT_LINE('Comunidade ' || p_comunidade || ' adicionada à facção ' || v_nome_facao);
		COMMIT;

	EXCEPTION
		WHEN erro_alterar THEN
			DBMS_OUTPUT.PUT_LINE('Usuário não é líder de nenhuma facção.');
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('A comunidade não pertence a faccao.');
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Erro ao cadastrar nova comunidade: ' || SQLERRM);
			ROLLBACK;
	END;


	-- O procedimento eliminar_comunidade remove a associação de uma comunidade específica da facção liderada pelo líder. Primeiramente, ele verifica se o usuário é de fato líder de alguma facção, exibindo uma mensagem de erro e encerrando a execução caso contrário. Em seguida, verifica se a comunidade está associada à facção na visão GERENCIAMENTO_FACCAO. Se a comunidade estiver associada, o procedimento remove a associação da tabela GERENCIAMENTO_FACCAO e confirma a remoção exibindo uma mensagem de confirmação e executando um COMMIT. Caso a comunidade não seja encontrada ou ocorra um erro durante o processo, uma mensagem de erro é exibida e a transação é revertida com um ROLLBACK para garantir a integridade dos dados. 
	PROCEDURE eliminar_comunidade(p_cpi IN CHAR, p_comunidade IN VARCHAR2) IS
		v_nome_facao FACCAO.NOME%TYPE;
		v_check_faccao FACCAO.NOME%TYPE;

		nao_lider EXCEPTION;

	BEGIN
		v_nome_facao := faccao_de_lider(p_cpi);

		IF v_nome_facao IS NULL THEN
			RAISE nao_lider;
			--RETURN;
		END IF;

		SELECT FACCAO INTO v_check_faccao FROM GERENCIAMENTO_FACCAO WHERE COMUNIDADE = p_comunidade AND FACCAO = v_nome_facao;

		DELETE FROM GERENCIAMENTO_FACCAO WHERE FACCAO = v_nome_facao AND COMUNIDADE = p_comunidade;

		DBMS_OUTPUT.PUT_LINE('Comunidade ' || p_comunidade || ' deletada da facção ' || v_nome_facao);
		COMMIT;

	EXCEPTION
		WHEN nao_lider THEN
			DBMS_OUTPUT.PUT_LINE('Usuário não é líder de nenhuma facção.');
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Comunidade não encontrada.');
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Erro ao cadastrar nova comunidade: ' || SQLERRM);
			ROLLBACK;
	END;


	--O procedimento indicar_novo_lider tem como objetivo atualizar o líder de uma facção, nomeando um novo líder baseado no CPI fornecido. Primeiramente, ele verifica se o usuário atual é realmente líder de uma facção, exibindo uma mensagem de erro e encerrando a execução caso contrário. Em seguida, obtém a nação do novo líder candidato e verifica se este líder pertence à mesma facção da nação associada, garantindo que a mudança seja válida. Se todas as condições forem satisfeitas, o procedimento atualiza a tabela FACCAO com o novo líder e confirma a operação com um COMMIT, exibindo uma mensagem de sucesso. Caso o novo líder não pertença à facção ou ocorra qualquer outro erro durante o processo, uma mensagem de erro é exibida e a transação é revertida com um ROLLBACK, 
	PROCEDURE indicar_novo_lider(p_cpi IN CHAR, p_novo_lider IN CHAR) IS
		v_nacao LIDER.NACAO%TYPE;
		v_nome_facao FACCAO.NOME%TYPE;
		v_check_facao FACCAO.NOME%TYPE;
		lider_novo_errado EXCEPTION;
		nao_lider EXCEPTION;

	BEGIN

		v_nome_facao := faccao_de_lider(p_cpi);

		IF v_nome_facao IS NULL THEN
			RAISE nao_lider;
			--RETURN;
		END IF;

		SELECT NACAO INTO v_nacao FROM LIDER WHERE CPI = p_novo_lider;

		SELECT FACCAO INTO v_check_facao FROM NACAO_FACCAO WHERE NACAO = v_nacao AND FACCAO = v_nome_facao;
		IF v_check_facao IS NULL THEN
			RAISE lider_novo_errado;
		END IF;


		UPDATE FACCAO SET LIDER = p_novo_lider WHERE NOME = v_nome_facao;

		DBMS_OUTPUT.PUT_LINE('Líder da facção ' || v_nome_facao || ' atualizado para ' || p_novo_lider);
		COMMIT;

	EXCEPTION
		WHEN nao_lider THEN
			DBMS_OUTPUT.PUT_LINE('Usuário não é líder de nenhuma facção.');
		WHEN lider_novo_errado THEN
			DBMS_OUTPUT.PUT_LINE('Lider não pertence a faccao.');
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Erro ao indicar novo líder: ' || SQLERRM);
			ROLLBACK;
	END;


	-- O procedimento remover_relacao_facao tem como objetivo remover a relação entre uma facção e uma nação especificada. Primeiro, verifica se o usuário é realmente líder de alguma facção e se a nação fornecida não é nula, lançando uma exceção se qualquer uma dessas condições não for satisfeita. Em seguida, tenta deletar a entrada correspondente na tabela NACAO_FACCAO que associa a facção e a nação. Após a remoção, verifica se alguma linha foi afetada; caso contrário, lança uma exceção indicando que nada foi deletado. Se a remoção for bem-sucedida, exibe uma mensagem de confirmação e executa um COMMIT para confirmar a transação. Em caso de erro, uma mensagem apropriada é exibida e a transação é revertida com um ROLLBACK. Quando é deletado uma entrada da tabela nação facção o trigger atualiza a quantidade de planetas
	PROCEDURE remover_relacao_facao(cpi IN CHAR, nacao IN VARCHAR2) IS
		v_nome_facao FACCAO.NOME%TYPE;
		v_nacao NACAO_FACCAO.NACAO%TYPE;
		rows_deleted NUMBER;
		nada_deletado EXCEPTION;
		PRAGMA EXCEPTION_INIT(nada_deletado, -20001);
		valor_null EXCEPTION;
	BEGIN
		v_nome_facao := faccao_de_lider(cpi);
		v_nacao := nacao;

		IF v_nacao IS NULL OR v_nome_facao IS NULL THEN 
			RAISE valor_null;
		END IF;

		DELETE FROM NACAO_FACCAO WHERE FACCAO = v_nome_facao AND NACAO = v_nacao;

		rows_deleted := SQL%ROWCOUNT;
		IF rows_deleted = 0 THEN
			RAISE_APPLICATION_ERROR(-20001, 'Nada deletado');
		ELSE
			DBMS_OUTPUT.PUT_LINE('Facção ' || v_nome_facao || ' removida de ' || v_nacao);
			COMMIT;
		END IF;

		EXCEPTION
			WHEN nada_deletado THEN
				DBMS_OUTPUT.PUT_LINE('Nada deletado');
			WHEN valor_null THEN
				DBMS_OUTPUT.PUT_LINE('Valor nulo');
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('Erro ao remover relação: ' || SQLERRM);
				ROLLBACK;
	END;


	-- Procedure que retorna os valores de todas as comunidades da facção de um lider, agrupadas por Nação, Especie, Planeta ou Sistema. Agrupamento é definido por parâmetro. 
	PROCEDURE get_communities_info (
		p_cpi IN LIDER.CPI%TYPE,
		p_group_by IN VARCHAR2
	) IS
	BEGIN
		IF p_group_by = 'NACAO' THEN
			DBMS_OUTPUT.PUT_LINE('Agrupando por Nação:');
			FOR r IN (
				SELECT c.ESPECIE, c.NOME, c.QTD_HABITANTES, n.NOME AS nacao_nome
				FROM LIDER l
				JOIN FACCAO f ON l.CPI = f.LIDER
				JOIN PARTICIPA p ON f.NOME = p.FACCAO
				JOIN COMUNIDADE c ON p.ESPECIE = c.ESPECIE AND p.COMUNIDADE = c.NOME
				JOIN NACAO n ON l.NACAO = n.NOME
				WHERE l.CPI = p_cpi
				GROUP BY n.NOME
			) LOOP
				DBMS_OUTPUT.PUT_LINE('Nação: ' || r.nacao_nome || ', Comunidade: ' || r.NOME || ', Espécie: ' || r.ESPECIE || ', Qtd Habitantes: ' || r.QTD_HABITANTES);
			END LOOP;
		ELSIF p_group_by = 'ESPECIE' THEN
			DBMS_OUTPUT.PUT_LINE('Agrupando por Espécie:');
			FOR r IN (
				SELECT c.ESPECIE, c.NOME, c.QTD_HABITANTES
				FROM LIDER l
				JOIN FACCAO f ON l.CPI = f.LIDER
				JOIN PARTICIPA p ON f.NOME = p.FACCAO
				JOIN COMUNIDADE c ON p.ESPECIE = c.ESPECIE AND p.COMUNIDADE = c.NOME
				WHERE l.CPI = p_cpi
				GROUP BY c.ESPECIE
			) LOOP
				DBMS_OUTPUT.PUT_LINE('Espécie: ' || r.ESPECIE || ', Comunidade: ' || r.NOME || ', Qtd Habitantes: ' || r.QTD_HABITANTES);
			END LOOP;
		ELSIF p_group_by = 'PLANETA' THEN
			DBMS_OUTPUT.PUT_LINE('Agrupando por Planeta:');
			FOR r IN (
				SELECT c.ESPECIE, c.NOME, c.QTD_HABITANTES, e.PLANETA_OR
				FROM LIDER l
				JOIN FACCAO f ON l.CPI = f.LIDER
				JOIN PARTICIPA p ON f.NOME = p.FACCAO
				JOIN COMUNIDADE c ON p.ESPECIE = c.ESPECIE AND p.COMUNIDADE = c.NOME
				JOIN ESPECIE e ON c.ESPECIE = e.NOME
				WHERE l.CPI = p_cpi
				GROUP BY e.PLANETA_OR
			) LOOP
				DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.PLANETA_OR || ', Comunidade: ' || r.NOME || ', Espécie: ' || r.ESPECIE || ', Qtd Habitantes: ' || r.QTD_HABITANTES);
			END LOOP;
		ELSIF p_group_by = 'SISTEMA' THEN
			DBMS_OUTPUT.PUT_LINE('Agrupando por Sistema:');
			FOR r IN (
				SELECT c.ESPECIE, c.NOME, c.QTD_HABITANTES, s.NOME AS sistema_nome
				FROM LIDER l
				JOIN FACCAO f ON l.CPI = f.LIDER
				JOIN PARTICIPA p ON f.NOME = p.FACCAO
				JOIN COMUNIDADE c ON p.ESPECIE = c.ESPECIE AND p.COMUNIDADE = c.NOME
				JOIN ESPECIE e ON c.ESPECIE = e.NOME
				JOIN PLANETA pl ON e.PLANETA_OR = pl.ID_ASTRO
				JOIN ORBITA_PLANETA op ON pl.ID_ASTRO = op.PLANETA
				JOIN SISTEMA s ON op.ESTRELA = s.ESTRELA
				WHERE l.CPI = p_cpi
				GROUP BY s.NOME
			) LOOP
				DBMS_OUTPUT.PUT_LINE('Sistema: ' || r.sistema_nome || ', Comunidade: ' || r.NOME || ', Espécie: ' || r.ESPECIE || ', Qtd Habitantes: ' || r.QTD_HABITANTES);
			END LOOP;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Agrupamento não especificado ou inválido.');
		END IF;
	END get_communities_info;


END PacoteLiderFaccao;
/






--Exemplo de uso em sql ELLIMINAR DEPOIS!!!
--DEClARE
--  nome_nacao NACAO.nome%TYPE;
--  nome_lider LIDER.cpi%TYPE;
--  novo_nome_faccao FACCAO.nome%TYPE;
--  comunidade_cadastrar COMUNIDADE.NOME%TYPE;
--  novo_lider NACAO.nome%TYPE;
--  lider_com LIDER.cpi%TYPE;

--BEGIN
--  nome_lider := '233.123.456-11'; --obtido pelo login do usuário no sistema
--  nome_nacao := 'NacaoP'; --Usuario que possui a função de lider insere o nome_nacao que deseja eliminar
--  novo_nome_faccao := 'amarillo'; --como vai ser conseguido? por meio da aplicação
--  comunidade_cadastrar := 'Comunidade A';
--  novo_lider := '111.456.789-00';
--  lider_com := '123.123.123-10';


  --PacoteLiderFaccao.alterar_nome_faccao(nome_lider, novo_nome_faccao);
  --PacoteLiderFaccao.indicar_novo_lider(nome_lider, novo_lider);
  --PacoteLiderFaccao.cadastrar_nova_comunidade(lider_com, comunidade_cadastrar);
  --PacoteLiderFaccao.eliminar_comunidade(lider_com, comunidade_cadastrar);
 -- PacoteLiderFaccao.remover_relacao_facao(novo_lider, nome_nacao);

--END;
--/








	








------------------
--  COMANDANTE  --
------------------

--Este arquivo contem o pacote comandante com todos seus procedimentos e relatirios.

CREATE OR REPLACE PACKAGE PacoteComandante AS

	PROCEDURE incluir_federacao(cpi IN CHAR, nome_federacao IN VARCHAR2);
	PROCEDURE excluir_federacao(cpi IN CHAR, nome_federacao IN VARCHAR2);
	PROCEDURE criar_nova_federacao(cpi IN CHAR, nome_federacao IN VARCHAR2, data_fundacao IN DATE);
	PROCEDURE inserir_dominancia_planeta(cpi IN CHAR, nome_planeta IN VARCHAR2);
	PROCEDURE get_planet_info(p_cpi IN LIDER.CPI%TYPE, p_action IN VARCHAR2);
	PROCEDURE monitor_planet_info(p_start_date IN DATE DEFAULT NULL, p_end_date IN DATE DEFAULT NULL);

END PacoteComandante;
/




CREATE OR REPLACE PACKAGE BODY PacoteComandante AS

	--Função que retorna a nação do comandante
	FUNCTION nacao_de_comandante(p_cpi LIDER.CPI%TYPE) RETURN VARCHAR2 IS
		v_nome_nacao LIDER.NACAO%TYPE;
	BEGIN 
		SELECT NACAO INTO v_nome_nacao FROM LIDER WHERE CPI = p_cpi;
		RETURN v_nome_nacao;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Não foi encontrado comandante');
			RETURN NULL;
		WHEN OTHERS THEN
			RAISE;
	END nacao_de_comandante;

	-- O procedimento incluir_federacao associa uma nação liderada por um comandante específico a uma federação fornecida. Primeiramente, ele obtém o nome da nação associada ao comandante e verifica se o nome da federação não é nulo. Depois verifica se a federação já existe na tabela FEDERACAO. Se a federação existir e o nome da nação não for nulo, o procedimento atualiza a tabela NACAO, associando a nação à nova federação. Caso ocorra algum erro durante essas verificações o procedimento lança uma exceção apropriada e exibe uma mensagem de erro. Se todas as condições forem satisfeitas, a atualização é confirmada com um COMMIT.
	PROCEDURE incluir_federacao(cpi IN CHAR, nome_federacao IN VARCHAR2) IS

		v_nome_nacao NACAO.NOME%TYPE;
		v_nome_federacao FEDERACAO.NOME%TYPE;
		v_check_federacao FEDERACAO.NOME%TYPE;

		não_nação EXCEPTION;
		valor_null EXCEPTION;
		federação_existe EXCEPTION;

	BEGIN
		v_nome_nacao := nacao_de_comandante(cpi);
		v_nome_federacao := nome_federacao;

		IF v_nome_nacao IS NULL THEN
			RAISE não_nação;
		END IF;

		IF v_nome_federacao IS NULL THEN
			RAISE valor_null;
		END IF;

		SELECT NOME INTO v_check_federacao FROM FEDERACAO WHERE NOME = v_nome_federacao;
		IF v_check_federacao IS NULL THEN
			RAISE federação_existe;
		END IF;

		UPDATE NACAO SET FEDERACAO = v_nome_federacao WHERE NOME = v_nome_nacao;

		COMMIT;

	EXCEPTION
		WHEN não_nação THEN
			DBMS_OUTPUT.PUT_LINE('Não foi encontrado comandante');
		WHEN valor_null THEN 
			DBMS_OUTPUT.PUT_LINE('Nome de federação nulo');
		WHEN OTHERS THEN
			ROLLBACK;
			DBMS_OUTPUT.PUT_LINE('Erro ao criar nova federação e nação: ' || SQLERRM);
	END incluir_federacao;

	-- O procedimento excluir_federacao tem como objetivo desassociar uma nação liderada por um comandante específico de uma federação fornecida. Primeiramente, ele obtém o nome da nação associada ao comandante e verifica se o nome da federação não é nulo. Em seguida, verifica se a federação existe na tabela FEDERACAO. Se a federação existir e o nome da nação não for nulo, o procedimento atualiza a tabela NACAO, removendo a associação da nação à federação, definindo o campo FEDERACAO como NULL. Caso ocorra algum erro durante essas verificações, como o comandante não estar associado a nenhuma nação, o nome da federação ser nulo ou a federação não existir, o procedimento lança uma exceção apropriada e exibe uma mensagem de erro. Se todas as condições forem satisfeitas, a atualização é confirmada com um COMMIT. Em caso de erro durante o processo, uma mensagem de erro é exibida e a transação é revertida com um ROLLBACK para garantir a integridade dos dados. Esta implementação assegura que as nações sejam corretamente desassociadas das federações quando necessário, mantendo a consistência e a integridade do banco de dados.
	PROCEDURE excluir_federacao(cpi IN CHAR, nome_federacao IN VARCHAR2) IS

		v_nome_nacao NACAO.NOME%TYPE;
		v_nome_federacao FEDERACAO.NOME%TYPE;
		v_check_federacao FEDERACAO.NOME%TYPE;

		não_nação EXCEPTION;
		valor_null EXCEPTION;
		federação_existe EXCEPTION;

	BEGIN
		v_nome_nacao := nacao_de_comandante(cpi);
		v_nome_federacao := nome_federacao;

		IF v_nome_nacao IS NULL THEN
			RAISE não_nação;
		END IF;

		IF v_nome_federacao IS NULL THEN
			RAISE valor_null;
		END IF;

		SELECT NOME INTO v_check_federacao FROM FEDERACAO WHERE NOME = v_nome_federacao;
		IF v_check_federacao IS NULL THEN
			RAISE federação_existe;
		END IF;

		UPDATE NACAO SET FEDERACAO = NULL WHERE NOME = v_nome_nacao;

		COMMIT;

	EXCEPTION
		WHEN não_nação THEN
			DBMS_OUTPUT.PUT_LINE('Não foi encontrado comandante');
		WHEN valor_null THEN 
			DBMS_OUTPUT.PUT_LINE('Nome de federação nulo');
		WHEN OTHERS THEN
			ROLLBACK;
			DBMS_OUTPUT.PUT_LINE('Erro ao criar nova federação e nação: ' || SQLERRM);
	END excluir_federacao;

	--O procedimento criar_nova_federacao tem como objetivo criar uma nova federação e associar a ela uma nação. Primeiramente, obtém o nome da nação associada ao comandante e verifica se o nome da federação fornecido não é nulo. Em seguida, tenta inserir a nova federação na tabela FEDERACAO com o nome e a data de fundação fornecidos. Se a federação for inserida com sucesso, o procedimento atualiza a tabela NACAO para associar a nação à nova federação. Caso ocorra algum erro durante o processo, como o comandante não estar associado a nenhuma nação, o nome da federação ser nulo ou a federação já existir, o procedimento lança uma exceção e exibe uma mensagem de erro.
	PROCEDURE criar_nova_federacao(cpi IN CHAR, nome_federacao IN VARCHAR2, data_fundacao IN DATE) IS

		v_nome_nacao NACAO.NOME%TYPE;
		v_nome_federacao FEDERACAO.NOME%TYPE;

		chave_violada EXCEPTION;
		PRAGMA EXCEPTION_INIT(chave_violada, -00001);
		valor_null EXCEPTION;
		não_nação EXCEPTION;

	BEGIN
		v_nome_nacao := nacao_de_comandante(cpi);
		v_nome_federacao := nome_federacao;
		IF v_nome_nacao IS NULL THEN
			RAISE não_nação;
		END IF;

		IF v_nome_federacao IS NULL THEN
			RAISE valor_null;
		END IF;

		INSERT INTO FEDERACAO (NOME, DATA_FUND) VALUES (v_nome_federacao, data_fundacao);
		UPDATE NACAO SET FEDERACAO = v_nome_federacao WHERE NOME = v_nome_nacao;

		COMMIT;

		EXCEPTION
			WHEN não_nação THEN
				DBMS_OUTPUT.PUT_LINE('Não foi encontrado comandante');
			WHEN valor_null THEN 
				DBMS_OUTPUT.PUT_LINE('Nome de federação nulo');
			WHEN chave_violada THEN
				DBMS_OUTPUT.PUT_LINE('Federação com o nome ' || nome_federacao || ' já existe.');
				ROLLBACK;
			WHEN OTHERS THEN
				ROLLBACK;
				DBMS_OUTPUT.PUT_LINE('Erro ao criar nova federação e nação: ' || SQLERRM);
	END criar_nova_federacao;


	--O procedimento remover_relacao_facao tem como objetivo remover a relação entre uma facção e uma nação especificada. Primeiramente, ele verifica se o usuário é realmente líder de alguma facção e se a nação fornecida não é nula, lançando uma exceção se qualquer uma dessas condições não for satisfeita. Em seguida, tenta deletar a entrada correspondente na tabela NACAO_FACCAO que associa a facção e a nação. Após a remoção, verifica se alguma linha foi afetada; caso contrário, lança uma exceção indicando que nada foi deletado. Se a remoção for bem-sucedida, exibe uma mensagem de confirmação e executa um COMMIT.
	PROCEDURE inserir_dominancia_planeta(cpi IN CHAR, nome_planeta IN VARCHAR2) IS

		v_nome_nacao NACAO.NOME%TYPE;
		v_nome_planeta PLANETA.ID_ASTRO%TYPE;
		v_qtd_planetas NACAO.QTD_PLANETAS%TYPE;
		v_check_dominancia PLANETA.ID_ASTRO%TYPE;

		planeta_dominado EXCEPTION;
		não_nação EXCEPTION;

	BEGIN
		v_nome_nacao := nacao_de_comandante(cpi);
		v_nome_planeta := nome_planeta;

		IF v_nome_nacao IS NULL THEN
			RAISE não_naçãO;
		END IF;


		SELECT COUNT(*) INTO v_check_dominancia FROM DOMINANCIA WHERE PLANETA = v_nome_planeta AND DATA_FIM IS NULL;
		IF v_check_dominancia > 0 THEN
			RAISE planeta_dominado;
		END IF;

		INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI) VALUES (v_nome_planeta, v_nome_nacao, SYSDATE);

		SELECT QTD_PLANETAS INTO v_qtd_planetas FROM NACAO WHERE NOME = v_nome_nacao;
		UPDATE NACAO SET QTD_PLANETAS = v_qtd_planetas + 1 WHERE NOME = v_nome_nacao;

		DBMS_OUTPUT.PUT_LINE('Dominância do planeta ' || v_nome_planeta || ' adicionada à nação ' || v_nome_nacao);
		COMMIT;

	EXCEPTION
		WHEN não_nação THEN
			DBMS_OUTPUT.PUT_LINE('Usuário não é comandante de nenhuma nação.');
		WHEN planeta_dominado THEN
			DBMS_OUTPUT.PUT_LINE('Erro: O planeta ' || nome_planeta || ' já está sendo dominado por outra nação.');
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Erro ao inserir nova dominância: ' || SQLERRM);
			ROLLBACK;
	END inserir_dominancia_planeta;


	-- Procedure que retorna informações de planetas dominados pela facção de um lider ou possíveis expansões para sua facção. A ação é definida por parâmetro.
	PROCEDURE get_planet_info (
		p_cpi IN LIDER.CPI%TYPE,
		p_action IN VARCHAR2
	) IS
		v_nacao LIDER.NACAO%TYPE;
	BEGIN
		SELECT NACAO INTO v_nacao FROM LIDER WHERE CPI = p_cpi;

		IF p_action = 'DOMINIO' THEN
			DBMS_OUTPUT.PUT_LINE('Relatório de Planetas Dominados:');
			FOR r IN (
				SELECT 
					pl.ID_ASTRO AS planeta,
					dom.NACAO AS nacao_dominante,
					TO_CHAR(dom.DATA_INI, 'DD/MM/YYYY') AS inicio_dominacao,
					TO_CHAR(dom.DATA_FIM, 'DD/MM/YYYY') AS fim_dominacao,
					c.NOME AS comunidade,
					e.NOME AS especie,
					c.QTD_HABITANTES AS total_habitantes,
					f.NOME AS faccao
				FROM PLANETA pl
				LEFT JOIN DOMINANCIA dom ON pl.ID_ASTRO = dom.PLANETA
				LEFT JOIN HABITACAO h ON pl.ID_ASTRO = h.PLANETA
				LEFT JOIN COMUNIDADE c ON h.ESPECIE = c.ESPECIE AND h.COMUNIDADE = c.NOME
				LEFT JOIN ESPECIE e ON c.ESPECIE = e.NOME
				LEFT JOIN PARTICIPA p ON c.ESPECIE = p.ESPECIE AND c.NOME = p.COMUNIDADE
				LEFT JOIN FACCAO f ON p.FACCAO = f.NOME
				WHERE dom.NACAO IS NOT NULL
				ORDER BY pl.ID_ASTRO, dom.DATA_INI
			) LOOP
				IF r.nacao_dominante = v_nacao THEN
					DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || ', Nação Dominante: ' || r.nacao_dominante || 
									 ', Início da Dominação: ' || r.inicio_dominacao || ', Fim da Dominação: ' || NVL(r.fim_dominacao, 'Atualmente dominado') || 
									 ', Comunidade: ' || r.comunidade || ', Espécie: ' || r.especie || 
									 ', Total Habitantes: ' || NVL(r.total_habitantes, 0) || ', Facção: ' || NVL(r.faccao, 'Nenhuma'));
				ELSE
					 DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || ', Nação Dominante: ' || r.nacao_dominante || 
									 ', Início da Dominação: ' || r.inicio_dominacao || ', Fim da Dominação: ' || NVL(r.fim_dominacao, 'Atualmente dominado') || 
									 ', Comunidade: ' || r.comunidade || ', Espécie: Inacessível' || 
									 ', Total Habitantes: Inacessível'  || ', Facção: ' || NVL(r.faccao, 'Nenhuma'));
				END IF;
			END LOOP;
		ELSIF p_action = 'EXPANSAO' THEN
			DBMS_OUTPUT.PUT_LINE('Relatório de Potencial de Expansão:');
			FOR r IN (
				SELECT 
					pl.ID_ASTRO AS planeta,
					pl.MASSA,
					pl.RAIO,
					pl.CLASSIFICACAO,
					es.NOME AS estrela,
					s.NOME AS sistema,
					(
						SELECT 
							MIN(SQRT(POWER(es.X - es_dominada.X, 2) + POWER(es.Y - es_dominada.Y, 2) + POWER(es.Z - es_dominada.Z, 2)))
						FROM DOMINANCIA d
						JOIN ORBITA_PLANETA op_dominada ON d.PLANETA = op_dominada.PLANETA
						JOIN ESTRELA es_dominada ON op_dominada.ESTRELA = es_dominada.ID_ESTRELA
						WHERE d.NACAO = v_nacao
					) AS distancia_ao_territorio
				FROM PLANETA pl
				JOIN ORBITA_PLANETA op ON pl.ID_ASTRO = op.PLANETA
				JOIN ESTRELA es ON op.ESTRELA = es.ID_ESTRELA
				JOIN SISTEMA s ON es.ID_ESTRELA = s.ESTRELA
				LEFT JOIN DOMINANCIA dom ON pl.ID_ASTRO = dom.PLANETA
				WHERE dom.NACAO IS NULL
				ORDER BY distancia_ao_territorio
			) LOOP
				IF r.distancia_ao_territorio IS NOT NULL THEN
					DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || ', Massa: ' || r.MASSA || ', Raio: ' || r.RAIO || 
										 ', Classificação: ' || r.CLASSIFICACAO || ', Sistema: ' || r.sistema || ', Estrela: ' || r.estrela ||
										 ', Distância ao Território: ' || r.distancia_ao_territorio);
				ELSE
					DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || ', Massa: ' || r.MASSA || ', Raio: ' || r.RAIO || 
										 ', Classificação: ' || r.CLASSIFICACAO || ', Sistema: ' || r.sistema || ', Estrela: ' || r.estrela ||
										 ', Distância ao Território: N/A');
				END IF;
			END LOOP;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Ação não especificada ou inválida.');
		END IF;
	END get_planet_info;


	PROCEDURE monitor_planet_info (
		p_start_date IN DATE DEFAULT NULL,
		p_end_date IN DATE DEFAULT NULL
	) IS
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Monitoramento de Planetas:');

		IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
			DBMS_OUTPUT.PUT_LINE('Intervalo de Tempo: ' || TO_CHAR(p_start_date, 'DD/MM/YYYY') || ' até ' || TO_CHAR(p_end_date, 'DD/MM/YYYY'));

			FOR r IN (
				SELECT
					pl.ID_ASTRO AS planeta,
					'DOMINACAO' AS tipo,
					dom.DATA_INI AS data_inicio,
					dom.DATA_FIM AS data_fim,
					dom.NACAO AS detalhe_1,
					NULL AS detalhe_2,
					NULL AS detalhe_3
				FROM PLANETA pl
				LEFT JOIN DOMINANCIA dom ON pl.ID_ASTRO = dom.PLANETA
				WHERE dom.DATA_INI <= p_end_date AND (dom.DATA_FIM >= p_start_date OR dom.DATA_FIM IS NULL)

				UNION ALL

				SELECT
					pl.ID_ASTRO AS planeta,
					'HABITACAO' AS tipo,
					h.DATA_INI AS data_inicio,
					h.DATA_FIM AS data_fim,
					h.ESPECIE AS detalhe_1,
					h.COMUNIDADE AS detalhe_2,
					NULL AS detalhe_3
				FROM PLANETA pl
				LEFT JOIN HABITACAO h ON pl.ID_ASTRO = h.PLANETA
				WHERE h.DATA_INI <= p_end_date AND (h.DATA_FIM >= p_start_date OR h.DATA_FIM IS NULL)

				ORDER BY planeta, data_inicio
			) LOOP
				IF r.tipo = 'DOMINACAO' THEN
					DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || 
										 ', Nação Dominante: ' || r.detalhe_1 || 
										 ', Início da Dominação: ' || TO_CHAR(r.data_inicio, 'DD/MM/YYYY') || 
										 ', Fim da Dominação: ' || NVL(TO_CHAR(r.data_fim, 'DD/MM/YYYY'), 'Atualmente dominado'));
				ELSIF r.tipo = 'HABITACAO' THEN
					DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || 
										 ', Espécie Habitante: ' || r.detalhe_1 || 
										 ', Comunidade Habitante: ' || r.detalhe_2 || 
										 ', Início da Habitação: ' || TO_CHAR(r.data_inicio, 'DD/MM/YYYY') || 
										 ', Fim da Habitação: ' || NVL(TO_CHAR(r.data_fim, 'DD/MM/YYYY'), 'Atualmente habitado'));
				END IF;
			END LOOP;

		ELSE
			DBMS_OUTPUT.PUT_LINE('Linha do Tempo Completa de Informações dos Planetas:');

			FOR r IN (
				SELECT
					pl.ID_ASTRO AS planeta,
					'DOMINACAO' AS tipo,
					dom.DATA_INI AS data_inicio,
					dom.DATA_FIM AS data_fim,
					dom.NACAO AS detalhe_1,
					NULL AS detalhe_2,
					NULL AS detalhe_3
				FROM PLANETA pl
				LEFT JOIN DOMINANCIA dom ON pl.ID_ASTRO = dom.PLANETA

				UNION ALL

				SELECT
					pl.ID_ASTRO AS planeta,
					'HABITACAO' AS tipo,
					h.DATA_INI AS data_inicio,
					h.DATA_FIM AS data_fim,
					h.ESPECIE AS detalhe_1,
					h.COMUNIDADE AS detalhe_2,
					NULL AS detalhe_3
				FROM PLANETA pl
				LEFT JOIN HABITACAO h ON pl.ID_ASTRO = h.PLANETA

				ORDER BY planeta, data_inicio
			) LOOP
				IF r.tipo = 'DOMINACAO' THEN
					DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || 
										 ', Nação Dominante: ' || r.detalhe_1 || 
										 ', Início da Dominação: ' || TO_CHAR(r.data_inicio, 'DD/MM/YYYY') || 
										 ', Fim da Dominação: ' || NVL(TO_CHAR(r.data_fim, 'DD/MM/YYYY'), 'Atualmente dominado'));
				ELSIF r.tipo = 'HABITACAO' THEN
					DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || 
										 ', Espécie Habitante: ' || r.detalhe_1 || 
										 ', Comunidade Habitante: ' || r.detalhe_2 || 
										 ', Início da Habitação: ' || TO_CHAR(r.data_inicio, 'DD/MM/YYYY') || 
										 ', Fim da Habitação: ' || NVL(TO_CHAR(r.data_fim, 'DD/MM/YYYY'), 'Atualmente habitado'));
				END IF;
			END LOOP;
		END IF;
	END monitor_planet_info;
	


END PacoteComandante;
/





--Exemplo para testar no oracle, DELETAR DEPOIS!!!
--DECLARE
--	nome_comandante LIDER.cpi%TYPE;
--	nome_federacao FEDERACAO.nome%TYPE;
--	data_fundacao DATE;
--	fed_nova FEDERACAO.nome%TYPE;
--	nome_planeta PLANETA.ID_ASTRO%TYPE;

--BEGIN
--	nome_comandante := '145.234.235-01'; -- Obtido pelo login do usuário no sistema
--	nome_federacao := 'FedNova'; -- Nome da nova federação a ser criada
--	data_fundacao := SYSDATE; -- Data de fundação da nova federação
--	fed_nova := 'Amet quo.';
--	nome_planeta := 'HATS-8 b'; 

	--PacoteComandante.criar_nova_federacao(nome_comandante, nome_federacao, data_fundacao);
	--PacoteComandante.incluir_federacao(nome_comandante, fed_nova);
	--PacoteComandante.excluir_federacao(nome_comandante, fed_nova);
	--PacoteComandante.inserir_dominancia_planeta(nome_comandante, nome_planeta);

-- EXCEPTION
--	WHEN OTHERS THEN
--		DBMS_OUTPUT.PUT_LINE('Erro ao executar o bloco PL/SQL: ' || SQLERRM);
--END;
--/


--SELECT * FROM FEDERACAO WHERE NOME = 'FedNova';
--SELECT * FROM NACAO WHERE NOME = 'NacaoBeta';





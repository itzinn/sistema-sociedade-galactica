---------------
-- CIENTISTA --
---------------

--Este arquivo contem o pacote cientista com todos seus procedimentos e relatirios.

CREATE OR REPLACE PACKAGE PacoteCientista AS
	
	PROCEDURE criar_estrela(p_id_estrela IN VARCHAR2, p_nome IN VARCHAR2, p_classificacao IN VARCHAR2, p_massa IN NUMBER, p_x IN NUMBER, p_y IN NUMBER, p_z IN NUMBER);
	PROCEDURE ler_estrela(p_id_estrela IN VARCHAR2);
	PROCEDURE atualizar_estrela(p_id_estrela IN VARCHAR2, p_nome IN VARCHAR2, p_classificacao IN VARCHAR2, p_massa IN NUMBER, p_x IN NUMBER, p_y IN NUMBER, p_z IN NUMBER);
	PROCEDURE excluir_estrela(p_id_estrela IN VARCHAR2);
	PROCEDURE relatorio_estrelas;
	PROCEDURE relatorio_planetas;
	PROCEDURE relatorio_sistemas;
	PROCEDURE relatorio_corpos_celestes(ref_id IN VARCHAR2, ref_type IN VARCHAR2, dist_min IN NUMBER, dist_max IN NUMBER);

END PacoteCientista;
/

CREATE OR REPLACE PACKAGE BODY PacoteCientista AS

	---- O procedimento criar_estrela tem como objetivo inserir um novo registro de estrela na tabela ESTRELA com os detalhes fornecidos como parâmetros. Se a inserção for bem-sucedida, a operação é confirmada com um COMMIT e uma mensagem de sucesso é exibida. 
	PROCEDURE criar_estrela(p_id_estrela IN VARCHAR2, p_nome IN VARCHAR2, p_classificacao IN VARCHAR2, p_massa IN NUMBER, p_x IN NUMBER, p_y IN NUMBER, p_z IN NUMBER) IS
		e_estrela_existente EXCEPTION;
		PRAGMA EXCEPTION_INIT(e_estrela_existente, -00001); -- ORA-00001: unique constraint violated

	BEGIN
		INSERT INTO ESTRELA (ID_ESTRELA, NOME, CLASSIFICACAO, MASSA, X, Y, Z) 
		VALUES (p_id_estrela, p_nome, p_classificacao, p_massa, p_x, p_y, p_z);
		COMMIT;
		dbms_output.put_line('Estrela ' || p_nome || ' criada com sucesso.');
  
	EXCEPTION
		WHEN e_estrela_existente THEN
		  dbms_output.put_line('Alguma característica única da estrela foi violada');
		WHEN OTHERS THEN
		  dbms_output.put_line('Erro ao criar estrela: ' || SQLERRM);
	END criar_estrela;

	--O procedimento ler_estrela tem como objetivo ler e exibir as informações detalhadas de uma estrela específica identificada pelo seu ID_ESTRELA. Caso nenhuma estrela seja encontrada com o ID_ESTRELA fornecido, uma exceção NO_DATA_FOUND é capturada, e uma mensagem informando que a estrela não foi encontrada é exibida.
	PROCEDURE ler_estrela(p_id_estrela IN VARCHAR2) IS
		v_nome ESTRELA.NOME%TYPE;
		v_classificacao ESTRELA.CLASSIFICACAO%TYPE;
		v_massa ESTRELA.MASSA%TYPE;
		v_x ESTRELA.X%TYPE;
		v_y ESTRELA.Y%TYPE;
		v_z ESTRELA.Z%TYPE;

	BEGIN
		SELECT NOME, CLASSIFICACAO, MASSA, X, Y, Z 
		INTO v_nome, v_classificacao, v_massa, v_x, v_y, v_z
		FROM ESTRELA
		WHERE ID_ESTRELA = p_id_estrela;

		dbms_output.put_line('Estrela: ' || v_nome);
		dbms_output.put_line('Classificação: ' || v_classificacao);
		dbms_output.put_line('Massa: ' || v_massa);
		dbms_output.put_line('Coordenadas: (' || v_x || ', ' || v_y || ', ' || v_z || ')');

  	EXCEPTION
		WHEN NO_DATA_FOUND THEN
	  		dbms_output.put_line('Estrela não encontrada.');
		WHEN OTHERS THEN
	  		dbms_output.put_line('Erro ao ler estrela: ' || SQLERRM);
  	END ler_estrela;


	-- O procedimento atualizar_estrela tem como objetivo atualizar as informações de uma estrela existente na tabela ESTRELA com os detalhes fornecidos como parâmetros. ele verifica se alguma linha foi afetada usando SQL%ROWCOUNT. Se nenhuma linha foi atualizada, uma exceção personalizada e_estrela_nao_encontrada é lançada, indicando que a estrela com o ID fornecido não foi encontrada.
	PROCEDURE atualizar_estrela(p_id_estrela IN VARCHAR2, p_nome IN VARCHAR2, p_classificacao IN VARCHAR2, p_massa IN NUMBER, p_x IN NUMBER, p_y IN NUMBER, p_z IN NUMBER) IS
		e_estrela_nao_encontrada EXCEPTION;
		PRAGMA EXCEPTION_INIT(e_estrela_nao_encontrada, -20001);

	BEGIN
		UPDATE ESTRELA SET NOME = p_nome, CLASSIFICACAO = p_classificacao, MASSA = p_massa, X = p_x, Y = p_y, Z = p_z WHERE ID_ESTRELA = p_id_estrela;

		IF SQL%ROWCOUNT = 0 THEN
		  RAISE e_estrela_nao_encontrada;
		END IF;
	  	COMMIT;
	  	dbms_output.put_line('Estrela ' || p_nome || ' atualizada com sucesso.');
	EXCEPTION
		WHEN e_estrela_nao_encontrada THEN
		  dbms_output.put_line('Estrela não encontrada.');
		WHEN OTHERS THEN
		  dbms_output.put_line('Erro ao atualizar estrela: ' || SQLERRM);
	END atualizar_estrela;


	--O procedimento excluir_estrela tem como objetivo remover uma estrela da tabela ESTRELA com base no ID_ESTRELA fornecido. Ele tenta deletar a estrela correspondente ao ID fornecido. Após a tentativa de exclusão, verifica se alguma linha foi afetada usando SQL%ROWCOUNT. Se nenhuma linha foi deletada, uma exceção personalizada e_estrela_nao_encontrada é lançada, indicando que a estrela com o ID fornecido não foi encontrada. Caso contrário, a operação é confirmada com um COMMIT e uma mensagem de sucesso é exibida.
	PROCEDURE excluir_estrela(p_id_estrela IN VARCHAR2) IS
		e_estrela_nao_encontrada EXCEPTION;
		PRAGMA EXCEPTION_INIT(e_estrela_nao_encontrada, -20001);

	BEGIN
		DELETE FROM ESTRELA WHERE ID_ESTRELA = p_id_estrela;

		IF SQL%ROWCOUNT = 0 THEN
		  RAISE e_estrela_nao_encontrada;
		ELSE
		  COMMIT;
		  dbms_output.put_line('Estrela excluída com sucesso.');
		END IF;
	EXCEPTION
		WHEN e_estrela_nao_encontrada THEN
		  dbms_output.put_line('Estrela não encontrada.');
		WHEN OTHERS THEN
		  dbms_output.put_line('Erro ao excluir estrela: ' || SQLERRM);
  	END excluir_estrela;

/*
		     __       __              _          
	  ____ ___  / /___ _ / /_ ___   ____ (_)___   ___
	 / __// -_)/ // _ `// __// _ \ / __// // _ \ (_-<
	/_/   \__//_/ \_,_/ \__/ \___//_/  /_/ \___//___/

*/

	PROCEDURE relatorio_estrelas IS
	-- Esse relatório retorna informações úteis para se catalogar estrelas
	-- As informações incluem os seguintes dados: ID, Nome, Classificação, Mass, Coordenadas e Número de planetas que a orbitam
	BEGIN
		FOR r IN (
		  SELECT e.ID_ESTRELA, e.NOME, e.CLASSIFICACAO, e.MASSA, e.X, e.Y, e.Z, COUNT(op.PLANETA) AS NUM_PLANETAS
		  FROM ESTRELA e
		  LEFT JOIN ORBITA_PLANETA op ON e.ID_ESTRELA = op.ESTRELA
		  GROUP BY e.ID_ESTRELA, e.NOME, e.CLASSIFICACAO, e.MASSA, e.X, e.Y, e.Z
		) LOOP
		  dbms_output.put_line('ID Estrela: ' || r.ID_ESTRELA || ', Nome: ' || r.NOME || ', Classificação: ' || r.CLASSIFICACAO || ', Massa: ' || r.MASSA || ', Coordenadas: (' || r.X || ', ' || r.Y || ', ' || r.Z || '), Número de Planetas: ' || r.NUM_PLANETAS);
		END LOOP;

	EXCEPTION
		WHEN OTHERS THEN
		  dbms_output.put_line('Erro ao gerar relatório de estrelas: ' || SQLERRM);
	END relatorio_estrelas;


	PROCEDURE relatorio_planetas IS
	-- Esse relatório retorna informações úteis para se catalogar planetas
	-- As informações incluem os seguintes dados: ID, Massa, Raio, Classificação e Número de Espécies que nele habitam.
	BEGIN
		FOR r IN (
		  SELECT p.ID_ASTRO, p.MASSA, p.RAIO, p.CLASSIFICACAO, COUNT(h.ESPECIE) AS NUM_ESPECIES
		  FROM PLANETA p
		  LEFT JOIN HABITACAO h ON p.ID_ASTRO = h.PLANETA
		  GROUP BY p.ID_ASTRO, p.MASSA, p.RAIO, p.CLASSIFICACAO
		) LOOP
		  dbms_output.put_line('ID Planeta: ' || r.ID_ASTRO || ', Massa: ' || r.MASSA || ', Raio: ' || r.RAIO || ', Classificação: ' || r.CLASSIFICACAO || ', Número de Espécies: ' || r.NUM_ESPECIES);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
		  dbms_output.put_line('Erro ao gerar relatório de planetas: ' || SQLERRM);
	END relatorio_planetas;


	PROCEDURE relatorio_sistemas IS
	-- Esse relatório retorna informações úteis para se catalogar sistemas inteiros
	-- As informações incluem os seguintes dados: ID da estrela principal, Nome da estrela principal, Nome do Sistema, Número de Planetas, Número de Estrelas Orbitantes com relação à estrela principal.
	BEGIN
		FOR r IN (
		  SELECT s.ESTRELA, e.NOME AS NOME_ESTRELA, s.NOME AS NOME_SISTEMA, 
				 COUNT(op.PLANETA) AS NUM_PLANETAS, COUNT(oe.ORBITANTE) AS NUM_ESTRELAS_ORBITANTES
		  FROM SISTEMA s
		  JOIN ESTRELA e ON s.ESTRELA = e.ID_ESTRELA
		  LEFT JOIN ORBITA_PLANETA op ON s.ESTRELA = op.ESTRELA
		  LEFT JOIN ORBITA_ESTRELA oe ON s.ESTRELA = oe.ORBITADA
		  GROUP BY s.ESTRELA, e.NOME, s.NOME
		) LOOP
		  dbms_output.put_line('ID Estrela: ' || r.ESTRELA || ', Nome da Estrela: ' || r.NOME_ESTRELA || ', Nome do Sistema: ' || r.NOME_SISTEMA || ', Número de Planetas: ' || r.NUM_PLANETAS || ', Número de Estrelas Orbitantes: ' || r.NUM_ESTRELAS_ORBITANTES);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
		  dbms_output.put_line('Erro ao gerar relatório de sistemas: ' || SQLERRM);
	END relatorio_sistemas;






	/*
												=====================
		Relatório de corpos celestes que distam uma estrela/sistema selecionado		=+= VERSÃO BÁSICA =+=
												=====================
	*/
	PROCEDURE relatorio_corpos_celestes(ref_id IN VARCHAR2, ref_type IN VARCHAR2, dist_min IN NUMBER, dist_max IN NUMBER) IS
	/*
		Esse relatório é pensado em retornar todos os corpos celestes (estrelas e planetas) que estão em uma faixa de distância deteminada de uma estrela ou sistema.
		Parâmetros:
			ref_id	: id de uma estrela ou nome de um sistema
			ref_type: tipo definido como ESTRELA ou SISTEMA
			dist_min: um número
			dist_max: um número

		A forma de cálculo de distâncias é um filtro na busca, que calcula a distância em cada consulta. Mas detalhes abaixo.
	*/
	ref_x NUMBER;
	ref_y NUMBER;
	ref_z NUMBER;
  	BEGIN
		-- Primeiro, coletamos as coordenadas da estrela
		IF ref_type = 'ESTRELA' THEN
		BEGIN
			SELECT e.X, e.Y, e.Z
			INTO ref_x, ref_y, ref_z
			FROM ESTRELA e
			WHERE e.ID_ESTRELA = ref_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('Estrela de referência não encontrada.');
			RETURN;
			WHEN TOO_MANY_ROWS THEN
			dbms_output.put_line('Erro: múltiplas estrelas com o mesmo ID de referência.');
			RETURN;
			WHEN OTHERS THEN
			dbms_output.put_line('Erro ao obter coordenadas da estrela de referência: ' || SQLERRM);
			RETURN;
		END;

		-- No caso de passarem um sistema, devemos pegar a estrela principal dele para extrair suas coordenadas
		ELSIF ref_type = 'SISTEMA' THEN
		BEGIN
			SELECT e.X, e.Y, e.Z
			INTO ref_x, ref_y, ref_z
			FROM ESTRELA e
			JOIN SISTEMA s ON e.ID_ESTRELA = s.ESTRELA
			WHERE s.NOME = ref_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('Sistema de referência não encontrado.');
			RETURN;
			WHEN TOO_MANY_ROWS THEN
			dbms_output.put_line('Erro: múltiplas entradas com o mesmo ID de referência.');
			RETURN;
			WHEN OTHERS THEN
			dbms_output.put_line('Erro ao obter coordenadas do sistema de referência: ' || SQLERRM);
			RETURN;
		END;
		ELSE
		dbms_output.put_line('Tipo de referência inválido. Deve ser "ESTRELA" ou "SISTEMA".');
		RETURN;
		END IF;

		-- Aqui temos a consulta em si
		-- Primeiro, selecionamos todas as estrelas que estejam na área desejada (filtro determinado pela distância euclidiana entre elas)
		-- Depois, fazemos um UNION com todos os planetas que estão nessa área, usando a mesma estratégia.
		-- Para calcular a distância do planeta, busca-se a estrela que ele orbita, calcula-se a distância dela para a referência e soma-se com a distância mínima entre planeta e sua estrela
		FOR r IN (
		SELECT 'Estrela' AS TIPO, e.ID_ESTRELA AS ID, e.NOME, e.CLASSIFICACAO, e.MASSA, e.X, e.Y, e.Z,
				SQRT(POWER(e.X - ref_x, 2) + POWER(e.Y - ref_y, 2) + POWER(e.Z - ref_z, 2)) AS DISTANCIA
		FROM ESTRELA e
		WHERE SQRT(POWER(e.X - ref_x, 2) + POWER(e.Y - ref_y, 2) + POWER(e.Z - ref_z, 2)) BETWEEN dist_min AND dist_max
		UNION ALL
		SELECT 'Planeta' AS TIPO, p.ID_ASTRO AS ID, NULL AS NOME, p.CLASSIFICACAO, p.MASSA, op.X, op.Y, op.Z,
				SQRT(POWER(op.X - ref_x, 2) + POWER(op.Y - ref_y, 2) + POWER(op.Z - ref_z, 2)) + op.DIST_MIN AS DISTANCIA
		FROM PLANETA p
		JOIN (SELECT op.PLANETA, e.X, e.Y, e.Z, op.DIST_MIN
				FROM ORBITA_PLANETA op
				JOIN ESTRELA e ON op.ESTRELA = e.ID_ESTRELA) op
		ON p.ID_ASTRO = op.PLANETA
		WHERE (SQRT(POWER(op.X - ref_x, 2) + POWER(op.Y - ref_y, 2) + POWER(op.Z - ref_z, 2)) + op.DIST_MIN) BETWEEN dist_min AND dist_max
		ORDER BY DISTANCIA
		) LOOP
		dbms_output.put_line('Tipo: ' || r.TIPO || ', ID: ' || r.ID || ', Nome: ' || r.NOME || ', Classificação: ' || r.CLASSIFICACAO || ', Massa: ' || TO_CHAR(r.MASSA, 'FM0.099999') || ', Coordenadas: (' || TO_CHAR(r.X, 'FM0.099999') || ', ' || TO_CHAR(r.Y, 'FM0.099999') || ', ' || TO_CHAR(r.Z, 'FM0.099999') || '), Distância: ' || TO_CHAR(r.DISTANCIA, 'FM0.099999'));
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
		  dbms_output.put_line('Erro ao gerar relatório de corpos celestes: ' || SQLERRM);
	END relatorio_corpos_celestes;






	/*
												========================
		Relatório de corpos celestes que distam uma estrela/sistema selecionado		=+= VERSÃO OTIMIZADA =+=
												========================
	*/
	PROCEDURE relatorio_cc_otimizado(ref_id IN VARCHAR2, ref_type IN VARCHAR2, dist_min IN NUMBER, dist_max IN NUMBER) IS
	/*
		Esse relatório é pensado em retornar todos os corpos celestes (estrelas e planetas) que estão em uma faixa de distância deteminada de uma estrela ou sistema.
		Parâmetros:
			ref_id	: id de uma estrela ou nome de um sistema
			ref_type: tipo definido como ESTRELA ou SISTEMA
			dist_min: um número
			dist_max: um número

		As distâncias não são calculadas nas consultas, desta vez. Elas veêm de uma consulta à tabela DISTANCIAS_ESTRELAS.
	*/
		ref_x NUMBER;
		ref_y NUMBER;
		ref_z NUMBER;
	  BEGIN
		-- Obter coordenadas da estrela ou sistema de referência
		IF ref_type = 'ESTRELA' THEN
		  BEGIN
			SELECT e.X, e.Y, e.Z
			INTO ref_x, ref_y, ref_z
			FROM ESTRELA e
			WHERE e.ID_ESTRELA = ref_id;
		  EXCEPTION
			WHEN NO_DATA_FOUND THEN
			  dbms_output.put_line('Estrela de referência não encontrada.');
			  RETURN;
			WHEN TOO_MANY_ROWS THEN
			  dbms_output.put_line('Erro: múltiplas estrelas com o mesmo ID de referência.');
			  RETURN;
			WHEN OTHERS THEN
			  dbms_output.put_line('Erro ao obter coordenadas da estrela de referência: ' || SQLERRM);
			  RETURN;
		  END;

		-- Caso sistema, pegar a estrela dele
		ELSIF ref_type = 'SISTEMA' THEN
		  BEGIN
			SELECT e.X, e.Y, e.Z
			INTO ref_x, ref_y, ref_z
			FROM ESTRELA e
			JOIN SISTEMA s ON e.ID_ESTRELA = s.ESTRELA
			WHERE s.NOME = ref_id;
		  EXCEPTION
			WHEN NO_DATA_FOUND THEN
			  dbms_output.put_line('Sistema de referência não encontrado.');
			  RETURN;
			WHEN TOO_MANY_ROWS THEN
			  dbms_output.put_line('Erro: múltiplas entradas com o mesmo ID de referência.');
			  RETURN;
			WHEN OTHERS THEN
			  dbms_output.put_line('Erro ao obter coordenadas do sistema de referência: ' || SQLERRM);
			  RETURN;
		  END;
		ELSE
		  dbms_output.put_line('Tipo de referência inválido. Deve ser "ESTRELA" ou "SISTEMA".');
		  RETURN;
		END IF;
	
		-- Consultar corpos celestes dentro do intervalo de distâncias usando as informações da tabela DISTANCIAS_ESTRELAS
		-- Para estrelas, a mera distância basta
		-- Para planetas, somamos a distância entre a estrela referência a e orbitada por ele com sua distância mínima à ela
		FOR r IN (
		  SELECT 'Estrela' AS TIPO, e.ID_ESTRELA AS ID, e.NOME, e.CLASSIFICACAO, e.MASSA, e.X, e.Y, e.Z,
				 d.Distancia AS DISTANCIA
		  FROM ESTRELA e
		  JOIN DISTANCIAS_ESTRELAS d ON (d.Estrela1_ID = ref_id AND d.Estrela2_ID = e.ID_ESTRELA)
									OR (d.Estrela1_ID = e.ID_ESTRELA AND d.Estrela2_ID = ref_id)
		  WHERE d.Distancia BETWEEN dist_min AND dist_max
		  UNION ALL
		  SELECT 'Planeta' AS TIPO, p.ID_ASTRO AS ID, NULL AS NOME, p.CLASSIFICACAO, p.MASSA, op.X, op.Y, op.Z,
				 d.Distancia + op.DIST_MIN AS DISTANCIA
		  FROM PLANETA p
		  JOIN (SELECT op.PLANETA, e.X, e.Y, e.Z, op.DIST_MIN, op.ESTRELA
				FROM ORBITA_PLANETA op
				JOIN ESTRELA e ON op.ESTRELA = e.ID_ESTRELA) op
		  ON p.ID_ASTRO = op.PLANETA
		  JOIN DISTANCIAS_ESTRELAS d ON (d.Estrela1_ID = ref_id AND d.Estrela2_ID = op.ESTRELA)
									OR (d.Estrela1_ID = op.ESTRELA AND d.Estrela2_ID = ref_id)
		  WHERE (d.Distancia + op.DIST_MIN) BETWEEN dist_min AND dist_max
		  ORDER BY DISTANCIA
		) LOOP
		  dbms_output.put_line('Tipo: ' || r.TIPO || ', ID: ' || r.ID || ', Nome: ' || r.NOME || ', Classificação: ' || r.CLASSIFICACAO || 
							   ', Massa: ' || TO_CHAR(r.MASSA, 'FM0.000000') || 
							   ', Coordenadas: (' || TO_CHAR(r.X, 'FM9999990.000000') || ', ' || 
													TO_CHAR(r.Y, 'FM9999990.000000') || ', ' || 
													TO_CHAR(r.Z, 'FM9999990.000000') || 
							   '), Distância: ' || TO_CHAR(r.DISTANCIA, 'FM9999990.000000'));
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
		  dbms_output.put_line('Erro ao gerar relatório de corpos celestes: ' || SQLERRM);
	END relatorio_cc_otimizado;

END PacoteCientista;
/

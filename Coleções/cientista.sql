---------------
-- CIENTISTA --
---------------

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

	PROCEDURE relatorio_corpos_celestes(ref_id IN VARCHAR2, ref_type IN VARCHAR2, dist_min IN NUMBER, dist_max IN NUMBER) IS
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

		-- Consultar corpos celestes dentro do intervalo de distâncias
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

END PacoteCientista;
/

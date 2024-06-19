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


END PacoteCientista;
/
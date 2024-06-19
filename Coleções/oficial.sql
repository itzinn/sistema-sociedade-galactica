CREATE OR REPLACE PACKAGE PacoteOficial AS
  PROCEDURE relatorio_habitantes_por_nacao(p_nome_nacao IN VARCHAR2, p_agrupamento IN VARCHAR2 DEFAULT NULL);
END PacoteOficial;
/

CREATE OR REPLACE PACKAGE BODY PacoteOficial AS

  PROCEDURE relatorio_habitantes_por_nacao(p_nome_nacao IN VARCHAR2, p_agrupamento IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
	CASE p_agrupamento
	  WHEN 'PLANETA' THEN
		FOR r IN (
		  SELECT n.NOME AS NACAO, h.PLANETA, SUM(c.QTD_HABITANTES) AS QTD_HABITANTES
		  FROM HABITACAO h
			JOIN COMUNIDADE c ON h.ESPECIE = c.ESPECIE AND h.COMUNIDADE = c.NOME
			JOIN PLANETA p ON h.PLANETA = p.ID_ASTRO
			JOIN DOMINANCIA d ON p.ID_ASTRO = d.PLANETA
			LEFT JOIN NACAO n ON d.NACAO = n.NOME
		  WHERE n.NOME = p_nome_nacao
		  GROUP BY n.NOME, h.PLANETA
		  ORDER BY h.PLANETA
		) LOOP
		  dbms_output.put_line('Nação: ' || r.NACAO || ', Planeta: ' || r.PLANETA || ', Quantidade de Habitantes: ' || r.QTD_HABITANTES);
		END LOOP;

	  WHEN 'ESPECIE' THEN
		FOR r IN (
		  SELECT n.NOME AS NACAO, h.ESPECIE, SUM(c.QTD_HABITANTES) AS QTD_HABITANTES
		  FROM HABITACAO h
			JOIN COMUNIDADE c ON h.ESPECIE = c.ESPECIE AND h.COMUNIDADE = c.NOME
			JOIN PLANETA p ON h.PLANETA = p.ID_ASTRO
			JOIN DOMINANCIA d ON p.ID_ASTRO = d.PLANETA
			LEFT JOIN NACAO n ON d.NACAO = n.NOME
		  WHERE n.NOME = p_nome_nacao
		  GROUP BY n.NOME, h.ESPECIE
		  ORDER BY h.ESPECIE
		) LOOP
		  dbms_output.put_line('Nação: ' || r.NACAO || ', Espécie: ' || r.ESPECIE || ', Quantidade de Habitantes: ' || r.QTD_HABITANTES);
		END LOOP;

	  WHEN 'FACCAO' THEN
		FOR r IN (
		  SELECT n.NOME AS NACAO, f.NOME AS FACCAO, SUM(c.QTD_HABITANTES) AS QTD_HABITANTES
		  FROM HABITACAO h
			JOIN COMUNIDADE c ON h.ESPECIE = c.ESPECIE AND h.COMUNIDADE = c.NOME
			JOIN PLANETA p ON h.PLANETA = p.ID_ASTRO
			JOIN DOMINANCIA d ON p.ID_ASTRO = d.PLANETA
			LEFT JOIN NACAO n ON d.NACAO = n.NOME
			LEFT JOIN NACAO_FACCAO nf ON n.NOME = nf.NACAO
			LEFT JOIN FACCAO f ON nf.FACCAO = f.NOME
		  WHERE n.NOME = p_nome_nacao
		  GROUP BY n.NOME, f.NOME
		  ORDER BY f.NOME
		) LOOP
		  dbms_output.put_line('Nação: ' || r.NACAO || ', Facção: ' || r.FACCAO || ', Quantidade de Habitantes: ' || r.QTD_HABITANTES);
		END LOOP;

	  WHEN 'SISTEMA' THEN
		FOR r IN (
		  SELECT n.NOME AS NACAO, s.NOME AS SISTEMA, SUM(c.QTD_HABITANTES) AS QTD_HABITANTES
		  FROM HABITACAO h
			JOIN COMUNIDADE c ON h.ESPECIE = c.ESPECIE AND h.COMUNIDADE = c.NOME
			JOIN PLANETA p ON h.PLANETA = p.ID_ASTRO
			JOIN DOMINANCIA d ON p.ID_ASTRO = d.PLANETA
			JOIN ORBITA_PLANETA op ON p.ID_ASTRO = op.PLANETA
			JOIN SISTEMA s ON op.ESTRELA = s.ESTRELA
			LEFT JOIN NACAO n ON d.NACAO = n.NOME
		  WHERE n.NOME = p_nome_nacao
		  GROUP BY n.NOME, s.NOME
		  ORDER BY s.NOME
		) LOOP
		  dbms_output.put_line('Nação: ' || r.NACAO || ', Sistema: ' || r.SISTEMA || ', Quantidade de Habitantes: ' || r.QTD_HABITANTES);
		END LOOP;

	  ELSE
		FOR r IN (
		  SELECT n.NOME AS NACAO, h.PLANETA, h.ESPECIE, c.QTD_HABITANTES AS QTD_HABITANTES, f.NOME AS FACCAO, s.NOME AS SISTEMA
		  FROM HABITACAO h
			JOIN COMUNIDADE c ON h.ESPECIE = c.ESPECIE AND h.COMUNIDADE = c.NOME
			JOIN PLANETA p ON h.PLANETA = p.ID_ASTRO
			JOIN DOMINANCIA d ON p.ID_ASTRO = d.PLANETA
			JOIN ORBITA_PLANETA op ON p.ID_ASTRO = op.PLANETA
			JOIN SISTEMA s ON op.ESTRELA = s.ESTRELA
			LEFT JOIN NACAO n ON d.NACAO = n.NOME
			LEFT JOIN NACAO_FACCAO nf ON n.NOME = nf.NACAO
			LEFT JOIN FACCAO f ON nf.FACCAO = f.NOME
		  WHERE n.NOME = p_nome_nacao
		  ORDER BY h.PLANETA
		) LOOP
		  dbms_output.put_line('Nação: ' || r.NACAO || ', Planeta: ' || r.PLANETA || ', Espécie: ' || r.ESPECIE || ', Quantidade de Habitantes: ' || r.QTD_HABITANTES || ', Facção: ' || r.FACCAO || ', Sistema: ' || r.SISTEMA);
		END LOOP;
	END CASE;

  EXCEPTION
	WHEN OTHERS THEN
	  dbms_output.put_line('Erro ao gerar relatório de habitantes: ' || SQLERRM);
  END relatorio_habitantes_por_nacao;

END PacoteOficial;
/

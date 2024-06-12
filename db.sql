CREATE TABLE USERS (
    UserID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Lider CHAR(14 BYTE) UNIQUE,
    Password VARCHAR2(32),
    CONSTRAINT fk_lider FOREIGN KEY (Lider) REFERENCES LIDER(CPI)
);

CREATE OR REPLACE TRIGGER trg_users_password
BEFORE INSERT OR UPDATE ON USERS
FOR EACH ROW
DECLARE
    md5_val USERS.Password%type;
BEGIN
    SELECT DBMS_OBFUSCATION_TOOLKIT.md5 (input => UTL_RAW.cast_to_raw(:NEW.Password)) into md5_val FROM DUAL;
    -- Usa a função DBMS_OBFUSCATION_TOOLKIT.md5 para calcular o hash MD5 da senha. 
    -- A função UTL_RAW.cast_to_raw converte a senha para um formato RAW adequado para a função MD5.
    :NEW.Password := md5_val;
END;
/

CREATE TABLE LOG_TABLE (
    Userid NUMBER,
    log_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message VARCHAR2(4000),
    CONSTRAINT fk_log_user FOREIGN KEY (Userid) REFERENCES USERS(Userid)
);

CREATE OR REPLACE PROCEDURE insert_missing_leaders AS
BEGIN
    FOR r IN (
        SELECT l.CPI 
        FROM LIDER l
        LEFT JOIN USERS u ON l.CPI = u.Lider
        WHERE u.Lider IS NULL
    ) LOOP
        INSERT INTO USERS (Lider, Password) 
        VALUES (r.CPI, 'admin');
    END LOOP;
    
    COMMIT;
END;
/



CREATE OR REPLACE PROCEDURE get_communities_info (
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
END;
/







CREATE OR REPLACE PROCEDURE get_planet_info (
    p_cpi IN LIDER.CPI%TYPE,
    p_action IN VARCHAR2
) IS
BEGIN
    IF p_action = 'DOMINIO' THEN
        DBMS_OUTPUT.PUT_LINE('Relatório de Planetas Dominados:');
        FOR r IN (
            SELECT 
                pl.ID_ASTRO AS planeta,
                dom.NACAO AS nacao_dominante,
                dom.DATA_INI AS inicio_dominacao,
                dom.DATA_FIM AS fim_dominacao,
                COUNT(DISTINCT c.NOME) AS qtd_comunidades,
                COUNT(DISTINCT e.NOME) AS qtd_especies,
                SUM(c.QTD_HABITANTES) AS total_habitantes,
                COUNT(DISTINCT f.NOME) AS qtd_faccoes,
                MAX(f.NOME) KEEP (DENSE_RANK FIRST ORDER BY COUNT(f.NOME) DESC) AS faccao_majoritaria
            FROM PLANETA pl
            LEFT JOIN DOMINANCIA dom ON pl.ID_ASTRO = dom.PLANETA
            LEFT JOIN HABITACAO h ON pl.ID_ASTRO = h.PLANETA
            LEFT JOIN COMUNIDADE c ON h.ESPECIE = c.ESPECIE AND h.COMUNIDADE = c.NOME
            LEFT JOIN ESPECIE e ON c.ESPECIE = e.NOME
            LEFT JOIN PARTICIPA p ON c.ESPECIE = p.ESPECIE AND c.NOME = p.COMUNIDADE
            LEFT JOIN FACCAO f ON p.FACCAO = f.NOME
            GROUP BY pl.ID_ASTRO, dom.NACAO, dom.DATA_INI, dom.DATA_FIM
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || ', Nação Dominante: ' || r.nacao_dominante || 
                                 ', Início da Dominação: ' || r.inicio_dominacao || ', Fim da Dominação: ' || r.fim_dominacao || 
                                 ', Qtd Comunidades: ' || r.qtd_comunidades || ', Qtd Espécies: ' || r.qtd_especies || 
                                 ', Total Habitantes: ' || r.total_habitantes || ', Qtd Facções: ' || r.qtd_faccoes || 
                                 ', Facção Majoritária: ' || r.faccao_majoritaria);
        END LOOP;
    ELSIF p_action = 'EXPANSAO' THEN
        DBMS_OUTPUT.PUT_LINE('Relatório de Potencial de Expansão:');
        FOR r IN (
            SELECT 
                pl.ID_ASTRO AS planeta,
                pl.MASSA,
                pl.RAIO,
                pl.CLASSIFICACAO,
                s.NOME AS sistema,
                MIN(POWER(s.X - s2.X, 2) + POWER(s.Y - s2.Y, 2) + POWER(s.Z - s2.Z, 2)) AS distancia_ao_territorio
            FROM PLANETA pl
            JOIN ORBITA_PLANETA op ON pl.ID_ASTRO = op.PLANETA
            JOIN SISTEMA s ON op.ESTRELA = s.ESTRELA
            LEFT JOIN DOMINANCIA dom ON pl.ID_ASTRO = dom.PLANETA
            LEFT JOIN ORBITA_PLANETA op2 ON dom.PLANETA = op2.PLANETA
            LEFT JOIN SISTEMA s2 ON op2.ESTRELA = s2.ESTRELA
            WHERE dom.NACAO IS NULL
            GROUP BY pl.ID_ASTRO, pl.MASSA, pl.RAIO, pl.CLASSIFICACAO, s.NOME
            HAVING MIN(POWER(s.X - s2.X, 2) + POWER(s.Y - s2.Y, 2) + POWER(s.Z - s2.Z, 2)) < 100 -- Ajuste o valor da distância conforme necessário
            ORDER BY distancia_ao_territorio
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || ', Massa: ' || r.MASSA || ', Raio: ' || r.RAIO || 
                                 ', Classificação: ' || r.CLASSIFICACAO || ', Sistema: ' || r.sistema || 
                                 ', Distância ao Território: ' || r.distancia_ao_territorio);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ação não especificada ou inválida.');
    END IF;
END;
/


CREATE OR REPLACE PROCEDURE monitor_planet_info (
    p_start_date IN DATE,
    p_end_date IN DATE
) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Monitoramento de Planetas de ' || TO_CHAR(p_start_date, 'DD/MM/YYYY') || ' até ' || TO_CHAR(p_end_date, 'DD/MM/YYYY'));

    -- Monitoramento de Dominações de Planetas
    FOR r IN (
        SELECT 
            dom.PLANETA AS planeta,
            dom.NACAO AS nacao_dominante,
            dom.DATA_INI AS inicio_dominacao,
            dom.DATA_FIM AS fim_dominacao
        FROM DOMINANCIA dom
        WHERE dom.DATA_INI <= p_end_date AND (dom.DATA_FIM >= p_start_date OR dom.DATA_FIM IS NULL)
        ORDER BY dom.PLANETA, dom.DATA_INI
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || ', Nação Dominante: ' || r.nacao_dominante || 
                             ', Início da Dominação: ' || r.inicio_dominacao || ', Fim da Dominação: ' || NVL(r.fim_dominacao, 'Atualmente dominado'));
    END LOOP;

    -- Monitoramento de Habitações de Planetas
    FOR r IN (
        SELECT 
            h.PLANETA AS planeta,
            h.ESPECIE AS especie,
            h.COMUNIDADE AS comunidade,
            h.DATA_INI AS inicio_habitacao,
            h.DATA_FIM AS fim_habitacao
        FROM HABITACAO h
        WHERE h.DATA_INI <= p_end_date AND (h.DATA_FIM >= p_start_date OR h.DATA_FIM IS NULL)
        ORDER BY h.PLANETA, h.DATA_INI
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Planeta: ' || r.planeta || ', Espécie: ' || r.especie || ', Comunidade: ' || r.comunidade || 
                             ', Início da Habitação: ' || r.inicio_habitacao || ', Fim da Habitação: ' || NVL(r.fim_habitacao, 'Atualmente habitado'));
    END LOOP;

END;
/

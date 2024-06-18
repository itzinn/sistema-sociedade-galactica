-- Tabela de usuários
CREATE TABLE USERS (
    UserID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Lider CHAR(14 BYTE) UNIQUE,
    Password VARCHAR2(32),
    CONSTRAINT fk_lider FOREIGN KEY (Lider) REFERENCES LIDER(CPI)
);

-- Trigger para conversão de senhas através de md5
CREATE OR REPLACE TRIGGER trg_users_password
BEFORE INSERT OR UPDATE ON USERS
FOR EACH ROW
DECLARE
    md5_val USERS.Password%type;
BEGIN
    SELECT DBMS_OBFUSCATION_TOOLKIT.md5 (input => UTL_RAW.cast_to_raw(:NEW.Password)) into md5_val FROM DUAL;
    :NEW.Password := md5_val;
END;
/


-- Tabela de log de atividades dos usuários
CREATE TABLE LOG_TABLE (
    Userid NUMBER,
    log_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message VARCHAR2(4000),
    CONSTRAINT fk_log_user FOREIGN KEY (Userid) REFERENCES USERS(Userid)
);


-- Procedure que retorna o cargo de um lider e se ele é lider de uma facção
CREATE OR REPLACE PROCEDURE get_leader_info (
    p_cpi IN LIDER.CPI%TYPE 
) IS
    v_cargo LIDER.CARGO%TYPE; 
    v_e_lider VARCHAR2(5); 
BEGIN
    SELECT CARGO INTO v_cargo FROM LIDER WHERE CPI = p_cpi;

    SELECT CASE WHEN EXISTS (
        SELECT 1
        FROM FACCAO
        WHERE LIDER = p_cpi
    )
    THEN 'TRUE' ELSE 'FALSE' END INTO v_e_lider
    FROM DUAL;

    -- Exibe a saída no formato "CARGO / É LIDER".
    DBMS_OUTPUT.PUT_LINE(v_cargo || ' / ' || v_e_lider);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum líder encontrado com o CPI fornecido.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END;
/


-- Procedure que insere todos os lideres não cadastrados na tabela de usuários.
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


-- Procedure que retorna os valores de todas as comunidades da facção de um lider, agrupadas por Nação, Especie, Planeta ou Sistema. Agrupamento é definido por parâmetro. 
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






-- Procedure que retorna informações de planetas dominados pela facção de um lider ou possíveis expansões para sua facção. A ação é definida por parâmetro.
CREATE OR REPLACE PROCEDURE get_planet_info (
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
END;
/



-- Procedure que retorna uma linha do tempo das informações de todos os planetas, podendo ou não ser de uma janela de tempo específica.
CREATE OR REPLACE PROCEDURE monitor_planet_info (
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
END;
/

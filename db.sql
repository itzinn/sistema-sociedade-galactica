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

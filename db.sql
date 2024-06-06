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

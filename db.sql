CREATE TABLE USERS (
    UserID NUMBER PRIMARY KEY,
    Password VARCHAR2(32),
    Lider CHAR(14 BYTE) UNIQUE,
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

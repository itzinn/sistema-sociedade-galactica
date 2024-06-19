--Não precisa chamar na aplicação estes procedures

--Arquivo para ser rodado antes no SQL developer. Contem a criação da tabela user e seus respectivos triggers. Tem o procedimento para cadastrar lideres que não foram cadastrados


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


-- Procudere para inserir lideres que não estão na tabela de user e coloca uma senha padrão 'admin'
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

-- Chamada para o procedimento que insere os líderes
BEGIN
	insert_missing_leaders;
END;
/

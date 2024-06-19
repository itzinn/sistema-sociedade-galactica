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

-- Criação da tabela de distâncias entre estrelas, utilizada para cumprir o item 4.c
CREATE TABLE DISTANCIAS_ESTRELAS (
	Estrela1_ID VARCHAR2(31),
	Estrela2_ID VARCHAR2(31),
	Distancia NUMBER,
	CONSTRAINT pk_distancias PRIMARY KEY (Estrela1_ID, Estrela2_ID)
);

-- Populando a tabela com estrelas já existentes no banco
CREATE OR REPLACE PROCEDURE Preencher_Distancias_Estrelas IS
BEGIN
	FOR e1 IN (SELECT ID_ESTRELA, X, Y, Z FROM ESTRELA) LOOP
		FOR e2 IN (SELECT ID_ESTRELA, X, Y, Z FROM ESTRELA WHERE ID_ESTRELA > e1.ID_ESTRELA) LOOP
			INSERT INTO Distancias_Estrelas (Estrela1_ID, Estrela2_ID, Distancia)
			VALUES (
				e1.ID_ESTRELA, e2.ID_ESTRELA,
				SQRT(POWER(e2.X - e1.X, 2) + POWER(e2.Y - e1.Y, 2) + POWER(e2.Z - e1.Z, 2))
			);
		END LOOP;
	END LOOP;
	COMMIT;
END;
/

-- Preencher a tabela de distâncias
BEGIN
  Preencher_Distancias_Estrelas;
END;
/




-- Trigger necessário para utilizar o relatório de corpos celestes otimizado de cientista
CREATE OR REPLACE TRIGGER trg_gerenciar_distancias
FOR INSERT OR UPDATE OR DELETE ON ESTRELA
COMPOUND TRIGGER

  -- registro para armazenar os valores das estrelas
  TYPE estrela_row IS RECORD (
    id_estrela VARCHAR2(20),
    x NUMBER,
    y NUMBER,
    z NUMBER
  );
  
  -- coleção (array) de registros de estrelas, indexado por PLS_INTEGER
  TYPE T_STARROW IS TABLE OF estrela_row INDEX BY PLS_INTEGER;

  -- coleções para armazenar as estrelas afetadas pelas operações de INSERT, UPDATE e DELETE
  estrelas_ins T_STARROW;
  estrelas_upd T_STARROW;
  estrelas_del T_STARROW;

  BEFORE EACH ROW IS
  BEGIN
    IF INSERTING THEN
      estrelas_ins(estrelas_ins.COUNT + 1) := estrela_row(:NEW.ID_ESTRELA, :NEW.X, :NEW.Y, :NEW.Z);
    ELSIF UPDATING THEN
      estrelas_upd(estrelas_upd.COUNT + 1) := estrela_row(:NEW.ID_ESTRELA, :NEW.X, :NEW.Y, :NEW.Z);
    ELSIF DELETING THEN
      estrelas_del(estrelas_del.COUNT + 1) := estrela_row(:OLD.ID_ESTRELA, :OLD.X, :OLD.Y, :OLD.Z);
    END IF;
  END BEFORE EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    -- Para inserções
    FOR i IN 1 .. estrelas_ins.COUNT LOOP
      FOR e IN (SELECT ID_ESTRELA, X, Y, Z FROM ESTRELA WHERE ID_ESTRELA != estrelas_ins(i).id_estrela) LOOP
        -- distâncias entre a nova estrela e todas as estrelas existentes
        INSERT INTO Distancias_Estrelas (Estrela1_ID, Estrela2_ID, Distancia)
        VALUES (
          estrelas_ins(i).id_estrela, e.ID_ESTRELA,
          SQRT(POWER(e.X - estrelas_ins(i).x, 2) + POWER(e.Y - estrelas_ins(i).y, 2) + POWER(e.Z - estrelas_ins(i).z, 2))
        );
      END LOOP;
    END LOOP;

    -- Para atualizações
    FOR i IN 1 .. estrelas_upd.COUNT LOOP
      FOR e IN (SELECT ID_ESTRELA, X, Y, Z FROM ESTRELA WHERE ID_ESTRELA != estrelas_upd(i).id_estrela) LOOP
        -- Atualizar distâncias para a estrela atualizada e todas as estrelas existentes
        UPDATE Distancias_Estrelas
        SET Distancia = SQRT(POWER(e.X - estrelas_upd(i).x, 2) + POWER(e.Y - estrelas_upd(i).y, 2) + POWER(e.Z - estrelas_upd(i).z, 2))
        WHERE (Estrela1_ID = estrelas_upd(i).id_estrela AND Estrela2_ID = e.ID_ESTRELA)
           OR (Estrela1_ID = e.ID_ESTRELA AND Estrela2_ID = estrelas_upd(i).id_estrela);
      END LOOP;
    END LOOP;

    -- Para remoções
    FOR i IN 1 .. estrelas_del.COUNT LOOP
      DELETE FROM Distancias_Estrelas
      WHERE Estrela1_ID = estrelas_del(i).id_estrela
         OR Estrela2_ID = estrelas_del(i).id_estrela;
    END LOOP;
  END AFTER STATEMENT;

END trg_gerenciar_distancias;
/

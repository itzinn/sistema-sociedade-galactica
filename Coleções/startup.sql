CREATE OR REPLACE PACKAGE PacoteStart AS
	FUNCTION verify_user_credentials (
		p_lider IN USERS.Lider%TYPE,
		p_password IN USERS.Password%TYPE
	) RETURN BOOLEAN;

	PROCEDURE get_leader_info (
		p_cpi IN LIDER.CPI%TYPE,
		p_results OUT SYS_REFCURSOR
	);
END PacoteStart;
/


	
CREATE OR REPLACE PACKAGE BODY PacoteStart AS
	FUNCTION verify_user_credentials (
		p_lider IN USERS.Lider%TYPE,
		p_password IN USERS.Password%TYPE
	) RETURN BOOLEAN IS
		v_stored_password USERS.Password%TYPE;
		v_input_password USERS.Password%TYPE;
	BEGIN
		SELECT DBMS_OBFUSCATION_TOOLKIT.md5(input => UTL_RAW.cast_to_raw(p_password))
		INTO v_input_password
		FROM DUAL;

		BEGIN
			SELECT Password INTO v_stored_password
			FROM USERS
			WHERE Lider = p_lider;


			IF v_stored_password = v_input_password THEN
				RETURN TRUE;
			ELSE
				RETURN FALSE;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN FALSE;
		END;
	END verify_user_credentials;

	PROCEDURE get_leader_info (
		p_cpi IN LIDER.CPI%TYPE,
		p_results OUT SYS_REFCURSOR
	) IS
		v_cargo LIDER.CARGO%TYPE;
		v_e_lider VARCHAR2(5);
		v_nome LIDER.NOME%TYPE;
		v_nacao LIDER.NACAO%TYPE;
		v_especie LIDER.ESPECIE%TYPE;
	BEGIN

		SELECT CARGO, NOME, NACAO, ESPECIE 
		INTO v_cargo, v_nome, v_nacao, v_especie 
		FROM LIDER 
		WHERE CPI = p_cpi;

		SELECT CASE WHEN EXISTS (
			SELECT 1
			FROM FACCAO
			WHERE LIDER = p_cpi
		)
		THEN 'TRUE' ELSE 'FALSE' END INTO v_e_lider
		FROM DUAL;

		OPEN p_results FOR
		SELECT 
			v_cargo AS CARGO, 
			v_e_lider AS E_LIDER,
			v_nome AS NOME, 
			v_nacao AS NACAO, 
			v_especie AS ESPECIE
		FROM DUAL;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Nenhum líder encontrado com o CPI fornecido.');
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
	END get_leader_info;
END PacoteStart;
/



DECLARE
	v_result BOOLEAN;
BEGIN
	v_result := PacoteStart.verify_user_credentials('lider_example', 'password_example');

	IF v_result THEN
		DBMS_OUTPUT.PUT_LINE('Usuário e senha corretos.');
	ELSE
		DBMS_OUTPUT.PUT_LINE('Usuário ou senha incorretos.');
	END IF;
END;
/


DECLARE
	p_results SYS_REFCURSOR;
	v_cargo VARCHAR2(50);
	v_e_lider VARCHAR2(5);
	v_nome VARCHAR2(100);
	v_nacao VARCHAR2(50);
	v_especie VARCHAR2(50);
BEGIN
	-- Chama o procedimento get_leader_info do pacote
	PacoteStart.get_leader_info('cpi_example', p_results);

	-- Lê os resultados do cursor
	LOOP
		FETCH p_results INTO v_cargo, v_e_lider, v_nome, v_nacao, v_especie;
		EXIT WHEN p_results%NOTFOUND;

		DBMS_OUTPUT.PUT_LINE('CARGO: ' || v_cargo);
		DBMS_OUTPUT.PUT_LINE('E_LIDER: ' || v_e_lider);
		DBMS_OUTPUT.PUT_LINE('NOME: ' || v_nome);
		DBMS_OUTPUT.PUT_LINE('NACAO: ' || v_nacao);
		DBMS_OUTPUT.PUT_LINE('ESPECIE: ' || v_especie);
	END LOOP;

	-- Fecha o cursor
	CLOSE p_results;
END;
/




import cx_Oracle

# Configurações da conexão
dsn_tns = cx_Oracle.makedsn('host', 'port', service_name='service_name')
connection = cx_Oracle.connect(user='username', password='password', dsn=dsn_tns)

# Credenciais do usuário
lider = 'lider_example'
password = 'password_example'

# Chamada do procedimento PL/SQL
cursor = connection.cursor()
result = cursor.var(cx_Oracle.NUMBER)  # Variável para armazenar o resultado

# Chamada da função dentro do pacote
cursor.callfunc('PacoteStart.verify_user_credentials', result, [lider, password])

# Verifica o resultado
is_valid = bool(result.getvalue())

if is_valid:
	print("Usuário e senha corretos.")
else:
	print("Usuário ou senha incorretos.")

# Fecha a conexão
cursor.close()
connection.close()

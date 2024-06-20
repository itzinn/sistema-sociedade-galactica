-- Procedimento para inserir registros na tabela LOG_TABLE
CREATE OR REPLACE PROCEDURE log_operation (
    p_userid IN USERS.UserID%TYPE, -- ID do usuário que está realizando a operação
    p_message IN LOG_TABLE.message%TYPE -- Mensagem de log que descreve a operação
) IS
BEGIN
    -- Insere um novo registro na tabela de logs
    INSERT INTO LOG_TABLE (Userid, message)
    VALUES (p_userid, p_message);

    -- Confirma a inserção na tabela de logs
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de erro, exibe uma mensagem de erro
        DBMS_OUTPUT.PUT_LINE('Erro ao inserir no log: ' || SQLERRM);
        -- Opcional: podemos também reverter a transação em caso de erro, se necessário
        ROLLBACK;
END log_operation;
/

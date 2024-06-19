-----------------
--  Transação  --
-----------------

-- Transação: trocar nação de federação.

/*
Operações estão incluídas na transação (incluindo operações em triggers):

Excluir nação de uma federação.
Se a federação ficar sem nações após a remoção, excluir a federação. (trigger)
Adicionamos a nação em questão a uma federeção.
Verifica-se se a federação já existe. Caindo
em uma das opções:

  1 - Adicionar uma nação a uma federação existente:
  Atualizar a tabela de Nações para associar a nação à federação.

  2 - Criar federação se não existir:
  Inserir a nova federação na tabela de Federações.
  Atualizar a tabela de Nações para associar a nação à nova federação.

Justificativa:
Essa transação cobriria uma funcionalidade composta (Trocar nação de federeção) que envolve as duas funcionalidades de gerenciamento da letra "a." do comandante. Nesse sentido, estas operações garantem a consistência e a integridade dos dados, impedindo que uma federação seja deletada caso a mudança falhe e mantendo a coesão de que cada federação deve ter pelo menos uma nação associada.

*/

/*
Nível de isolamento da transção
Usaremos o nível de isolamento de serialização, pois garante que todas as transações sejam completamente isoladas umas das outras, assegurando a integridade dos dados do sistema e evitando phantom reads. Isso é crucial para prevenir condições de corrida e outros problemas de concorrência. Nossa transação será usada por líderes e, dado que a mudança de federação de uma nação é uma ação crítica e pouco frequente, decidimos priorizar a integridade dos dados fornecida pelo nível serializable. Embora isso resulte em maior contenção de recursos, a segurança dos dados justifica esse trade-off.
*/



CREATE OR REPLACE PROCEDURE swap_nation_federation (
  p_nation_name IN NACAO.NOME%TYPE,
  p_new_federation_name IN FEDERACAO.NOME%TYPE
) AS
  v_federation_exists NUMBER;
  v_nation_exists NUMBER;
  v_federation_nations NUMBER;
  v_old_federation FEDERACAO.NOME%TYPE;
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

  BEGIN
      SELECT COUNT(*)
      INTO v_nation_exists
      FROM NACAO
      WHERE NOME = p_nation_name;

      IF v_nation_exists = 0 THEN
          DBMS_OUTPUT.PUT_LINE('Erro: A nação ' || p_nation_name || ' não existe.');
          ROLLBACK;
          RETURN;
      END IF;


      SELECT COUNT(*)
      INTO v_federation_exists
      FROM FEDERACAO
      WHERE NOME = p_new_federation_name;

      IF v_federation_exists = 0 THEN
          DBMS_OUTPUT.PUT_LINE('Nova federação não encontrada. Criando nova federação...');
          INSERT INTO FEDERACAO (NOME, DATA_FUND)
          VALUES (p_new_federation_name, SYSDATE);
      END IF;

      SELECT FEDERACAO INTO v_old_federation
      FROM NACAO
      WHERE NOME = p_nation_name;

      UPDATE NACAO
      SET FEDERACAO = p_new_federation_name
      WHERE NOME = p_nation_name;

      COMMIT;

      SELECT COUNT(*)
      INTO v_federation_nations
      FROM NACAO
      WHERE FEDERACAO = v_old_federation;

       IF v_federation_nations = 0 THEN
          DBMS_OUTPUT.PUT_LINE('Deletando federação' || v_old_federation);
          DELETE FROM FEDERACAO
          WHERE NOME = v_old_federation;
      END IF;

      COMMIT;

      DBMS_OUTPUT.PUT_LINE('Nação ' || p_nation_name || ' foi movida para a federação ' || p_new_federation_name || '.');

  EXCEPTION
      WHEN VALUE_ERROR THEN
          DBMS_OUTPUT.PUT_LINE('Erro de valor detectado.');
          ROLLBACK;
      WHEN OTHERS THEN
          ROLLBACK;
          DBMS_OUTPUT.PUT_LINE('Erro ao trocar a nação de federação: ' || SQLERRM);
  END;
END;
/




BEGIN
  swap_nation_federation('Quo labore.', 'NovaFederacao4'); -- Substitua pelos valores reais de nação e federação.
END;
/


-- Verificar a entrada da nação na tabela NACAO
SELECT NOME, QTD_PLANETAS, FEDERACAO
FROM NACAO
WHERE NOME = 'Quo labore.';


SELECT NOME, QTD_PLANETAS, FEDERACAO
FROM NACAO
WHERE FEDERACAO = 'NovaFederacao2';
-- Verificar a entrada da nova federação na tabela FEDERACAO
SELECT NOME, DATA_FUND
FROM FEDERACAO
WHERE NOME = 'NovaFederacao2';

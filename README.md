Para inicializar a aplicação, primeiramente deverá ser criado um arquivo .env (sem nome, somente .env) para as credenciais. Este arquivo deverá seguir o seguinte modelo:

ORACLE_USER='XXXXX'

ORACLE_PASSWORD='XXXXXX'

ORACLE_DSN='orclgrad1.icmc.usp.br:1521/pdb_XXXXX.icmc.usp.br'

Depois de criar este arquivo, deverá fazer a instalação das dependências. Logo, ir para o arquivo ‘_init_’ na pasta principal e começar a rodar. Ao rodar o arquivo no terminal aparecerá um link para seguir, como por exemplo o seguinte:

	http://127.0.0.1:5000

Siga para este link, que levará a uma página de erro inicialmente. Para usar a aplicação deverá adicionar um /login no final da url, como mostrado a seguir:

	http://127.0.0.1:5000/login 

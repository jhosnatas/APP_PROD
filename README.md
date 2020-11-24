A saida sera uma lista de conexões ativas do sqlplus na maquina , ajudando na abertura de chamados .
a sessions_longops ajuda a uma analise fácil se o processo esta travado mas apenas para sessões com durações maior de 6 segundos . 

exemplo de saida do verpid

----------------------------------------------------------------------------------------------------------------------------- \n
 MODULO: @/arquivo_sql_em_execucao.tmp.sql.tmp \n
 SID: 3223 \n
 SERIAL: 16707 \n
 PROCESS: 55682 \n
 USER: SYSADM \n
 STATUS: ACTIVE \n
 MACHINE: maquina111 \n
 SQL_ID: dayga8dd464k \n
 LONGOPS: 37% \n
---------------------------------------------------------------------------------------------------------------------------- \n
(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = hosttnsping)(PORT = 9999))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = BANCODBOORACLE))) \n
---------------------------------------------------------------------------------------------------------------------------- \n

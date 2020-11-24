A saida sera uma lista de conexões ativas do sqlplus na maquina , ajudando na abertura de chamados .
a sessions_longops ajuda a uma analise fácil se o processo esta travado mas apenas para sessões com durações maior de 6 segundos . 

exemplo de saida do verpid

-----------------------------------------------------------------------------------------------------------------------------
 MODULO: @/arquivo_sql_em_execucao.tmp.sql.tmp
 SID: 3223
 SERIAL: 16707
 PROCESS: 55682
 USER: SYSADM
 STATUS: ACTIVE
 MACHINE: maquina111
 SQL_ID: dayga8dd464k
 LONGOPS: 37%
----------------------------------------------------------------------------------------------------------------------------
(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = hosttnsping)(PORT = 9999))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = BANCODBOORACLE)))
----------------------------------------------------------------------------------------------------------------------------

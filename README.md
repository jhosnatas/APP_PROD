A saida sera uma lista de conexões ativas do sqlplus na maquina , ajudando na abertura de chamados .
a sessions_longops ajuda a uma analise fácil se o processo esta travado mas apenas para sessões com durações maior de 6 segundos . 

exemplo de saida do verpid

-----------------------------------------------------------------------------------------------------------------------<p>
 MODULO: @/arquivo_sql_em_execucao.tmp.sql.tmp<br>
 SID: 3223<p>
 SERIAL: 16707<p>
 PROCESS: 55682<p>
 USER: SYSADM<p>
 STATUS: ACTIVE<p>
 MACHINE: maquina111<p>
 SQL_ID: dayga8dd464k<p>
 LONGOPS: 37%<p>
-------------------------------------------------------------------------------------------------------------------------<p>
(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = hosttnsping)(PORT = 9999))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = BANCODBOORACLE)))<p>
-------------------------------------------------------------------------------------------------------------------------<p>

ENVIA EMAIL<p>
Para anexos pesados é necessario criar um job para aft ou scp <p> 
Ex do email enviado <p>

Titulo :[MODULO NOME] RELATORIO NOME [24/11/2020] <p>
 
 Segue lista de arquivos RELATORIO NOME ANEXOS  <p>
 
 Anexo0.csv <p>
 Anexo1.csv <p>
 Anexo2.csv <p>
 Anexo3.csv <p>
 Anexo4.csv <p>
 Anexo5.csv <p>
 
 Att. MEU TIME DE RELATORIOS<p>

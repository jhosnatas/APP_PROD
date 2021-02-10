# Bem vindo a o meu repositório de script shell !

O objetivo deste repositório e demostrar o uso do shellscript para automatizar pequenas tarefas na produção #linux ,



## Ver PID
[Ver_pid.sh]("https://github.com/jhosnatas/APP_PROD/blob/main/Verpid.sh")
Este script gera uma lista de conexções do sqlplus no host 
com as informações  necessárias para continuação da analise pelo dba . 
, ajudando na agilidade  na abertura de chamados . a sessions_longops ajuda a uma analise fácil se o processo esta travado mas apenas para sessões com durações maior de 6 segundos .<p>
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
  

## ENVIA EMAIL
[Envia_email.sh]("https://github.com/jhosnatas/APP_PROD/blob/main/Envia_emailx.sh")
Shellscript para envio de email automatico com relatórios anexos .

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

 Att. TIME DE BI <p>

## Transferencia 
[Transfere.sh ]("https://github.com/jhosnatas/APP_PROD/blob/main/Transfere.sh")

Esta é um versão simplificado de um shellscript  para transferir arquivos  apatir de uma lista obtida no banco oracle , com capactade de enviar 100k por hora . Dividindo a lista e trabalhando com ate 30 paralelos simultâneos , conforme configuração. 

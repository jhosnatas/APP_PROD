# Bem vindo a o meu repositório de script shell !

O objetivo deste repositório e demostrar o uso do shellscript para automatizar pequenas tarefas na produção #linux ,



## Ver PID
[Ver_pid.sh]("https://github.com/jhosnatas/APP_PROD/blob/main/Verpid.sh")
Este script gera uma lista de conexções do sqlplus no host 
com as informações  necessárias para continuação da analise pelo dba . 
, ajudando na agilidade  na abertura de chamados . a sessions_longops ajuda a uma analise fácil se o processo esta travado mas apenas para sessões com durações maior de 6 segundos .

-----------------------------------------------------------------------------------
MODULO: @/arquivo_sql_em_execucao.tmp.sql.tmp  
SID: 3223
SERIAL: 16707
PROCESS: 55682
USER: SYSADM
STATUS: ACTIVE
MACHINE: maquina111
SQL_ID: dayga8dd464k
LONGOPS: 37%

-------------------------------------------------------------------------------------------
(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = hosttnsping)(PORT = 9999))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = BANCODBOORACLE)))

-------------------------------------------------------------------------------------------

## ENVIA EMAIL
[Envia_email.sh]("https://github.com/jhosnatas/APP_PROD/blob/main/Envia_emailx.sh")
Shellscript para envio de email automatico com relatórios anexos .

Titulo :[MODULO NOME] RELATORIO NOME [dd/mm/yyyy]
Corpo:
Segue lista de arquivos RELATORIO NOME ANEXOS
Anexo0.csv
Anexo1.csv
Anexo2.csv
Anexo3.csv
Anexo4.csv
Anexo5.csv

Att. MEU TIME DE B.I

## Transferencia 
[Transfere.sh ]("https://github.com/jhosnatas/APP_PROD/blob/main/Transfere.sh")

Esta é um versão simplificado de um shellscript  para transferir arquivos  apatir de uma lista obtida no banco oracle , com capactade de enviar 100k por hora . Dividindo a lista e trabalhando com ate 30 paralelos simultâneos , conforme configuração. 

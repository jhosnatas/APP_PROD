# Bem vindo a o meu repositório de script shell !

O objetivo deste repositório e demostrar o uso do shellscript para automatizar pequenas tarefas na produção #linux ,



## Ver PID
[Ver_pid.sh]("https://github.com/jhosnatas/APP_PROD/blob/main/Verpid.sh")
Este script gera uma lista de conexções do sqlplus no host 
com as informações  necessárias para continuação da analise pelo dba . 
, ajudando na agilidade  na abertura de chamados . a sessions_longops ajuda a uma analise fácil se o processo esta travado mas apenas para sessões com durações maior de 6 segundos .<p>
-----------------------------------------------------------------------------------------------------------------------<br>
 MODULO: @/arquivo_sql_em_execucao.tmp.sql.tmp<br>
 SID: 3223<br>
 SERIAL: 16707<br>
 PROCESS: 55682<br>
 USER: SYSADM<br>
 STATUS: ACTIVE<br>
 MACHINE: maquina111<br>
 SQL_ID: dayga8dd464k<br>
 LONGOPS: 37%<br>
-------------------------------------------------------------------------------------------------------------------------<br>
(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = hosttnsping)(PORT = 9999))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = BANCODBOORACLE)))<br>
-------------------------------------------------------------------------------------------------------------------------<br>
  

## ENVIA EMAIL
[Envia_email.sh]("https://github.com/jhosnatas/APP_PROD/blob/main/Envia_emailx.sh")
Shellscript para envio de email automatico com relatórios anexos .

Para anexos pesados é necessario criar um job para aft ou scp <p> 
Ex do email enviado <p>

Titulo :[MODULO NOME] RELATORIO NOME [24/11/2020] <br>
 Segue lista de arquivos RELATORIO NOME ANEXOS  <br>
 Anexo0.csv <br>
 Anexo1.csv <br>
 Anexo2.csv <br>
 Anexo3.csv <br>
 Anexo4.csv <br>
 Anexo5.csv <br>

 Att. TIME DE BI <br>

## Transferencia 
[Transfere.sh ]("https://github.com/jhosnatas/APP_PROD/blob/main/Transfere.sh")

Esta é um versão simplificado de um shellscript  para transferir arquivos  apatir de uma lista obtida no banco oracle , com capactade de enviar 100k por hora . Dividindo a lista e trabalhando com ate 30 paralelos simultâneos , conforme configuração. 

## Lowcase.sh
[Lowcase.sh ]("https://github.com/jhosnatas/APP_PROD/blob/main/Lowcase.sh")
Script feito para tratar conteudo de arquivos texto de maiusculo para minisculo .

## Template.sh
[Template.sh ]("https://github.com/jhosnatas/APP_PROD/blob/main/Template.sh")
Script TEMPLATE  genérico para criação de novos scripts , neles já contem as seguintes funções 
VALIDA : Função para validar erros e escrever no log .
VALIDA_LOCK : Cria um arquivo lock de execução e faz a validação antes de iniciar uma nova execução , visando eliminar execuções simultâneas . 
TEMPOS : Registra no banco de dados ORACLE inicio , fim , saida e etc sobre o script .
VALIDA PARAMETROS : Validar parâmetros de entrada do script .


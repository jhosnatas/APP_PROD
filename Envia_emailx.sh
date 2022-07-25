#!/bin/bash

#------------------------------------------------------
### JONATAS SILVA 2020
### Enviando anexos automaticamente com mailx
### http://jhosnatas.github.io/ 
### 
#------------------------------------------------------

## Variaveis
MASK="*.csv" # Mascara dos arquivos
PARA="jonatassilvas@jonatassilvas.com.br jonatassilvas@jonatassilvas.com.br" # Lista email
TITLE="[MODULO NOME] RELATORIO NOME [$(date +%d/%m/%Y)]" # Titulo do email

## Enviando o email
if [ "$(ls $MASK 2> /dev/null | wc -l)" == "0" ] ; then ## Valida a existencia dos arquivos
        ## email caso NAO exista arquivos
        EMAIL="\n\nNao existem arquivos RELATORIO NOME  para enviar\n\nAtt. MEU TIME DE RELATORIOS" ## corpo do email
        echo -e ${EMAIL[@]} | mailx -r EXTRATOR_ETL -s "${TITLE}"  $PARA ## Enviando o email
                [[ $? != 0 ]] && echo "ERRO ao enviar email " && exit 1 ## Valida envio do email
        else
                ## email caso exista arquivos
                EMAIL="\n \n  Segue lista de arquivos RELATORIO NOME ANEXOS \n \n" ## Cabecalho
                EMAIL+=$(ls ${MASK} | awk '{print $1 "\n"}' ) ## corpo do email
                EMAIL+="\n \n Att. MEU TIME DE RELATORIOS" ## Rodade
                ANEXOS+=$(ls ${MASK} | awk '{print "-a " $1}' ) ## Lista de anexos
                echo -e ${EMAIL[@]} |  mailx -r EXTRATOR_ETL -s "${TITLE}" ${ANEXOS} $PARA #envia email
                        [[ $? != 0 ]] &&  echo "ERRO ao enviar email " && exit 1 ## Valida envio do email
                for x in $(ls $MASK ) ; do mv $x /enviados/ ; done ## Move arquivos para o backup
fi


exit 0

# Final do Shell


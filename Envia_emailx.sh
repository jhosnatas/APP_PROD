#!/bin/sh
# Enviando por email utilizando mailx
# utizando array ao inves de criar arquivos 
# JONATAS SILVA
MASK="*.csv"
PARA="jonatassilvas@jonatassilvas.com.br jonatassilvas@jonatassilvas.com.br"
TITLE="[MODULO NOME] RELATORIO NOME [$(date +%d/%m/%Y)]"

if [ "$(ls $MASK 2> /dev/null | wc -l)" == "0" ] ; then
        EMAIL="\n\nNao existem arquivos RELATORIO NOME  para enviar\n\nAtt. MEU TIME DE RELATORIOS"
        echo -e ${EMAIL[@]} | mailx -r EXTRATOR_ETL -s "${TITLE}"  $PARA
        else
                EMAIL="\n \n  Segue lista de arquivos RELATORIO NOME ANEXOS \n \n" ##cabecalho
                EMAIL+=$(ls ${MASK} | awk '{print $1 "\n"}' ) ## corpo do email
                EMAIL+="\n \n Att. MEU TIME DE RELATORIOS" ## rodade
                ANEXOS+=$(ls ${MASK} | awk '{print "-a " $1}' ) ### lista de anexos
                echo -e ${EMAIL[@]} |  mailx -r EXTRATOR_ETL -s "${TITLE}" ${ANEXOS} $PARA #envia email
                 for x in $(ls $MASK ) ; do mv $x /enviados/ ; done # move arquivos para o backupi
fi
# Final do Shell


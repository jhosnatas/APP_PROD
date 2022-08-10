#!/bin/bash
###################################################################
#Script Name    : Template.sh
#Description    : Usado como modelo base para criar novos sh
#Data           : 10/08/2022
#Author         : Jonatas Silva
#Email          : jonatas.silva@jonatas.silva
###################################################################
## DEBUG MOD
set -x
VALIDA () { if [ $? != 0 ]; then echo "$*" | tee -a ${LOG} && exit 1 ; fi }
#if [ "$1" == '' ] ; then echo " Informar opcao " &&  exit 1 ; fi


PADRAO () {

if [ "$1" == '' ] ; then echo " Informar nome do script  " &&  exit 1 ; fi

echo "#!/bin/bash
#
###################################################################
#Script Name    : $1
#Description    : ${@//$1/}
#Data           : $(date +%d/%m/%Y)
#Author         : Jonatas Silva
#Email          : jonatas.silva.terceiros@claro.com.br
###################################################################" > $1
echo '
###################################################################
## DEBUG MOD
#set -x
set +xv

###################################################################
## VARIAVEIS
DIR_LOG=/home/pmart/jhosnatas
DATE_PROC=$(date +%Y%m%d%H%M%S)
LOG=${DIR_LOG}/$0_${DATE_PROC}.log
LOCK=${DIR_LOG}/$0.lock

###################################################################
## VALIDANDO PARAMETROS
if [ $# -lt 2 ] ; then
        echo "INFORMAR PARAMETROS" | tee -a ${LOG}
        exit 1
        else
        echo -e "$DATE_PROC Iniciada a execucao $0 " | tee -a ${LOG}
fi

## VALIDA LOCK
if [ -f "$LOCK" ]; then
        echo "Erro : Processo ja esta em execucao " | tee -a ${LOG}
        exit 99
        else
        echo "$$" > $LOCK
fi

###################################################################
## Funcoes pre definidas

VALIDA () {
        SAIDA="$?"
        if [ "$SAIDA" != 0 ]; then echo "$*" | tee -a ${LOG}
        TEMPOS "$*"
        exit 1
        fi
        }


## Registra tempo no BD
TEMPOS () {
        rm -f $LOCK
        DTFIM=$(date +%d/%m/%Y" "%H:%M:%S)
        sqlplus -s ${USERDB}/${SENHABD}@ORACLE12C<<END
        set heading OFF termout ON trimout ON feedback OFF
        set pagesize 0
        INSERT INTO TABTEMPOS (JOBNAME, INICIO , FIM , SAIDA , OBS )
        VALUES ($0, $DTINICIO , $DTFIM , $SAIDA ," $* ");
END
        }

###################################################################
## Script comeca aqui
for ((i=1;i<=10;i++)); do echo $i; done

## Fim do Shell
SAIDA="0"
TEMPOS SCRIPT EXECUTADO COM SUCESSO
exit 0' >> $1

chmod 755 $1
VALIDA ERRO DE PERMISSAO NO ARQUIVO $1

}


if [ $# -lt 2 ] ; then
        echo "./Template.sh NOME DESCRICAO SCRIPT " | tee -a ${LOG}
        exit 1
        else PADRAO $@
fi


exit 0

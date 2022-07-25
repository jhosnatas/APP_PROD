#!/bin/bash

#------------------------------------------------------
### JONATAS SILVA 2020
### listar processos conetactados ao oracle
### http://jhosnatas.github.io/ 
### Necessario sysadm para acessos as views
#------------------------------------------------------

echo -e "|$(date)|"

DBUSER=$( cat ./dbpasswd )

## gerar lista de processos sql , precisa ser adpdatado a sua necessidade
TMPPID=$( ps -ef | grep "sqlplus" | grep @ | awk {'print $2'} )

## Buscando informações no oracle
for I in $(echo ${TMPPID[@]})
do
SID=$(sqlplus -s sysadm/${DBUSER}@BANCODBOORACLE << END
        SET PAGESIZE 0 FEEDBACK off VERIFY off HEADING off WRAP off
        SELECT  sid || ' ' || serial# || ' ' || process || ' ' || status || ' ' || sql_id || ' ' || machine || ' ' || username
        FROM gv\$session  WHERE process in ('${I}');
END
)

## tratando multiplos vetores no array
for I in $(printf "%s\n" `echo ${SID[@]} |sed 's/ /\n/g'`) ; do ARRAY+=("${I}") ; done
SID=("${ARRAY[@]}")

## SESSION_LONGOPS "This view displays the status of various operations"
PERC=$(sqlplus -s sysadm/${DBUSER}@BANCODBOORACLE << END
        SET PAGESIZE 0 FEEDBACK off VERIFY off HEADING off WRAP off
        select round(sofar*100/totalwork,2) perc from GV\$SESSION_LONGOPS a where sid = '${SID[0]}' ;
END
)

## Identificando nome do modulo
mD=$( ps -ef | grep ${SID[2]} | grep -v grep | awk {'print $10, $11'} )


# exibindo informacoes na tela
echo -e "-------------------------------------------------------------"
echo -e " MODULO: ${mD}"
echo -e " SID: ${SID[0]}"
echo -e " SERIAL: ${SID[1]}"
echo -e " PROCESS: ${SID[2]}"
echo -e " USER: ${SID[6]}"
echo -e " STATUS: ${SID[3]}"
echo -e " MACHINE: ${SID[5]}"
echo -e " SQL_ID: ${SID[4]}"

# Validando LONGOPS views / exibe apenas caso seja um numero valido 
for I in $(echo ${PERC[@]}) ; do I=$( echo $I |egrep -iv "ORA"  | cut -d '.' -f1 |sed 's/[^0-9]//g' )
[[ "${I}" -lt "100" ]] && [[ "${I}" != "" ]] && echo -e " LONGOPS: ${I}%"
done

#limpando array
unset SID ; unset ARRAY

done

echo -e "----------------------------------------------------------------------------------------------------------------------------"
echo -e "(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = hosttnsping)(PORT = 9999))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = BANCODBOORACLE)))"
echo -e "----------------------------------------------------------------------------------------------------------------------------"

exit 0

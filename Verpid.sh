#!/bin/sh
### JONATAS SILVA 2020
### SCRIPT para pegar pid de processos conetactados ao oracle com sqlplus
### Necessario sysadm para acessos as views

echo -e "|              `date`          |"
DBUSER=$( cat ./dbuser )

## gerar lista de processos sql , precisa ser adpdatado a sua necessidade
TMPPID=$( ps -ef | grep "sqlplus" | grep @ | grep -v "replicador_status.sql" | awk {'print $2'} )
for I in $(echo ${TMPPID[@]})
do
### || '|' ||
### SELECT  sid, serial#, process, status, sql_id, machine , username

SID=$(sqlplus -s sysadm/${DBUSER}@BANCODBOORACLE << END
        SET PAGESIZE 0 FEEDBACK off VERIFY off HEADING off WRAP off
        SELECT  sid || ' ' || serial# || ' ' || process || ' ' || status || ' ' || sql_id || ' ' || machine || ' ' || username
        FROM gv\$session  WHERE process in ('${I}');
END
)
##tratando multiplos vetores no array , vou validar a eficacio do  || ' ' || 
for I in $(printf "%s\n" `echo ${SID[@]} |sed 's/ /\n/g'`) ; do ARRAY+=("${I}") ; done
SID=("${ARRAY[@]}")

### SESSION_LONGOPS Views para acompanha a instrucao sql no momento
PERC=$(sqlplus -s sysadm/${DBUSER}@BANCODBOORACLE << END
        SET PAGESIZE 0 FEEDBACK off VERIFY off HEADING off WRAP off
        select round(sofar*100/totalwork,2) perc from GV\$SESSION_LONGOPS a where sid = '${SID[0]}' ;
END
)
### exibindo informacoes na tela
echo -e "-----------------------------------------------------------------------------------------------------------------------------"
mD=$( ps -ef | grep ${SID[2]} | grep -v grep | awk {'print $10, $11'} )
echo -e " MODULO: ${mD}" ; echo -e " SID: ${SID[0]}" ; echo -e " SERIAL: ${SID[1]}" ; echo -e " PROCESS: ${SID[2]}"
 echo -e " USER: ${SID[6]}" ; echo -e " STATUS: ${SID[3]}" ; echo -e " MACHINE: ${SID[5]}" ;echo -e " SQL_ID: ${SID[4]}"
### Validando LONGOPS views
for I in $(echo ${PERC[@]}) ; do I=$( echo $I |egrep -iv "ORA"  | cut -d '.' -f1 |sed 's/[^0-9]//g' )
[[ "${I}" -lt "100" ]] && [[ "${I}" != "" ]] && echo -e " LONGOPS: ${I}%"
done
unset SID ; unset ARRAY
done
echo -e "----------------------------------------------------------------------------------------------------------------------------"
echo -e "(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = hosttnsping)(PORT = 9999))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = BANCODBOORACLE)))"
echo -e "----------------------------------------------------------------------------------------------------------------------------"

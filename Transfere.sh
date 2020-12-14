#!/bin/ksh
# Enviando por email utilizando mailx
# utizando array ao inves de criar arquivos 
# JONATAS SILVA
# Esta é um versão simplificado de um shell para transferis centenas de milhares de arquivos .
# Organizo os arquivos em pastas evitando o erro "argument list is too long"
# Envio em paralelo para 2 hosts


GERA_LISTA ()
{
### gera uma lista apartir de uma consulta ao oracle
ListaARQ=$(sqlplus -s ${USERDB}/${SENHABD}@ORACLE12C<<END
set heading OFF termout ON trimout ON feedback OFF
set pagesize 0
select caminhodoarquivo from arquivos gerados where request_id = '$REQUEST' ;
END
)
### tratando multiplis valores no array
for I in $(printf "%s\n" `echo ${ListaARQ[@]} |sed 's/ /\n/g'`) ; do ARRAY+=("${I}") ; done
wait
ListaARQ=("${ARRAY[@]}")
}


DIVIDE_LISTA () {
### DIVIDINDO O ARRAY EM 3 PARA EXECUTAR A TRANSFERENCIA EM PARALELO
#tira da sequencia da tabela 
#motivo em uma lista ordenada de 150k caso eu já tenha enviado 100 primeiros o array 1 e 2 ficaria somente com arquivos inexistentes eo 3 com os 50k para enviar 
#desta forma cada array teria 16.666 arquivos para enviar . 


date
        for ARQUIVO in $(echo ${!ListaARQ[*]}); do
        MENOR=$(printf '%s\n'  $(echo ${#ARRAY1[*]}) $(echo ${#ARRAY2[*]}) $(echo ${#ARRAY3[*]}) | sort -n | head -n1 )
        if [ "$(echo ${#ARRAY1[*]})" -le "$MENOR" ] ; then ARRAY1+=("ARQUIVO")
        elif [ "$(echo ${#ARRAY2[*]})" -le $(echo ${#ARRAY3[*]}) ] ; then ARRAY2+=("ARQUIVO")
        else ARRAY3+=("ARQUIVO")
        fi
        done
echo "divido"
date
####CHAMANDO A TRANSFERENCIA PARALELA
TRANSFERE ${ARRAY1[@]} &
TRANSFERE ${ARRAY2[@]} &
TRANSFERE ${ARRAY3[@]} &
        }


MKDIR ()
{
##CRIANDO PASTA COM RANDOM
DIR="/pasta1/pasta2/pasta3/ARQUIVOS_$(( $RANDOM % 10000 ))/99/"
mkdir -p $DIR
valida erro ao criar diretorio
}

ENVIA_BKP ()
{
#CRIO PASTA BKP
BCK_HOST="useruser@maquinaservidor3"
BCK_IN="/home/pasta1/pasta2/$REQUEST"
ssh ${BCK_HOST}  mkdir -p "${BCK_IN}"
#ENVIANDO OS ARQUIVOS
scp -r ${DIR}*xml ${BCK_HOST}:${BCK_IN}
}


ENVIA ()
{
#ENVIO PARA BACKUP
ENVIA_BKP &
# ENVIANDO PARA O INPUT DE PROCESSAMENTO
DESTINO="usarioa@maquinadestino:/dirhome/dir/dirok/input/"
echo "ENVIANDO OS ARQUIVOS "
scp -r ${DIR}*xml ${DESTINO}
wait
}


TRANSFERE ()
{
#TESTO A EXISTENCIA , ORGANIZO E ENVIO A CADA N ARQUIVOS
ListaARQ=("$@")
MKDIR
cont="0"

for I in $(echo ${!ListaARQ[*]}); do
        if [ -e ${ListaARQ[I]} ] ; then
        if [ "$cont" -gt "2000" ] ; then ENVIA & sleep 3
		MKDIR ; cont="0" ; fi
        mv ${ListaARQ[I]} $DIR
        cont=$(($cont+1))
        fi
        done
        if [ "$cont" -gt "0" ] ; then ENVIA  ; fi
echo " Total ${#ListaARQ[*]} "
echo "todos os arquivos foram enviados"
}

#########################################################################
#INICIO DA EXECUÇÃO

REQUEST=$1

if [ $# -ne 1 ] ; then
	echo "$0 REQUEST_ID "; exit 1
    else GERA_LISTA $REQUEST
fi

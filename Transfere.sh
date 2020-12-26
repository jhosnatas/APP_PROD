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
spool ListaARQ.txt
select caminhodoarquivo from arquivosgerados where request_id = '$REQUEST' ;
END
)
### tratando multiplis valores no array
for I in $(printf "%s\n" `echo ${ListaARQ[@]} |sed 's/ /\n/g'`) ; do ARRAY+=("${I}") ; done
wait
ListaARQ=("${ARRAY[@]}")
}

DIVIDE_LISTA () {
echo "INICIANDO O ENVIO"
date
#DIVIDE A LISTA
split --lines 1000 ListaARQ.txt ListaARQ_
#PASSO A LISTA COMO PARAMETRO PARA A FUNÇAO TRANSFERE E EXECUTADO EM SEGUNDO PLANO , PODENDO EXECUTAR N LISTA SIMULTANEAS 
for LISTA in $(ls ListaARQ_*) ; do TRANSFERE $(cat ${LISTA}) &
NOAR=$(jobs |wc -l); echo " $LISTA em execucao " ; rm -f $LISTA ; sleep 1
until [ ! $NOAR -ge "30" ] ; do sleep 15 ; NOAR=$(jobs |wc -l) ; done
done

rm -f ListaARQ.txt
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
        if [ "$cont" -gt "501" ] ; then ENVIA & sleep 3
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

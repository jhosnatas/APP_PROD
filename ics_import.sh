#!/bin/bash
#
###################################################################
#Script Name    : IICS_util.sh
#Description    :  Utilitario do informatica cloud
#Data           : 06/09/2022
#Author         : Jonatas Silva
#Email          : jonatas.silva.terceiros@claro.com.br
###################################################################

###################################################################
## DEBUG MOD
#set -x
#set +xv

###################################################################
## VARIAVEIS

DIR_LOG=/dw/LOAD/LOG
DATE_PROC=$(date +%Y%m%d%H%M%S)
LOG=${DIR_LOG}/${0##*/}_${DATE_PROC}.log
LOCK=${DIR_LOG}/${0##*/}.lock
DTINICIO="$(date +%d/%m/%Y" "%H:%M:%S)"

###################################################################
## Funcoes pre definidas

VALIDA () {
        SAIDA="$?"
        if [ "$SAIDA" != 0 ] ; then
		echo "$*" | tee -a ${LOG}
        	TEMPOS "$*"
        	exit 1
        fi
        }


## Registra tempo no BD
TEMPOS () {
        DTFIM=$(date +%d/%m/%Y" "%H:%M:%S)
        echo "$0;$DTINICIO;$DTFIM;$SAIDA;$*" >> ${DIR_LOG}/TEMPOS.csv
        }

###################################################################
## Script comeca aqui
#for ((i=1;i<=10;i++)); do echo $i; done
usage () {
echo 'SOLUTION : HOW TO: Import assets into different Project using import REST API in IICS
The default behavior of the Import operation is, it will create a directory structure similar to the Export operation.
Source Org => Explore/MyProject/MyFolder/MyAssets --> Gets exported into a Zip file with this directory structure
Target Org => Explore/MyProject/MyFolder/MyAssets --> Gets imported with similar structure as Source Org.

STEP BY STEP
1) Do a REST V2 login/loginSaml or REST V3 login call to get the session ID for the Source Org. Find the following reference KBs
2). From the login API response, get icSessionId (V2 login) or sessionId (V3 login) and Service URL.
3) REST V3 Lookup on Project
4) Make a note of "id" value from above response that shall be used in the import API
5) Login into Target Org as mentioned in Step 1 and get session ID
6) Do V3 lookup and get FRS ID for the Target Orgs Project as well.
As part of Import API step, provide Source Orgs Project asset ID and Target Orgs Project asset ID into the Request. Refer to the below KB for steps involved in Import operation.
https://knowledge.informatica.com/s/article/631565?language=en_US
As part of Step 7 on the KB, Project override can be done as below. Similar to projects other assets can be overwritten as well like Runtime Environments, Connections, etc.
https://network.informatica.com/onlinehelp/IICS/prod/CDI/en/index.htm#page/tt-cloud-rest-api/Informatica_Intelligent_Cloud_Services_REST_API.html'
}

proxy_ini ()
	{
	PROXY_INI=/secureagent/apps/agentcore/conf/proxy.ini
	if [ -f $PROXY_INI ] ; then 
		ProxyPassword="$( grep -w InfaAgent.ProxyPassword $PROXY_INI )" 
		ProxyHost="$( grep -w InfaAgent.ProxyHost $PROXY_INI )"
		ProxyPort="$( grep -w InfaAgent.ProxyPort $PROXY_INI )"	
		PROXY="http://:${ProxyPassword:24}@${ProxyHost:20}:${ProxyPort:20}"
		CURLX="curl -sS -x ${PROXY} -L -X"  ###"${SRCENV//['"']/}"
		$CURLX POST 'https://dm-us.informaticacloud.com/ma/api/v2/user/login' >/dev/null 2>&1
		VALIDA ERRO DE PROXY
		echo "CONECTIVADE COM IICS OK -> dm-us.informaticacloud <- " | tee -a ${LOG}
	else
		echo "ARQUIVO DE PROXY INVALIDO\n${PROXY_INI}" | tee -a ${LOG}
	fi
	export CURLX
	export HEADER='-H Accept:application/json -H Content-Type:application/json '
	}


get_token () 
	{
	API='https://dm-us.informaticacloud.com/ma/api/v2/user/login'
	echo -e "GERANDO TOKEN DE ACESSO\nAPI:${API}" | tee -a ${LOG}
	RAW="{\"@type\":\"login\",\"username\":\"${USER}\",\"password\":\"${PASSWD}\"}"
	CMD=$( ${CURLX} POST $API  ${HEADER} --data-raw ${RAW} 2>/dev/null )
	export SERVERURL="$( /dw/jq/jq .serverUrl <<< $CMD )"
	export ICSESSIONID="$( /dw/jq/jq .icSessionId <<< $CMD )"
        SERVERURL="${SERVERURL//['"']/}"
        ICSESSIONID="${ICSESSIONID//['"']/}"
	HEADER+='-H INFA-SESSION-ID:'${ICSESSIONID}''
	export HEADER
        }

#VALIDA TOKEN OK
valida_token () 
	{	
        [ $1 ] && ICSESSIONID=$1
	[ $SERVERURL ] || SERVERURL='https://use6.dm-us.informaticacloud.com/saas'
	export SERVERURL
	API=''${SERVERURL}'/api/v2/user/validSessionId'
	RAW="{\"@type\":\"validatedToken\",\"userName\":\"${USER}\",\"icToken\":\"${ICSESSIONID}\"}"
	CMD=$( $CURLX POST $API $HEADER --data-raw $RAW )
	TRUE="$(/dw/jq/jq .isValidToken  <<< $CMD )"
	if [ "$TRUE" == 'true' ] ; then
		echo "TOKEN VALIDADO COM SUCESSO"
	else
		echo "ERRO DO AUTENTICACAO NO IICS"
		exit 99
	fi
	}


#CRIA PACOTE EXPORT
cria_export ()
	{
        echo -e "\nGERANDO PACOTE PARA O EXPORT \n-> receber objeto id do lookup" | tee -a ${LOG}
        OBJID="2IYcU7hnoDVbfWh2sg2DGT" 
#2IYcU7hnoDVbfWh2sg2DGT # "2IYcU7hnoDVbfWh2sg2DGT" ID DO OBJETO "path":"Project_Hml","type":"Project" #"id": "7nVa4BHNJ0FflXpdXN8WSo", "path": "Project_Hml/PJ_API",
	API=''${SERVERURL}'/public/core/v3/export'
	RAW="{\"name\":\"testJob1\",\"objects\":[{\"id\":\"${OBJID}\",\"includeDependencies\":\"true\"}]}"
	CMD=$( $CURLX POST $API $HEADER --data-raw $RAW )
	EXPID="$(/dw/jq/jq .id <<< $CMD )"
	EXPSTT="$(/dw/jq/jq .status.state <<< $CMD )"
	EXPID=${EXPID//['"']/}

        }

status_export ()
	{
	API=''${SERVERURL}'/public/core/v3/export/'${EXPID}'?expand=objects'
	while true ; do
		grep -q '"SUCCESSFUL"' <<< ${EXPSTT}
		if [ $? -ne  0 ] ; then
			sleep 10
			CMD=$( $CURLX GET $API $HEADER )
			EXPSTT="$(/dw/jq/jq .status.state <<< $CMD )"
		else
			break
		fi
	done

	}

download_pack ()
	{
         echo -e "\nINICIANDO DOWNLOAD DO PACOTE \n -> receber export id "  | tee -a ${LOG}
         API=''${SERVERURL}'/public/core/v3/export/'${EXPID}'/package'
 	$CURLX GET $API $HEADER -o exp_pack.zip
 	if [ -f "exp_pack.zip" ] ; then
 	echo 'DOWNLOAD EFETUADO COM SUCESSO' | tee -a ${LOG}
 	fi
        }

cria_import ()
        {
	API=''${SERVERURL}'/public/core/v3/import/package'
	echo -e "\nCRIANDO PACOTE DE IMPORT\nAPI:${API}\nAMBIENTE ORIGEM: ${SRCENV}\nAMBIENTE DESTINO: ${ENVI}\nPACKAGE NAME: ${PKGNAME}" | tee -a ${LOG}
	IMPHEADER='-H Content-Type:multipart/form-data -H INFA-SESSION-ID:'${ICSESSIONID}' -F package=@'${ZIPFILE}''
	CMD=$( $CURLX POST $IMPHEADER $API )
        IMPSTT="$( /dw/jq/jq .jobStatus.state <<< $CMD )"
	IPT_ID="$( /dw/jq/jq .jobId <<< $CMD )"
        IPT_ID="${IPT_ID//['"']/}"
	if [ $IMPSTT == '"NOT_STARTED"' ] ; then 
		echo -e "IMPORT CRIADO COM SUCESSO \nID: ${IPT_ID} " | tee -a ${LOG}
	else
		echo -e "FALHA AO CRIAR IMPORT\n$CMD" | tee -a ${LOG}
		exit 55
	fi

        }


status_import ()
        {
	API=''${SERVERURL}'/public/core/v3/import/'${IPT_ID}''
        while true ; do
                grep -q '"SUCCESSFUL"' <<< ${IMPSTT:=INPROGRESS}
                if [ $? -ne 0 ] ; then
			echo -e "AGUARDANDO FIM DO IMPORT ..." | tee -a ${LOG}
                        sleep 10
                        CMD=$( $CURLX GET $API $HEADER )
                        IMPSTT="$(/dw/jq/jq .status.state <<< $CMD )"
                else
			echo -e "IMPORT FINALIZADO COM SUCESSO " | tee -a ${LOG}
                        break
                fi
        done

}

start_import ()
        {
	echo -e "\nINICIANDO IMPORT NO IICS"  | tee -a ${LOG}
	API=''${SERVERURL}'/public/core/v3/import/'${IPT_ID}''
	RAW="{\"name\":\"testJob1\",\"importSpecification\":{\"defaultConflictResolution\":\"OVERWRITE\",\"objectSpecification\":[{\"sourceObjectId\":\"${TARGETOBJID}\",\"targetObjectId\":\"${TARGETOBJID}\"}]}}"
	CMD=$( $CURLX POST $API $HEADER --data-raw $RAW )
	IMPSTT="$( /dw/jq/jq .status.state <<< $CMD )"
	if [ $IMPSTT == '"IN_PROGRESS"'  ] ; then echo -e "IMPORT EM EXECUÇÃO\nSTATUS: ${IMPSTT}"  | tee -a ${LOG}
	else
		echo -e "ERRO AO INICIAR IMPORT\n${CMD}" | tee -a ${LOG}
	fi
	}
valida_publish ()
		{
			echo -e "ERRO NOs SEGUINTES ITEM\n$( /dw/jq/jq '.data.attributes.itemDetail[] |  select(.itemState!="SUCCESS")' <<< $CMD )" 
			exit 256
		}
publish_state ()
	        {
		[ $1 ] && echo "IN_PROGRESS AGUARDANDO FIM DO PUBLISH" && sleep 15 
		CMD=$( $CURLX GET $PUBLINK $PUBHEADER )
		PUBSTT="$( /dw/jq/jq .data.attributes.jobState <<<  $CMD)"

	 case $PUBSTT in 
		 '"IN_PROGRESS"') publish_state 0 ;;
		 '"SUCCESS"') echo -e "PUBLISH FINALIZADO COM SUCESSO" | tee -a ${LOG}  ;;
		 '"WARNING"') valida_publish ;;
		*) echo "ERRO NO PUBLISH " ;;
 	 esac
		}

publish_taskflow ()
	{
	RAW="{\"data\":{\"type\":\"publish\",\"attributes\":{\"assetPaths\":[${LISTASKFLOW}]}}}"
         echo -e "\nPUBLICANDO WORKFLOWTASK"  | tee -a ${LOG}
	API='https://use6.dm-us.informaticacloud.com/active-bpel/public/api/cai/v1/PublishJobs'
	PUBHEADER='-H Content-Type:application/vnd.api+json -H Accept:application/vnd.api+json -H INFA-SESSION-ID:'${ICSESSIONID}''
	export PUBHEADER
         CMD=$( $CURLX POST $API $PUBHEADER --data-raw $RAW )
	 PUBSTT="$( /dw/jq/jq '.data.attributes.jobState' <<<  $CMD)"
         if [ $PUBSTT == '"NOT_STARTED"'  ] ; then
		 echo -e "PUBLISH EM EXECUÇÃO\nSTATUS: ${PUBSTT}\nITEMS:"  | tee -a ${LOG}
		 echo "$( /dw/jq/jq '.data.attributes.assetPaths' <<< $CMD )" | tee -a ${LOG}
		 export PUBSELF="$( /dw/jq/jq .links.self <<< $CMD )"
		 PUBLINK="$( /dw/jq/jq .links.status <<< $CMD )"
		 export PUBLINK="${PUBLINK//['"']/}"
         else
                 echo -e "ERRO AO INICIAR PUBLISH\n${CMD}" | tee -a ${LOG}
         fi
	publish_state
	}

trata_obj () {
        #LIMAPANDO OBJ INDESEJADOS DA SAIDA
        OBJETO="${OBJETO//'"OK-Process" type'/}"
        OBJETO="${OBJETO//'"REJ-Process" type'/}"
        OBJETO="${OBJETO//'"Processado" type'/}"
        OBJETO="${OBJETO//'"Rejeitado" type'/}"
        OBJETO="${OBJETO// /}"
        export OBJETO
        }

error_handling () 
	{
	ARQ=$1
	unset LOBJETO
	FAULTFILD=$(grep -n interrupting $ARQ | sed 's/interrupting=//g' | sed 's/ //g' )
	for X in ${FAULTFILD[@]} ; do
        	line="$( echo $X | cut -d ':' -f1)"
                grep -q 'true' <<< ${X}
                if [ $? -ne 0 ] ; then
                line=$((${line}-2))
                OBJETO="$(sed -n "${line}p" $ARQ | cut -d '=' -f2 | cut -d '.' -f2 | cut -d '/' -f1)"
                LOBJETO+="${OBJETO} : Error_Handling = False\n"
        	fi
	done
	[ "$LOBJETO" ] && echo -e "${LOBJETO}"

                }

failOnNotRun () 
	{
	ARQ=$1
	unset LOBJETO
	FAULTFILD=$(grep -n failOnNotRun $ARQ | sed 's/ //g' )
	for X in ${FAULTFILD[@]} ; do
        	line="$( echo $X | cut -d ':' -f1)"
        	field="$( echo $X | cut -d ':' -f2)"
                	grep -q 'true' <<< ${field}
                	if [ $? -ne 0 ] ; then
                	line=$((${line}-3))
                	OBJETO="$(sed -n "${line}p" $ARQ | cut -d '=' -f3)"
                	trata_obj
                	[ ${#OBJETO} -gt 0 ] && LOBJETO+="${OBJETO}: failOnNotRun = False\n"
        	fi
	done
	[ "$LOBJETO" ] && echo -e "${LOBJETO}"
                }

failOnFault () 
	{
	ARQ=$1
	unset LOBJETO
	FAULTFILD=$(grep -n failOnFault $ARQ | sed 's/ //g' )
	for X in ${FAULTFILD[@]} ; do
        	line="$( echo $X | cut -d ':' -f1)"
        	field="$( echo $X | cut -d ':' -f2)"
                	grep -q 'true' <<< ${field}
                	if [ $? -ne 0 ] ; then
                	line=$((${line}-4))
                	OBJETO="$(sed -n "${line}p" $ARQ | cut -d '=' -f3)"
                	trata_obj
                	[ ${#OBJETO} -gt 0 ] && LOBJETO+="${OBJETO} failOnFault = False\n"
        	fi
	done
	[ "$LOBJETO" ] && echo -e "${LOBJETO}"
                }

allowedGroups () 
	{
	ARQ=$1
	unset LOBJETO
	FAULTFILD=$(grep -n '<group>' $ARQ | sed 's/ //g' )
	for X in ${FAULTFILD[@]} ; do
        	grep -q 'Automação' <<< ${X}
                if [ $? -ne 0 ] ; then
                	LOBJETO+="AllowedGroups = Invalido\n"
        	fi
	done
	[ "$LOBJETO" ] && echo -e "${LOBJETO}"
                }

apiname () 
	{
	ARQ=$1
	unset LOBJETO
	APINAME="$( grep '<types1:Name>' $ARQ |cut -d '>' -f2  |cut -d '<' -f1 )"
	WKFNAME="$( grep '<types1:DisplayName>' $ARQ |cut -d '>' -f2  |cut -d '<' -f1  )"
        if [ ${APINAME// /} != ${WKFNAME// /} ]  ; then
                echo -e "API NAME = INVALIDO\n"
        fi
        }

validaxml ()
	{
	cd $LDIR
	for ARQUIVO in  *.TASKFLOW.xml ; do
        	declare SAIDA
        	ARQUIVO="${ARQUIVO// /}"
       # 	SAIDA+="$( apiname $ARQUIVO )\n"
        	SAIDA+="$( allowedGroups $ARQUIVO )\n"
        	SAIDA+="$( error_handling $ARQUIVO )\n"
        	SAIDA+="$( failOnNotRun $ARQUIVO )\n"
        	SAIDA+="$( failOnFault $ARQUIVO )\n"
        	V=$( echo -e "${ARQUIVO}\n${SAIDA}" | sed -r '/^[\s\t]*$/d') && V="${V// /}"
        	if [ "$V" ==  "$ARQUIVO" ] ; then
                	ARQUIVO="${ARQUIVO/.TASKFLOW.xml/}"
                	echo -e "$ARQUIVO - VALIDADO COM SUCESSO" | tee -a ${LOG}
        	else
                	ARQUIVO="${ARQUIVO/.TASKFLOW.xml/}"
                	echo  -e "\n${ARQUIVO} - ERRO NA VALIDAÇÃO\n${SAIDA}"  | sed -r '/^[\s\t]*$/d' | tee -a ${LOG} &&  echo -e "\n" | tee -a ${LOG}
                	INVALIDO+="${ARQUIVO}\n"
        	fi
        	unset SAIDA
	done
	export INVALIDO
        }


apagatmp ()
 {
        grep -q '.TMP' <<< ${DIRZ}
        if [ $? -eq 0 ] ; then
                rm -rf ${DIRZ}
                VALIDA ERRO AO APAGAR DIR TMP
        else
                echo "ERRO AO APAGAR DIR TMP" | tee -a ${LOG}
                exit 89
        fi
           }

zipfile ()
{
ZIPFILE=${1:-ZIPARQ}
WKDIR="/dw/WORK"
declare INVALIDO

cd $WKDIR
grep -q ".zip$" <<< $ZIPFILE
VALIDA Uso incorreto informar arquivo .zip
echo -e "VALIDANDO ZipFile: ${1##*/}" | tee -a ${LOG}

if [ -f "$ZIPFILE" ]; then
        DIRZ="${ZIPFILE##*/}" && DIRZ="${WKDIR}/${DIRZ/.zip/.TMP}"
        mkdir -p ${DIRZ}
        VALIDA ERRO AO CRIAR DIR TEMP
        unzip -o -q $ZIPFILE -d $DIRZ
        VALIDA ERRO AO Descompactar arquivo
	SRCENV="$( /dw/jq/jq '.exportedObjects[] | select (.objectType=="AgentGroup") | .objectGuid' ${DIRZ}/exportMetadata.v2.json  )"
	export SRCENV="${SRCENV//['"']/}"
	export PKGNAME="$( /dw/jq/jq .name ${DIRZ}/exportMetadata.v2.json  )"
	LISTASKFLOW="$( find $DIRZ/Explore/Project_Hml/ -name "*TASKFLOW.xml" )"
	export LISTASKFLOW=${LISTASKFLOW//$DIRZ/}
	LISTASKFLOW="$(echo ${LISTASKFLOW}  | sed 's/\/Explore/"Explore/g ; s/ /",/g ; s/$/"/g')"
	echo "$( /dw/jq/jq '.exportedObjects[] | select (.objectType=="AgentGroup") | .objectGuid , .objectName' ${DIRZ}/exportMetadata.v2.json )" | tee -a ${LOG}
        for LDIR in $( find $DIRZ -type d ) ; do
                ls ${LDIR}/*.TASKFLOW.xml  >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                echo "PATH TMP : $LDIR" | tee -a ${LOG}
                validaxml $LDIR
                fi
        done
        if [ "$INVALIDO" ] ; then
                echo -e "\nTASKFLOW INVALIDO:\n$INVALIDO"  | tee -a ${LOG}
                apagatmp
                exit 99
        else
                echo -e "ZIPEFILE VALIDADO COM SUCESSO\n"  | tee -a ${LOG}
                apagatmp
        fi
else
        echo "Arquivo invalido" | tee -a ${LOG}
        exit 55
fi

        }


dir_git_lab ()
        {
        #ambiente varia do usuario de login
        PROJETO=$1
        AMBIENTE=$2
        export WKDIR="/dw/WORK"
        GITLAB=http://vpsdomeugitlab.dcing.corp/bi_user_hml/$PROJETO
        cd $WKDIR

        if [ $# -lt 2 ] ; then
                echo -e "Uso da incorreto ta funcao"  | tee -a ${LOG}
                exit 1
        fi

        echo -e "$DTINICIO Iniciada a execucao\nScript: ${0##*/}\nUSUARIO: ${USER}\nAMBIENTE: ${ENVI}\nLog: ${LOG}" | tee -a ${LOG}
        echo -e "FUNCÃO: ICS IMPORT\nPROJETO : $PROJETO\n" | tee -a ${LOG}
        echo -e "BAIXANDO REPOSITORIO DE $AMBIENTE ATUALIZADO NO GIT" | tee -a ${LOG}

        if [ -d "$WKDIR/$PROJETO" ]; then
        echo "LIMPANDO EXECUCAO ANTERIOR"  | tee -a ${LOG}
                rm -rf "$WKDIR/$PROJETO"
        fi

        echo -e "\nclonando repositorio atualizado " | tee -a ${LOG}
        git clone $GITLAB ####>>${LOG} 2>&1
	
        cd $PROJETO
        git checkout ${AMBIENTE}
        git pull

        }

git_rollback () 
		{
        PROJETO=$1
        AMBIENTE=$2
        TAG=$3

        if [ $# -ne 3 ] ; then
        echo -e "INFORMAR PARAMETROS\n${0##/*} "  | tee -a ${LOG}
        exit 1
        fi
	echo "dir_git_lab $PROJETO $TAG"
        dir_git_lab $PROJETO $TAG
	ZIPFILE="$(ls *zip)"
	if [ "$( wc -l <<< $ZIPFILE )"  -ne 1 ] ; then
		echo "Erro ao selecionar arquivo de deploy"
		exit 1
		else
		echo -e "ARQUIVO SELECIONADO\n$ZIPFILE"
	fi
	
	cp ${ZIPFILE} ../
	echo "###################222222222222222222222222###########################"
	AMBIENTE=$2
	echo "dir_git_lab $PROJETO ${AMBIENTE}"
	dir_git_lab $PROJETO ${AMBIENTE}
	ls
	rm -vf *.*
	cp -v ${WKDIR}/${ZIPFILE} .
	git add .
	git commit -m "ROLLBACK PARA A VERSAO $TAG"
	git  push -u origin ${AMBIENTE}
        echo -e "ROLLBACK DE $AMBIENTE PARA A VERSAO $TAG \nEFETUADO COM SUCESSO" | tee -a ${LOG}
                }



create_tag () 
		{
	PROJETO=$1
	AMBIENTE=$2
	TAG=$3

	if [ $# -ne 3 ] ; then
        echo -e "INFORMAR PARAMETROS\n${0##/*} "  | tee -a ${LOG}
        exit 1
	fi

	dir_git_lab $PROJETO $AMBIENTE

	echo -e "\nCRIANDO NOVA TAG PARA O COMMIT"
	git tag -a "${TAG}" -m "${AMBIENTE} $(date +%d/%m/%Y) " ###>>${LOG} 2>&1
	git push -u origin ${AMBIENTE}  --tags ###>>${LOG} 2>&1
	echo "TAG : $TAG " | tee -a ${LOG}
	echo "TAG criada com sucesso " | tee -a ${LOG}
		}

updatexxx ()
        {
ENVTO=$3
ENVFROM=$2
PROJETO=$1

if [ $# -ne 3 ] ; then
        echo -e "INFORMAR PARAMETROS\n${0##/*} "  | tee -a ${LOG}
        exit 1
fi

echo -e "$DTINICIO Iniciada a execucao\nScript: ${0##*/}\nUSUARIO: ${USER}\nPROJETO: $PROJETO\nLog: ${LOG}" | tee -a ${LOG}
echo -e "FUNCÃO: GIT LAB MERGE \nFROM :$ENVFROM\nPARA: $ENVTO " | tee -a ${LOG}

dir_git_lab ${PROJETO} ${ENVTO}

echo -e "\nINICIANDO MERGE DE $ENVFROM PARA $ENVTO " | tee -a ${LOG}

git merge -m "MERGE DE $ENVFROM PARA $ENVTO" origin/$ENVFROM --strategy-option theirs

echo -e "\nATUALIZANDO BRANCH DE  $ENVTO " | tee -a ${LOG}
git add .
git commit -m "MERGE DE $ENVFROM PARA $ENVTO"
git  push -u origin $ENVTO

        }

update ()
       {
ENVTO=$3
ENVFROM=$2
PROJETO=$1
ARQUIVO=$4

if [ $# -ne 4 ] ; then
	echo -e "INFORMAR PARAMETROS\n${0##/*} "  | tee -a ${LOG}
	exit 1
fi

echo -e "\nPROMOVENDO PACOTE $ARQUIVO DE  $ENVFROM PARA $ENVTO " | tee -a ${LOG}

dir_git_lab ${PROJETO} ${ENVFROM}

ZIPFILE="$(ls  $ARQUIVO)"
if [ "$( wc -l <<< $ZIPFILE )"  -ne 1 ] ; then
    echo "Erro ao selecionar arquivo de deploy"
       exit 1
       else
       echo -e "ARQUIVO SELECIONADO\n$ZIPFILE"
fi
	cp ${ZIPFILE} ../
	echo "###################222222222222222222222222###########################"
	echo "dir_git_lab $PROJETO ${ENVTO}"
	dir_git_lab $PROJETO ${ENVTO}
	ls
	rm -vf *.*
	cp -v ${WKDIR}/${ZIPFILE} .
	git add .
	git commit -m "PROMOVENDO $ARQUIVO DE  $ENVFROM PARA $ENVTO"
	git  push -u origin ${ENVTO}
	echo -e "PACOTE $ARQUIVO DE PROMOVIDO DE $ENVFROM PARA $ENVTO COM SUCESSO" | tee -a ${LOG}
	echo -e "\nINICIANDO MERGE DE $ENVFROM PARA $ENVTO " | tee -a ${LOG}

	}


env_target ()
        {
USER=$1
PASSWD=$2

if ! [[ $USER ]] || ! [[ $PASSWD ]] ; then 
	echo -e "ERRO DE PARAMETROS \n${0##/*} -u USUARIO SENHA "
	exit 1
fi

case ${USER##*@} in
        bi.hom)ENVI='HOMOLOGACAO' && TARGETOBJID='25nku1Bhr6KdQBvCc17G8v' ;;
        bi.prd)ENVI='PRODUÇÃO' ;;
        *) echo "USUARIO INVALIDO" && exit 1 ;;
esac

        }
      
ics_update ()
	{
	
	if [ $# -ne 3 ] ; then
		        echo -e "INFORMAR PARAMETROS\n${0##/*} "  | tee -a ${LOG}
			        exit 1
	fi

	dir_git_lab $1 $2
#	ZIPFILE="$(ls *zip)"
 	ZIPFILE=$3
	if [ -f "$ZIPFILE" ]; then
       		unzip -o -q $ZIPFILE
        	VALIDA ERRO AO Descompactar arquivo
		cd "${ZIPFILE/.zip/}"
		DEPLOYZIP="$(ls | egrep "(deploy_|DEPLOY_)" | grep .zip$ )"
		if [ "$( wc -l <<< $DEPLOYZIP )"  -ne 1 ] ; then
        		echo "Erro ao selecionar arquivo de deploy"
			exit 1
		else
        		echo -e "ARQUIVO DE DEPLOY SELECIONADO\n$DEPLOYZIP"
		fi
	fi
	DEPLOYZIP=""$(pwd)"/$DEPLOYZIP"
	zipfile $DEPLOYZIP
	echo -e "CONECTANDO AO IICS \nAMBIENTE: ${ENVI}" | tee -a ${LOG}
	proxy_ini
	get_token
	valida_token
	echo -e "AMBIENTE ORIGEM: ${SRCENV}\nAMBIENTE DESTINO: ${ENVI}\n"
	cria_import $1
	start_import
	status_import
	publish_taskflow

	}

exec_import () 
	{
	dir_git_lab
	## VALIDANDO PARAMETROS
	if [ $# -lt 1 ] ; then
        	echo -e "INFORMAR PARAMETROS\n${0##/*} -u USUARIO SENHA -I /dir/arquivo.zip"  | tee -a ${LOG}
        	exit 1
	fi
	echo -e "$DTINICIO Iniciada a execucao\nScript: ${0##*/}\nUSUARIO: ${USER}\nAMBIENTE: ${ENVI}\nLog: ${LOG}" | tee -a ${LOG}
	echo -e "FUNCÃO: IMPORT\nARQUIVO : $1\n" | tee -a ${LOG}
	zipfile $1
	echo -e "CONECTANDO AO IICS \nAMBIENTE: ${ENVI}" | tee -a ${LOG}
	proxy_ini
	get_token
	valida_token
	echo -e "AMBIENTE ORIGEM: ${SRCENV}\nAMBIENTE DESTINO: ${ENVI}\n"
	cria_import $1
	start_import
	status_import
	publish_taskflow
         }

exec_export () 
	{
	get_token
	valida_token
	cria_export
	status_export
	download_pack
	}

#INICIO DA EXECUÇÃO AQUI
if [[ $* ]] ; then
	while [[ $* ]] ; do
		case $1 in
			"-u") env_target $2 $3 && shift 3 ;;
#			"-v") CMD="exec_import $2 $3" && shift 3 ;;
			"-x")set -x && shift 1 ;;
			"-E"|"-e") CMD="exec_export $2" && shift 2 ;;
			"-h") usage && exit 0 ;;
#			"-git_push") CMD="git_lab_push $2 $3 $4 $5 " && shift 5 ;;
			"-git_rollback") CMD="git_rollback $2 $3 $4" && shift 4 ;;
			"-git_update") CMD="update $2 $3 $4 $5" && shift 5 ;;
			"-ics_update") CMD="ics_update $2 $3 $4" && shift 4 ;;
			"-tag") CMD="create_tag $2 $3 $4" && shift 4 ;;
			*) echo "ERRO PARAMETRO INVALIDO : $1" && exit 1 ;;
		esac
	let i++
        if [ $i -gt 100 ]; then echo "ERRO DE PARAMETROS" ;  exit 1 ; fi
	done

	if  [[ $CMD ]] ; then
		$CMD
	else
		echo "ERRO PARAMETROS -I (Import) ou -E (Export)"
		exit 1
	fi
else
	echo "ERRO INFORMAR PARAMETROS"
	exit 1
fi

## Fim do Shell
SAIDA="0"
TEMPOS SCRIPT EXECUTADO COM SUCESSO
echo -e "FINALIZADO COM SUCESSO"
exit 0

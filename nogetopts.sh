#!/bin/bash
###################################################################
#Script Name    : nogetopts
#Description    : Usado como modelo base para criar novos sh
#Data           : 24/10/2022
#Author         : Jonatas Silva
#Email          : jhosnatas@hotmail.com
###################################################################

#COMO TRATAR ARGUMENTOS COM MULTIPLAS VARIAVEIS
#ALTERNATIVA GETOPS QUE SÓ RECEBE UMA VARIEVEL POR OPÇÃO
#LER $1 E CRIA LINHA DE COMANDO OU SET O AMBIENTE CONFORME OPÇCAO 
#EXEMPLO
#"-u") Ira configurar usuario e senha
#"-x") Ira set o debug 
#"-git_push") Ira criar uma linha de comando que sera executada no proximo passo 
#Assim dando prioridade para configurar e depois executar 

if [[ $* ]] ; then
        while [[ $* ]] ; do
                case $1 in
                        "-u") USER=$2 SENHA=$3 && shift 3 ;;
                        "-i"|"-I") CMD="exec_import $2" && shift 2 ;;
                        "-x")set -x && shift 1 ;;
                        "-E"|"-e") CMD="exec_export $2" && shift 2 ;;
                        "-h") usage && exit 0 ;;
                        "-git_push") CMD="git_lab_push $2 $3 $4 $5 " && shift 5 ;;
                        "-git_pull") CMD="git_lab_pull $2 $3 $4" && shift 4 ;;
                        *) echo "ERRO PARAMETRO INVALIDO : $1" && exit 1 ;;
                esac
      
        #SAIDA DO LOOP INFINITO EM CASO DE ERRO DE PAMETROS
        let i++
        if [ $i -gt 100 ]; then echo "ERRO DE PARAMETROS" ;  exit 1 ; fi
       
        done
        #EXECUTA LINHA DE COMANDO CRIADA
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

exit 0

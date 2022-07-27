#!/bin/bash
#
#------------------------------------------------------
### JONATAS SILVA 2022
### Passando arquivos para lowcase 
### http://jhosnatas.github.io/
### Pode receber lista de arquivos
#------------------------------------------------------
#
## Validando parametros
[ ! "$@" ] && echo " Informar arquivos " && exit 1

##Tratando arquivos
for I in $@ ; do
	if [ ! -f "$I"  ] ; then echo " Arquivo não encontrado "
	else
	tr '[:upper:]' '[:lower:]' < "$I" >> ${I}_small.txt
	fi
done

exit 0

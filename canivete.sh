Códigos prontos

Tratando arquivos windows com perl
perl -p -e 's/\r$//' < winfile.txt > unixfile.txt

Condicionais com o IF
if [ -f "$arquivo" ]; then echo 'Arquivo encontrado'; fi
if [ ! -d "$dir" ]; then echo 'Diretório não encontrado'; fi
if [ $i -gt 5 ]; then echo 'Maior que 5'; else echo 'Menor que 5'; fi
if [ $i -ge 5 -a $i -le 10 ]; then echo 'Entre 5 e 10, incluindo'; fi
if [ $i -eq 5 ]; then echo '=5'; elif [ $i -gt 5 ]; then echo '>5'; else echo '<5'; fi
if [ "$USER" = 'root' ]; then echo 'Oi root'; fi
if grep -qs 'root' /etc/passwd; then echo 'Usuário encontrado'; fi


Operadores Relacionais
== Igual
 != Diferente
> Maior
>= Maior ou Igual
< Menor
<= Menor ou Igual

Condicionais com o E (&&) e OU (||)
[ -f "$arquivo" ] && echo 'Arquivo encontrado'
[ -d "$dir" ] || echo 'Diretório não encontrado'
grep -qs 'root' /etc/passwd && echo 'Usuário encontrado'
cd "$dir" && rm "$arquivo" && touch "$arquivo" && echo 'feito!'
[ "$1" ] && param=$1 || param='valor padrão'
[ "$1" ] && param=${1:-valor padrão}
[ "$1" ] || { echo "Uso: $0 parâmetro" ; exit 1 ; }

Adicionar 1 à variável $i
i=$(expr $i + 1)
i=$((i+1))
let i=i+1
let i+=1
let i++

Loop de 1 à 10
for i in 1 2 3 4 5 6 7 8 9 10; do echo $i; done
for i in $(seq 10); do echo $i; done
for ((i=1;i<=10;i++)); do echo $i; done
i=1 ; while [ $i -le 10 ]; do echo $i ; i=$((i+1)) ; done
i=1 ; until [ $i -gt 10 ]; do echo $i ; i=$((i+1)) ; done
Loop nas linhas de um arquivo ou saída de comando
cat /etc/passwd | while read LINHA; do echo "$LINHA"; done
grep 'root' /etc/passwd | while read LINHA; do echo "$LINHA"; done
while read LINHA; do echo "$LINHA"; done < /etc/passwd
while read LINHA; do echo "$LINHA"; done < <(grep 'root' /etc/passwd)
Curingas nos itens do comando case
case "$dir" in /home/*) echo 'dir dentro do /home';; esac
case "$user" in root|joao|maria) echo "Oi $user";; *) echo "Não te conheço";; esac
case "$var" in ?) echo '1 letra';; ??) echo '2 letras';; ??*) echo 'mais de 2';; esac
case "$i" in [0-9]) echo '1 dígito';; [0-9][0-9]) echo '2 dígitos';; esac

Expansão de variáveis
Sintaxe Expansão Condicional
${var:-texto} Se var não está definida, retorna 'texto'
${var:=texto} Se var não está definida, defina-a com 'texto'
${var:?texto} Se var não está definida, retorna o erro 'texto'
${var:+texto} Se var está definida, retorna 'texto', senão retorna o vazio
Sintaxe Expansão de Strings
${var} É o mesmo que $var, porém não ambíguo
${#var} Retorna o tamanho da string
${!var} Executa o conteúdo de $var (igual 'eval \$$var')
${!texto*} Retorna os nomes de variáveis começadas por 'texto'
${var:N} Retorna o texto à partir da posição 'N'
${var:N:tam} Retorna 'tam' caracteres à partir da posição 'N'
${var#texto} Corta 'texto' do início da string
${var##texto} Corta 'texto' do início da string (* guloso)
${var%texto} Corta 'texto' do final da string
${var%%texto} Corta 'texto' do final da string (* guloso)
${var/texto/novo} Substitui 'texto' por 'novo', uma vez
${var//texto/novo} Substitui 'texto' por 'novo', sempre
${var/#texto/novo} Se a string começar com 'texto', substitui 'texto' por 'novo'
${var/%texto/novo} Se a string terminar com 'texto', substitui 'texto' por 'novo'


Blocos e agrupamentos
Sintaxe Descrição Exemplo
"..." Protege uma string, mas reconhece $, \ e ` como especiais "abc"
'...' Protege uma string, nenhum caractere é especial 'abc'
$'...' Protege uma string, mas interpreta \n, \t, \a, etc $'abc\n'
`...` Executa comandos numa subshell, retornando o resultado `ls`
{...} Agrupa comandos em um bloco { ls ; }
(...) Executa comandos numa subshell ( ls )
$(...) Executa comandos numa subshell, retornando o resultado $( ls )
((...)) Testa uma operação aritmética, retornando 0 ou 1 ((5 > 3))
$((...)) Retorna o resultado de uma operação aritmética $((5+3))
[...] Testa uma expressão, retorna 0 ou 1 (alias do comando 'test') [ 5 -gt 3 ]
[[...]] Testa uma expressão, retorna 0 ou 1 (podendo usar && e ||) [[ 5 > 3 ]]

Variáveis especiais
Variável Parâmetros Posicionais
$0 Parâmetro número 0 (nome do comando ou função)
$1 Parâmetro número 1 (da linha de comando ou função)
... Parâmetro número N ...
$9 Parâmetro número 9 (da linha de comando ou função)
${10} Parâmetro número 10 (da linha de comando ou função)
... Parâmetro número NN ...
$# Número total de parâmetros da linha de comando ou função
$* Todos os parâmetros, como uma string única
$@ Todos os parâmetros, como várias strings protegidas
Variável Miscelânia
$$ Número PID do processo atual (do próprio script)
$! Número PID do último job em segundo plano
$_ Último argumento do último comando executado
$? Código de retorno do último comando executado

Comando Função Opções úteis
cat Mostra arquivo -n, -s
cut Extrai campo -d -f, -c
date Mostra data -d, +'...'
diff Compara arquivos -u, -Nr, -i, -w
echo Mostra texto -e, -n
find Encontra arquivos -name, -iname, -type f, -exec, -or
fmt Formata parágrafo -w, -u
grep Encontra texto -i, -v, -r, -qs, -n, -l, -w -x, -A -B -C
head Mostra Início -n, -c
od Mostra Caracteres -a, -c, -o, -x
paste Paraleliza arquivos -d, -s
printf Mostra texto nenhuma
rev Inverte texto nenhuma
sed Edita texto -n, -f, s/isso/aquilo/, p, d, q, N
seq Conta Números -s, -f
sort Ordena texto -n, -f, -r, -k -t, -o
tac Inverte arquivo nenhuma
tail Mostra Final -n, -c, -f
tee Arquiva fluxo -a
tr Transforma texto -d, -s, A-Z a-z
uniq Remove duplicatas -i, -d, -u
wc Conta Letras -c, -w, -l, -L
xargs Gerencia argumentos -n, -i

Testes em arquivos
-b E um dispositivo de bloco
-c E um dispositivo de caractere Comparação NumErica
-d E um diretório
-e O arquivo existe
-f E um arquivo normal
-g O bit SGID está ativado
-G O grupo do arquivo E o do usuário atual
-k O sticky-bit está ativado
-L O arquivo E um link simbólico
-O O dono do arquivo E o usuário atual Comparação de Strings
-p O arquivo E um named pipe = E igual
-r O arquivo tem permissão de leitura
-s O tamanho do arquivo E maior que zero
-S O arquivo E um socket
-t O descritor de arquivos N E um terminal
-u O bit SUID está ativado Operadores Lógicos
-w O arquivo tem permissão de escrita
-x O arquivo tem permissão de execução
-nt O arquivo E mais recente (NewerThan)
-ot O arquivo E mais antigo (OlderThan)
-ef O arquivo E o mesmo (EqualFile)

Testes em variáveis
-lt E menor que (LessThan)
-gt E maior que (GreaterThan)
-le E menor igual (LessEqual)
-ge E maior igual (GreaterEqual)
-eq E igual (EQual)
-ne E diferente (NotEqual)

Comparação de String
= E igua
!= E diferente
-n E não nula
-z E nula

Operadores Lógicos
! Nao lógico (NOT)
-o OU lógico (OR)
-a E lógico (AND)


Operadores Aritméticos 
+ Adição 
- Subtração 
* Multiplicação 
/ Divisão 
% Módulo 
** Exponenciação

#fonte https://aurelio.net/shell/canivete/pdf/canivete-shell.pdf

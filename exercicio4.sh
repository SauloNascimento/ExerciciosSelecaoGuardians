#!/bin/bash

# Saulo Samuel Ferreira do Nascimento

# Obtendo o comando passado
comando=''
while [ $# -ne 0 ]; do
	comando="$comando $1"
	shift
done

# Armazenando o strace em um arquivo temporario
temp=$(mktemp)
(strace -T$comando) 2> $temp

# Armazenando maiores tempos encontrados
tempos=$(cat $temp | grep ">$" | rev | cut -d '>' -f 2 | cut -d '<' -f 1 | rev | sort -r | head -n 3)

echo "Chamadas:"
# Pegando o numero de vezes que cada um dos maiores tempo ocorre
echo $tempos | tr ' ' '\n' | uniq -c | awk -F " " '{print $1, $2}' | while read linha; do
	vezes=$(echo $linha | cut -d ' ' -f 1)
	tempo=$(echo $linha | cut -d ' ' -f 2)
	grep "<$tempo>" $temp | head -n $vezes # Filtrando o arquivos pelas chamadas que duratam 'tempo' e pegando as 'vezes' primeiras
done

echo

# Obtendo a chamada mais feita
maisFeita=$(cat $temp | cut -d "(" -f 1 | sort | uniq -c | awk -F " " '{print $1, $2}' | sort -g -r | head -n 1)
chamadas=$(echo $maisFeita | cut -d ' ' -f 1)
call=$(echo $maisFeita | cut -d ' ' -f 2)
echo "Syscall mais chamada: $call $chamadas"

# Obtendo a chamada com mais erros
maisErros=$(grep "= -" $temp | cut -d "(" -f 1 | sort | uniq -c | awk -F " " '{print $1, $2}' | sort -g -r | head -n 1)

erros=$(echo $maisErros | cut -d ' ' -f 1)
callErro=$(echo $maisErros | cut -d ' ' -f 2)
echo "Syscall com mais erros: $callErro $erros"

rm $temp

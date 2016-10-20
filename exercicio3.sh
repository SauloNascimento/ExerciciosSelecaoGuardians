#!/bin/bash

# Saulo Samuel Ferreira do Nascimento

# Metodo para testar um script
mktest()
{

	testing_script=$1
	testing_exercise=$(echo $testing_script | cut -d '_' -f 2) # Obtendo o numero do exercicio
	in_files=$(ls | grep ".in$" | grep "_"$testing_exercise"_" | sort) # Obtendo os arquivo de entrada

	echo $testing_script | sed -n "s/.sh/:/p"

	atual_out=$(mktemp) # Arquivo temporario para guarda a saida do exercicio executado

	for in_file in $in_files; do # Para cada arquivo de entrada encontrado
		out_file=$(echo $in_file | sed -n "s/.in/.out/p") # Arquivo de saida

		echo "- SAIDA PARA ENTRADA" $(echo $in_file | cut -d '.' -f 1 |cut -d '_' -f 3)":"
		
		(bash $script < $in_file) > $atual_out # Executando o exercicio
		cat $atual_out
		echo
		echo "- DIFERENCA PARA A SAIDA ESPERADA:"
		diff $atual_out $out_file
		echo
	done

	rm $atual_out

}

if [ $# -eq 2 ]; then # Se receber 2 parametros
	exercise=$1
	student=$2
	to_test="EXERCICIO_"$exercise"_"$student".sh" # Nome do arquivos a ser testado

elif [ $# -eq 1 ]; then # Se receber 1 parametros
	exercise=$1
	to_test=$(ls | grep ".sh$" | grep "_"$exercise"_") # Nome de todos arquivos de exercicio de numeracao recebida

elif [ $# -eq 0 ]; then # Se não nao receber parametros
	to_test=$(ls | grep ".sh$" | grep -v $0 | sort) # Nome de todos exercicios encontrados

else # Case receba mais parametros
	echo "Numero de Parametros inválidos"
	exit 1
fi

tested=0 # Contador para os arquivos testados

for script in $to_test; do # Para cada arquivo a testar
	mktest $script # Teste
	echo "...."
	echo
	tested=$(($tested + 1))
done

echo "$tested scripts testados."

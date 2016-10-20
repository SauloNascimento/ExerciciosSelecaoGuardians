#!/bin/bash

# Saulo Samuel Ferreira do Nascimento

# Funcao para ler a entrada caso não seja passada
readParameters()
{
	echo "Digite o número de observações a serem feitas:"
	read N
	echo "Digite um intervalo de tempo em segundos:"
	read S
	echo "Digite e um começo de nome de um usuário:"
	read P_USER
}

# Listagem e impressão da %CPU e %MEM dos usuarios que comecam com P_USER
getProcesses()
{
	
	users=$(ps aux | cut -d ' ' -f 1 | grep "^$P_USER" | sort | uniq) # Filtrando usuarios desejados
	cpu_total=0.0
	mem_total=0.0
	user_count=0 #variavel para contar o numero de usuarios encontrados
	if [ $users ]; then # Caso haja usuarios:
		for user in $users; do # Somando o total de uso de CPU e MEM de cada usuario 
			user_count=$(($user_count + 1))

			for cpu in $(ps -eo user,pcpu | grep "^$user" | cut -d ' ' -f 3); do
				cpu_total=$(echo "$cpu_total + $cpu" | bc -l)
			done

			for mem in $(ps -eo user,pmem | grep "^$user" | cut -d ' ' -f 3); do
				mem_total=$(echo "$mem_total + $mem" | bc -l)
			done
		done
	
	else # Case nenhum usuario seja encontrado:
		exit 2
	fi
	
	# Impressao dos totais encontrados e armazenamento dos valores
	echo "%CPU total encontrado:" $cpu_total"%"
	echo "%MEM total encontrado:" $mem_total"%"
	CPUs="$CPUs""$cpu_total/"
	MEMs="$MEMs""$mem_total/"
}

# Funcao para obter o maior e menor valor de CPU
CPUMaxMin() {
	max=$(echo $1 | cut -d '/' -f 1)
	min=$max

	for j in $(seq 2 $N); do
		atual_cpu=$(echo $1 | cut -d '/' -f $j)
		if [ $(echo "$atual_cpu > $max" | bc -l) -eq 1 ]; then
			max=$atual_cpu
		fi

		if [ $(echo "$atual_cpu < $max" | bc -l) -eq 1 ]; then
			min=$atual_cpu
		fi
	done

	echo "Maior valor de %CPU:" $max"%"
	echo "Menor valor de %CPU:" $min"%"
}

# Funcao para obter o maior e menor valor de MEM
MEMMaxMin() {
	max=$(echo $1 | cut -d '/' -f 1)
	min=$max

	for j in $(seq 2 $N); do
		atual_mem=$(echo $1 | cut -d '/' -f $j)
		if [ $(echo "$atual_mem > $max" | bc -l) -eq 1 ]; then
			max=$atual_mem
		fi

		if [ $(echo "$atual_mem < $max" | bc -l) -eq 1 ]; then
			min=$atual_mem
		fi
	done

	echo "Maior valor de %MEM:" $max"%"
	echo "Menor valor de %MEM:" $min"%"
}

# Funcao para fazer as N observacoes
listProcesses()
{
	if [ $N -gt 0 ] & [ $S -gt 0 ]; then # Se N e S são maiores que 0:
		CPUs='' # Variavel para armazenar os valores de CPU observados
		MEMs='' # Variavel para armazenar os valores de MEM observados
		for i in $(seq 1 $N); do
			echo "Observacao $i:"
			getProcesses
			echo
			sleep $S # Esperando S segundos
		done
		CPUMaxMin $CPUs
		echo
		MEMMaxMin $MEMs
		echo
		echo "$user_count usuario(s) encontrado(s):"
		for user in $users; do
			echo $user
		done

	else # Se não forem:
		exit 1
	fi
}

# Verificacao dos paramentros recebidos
if [ $# -eq 0 ]; then # Caso nenhum parametro foi passado:
	readParameters
	listProcesses
elif [ $# -eq 3 ]; then # Caso 3 parametros foram passados:
	N=$1
	S=$2
	P_USER=$3
	listProcesses
else # Caso qualquer outra quantidde de parametros:
	exit 1
fi


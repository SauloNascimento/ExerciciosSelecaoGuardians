#!/bin/bash

# Saulo Samuel Ferreira do Nascimento

# Variaveis iniciais
local_count=0
remote_count=0

# Contagem de requisicoes totais
total_count=$(wc -l ./access_log | cut -d ' ' -f 1)

# Laco para contar as requisicoes locais e remotas
for origem in $(sed -n "/- -/p" ./access_log | cut -d ' ' -f 1); do
	if [ $origem = 'local' ]; then
		local_count=$(($local_count + 1))
	elif [ $origem = 'remote' ]; then
		remote_count=$(($remote_count + 1))
	fi
done

# Contagem de requisicoes valias e invalidas
valid_count=$(($local_count + $remote_count))
invalid_count=$(($total_count - $valid_count))

local_hour=0
remote_hour=0

# Laco para contar as horas das requisicoes locais
for hora in $(sed -n "/local - -/p" ./access_log | cut -d ':' -f 2); do
	local_hour=$(($local_hour + 10#$hora))
done

# Calculando a hora media para requisicoes locais
local_hour=$(($local_hour / $local_count))

# Laco para contar as horas das requisicoes locais
for hora in $(sed -n "/remote - -/p" ./access_log | cut -d ':' -f 2); do
	remote_hour=$(($remote_hour + 10#$hora))
done

# Calculando a hora media para requisicoes locais
remote_hour=$(($remote_hour / $remote_count))

# Impressao
echo "Requisicoes Invalidas: $invalid_count"
echo "Requisicoes Validas: $valid_count"
echo " - Requisicoes Locais: $local_count"
echo " - Requisicoes Remotas: $remote_count"
echo "Requisicoes Totais: $total_count"
echo
echo "Hora Media de Requisicoes Locais: $local_hour""h"
echo "Hora Media de Requisicoes Remotas: $remote_hour""h"

echo

#verificando o tipo de requisicao mais feita
if [ $local_count -eq $remote_count ]; then
	echo "Mesma quantidade de requisicoes Locais e Remotas"
elif [ $local_count -gt $remote_count ]; then
	echo "Maior quantidade de requisicoes Locais"
else
	echo "Maior quantidade de requisicoes Remotas"
fi

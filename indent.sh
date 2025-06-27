#!/bin/bash

input=$1
indent=$2

lines=()
while IFS='' read -r value; do
    lines+=("$value")
done <<-EOF
$(echo "$input")
EOF

for i in "${!lines[@]}"; do
    if [[ i -ne 0 ]]; then
	for j in {0..$indent}; do
	    echo -n ' '
	done
    fi
    echo ${lines[$i]}
done

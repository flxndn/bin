#!/bin/bash

for i in $@; do
	output=$(echo $i| sed "s/\(\.[^\.]*\)/_big\1/");
	if [ -e $output ]; then
		echo "No creo $output porque ya existe."
	else
		json=$( \
			curl \
				-F "image=@$i" \
				-H 'api-key:a310289b-a5ef-40d1-a723-b1c671d4ec89' \
				https://api.deepai.org/api/torch-srgan  \
		)
		url=$(echo "$json" | jq -r .output_url)
		curl $url --output "$output"
	fi
done

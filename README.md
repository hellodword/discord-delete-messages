```sh
#! /bin/bash

curl --version || exit 1
jq --version || exit 1



while  true 
do

    response=$(<curl -s "https://discord.com/api/v9/guilds/<channel>/messages/search?max_id=<max_id>&author_id=<author_id>&sort_by=timestamp&sort_order=asc&offset=0" \
        -H >)
    total_results=$(echo "$response" | jq ".total_results")
    [ "$total_results" == "null" ] && (echo "$response"; exit 1)
    [ "$total_results" == "0" ] && exit 0

    echo "$response" | jq -r ".messages[] | .[0] | .id" | xargs -L 1 -I @%@%@ sh -c 'echo "deleting @%@%@"; <curl "https://discord.com/api/v9/channels/<channel>/messages/@%@%@" \
            -X "DELETE" -s -f \
            -H > || sleep 1s'

done
```
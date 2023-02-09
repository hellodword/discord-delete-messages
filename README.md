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


    echo "$response" \
      | jq -r '.messages[] | .[0] | .id + " " + .channel_id' \
      | while read id channel_id; do
        echo "deleting https://discord.com/api/v9/channels/$channel_id/messages/$id"
        <curl "https://discord.com/api/v9/channels/$channel_id/messages/$id" \
          -X "DELETE" -s -f \
          -H > || sleep 1s
      done

done
```

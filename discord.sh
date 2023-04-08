#! /bin/bash

set -e

export $(cat .env | xargs)

[ ! -z "$DISCORD_AUTH" ]
[ ! -z "$DISCORD_CHANNEL" ]
[ ! -z "$DISCORD_AUTHOR" ]

curl --version >/dev/null
jq --version   >/dev/null

while true 
do
    response=$(curl -s "https://discord.com/api/v9/guilds/$DISCORD_CHANNEL/messages/search?author_id=$DISCORD_AUTHOR&sort_by=timestamp&sort_order=asc&offset=0" \
      -H "authorization: $DISCORD_AUTH")
    total_results=$(echo "$response" | jq ".total_results")
    [ "$total_results" == "null" ] && (echo "$response"; exit 1)
    [ "$total_results" == "0" ] && exit 0

    echo "$response" \
      | jq -r '.messages[] | .[0] | .id + " " + .channel_id' \
      | while read id channel_id; do
          echo "deleting /$channel_id/messages/$id"
          http_code=$(curl "https://discord.com/api/v9/channels/$channel_id/messages/$id" \
            -X "DELETE" \
            -s -o /dev/null -I -w "%{http_code}" \
            -H "authorization: $DISCORD_AUTH")
          [ "$http_code" == "204" ] || (echo failed; sleep 1s)
        done
done

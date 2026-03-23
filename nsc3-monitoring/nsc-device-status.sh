#!/bin/bash
ORG_LIST=$(docker exec main-postgres psql -t -U nsc -d maindatabase -A -F"," -c "select id, name from organizationlist.organizations" | sed 's/ //g')
echo "'OrgName', 'OrgID', 'DeviceName', 'DeviceID', 'Connected', 'LastBroadCast'"
while IFS= read -r org_line
do
  # process the organisation
  ORG_ID=$(echo $org_line | awk  -F ',' '{ print $1 }')
  ORG_NAME=$(echo $org_line | awk  -F ',' '{ print $2 }')
  TEMP=$(echo "docker exec main-postgres psql -U nsc -d maindatabase -t -A -F"," -c" '"SELECT nickname, device_id FROM ''\"'$ORG_ID'\"''.devices WHERE state = 1 AND is_virtual = false;"'"")
  TEMP_DEV=$(bash -c "$TEMP")
  while IFS2= read -r device_line
  do
    # process the devices
    DEV_ID=$(echo $device_line | awk  -F ',' '{ print $2 }')
    [ ! -z "$DEV_ID" ] ||  DEV_ID="<no-DevID>"
    DEV_NAME=$(echo $device_line | awk  -F ',' '{ print $1 }')
    [ ! -z "$DEV_NAME" ] ||  DEV_NAME="<no-name>"
    REDIS_TEMP="'device:"$ORG_ID":"$DEV_ID"'"
    DEV_ONLINE_TEMP=$(echo "docker exec bus-redis redis-cli 'hget'" $REDIS_TEMP "'connected'")
    DEV_LAST_FRAME_TEMP=$(echo "docker exec bus-redis redis-cli 'hget'" $REDIS_TEMP " lastMessageTime")
    DEV_ONLINE=$(bash -c "$DEV_ONLINE_TEMP")
    [ ! -z "$DEV_ONLINE" ] ||  DEV_ONLINE="<no-connection-status>"
    DEV_LAST_FRAME=$(bash -c "$DEV_LAST_FRAME_TEMP")
    [ ! -z "$DEV_LAST_FRAME" ] ||  DEV_LAST_FRAME="<no-frame-status>"
    DEV_LAST_FRAME=$(echo ${DEV_LAST_FRAME} | date +"%Y-%m-%d %H:%M")
    echo "'"$ORG_NAME"'"",""'"$ORG_ID"'"",""'"$DEV_NAME"'"",""'"$DEV_ID"'"",""'"$DEV_ONLINE"'"",""'"$DEV_LAST_FRAME"'"
  done <<< "$TEMP_DEV"
done <<< "$ORG_LIST"

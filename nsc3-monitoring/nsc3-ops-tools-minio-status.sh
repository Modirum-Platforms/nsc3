#!/bin/bash
# Variables to configure per server
MINIOPATHDIR="/var/lib/docker/volumes/minio-volume/_data"
HOSTNAME="example.com"
OUTPUTLOCATION="/home/ubuntu/nsc3/logs"
# fixed variables
DATE=`date +%Y%m%d`   
OUTPUTFILE="minio-files-nsc3-${HOSTNAME}-${DATE}.csv"
# Run list of NSC3 orgs in Bucket format
docker exec main-postgres psql -U nsc -d maindatabase -c "select * from organizationlist.organizations" \
| awk '{ print $1, $3 }' | sed 's/-//g' | sed 's/_//g' | sed 's/\(.*\)/\L\1/' > /tmp/org-objects.tmp
COUNTLINES=$(cat /tmp/org-objects.tmp | wc -l)  2> /dev/null
let "COUNTLINES-=1"
LINENR=3
rm $OUTPUTLOCATION/$OUTPUTFILE
touch $OUTPUTLOCATION/$OUTPUTFILE
echo "'""DATE"",""'""HOSTNAME""'"",""'""ORGNAME""'"",""'""TOTAL SIZE""'"",""'""TOTAL COUNTS""'"",""'""OLDEST TIMESTAMP""'"",""'""BUCKETID""'" >> $OUTPUTLOCATION/$OUTPUTFILE
while [ "$LINENR" -lt "$COUNTLINES" ]; do
        BUCKETID=$(cat /tmp/org-objects.tmp | awk '(NR=='$LINENR')' | awk '{ print $1}') 2> /dev/null
        ORGNAME=$(cat /tmp/org-objects.tmp | awk '(NR=='$LINENR')' | awk '{ print $2}') 2> /dev/null
        SIZE=$(du -h --max-depth=0 "$MINIOPATHDIR"/"$BUCKETID/" | awk '{ print $1}') 2> /dev/null
        touch /tmp/temp.tmp        
        ls -lRU --time-style=long-iso $MINIOPATHDIR"/"$BUCKETID/ | awk 'BEGIN {cont=0; oldd=strftime("%Y%m%d"); } \
        { gsub(/-/,"",$6); if (substr($0,0,1)=="/") { pat=substr($0,0,length($0)-1)"/"; $6="" }; if( $6 ~ /^[0-9]+$/) \
        {if ( $6 < oldd ) { oldd=$6; oldf=$8; for(i=9; i<=NF; i++) oldf=oldf $i; oldf=pat oldf; }; count++;}} \
        END { print oldd, count}' > /tmp/temp.tmp
        # Print file
        OLDEST=$(cat /tmp/temp.tmp | awk '{ print $1}') 2> /dev/null
        COUNTFILES=$(cat /tmp/temp.tmp | awk '{ print $2}') 2> /dev/null
        echo "'"$DATE"'"",""'"$HOSTNAME"'"",""'"$ORGNAME"'"",""'"$SIZE"'"",""'"$COUNTFILES"'"",""'"$OLDEST"'"",""'"$BUCKETID"'" >> $OUTPUTLOCATION/$OUTPUTFILE
        rm /tmp/temp.tmp
        let "LINENR+=1"
done
rm  /tmp/org-objects.tmp

#!/bin/bash
# Following 3rd party tools are require curl and sysstat
# sudo apt-get install sysstat
# sudo apt-get install curl
# Variables to configure per server
MINIOPATHDIR="/var/lib/docker/volumes/minio-volume/_data"
DOCKERPATHDIR="/var/lib/docker"
HOSTNAME="example.com"
NSC3LOGS="/home/ubuntu/logs"
OUTPUTLOCATION="/home/ubuntu/logs"
#fixed values
DATE=`date +%Y%m%d`   
OUTPUTFILE="system-status-nsc3-${HOSTNAME}-${DATE}.csv"
# init 
rm $OUTPUTLOCATION/$OUTPUTFILE
touch $OUTPUTLOCATION/$OUTPUTFILE
# HTTP STATUS code
HTTPSTATUS=$(curl -I --http2 -s https://"$HOSTNAME" | grep HTTP | awk '{ print $2}') 2> /dev/null
# Check Cert and license status 
CERTEXPY=$(curl --cert-status -v https://"$HOSTNAME" 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }' | grep "*  expire date:" | awk '{ print $7}') 2> /dev/null
CERTEXPM=$(curl --cert-status -v https://"$HOSTNAME" 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }' | grep "*  expire date:" | awk '{ print $4}') 2> /dev/null
CERTEXPD=$(curl --cert-status -v https://"$HOSTNAME" 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }' | grep "*  expire date:" | awk '{ print $5}') 2> /dev/null
CERTEXP="$CERTEXPY"-"$CERTEXPM"-"$CERTEXPD"
NSCLICEXP=$(docker exec main-postgres psql -U nsc -d maindatabase -c "select to_timestamp(expiredate / 1000)::date from organizationlist.licenses where enabled = 3" | grep 20 | awk '{ print $1}') 2> /dev/null
# Check disk, mem and CPU usage
DISKUSAGELEVEL=$(df -hT | grep /$ | awk '{ print $6}') 2> /dev/null
STORAGESIZE=$(df -hT | grep /$ | awk '{ print $3}') 2> /dev/null
OBJECTSTORAGESIZE=$(du -h --max-depth=0 "$MINIOPATHDIR"/ | awk '{ print $1}') 2> /dev/null
CONTAINERSIZE=$(docker system df | grep Containers | awk '{ print $4}') 2> /dev/null     
NSCLOGS=$(du -h --max-depth=0 "$NSC3LOGS"/ | awk '{ print $1}') 2> /dev/null 
CPUUSAGEFREE=$(mpstat | tail -1 | awk '{ print $12}')"%" 2> /dev/null 
MEMUSAGEFREE=$(free -g | grep Mem: | awk '{ print $7}')"GB" 2> /dev/null
# Print outputfile
echo "'""DATE"",""'""HOSTNAME""'"",""CPUUSAGEFREE""'"",""'""MEMUSAGEFREE""'"",""'""DISKUSAGELEVEL""'"",""'""STORAGESIZE""'"",""'""OBJECTSTORAGESIZE""'"",""'""CONTAINERSIZE""'"",""'""NSCLOGS""'"",""'""CERTEXP""'"",""'""HTTPSTATUS""'"",""'""NSCLICEXP""'" >> $OUTPUTLOCATION/$OUTPUTFILE
echo "'"$DATE"'"",""'"$HOSTNAME"'"",""'"$CPUUSAGEFREE"'"",""'"$MEMUSAGEFREE"'"",""'"$DISKUSAGELEVEL"'"",""'"$STORAGESIZE"'"",""'"$OBJECTSTORAGESIZE"'"",""'"$CONTAINERSIZE"'"",""'"$NSCLOGS"'"",""'"$CERTEXP"'"",""'"$HTTPSTATUS"'"",""'"$NSCLICEXP"'" >> $OUTPUTLOCATION/$OUTPUTFILE

#!/bin/bash
## NSC3 registry:
export NSC3REG="registry.menturagroup.com/nsc3/docker-images"
TIMESTAMP=$(date +%Y%m%d%H%M)
silentmode=false
if [ ${1+"true"} ]; then
   if  [ $1 == "--silent" ]; then
       silentmode=true
       echo "*** silent installation mode ***"
   fi
   if  [ $1 == "--help" ]; then
       clear
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       echo "NSC3 installer usage:"
       echo ""
       echo "./team-bridge-install.sh --help 	  'help text'"
       echo "./team-bridge-install.sh --silent      'installation with command line parameters'"
       echo "./team-bridge-install.sh 		  'interactive installation mode'"
       echo ""
       echo "CLI parameters usage for client:"
       echo "./team-bridge-install.sh --silent <Installation path> <Role: client> <TCP or UDP mode> <Local Server IP> <Team Bridge Server IP> <Source Organisation ID>"
       echo ""
       echo "CLI parameters example for client:"
       echo "./team-bridge-install.sh --silent /home/ubuntu/nsc3 client UDP 192.168.10.12 192.168.10.13 L5JXk6d18KtyeuZfhKtLuerJeJtEnEYRGTfX"
       echo ""
       echo "CLI parameters usage for server:"
       echo "./team-bridge-install.sh --silent <Installation path> <Role: server/both> <TCP or UDP mode> <local Team-Bridge Server IP> <Source Organisation ID> <Targer Organisation ID>"
       echo ""
       echo "CLI parameters example for server:"
       echo "./team-bridge-install.sh --silent /home/ubuntu/nsc3 server UDP 192.168.10.13 L5JXk6d18KtyeuZfhKtLuerJeJtEnEYRGTfX kqkYDd2Ofv04eFBg-G7xmPIO9IjGMcx_VcEJ"
       echo ""
       echo "CLI parameters usage for both server and client:"
       echo "./team-bridge-install.sh --silent <Installation path> <Role: both> <TCP or UDP mode> <Client: Other end Team-Bridge Server IP> <Client: Source Organisation ID> <Server: Local Team-Bridge Server IP> <Server: Source Organisation ID> <Server: Targer Organisation ID>"
       echo ""
       echo "CLI parameters example for both server client:"
       echo "./team-bridge-install.sh --silent /home/ubuntu/nsc3 both UDP 192.168.10.13 L5JXk6d18KtyeuZfhKtLuerJeJtEnEYRGTfX 192.168.10.12 bMHZxI3Ke5QEaNqx7qFtuQUHTTNszYgNDEcK 57NK1bbudRW_b1fgzJztNzVLcbSvR2zHkqBU"
       echo ""
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       exit 0
   fi
   if [ ${2+"true"} ]; then
       export NSCHOME=$2
       if [ -f "$NSCHOME/nsc-host.env" ]; then source $NSCHOME/nsc-host.env 2> /dev/null; fi
   fi
   if [ ${3+"true"} ]; then
       export TBROLE=$3
   fi
   if ! [[ $TBROLE = client  ||  $TBROLE = server ||  $TBROLE = both ]]; then echo "*** "$TBROLE"  as input value is not range of role selection. please type client, server or both"; exit 0; fi
   if [ $TBROLE = client ]; then 
      if [ ${4+"true"} ]; then
          export TBMODE=$4
      fi
      if [ ${5+"true"} ]; then
          export TBSERVERIP2=$5
      fi
      if [ ${6+"true"} ]; then
          export TBSERVERIP=$6
      fi
      if [ ${7+"true"} ]; then
          export SOURCEORG=$7
      fi
      if ! [[ $TBSERVERIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP"  as input is not valid Team-Bridge server IP"; exit 0; fi
      if ! [[ $TBSERVERIP2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP2"  as input is not valid Team-Bridge server IP"; exit 0; fi
   fi
   if [ $TBROLE = server ]; then 
      if [ ${4+"true"} ]; then
          export TBMODE=$4
      fi
      if [ ${5+"true"} ]; then
          export TBSERVERIP2=$5
      fi
      if [ ${6+"true"} ]; then
          export SOURCEORG=$6
      fi
      if [ ${7+"true"} ]; then
          export TARGETORG=$7
      fi
      if [[ $TARGETORG = *" "* ]]; then echo "*** "$TARGETORG"  as input is not valid NSC3 target organisation ID"; exit 0; fi
      if ! [[ $TBSERVERIP2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP2"  as input is not valid Team-Bridge server IP"; exit 0; fi
   fi
   if [ $TBROLE = both ]; then 
      if [ ${4+"true"} ]; then
          export TBMODE=$4
      fi
      if [ ${5+"true"} ]; then
          export TBSERVERIP=$5
      fi
      if [ ${6+"true"} ]; then
          export SOURCEORG=$6
      fi
      if [ ${7+"true"} ]; then
          export TBSERVERIP2=$7
      fi
      if [ ${8+"true"} ]; then
          export SOURCEORG2=$8
      fi
      if [ ${9+"true"} ]; then
          export TARGETORG2=$9
      fi
      if ! [[ $TBSERVERIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP"  as input is not valid Team-Bridge server IP"; exit 0; fi
      if ! [[ $TBSERVERIP2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP2"  as input is not valid Team-Bridge server IP"; exit 0; fi
      if [[ $TARGETORG = *" "* ]]; then echo "*** "$TARGETORG"  as input is not valid NSC3 target organisation ID"; exit 0; fi
      if [[ $SOURCEORG2 = *" "* ]]; then echo "*** "$SOURCEORG2"  as input is not valid NSC3 source organisation ID"; exit 0; fi
      if [[ $TARGETORG2 = *" "* ]]; then echo "*** "$TARGETORG2"  as input is not valid NSC3 target organisation ID"; exit 0; fi
   fi
fi
if [ "$silentmode" = false ]; then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "                                        "
    echo "  NSC3 Team-Bridge installer:           "
    echo "  This script prepares NSC3 config      "
    echo "                                        "
    echo "++++++++++++++++++++++++++++++++++++++++"
    read -p "NSC3 installation folder, e.g /home/ubuntu/nsc3: " NSC3HOMEFOLDER
    export NSCHOME=$NSC3HOMEFOLDER
    if [ -f "$NSCHOME/nsc-host.env" ]; then source $NSCHOME/nsc-host.env 2> /dev/null; fi
    read -p "TCP or UDP Protocol ?: " TBMODE
    read -p "Role (client, server or both) ?: " TBROLE
    if ! [[ $TBROLE = client  ||  $TBROLE = server ||  $TBROLE = both ]]; then echo "*** "$TBROLE"  as input value is not range of role selection. please type client, server or both"; exit 0; fi
    if [ $TBROLE = client ]; then 
       read -p "Local Team-Bridge node IP address: " TBSERVERIP2
       read -p "Other end Team-Bridge server IP address: " TBSERVERIP
       read -p "Local source organisation ID: " SOURCEORG
       if ! [[ $TBSERVERIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP"  as input is not valid Team-Bridge server IP"; exit 0; fi
       if ! [[ $TBSERVERIP2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP2"  as input is not valid Team-Bridge server IP"; exit 0; fi
    fi
    if [ $TBROLE = server ]; then 
       read -p "Local Team-Bridge node IP address: " TBSERVERIP2
       read -p "Other end source organisation ID: " SOURCEORG
       read -p "local target organisation ID: " TARGETORG
       if ! [[ $TBSERVERIP2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP2"  as input is not valid Team-Bridge server IP"; exit 0; fi
       if [[ $TARGETORG = *" "* ]]; then echo "*** "$TARGETORG"  as input is not valid NSC3 target organisation ID"; exit 0; fi
    fi
    if [ $TBROLE = both ]; then 
       read -p "Client - other end Team-Bridge server IP address: " TBSERVERIP
       read -p "Client - Local source organisation ID: " SOURCEORG
       read -p "Server - Local Team-Bridge server IP address: " TBSERVERIP2
       read -p "Server - other end source organisation ID: " SOURCEORG2
       read -p "Server - Local target organisation ID: " TARGETORG2
       if ! [[ $TBSERVERIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP"  as input is not valid Team-Bridge server IP"; exit 0; fi
       if ! [[ $TBSERVERIP2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo "*** "$TBSERVERIP2"  as input is not valid Team-Bridge server IP"; exit 0; fi
       if [[ $TARGETORG = *" "* ]]; then echo "*** "$TARGETORG"  as input is not valid NSC3 target organisation ID"; exit 0; fi
       if [[ $SOURCEORG2 = *" "* ]]; then echo "*** "$SOURCEORG2"  as input is not valid NSC3 source organisation ID"; exit 0; fi
       if [[ $TARGETORG2 = *" "* ]]; then echo "*** "$TARGETORG2"  as input is not valid NSC3 target organisation ID"; exit 0; fi
    fi
fi
# Check values
if ! [ -d $NSCHOME ]; then echo "*** $NSCHOME 'Installation folder is missing! "; exit 0; fi
if ! [[ $TBMODE = TCP  ||  $TBMODE = UDP ]]; then echo "*** "$TBMODE"  as input value is not range of mode selection. please type TCP or UDP"; exit 0; fi
if [[ $SOURCEORG = *" "* ]]; then echo "*** "$SOURCEORG"  as input is not valid NSC3 source organisation ID"; exit 0; fi
# Create TCP keys
if ! [[ $TBMODE = TCP ]]; then
   if [ ! -d $NSCHOME/bridgekeys ]; then 
      chmod u+x $NSCHOME/generateTeamBridgeRSAKeyPairs.sh 2> /dev/null
      bash $NSCHOME/generateTeamBridgeRSAKeyPairs.sh 2> /dev/null
      KEY_COPY_REMINDER=true
   fi
fi
# Grep release tag value
NSC3REL=$(cat $NSCHOME/docker-compose.yml | grep registry.menturagroup.com/nsc3/docker-images/main-postgres: | cut -d\: -f3)
echo "*** Current release tag: $NSC3REL  ***" 
RELEASETAG=$NSC3REL
# Update env variables
chmod 666 $NSCHOME/nsc-host.env 2> /dev/null
if ! [ $(grep -c "TEAM_BRIDGE_ENABLED" $NSCHOME/nsc-host.env) -eq 1 ]; then echo "export TEAM_BRIDGE_ENABLED=true" >> $NSCHOME/nsc-host.env; fi
if ! [ -z "$TEAM_BRIDGE_ENABLED" ]; then 
   sed -i 's/export TEAM_BRIDGE_ENABLED=false/export TEAM_BRIDGE_ENABLED=true/g' $NSCHOME/nsc-host.env; 
fi
if ! [ $(grep -c "TBMODE" $NSCHOME/nsc-host.env) -eq 1 ]; then  
   echo "export TBMODE=$TBMODE" >> $NSCHOME/nsc-host.env;
   else 
   sed -i 's/.*TBMODE*.*/export TBMODE='"$TBMODE"'/' $NSCHOME/nsc-host.env
fi
if ! [ $(grep -c "TBROLE" $NSCHOME/nsc-host.env) -eq 1 ]; then 
   echo "export TBROLE=$TBROLE" >> $NSCHOME/nsc-host.env; 
   else 
   sed -i 's/.*TBROLE*.*/export TBROLE='"$TBROLE"'/' $NSCHOME/nsc-host.env
fi
if ! [ $(grep -c "TBSERVERIP" $NSCHOME/nsc-host.env) -eq 1 ]; then 
   echo "export TBSERVERIP=$TBSERVERIP" >> $NSCHOME/nsc-host.env; 
   else 
   sed -i 's/.*TBSERVERIP*.*/export TBSERVERIP='"$TBSERVERIP2"'/' $NSCHOME/nsc-host.env
fi
if ! [ $(grep -c "SOURCEORG" $NSCHOME/nsc-host.env) -eq 1 ]; then 
   echo "export SOURCEORG=$SOURCEORG" >> $NSCHOME/nsc-host.env; 
   else 
   sed -i 's/.*SOURCEORG*.*/export SOURCEORG='"$SOURCEORG"'/' $NSCHOME/nsc-host.env
fi
if ! [ $(grep -c "TARGETORG" $NSCHOME/nsc-host.env) -eq 1 ]; then 
   echo "export TARGETORG=$TARGETORG" >> $NSCHOME/nsc-host.env; 
   else 
   sed -i 's/.*TARGETORG*.*/export TARGETORG='"$TARGETORG"'/' $NSCHOME/nsc-host.env
fi
if ! [ $(grep -c "SOURCEORG2" $NSCHOME/nsc-host.env) -eq 1 ]; then 
   echo "export SOURCEORG2=$SOURCEORG2" >> $NSCHOME/nsc-host.env; 
   else 
   sed -i 's/.*SOURCEORG2*.*/export SOURCEORG2='"$SOURCEORG2"'/' $NSCHOME/nsc-host.env
fi
if ! [ $(grep -c "TARGETORG2" $NSCHOME/nsc-host.env) -eq 1 ]; then 
   echo "export TARGETORG2=$TARGETORG2" >> $NSCHOME/nsc-host.env;
   else 
   sed -i 's/.*TARGETORG2*.*/export TARGETORG2='"$TARGETORG2"'/' $NSCHOME/nsc-host.env
fi
# Update docker-compose.yml file
cd $NSCHOME
# make backup
if [ -f "docker-compose.yml" ]; then cp docker-compose.yml docker-compose-tb-addition-backup-$TIMESTAMP.yml 2> /dev/null; fi
if [ -f "nsc-team-bridge-service-server.env" ]; then cp nsc-team-bridge-service-server.env nsc-team-bridge-service-server-$TIMESTAMP.env 2> /dev/null; fi
if [ -f "nsc-team-bridge-service-client.env" ]; then cp nsc-team-bridge-service-client.env nsc-team-bridge-service-client-$TIMESTAMP.env 2> /dev/null; fi
if [[ $TBMODE = UDP ]]; then
   if [[ $TBROLE = client ]]; then
      (echo "cat <<EOF >docker-compose-temp.yml";
      cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
      sed '/add-on nsc-team-bridge-service-client-udp/,/add-off nsc-team-bridge-service-client-udp/ s/#//';
      ) >temp.yml
      . temp.yml 2> /dev/null
      cat docker-compose-temp.yml > docker-compose.yml;
      (echo "cat <<EOF >nsc-team-bridge-service-client-temp.yml";
      cat nsc-team-bridge-service-client.tmpl;
      ) >tb-client-temp.yml
      . tb-client-temp.yml 2> /dev/null
      cat nsc-team-bridge-service-client-temp.yml > nsc-team-bridge-service-client.env;
      rm -f tb-client-temp.yml nsc-team-bridge-service-client-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = server ]]; then
      TBSERVERIP=$TBSERVERIP2;
      (echo "cat <<EOF >docker-compose-temp.yml";
      cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
      sed '/add-on nsc-team-bridge-service-server-udp/,/add-off nsc-team-bridge-service-server-udp/ s/#//'; 
      ) >temp.yml
      . temp.yml 2> /dev/null
      cat docker-compose-temp.yml > docker-compose.yml;
      (echo "cat <<EOF >nsc-team-bridge-service-server-temp.yml";
      cat nsc-team-bridge-service-server.tmpl;
      ) >tb-server-temp.yml
      . tb-server-temp.yml 2> /dev/null
      cat nsc-team-bridge-service-server-temp.yml > nsc-team-bridge-service-server.env;
      rm -f tb-server-temp.yml nsc-team-bridge-service-server-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = both ]]; then
      (echo "cat <<EOF >docker-compose-temp.yml";
      cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' | 
      sed '/add-on nsc-team-bridge-service-server-udp/,/add-off nsc-team-bridge-service-server-udp/ s/#//' |
      sed '/add-on nsc-team-bridge-service-client-udp/,/add-off nsc-team-bridge-service-client-udp/ s/#//';
      ) >temp.yml
      . temp.yml 2> /dev/null
      cat docker-compose-temp.yml > docker-compose.yml;
      # Client
      (echo "cat <<EOF >nsc-team-bridge-service-client-temp.yml";
      cat nsc-team-bridge-service-client.tmpl;
      ) >tb-client-temp.yml
      . tb-client-temp.yml 2> /dev/null
      cat nsc-team-bridge-service-client-temp.yml > nsc-team-bridge-service-client.env;
      # Server
      CLIENTSOURCE=$SOURCEORG
      SERVERSOURCE=$SOURCEORG2
      SERVERDEST=$TARGETORG2
      SOURCEORG=$SERVERSOURCE
      TARGETORG=$SERVERDEST
      TBSERVERIP=$TBSERVERIP2
      (echo "cat <<EOF >nsc-team-bridge-service-server-temp.yml";
      cat nsc-team-bridge-service-server.tmpl;
      ) >tb-server-temp.yml
      . tb-server-temp.yml 2> /dev/null
      cat nsc-team-bridge-service-server-temp.yml > nsc-team-bridge-service-server.env;
      rm -f tb-server-temp.yml nsc-team-bridge-service-server-temp.yml tb-client-temp.yml nsc-team-bridge-service-client-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
   fi
fi
if [[ $TBMODE = TCP ]]; then
   if [[ $TBROLE = client ]]; then
      (echo "cat <<EOF >docker-compose-temp.yml";
      cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
      sed '/add-on nsc-team-bridge-service-client-tcp/,/add-off nsc-team-bridge-service-client-tcp/ s/#//';
      ) >temp.yml
      . temp.yml 2> /dev/null
      cat docker-compose-temp.yml > docker-compose.yml;
      (echo "cat <<EOF >nsc-team-bridge-service-client-temp.yml";
      cat nsc-team-bridge-service-client.tmpl;
      ) >tb-client-temp.yml
      . tb-client-temp.yml 2> /dev/null
      cat nsc-team-bridge-service-client-temp.yml > nsc-team-bridge-service-client.env;
      rm -f tb-client-temp.yml nsc-team-bridge-service-client-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = server ]]; then
      TBSERVERIP=$TBSERVERIP2;
      (echo "cat <<EOF >docker-compose-temp.yml";
      cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' |
      sed '/add-on nsc-team-bridge-service-server-tcp/,/add-off nsc-team-bridge-service-server-tcp/ s/#//';
      ) >temp.yml
      . temp.yml 2> /dev/null
      cat docker-compose-temp.yml > docker-compose.yml;
      (echo "cat <<EOF >nsc-team-bridge-service-server-temp.yml";
      cat nsc-team-bridge-service-server.tmpl;
      ) >tb-server-temp.yml
      . tb-server-temp.yml 2> /dev/null
      cat nsc-team-bridge-service-server-temp.yml > nsc-team-bridge-service-server.env;
      rm -f tb-server-temp.yml nsc-team-bridge-service-server-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
   fi
   if [[ $TBROLE = both ]]; then
      (echo "cat <<EOF >docker-compose-temp.yml";
      cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p' | 
      sed '/add-on nsc-team-bridge-service-server-tcp/,/add-off nsc-team-bridge-service-server-tcp/ s/#//' |
      sed '/add-on nsc-team-bridge-service-client-tcp/,/add-off nsc-team-bridge-service-client-tcp/ s/#//';
      ) >temp.yml
      . temp.yml 2> /dev/null
      cat docker-compose-temp.yml > docker-compose.yml;
      # Client
      (echo "cat <<EOF >nsc-team-bridge-service-client-temp.yml";
      cat nsc-team-bridge-service-client.tmpl;
      ) >tb-client-temp.yml
      . tb-client-temp.yml 2> /dev/null
      cat nsc-team-bridge-service-client-temp.yml > nsc-team-bridge-service-client.env;
      # Server
      CLIENTSOURCE=$SOURCEORG
      SERVERSOURCE=$SOURCEORG2
      SERVERDEST=$TARGETORG2
      SOURCEORG=$SERVERSOURCE
      TARGETORG=$SERVERDEST
      TBSERVERIP=$TBSERVERIP2
      (echo "cat <<EOF >nsc-team-bridge-service-server-temp.yml";
      cat nsc-team-bridge-service-server.tmpl;
      ) >tb-server-temp.yml
      . tb-server-temp.yml 2> /dev/null
      cat nsc-team-bridge-service-server-temp.yml > nsc-team-bridge-service-server.env;
      rm -f tb-server-temp.yml nsc-team-bridge-service-server-temp.yml tb-client-temp.yml nsc-team-bridge-service-client-temp.yml temp.yml docker-compose-temp.yml 2> /dev/null
   fi
fi
# Archive env specific file to system
if test -f docker-compose_$PUBLICIP.yml; then
    mv docker-compose_$PUBLICIP.yml docker-compose_$PUBLICIP.old  2> /dev/null
fi
cp docker-compose.yml docker-compose_$PUBLICIP.yml
# Maintenance log
if ! [ -f "$NSCHOME/logs/nsc-maintenance-log.txt" ]; then 
   touch $NSCHOME/logs/nsc-maintenance-log.txt 2> /dev/null;
   chmod 666 $NSCHOME/logs/nsc-maintenance-log.txt;
else 
   echo "$TIMESTAMP Team-Bridge Role:$TBROLE Procol:$TBMODE installed" >> $NSCHOME/logs/nsc-maintenance-log.txt 2> /dev/null;
fi
echo "*** docker-compose.yml file is created ***"
echo "*** Downloading docker images ... ***"
sudo docker-compose up -d
# Post installation steps 
## Configure webrtc
sleep 5
export MINIOSECRET=$(sudo docker inspect nsc-minio | grep MINIO_ROOT_PASSWORD= | awk '{print $1}' | sed s/MINIO_ROOT_PASSWORD=// | sed -e 's/[""]//g') 2> /dev/null
sed -i 's/.*MINIO_SECRET_KEY=*.*/      - MINIO_SECRET_KEY='"$MINIOSECRET"'/' $NSCHOME/docker-compose.yml;
sudo docker-compose up -d
## Configure stream-in service, removed from release-4.1
# sed -i 's/.*NSC3_STREAM_IN_SERVICE_TEAM_BRIDGE_ENABLED*.*/      - NSC3_STREAM_IN_SERVICE_TEAM_BRIDGE_ENABLED=true/' $NSCHOME/docker-compose.yml;
# sudo docker-compose restart nsc-stream-in-service
echo ""
echo "************************************************************************"
echo "                                                       "                                        
echo "NSC3 backend release $RELEASETAG is installed with  "
echo "Team-Bridge role: $TBROLE using $TBMODE protocol    "
if [ $TBROLE = client ]; then echo "Source org ID: $SOURCEORG ServerIP: $TBSERVERIP "; fi
if [ $TBROLE = server ]; then echo "Source org ID: $SOURCEORG Target org ID: $TARGETORG "; fi
if [ $TBROLE = both ]; then echo "Client: Source org ID: $CLIENTSOURCE ServerIP: $TBSERVERIP  "; fi
if [ $TBROLE = both ]; then echo "Server: Source org ID: $SERVERSOURCE Target org ID: $SERVERDEST "; fi
echo ""
echo "Backup-files:"
echo "Docker-compose backup: 'docker-compose-tb-addition-backup-$TIMESTAMP.yml' "
echo "Login to your NSC3 web app by URL address       "
echo "https://$PUBLICIP                               "
echo ""
if [ $KEY_COPY_REMINDER ]; then 
   echo "New TCP keypairs generated at this server. Please copy all key pair files from this server folder $NSCHOME/bridgekeys to other end server folder $NSCHOME/bridgekeys"; 
fi
echo "*************************************************************************"

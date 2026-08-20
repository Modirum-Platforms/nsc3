#!/bin/bash
## NSC3 registry:
export NSC3REG="modirumplatforms.azurecr.io"
source ./nsc-host.env
silentmode=false
FACE_DETECTION_ENABLED=false
OBJECT_DETECTION_ENABLED=false

compose_has_service() {
    local compose_file=$1
    local service_name=$2

    awk -v service_name="$service_name" '
        { sub(/\r$/, "") }
        $0 == "  " service_name ":" { found = 1 }
        END { exit !found }
    ' "$compose_file"
}

remove_compose_service() {
    local compose_file=$1
    local service_name=$2
    local temp_file="${compose_file}.tmp"

    awk -v service_name="$service_name" '
        $0 == "  " service_name ":" { skipping = 1; next }
        skipping && ($0 ~ /^  [^ ]/ || $0 ~ /^[^ ]/) { skipping = 0 }
        !skipping { print }
    ' "$compose_file" > "$temp_file" && mv "$temp_file" "$compose_file"
}

if [ ${1+"true"} ]; then
   if  [ $1 == "--silent" ]; then
       silentmode=true
       echo "silent mode"
   fi
   if  [ $1 == "--help" ]; then
       clear
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       echo "Valor Upgrade script usage:"
       echo ""
       echo "./valor-upgrade.sh --help 	  'help text'"
       echo "./valor-upgrade.sh --silent      'upgrade with command line parameters'"
       echo "./valor-upgrade.sh 		  'interactive upgrade mode'"
       echo ""
       echo "CLI parameters usage:"
       echo "./valor-upgrade.sh --silent <NSC3 release tag>"
       echo ""
       echo "CLI parameters example:"
       echo "./valor-upgrade.sh --silent release-4.5.3"
       echo ""
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       exit 0
   fi
   if [ ${2+"true"} ]; then
       export NSC3REL=$2
   fi
fi
if [ "$silentmode" = false ]; then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "                                        "
    echo "  Valor upgrade:        "
    echo "  This script is upgrading NSC3 system  "
    echo "                                        "
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "New NSC3 Release tag for upgrading, e.g release-4.5.3: "
    read REL
    export NSC3REL=$REL
fi
cd $NSCHOME
# Check values
if grep -q $NSC3REL $NSCHOME/valor-docker-compose-ext-reg.tmpl; then     
   echo "$NSC3REL tag found from docker-compose template" 
   RELEASETAG=$NSC3REL
   else    
   echo "Release tag: $NSC3REL is missing. Using release tag: rc as runtime parameters configuration" 
   RELEASETAG="rc"
fi
# Move old files
if [ -f "docker-compose-valor.yml" ]; then
   if compose_has_service docker-compose-valor.yml nsc-recipe-face-comparison-service; then
       FACE_DETECTION_ENABLED=true
   fi
   if compose_has_service docker-compose-valor.yml nsc-recipe-object-detection-service; then
       OBJECT_DETECTION_ENABLED=true
   fi
   mv docker-compose-valor.yml docker-compose-valor-$NSC3REL.old 2> /dev/null
fi
(echo "cat <<EOF >docker-compose-valor-temp.yml";
cat valor-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p';
) >temp.yml
. temp.yml 2> /dev/null
cat docker-compose-valor-temp.yml > docker-compose-valor.yml;
rm -f temp.yml docker-compose-valor-temp.yml 2> /dev/null
if [ "$FACE_DETECTION_ENABLED" != true ]; then
    remove_compose_service docker-compose-valor.yml nsc-recipe-face-comparison-service
fi
if [ "$OBJECT_DETECTION_ENABLED" != true ]; then
    remove_compose_service docker-compose-valor.yml nsc-recipe-object-detection-service-onnx
    remove_compose_service docker-compose-valor.yml nsc-recipe-object-detection-service
fi
# Archive env specific file to system
if test -f docker-compose-valor_$PUBLICIP.yml; then
    mv docker-compose-valor_$PUBLICIP.yml docker-compose-valor_$PUBLICIP.old  2> /dev/null
fi
cp docker-compose-valor.yml docker-compose-valor_$PUBLICIP.yml
echo "Upgrading docker images ..."
sudo docker compose -f docker-compose-valor.yml pull
sudo docker compose -f docker-compose-valor.yml up -d
echo "++++++++++++++++++++++++++++++++++++++++"
echo ""                                        
echo "Valor is upgraded to release $NSC3REL!"
echo ""
echo "Login to your NSC3 web app by URL address"
echo "https://$PUBLICIP"
echo ""
echo "++++++++++++++++++++++++++++++++++++++++"

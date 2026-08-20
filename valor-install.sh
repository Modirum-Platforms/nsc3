#!/bin/bash
## NSC3 registry:
export NSC3REG="modirumplatforms.azurecr.io"
export REDISAI_DEVICE="gpu"
source ./nsc-host.env
silentmode=false
FACE_DETECTION_ENABLED=${FACE_DETECTION_ENABLED:-false}
OBJECT_DETECTION_ENABLED=${OBJECT_DETECTION_ENABLED:-false}

ask_to_install() {
    local prompt=$1
    local answer

    while true; do
        read -p "$prompt (y/n): " answer
        case $answer in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
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
       echo "Valor installer usage:"
       echo ""
       echo "sudo ./valor-install.sh --help 	  'help text'"
       echo "sudo ./valor-install.sh --silent      'installation with command line parameters'"
       echo "sudo ./valor-install.sh 		  'interactive installation mode'"
       echo ""
       echo "CLI parameters usage:"
       echo "sudo ./valor-install.sh --silent <Valor release tag> <HW layout> [face detection true/false] [object detection true/false]"
       echo ""
       echo "CLI parameters example:"
       echo "sudo ./valor-install.sh --silent release-4.5.3 gpu true true"
       echo ""
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       exit 0
   fi
   if [ ${2+"true"} ]; then
       export NSC3REL=$2
   fi
   if [ ${3+"true"} ]; then
       export REDISAI_DEVICE=$3
   fi
   if [ ${4+"true"} ]; then
       FACE_DETECTION_ENABLED=$4
   fi
   if [ ${5+"true"} ]; then
       OBJECT_DETECTION_ENABLED=$5
   fi
fi
if [ "$silentmode" = false ]; then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "                                        "
    echo "  Valor docker-compose installer:       "
    echo "  This script prepares Valor config     "
    echo "                                        "
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "Valor Release tag, e.g release-4.4.2: "
    read REL
    export NSC3REL=$REL
    if ask_to_install "Install face detection?"; then
        FACE_DETECTION_ENABLED=true
    fi
    if ask_to_install "Install object detection?"; then
        OBJECT_DETECTION_ENABLED=true
    fi
fi
echo "export REDISAI_DEVICE=$REDISAI_DEVICE" >> $NSCHOME/nsc-host.env
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
echo "docker-compose-valor.yml file is created..."
echo "Downloading docker images ..."
sudo docker-compose -f docker-compose-valor.yml up -d
sudo docker restart nsc-scheduler-service
echo "*********************************************************"
echo ""                                        
echo "NSC3 backend with Valor version $NSC3REL is installed!"
echo ""
echo "Login to your NSC3 web app by URL address"
echo "https://$PUBLICIP"
echo ""
echo "*********************************************************"

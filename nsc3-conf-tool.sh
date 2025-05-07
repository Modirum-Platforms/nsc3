#!/bin/bash
## NSC3 registry:
export NSC3REG="registry.menturagroup.com/nsc3/docker-images"
export REDISAI_DEVICE="gpu"
flag=false
if [ ${1+"true"} ]; then
   flag=true
   if  [ $1 == "--help" ]; then
       clear
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       echo "NSC3 configuration tool usage:"
       echo ""
       echo "./nsc3-conf-tool.sh --help 	   'help text'"
       echo "./nsc3-conf-tool.sh --nsc3      'NSC3 conf creation with command line parameters'"
       echo "./nsc3-conf-tool.sh --valor 		 'Valor conf creation with command line parameters'"
       echo ""
       echo "CLI parameters usage: NSC3"
       echo "./nsc3-conf-tool.sh --nsc3 <installation_path> <hostname> <nsc3_release_tag>"
       echo ""
       echo "Output files:"
       echo "docker-compose.yml, docker-compose_<hostname>.yml, nsc-host.env"
       echo ""
       echo "CLI parameters usage: Valor"
       echo "./nsc3-conf-tool.sh --valor <installation_path> <hostname> <nsc3_release_tag>"
       echo ""
       echo "Output files:"
       echo "docker-compose-valor.yml, docker-compose-valor_<hostname>.yml, nsc-host.env"
       echo ""
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       exit 0
   fi
   if [ ${2+"true"} ]; then
       export NSCHOME=$2
   fi
   if [ ${3+"true"} ]; then
       export PUBLICIP=$3
   fi
   if [ ${4+"true"} ]; then
       export NSC3REL=$4
   fi   
fi
if  [ $flag == "false" ]; then
   echo "usage ./nsc3-conf-tool.sh --help"
   exit 0
fi

# Check values
if grep -q $NSC3REL $NSCHOME/nsc3-docker-compose-ext-reg.tmpl; then     
   echo "$NSC3REL tag found from docker-compose template" 
   export RELEASETAG=$NSC3REL
   else    
   echo "Release tag: $NSC3REL is missing. Using release tag: latest as runtime parameters configuration" 
   export RELEASETAG="latest"
fi

if  [ $1 == "--nsc3" ]; then
  # Remove old and create new env file
  if [ -f "nsc-host.env" ]; then
     rm nsc-host.env 2> /dev/null
  fi
  echo "export PUBLICIP=$PUBLICIP" > nsc-host.env
  echo "export NSCHOME=$NSCHOME" >> nsc-host.env
  # Create docker-compose.yml file
  if [ -f "docker-compose.yml" ]; then
     mv docker-compose.yml docker-compose-$NSC3REL.old 2> /dev/null
  fi
  (echo "cat <<EOF >docker-compose-temp.yml";
  cat nsc3-docker-compose-ext-reg.tmpl | sed -n '/'"$RELEASETAG"'/,/'"$RELEASETAG"'/p';
  ) >temp.yml
  . temp.yml 2> /dev/null
  cat docker-compose-temp.yml > docker-compose.yml;
  rm -f temp.yml docker-compose-temp.yml 2> /dev/null
  # Archive env specific file to system
  if test -f docker-compose_$PUBLICIP.yml; then
      mv docker-compose_$PUBLICIP.yml docker-compose_$PUBLICIP.old  2> /dev/null
  fi
  cp docker-compose.yml docker-compose_$PUBLICIP.yml
  echo "docker-compose.yml, docker-compose_$PUBLICIP.yml and nsc-host.env files are created"
fi
if [ -f "docker-compose-valor.yml" ]; then
   mv docker-compose-valor.yml docker-compose-valor_$NSC3REL.old 2> /dev/null
fi
if  [ $1 == "--valor" ]; then
  # Remove old and create new env file
  if [ -f "nsc-host.env" ]; then
     rm nsc-host.env 2> /dev/null
  fi
  echo "export PUBLICIP=$PUBLICIP" > nsc-host.env
  echo "export NSCHOME=$NSCHOME" >> nsc-host.env
  echo "export REDISAI_DEVICE=$REDISAI_DEVICE" >> nsc-host.env
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
  # Archive env specific file to system
  if test -f docker-compose-valor_$PUBLICIP.yml; then
      mv docker-compose-valor_$PUBLICIP.yml docker-compose-valor_$PUBLICIP.old  2> /dev/null
  fi
  cp docker-compose-valor.yml docker-compose-valor_$PUBLICIP.yml
  echo "docker-compose-valor.yml, docker-compose-valor_$PUBLICIP.yml and nsc-host.env files are created"
fi

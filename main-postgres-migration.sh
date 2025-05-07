#!/bin/bash
## NSC3 registry:
export NSC3REG="registry.menturagroup.com/nsc3/docker-images"

# Test if image is not local and pull
pull_image () {
    echo "Pulling image"
    if [ "$(docker image ls -q $1)" = "" ]; then
      docker pull $newDbImage > /dev/null
      [ ${?} -ne 0 ] && exit 1
    fi
}

print_info () {
  echo ""
  echo "#######################################################################################"
  echo ""
  echo "This script will make a database dump out of current main database container,"
  echo "then stop and remove the container and start a new database container with new volume."
  echo "Finally script migrates the database dump to new database."
  echo "No volumes will be removed."
  echo ""
  echo "Should you wish to roll back to old database,"
  echo "stop and remove new database container and reinstall the old database container."
  echo ""
  echo "Before running this script, you should stop all other nsc3 containers except database."
  echo "This ensures that no writes happen during the migration."
  echo ""
  echo "Possible errors and warning in restoring database will be stored in error-main-db.log"
  echo ""
}

if [ ${1+"true"} ]; then
  if  [ $1 == "--silent" ]; then
      if [ "$#" -ne 3 ]; then
          echo "Illegal number of parameters"
          echo "'./postgres-migration.sh --help' for help"
          exit 1
      fi
      if [ ${2+"true"} ]; then
          newDbVolume=$2
      fi
      if [ ${3+"true"} ]; then
          newDbImage=$3
      fi

      # Test if image is not local and pull

      docker exec main-postgres pg_dumpall -U nsc -l maindatabase > maindatabase-all.sql
      [ ${?} -ne 0 ] && exit 1
      docker stop main-postgres > /dev/null
      [ ${?} -ne 0 ] && exit 1
      docker container rm main-postgres > /dev/null
      [ ${?} -ne 0 ] && exit 1
      docker run -d -v $newDbVolume:/var/lib/postgresql/data --net nsc-network --restart unless-stopped --name main-postgres $newDbImage > /dev/null
      [ ${?} -ne 0 ] && exit 1
      sleep 5
      docker exec main-postgres psql -U nsc -c "DROP SCHEMA organizationlist CASCADE;" maindatabase > /dev/null 2>&1
      if [ ${?} -ne 0 ]; then
          echo "Error in schema dropping"
          exit 1
      fi
      docker exec main-postgres sed -i 's/host all all all scram-sha-256/host all all all md5/g' /var/lib/postgresql/data/pgdata/pg_hba.conf > /dev/null
      [ ${?} -ne 0 ] && exit 1
      docker cp maindatabase-all.sql main-postgres:/tmp > /dev/null
      [ ${?} -ne 0 ] && exit 1
      docker exec main-postgres psql -U nsc -f /tmp/maindatabase-all.sql maindatabase > /dev/null 2> error-main-db.log
      if [ ${?} -ne 0 ]; then
          echo "Error in migrating the db from dumpfile. Read error-main-db.log"
          exit 1
      fi
      docker restart main-postgres > /dev/null
      [ ${?} -ne 0 ] && exit 1

      exit 0
  fi
  if  [ $1 == "--help" ]; then
      print_info
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      echo "Postgres version migration script usage:"
      echo ""
      echo "./main-postgres-migration.sh --help       'help text'"
      echo "./main-postgres-migration.sh --silent     'installation with command line parameters'"
      echo "./main-postgres-migration.sh              'interactive installation mode'"
      echo ""
      echo "CLI parameters usage:"
      echo "./main-postgres-migration.sh --silent <new db volume> <new db image>"
      echo ""
      echo "CLI parameters example:"
      echo "./main-postgres-migration.sh --silent main-postgres-pg15-volume $NSC3REG/main-postgres:migrate-test-pg15"
      echo ""
      echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      exit 0
  fi
fi

print_info
read -p "Press enter to perform migration, Ctrl-c to cancel"

echo ""
echo "Enter a name for new database volume (eg. main-postgres-volume-pg15): "
read newDbVolume
echo "Enter new database docker image name and tag (eg. $NSC3REG/main-postgres:migrate-test-pg15)"
echo "When using a docker registry, be sure you have logged in before continuing with this script."
read newDbImage
echo ""
echo "New database volume name:           $newDbVolume"
echo "New database docker image:          $newDbImage"
echo ""
read -p "Are these correct? Press enter to continue, Ctrl-c to cancel"

# Parameter checking
paramerr=false
[ -n "$newDbVolume" ] || {
  echo "Error: You must provide a name for the volume of the new database container."
  paramerr=true
}
[ -n "$newDbImage" ] || {
  echo "Error: You must provide name of the new database image."
  paramerr=true
}
[ "$paramerr" = true ] && exit 1

# Test if image is not local and pull
pull_image $newDbImage

echo ""
echo "Making a database dump"
docker exec main-postgres pg_dumpall -U nsc -l maindatabase > maindatabase-all.sql
[ ${?} -ne 0 ] && exit 1
echo "Database dump done"

echo ""
echo "Stopping and removing the old database container"
docker stop main-postgres > /dev/null
[ ${?} -ne 0 ] && exit 1
docker container rm main-postgres > /dev/null
[ ${?} -ne 0 ] && exit 1
echo "Old database container stopped and removed"

echo ""
echo "Starting a new database container"
docker run -d -v $newDbVolume:/var/lib/postgresql/data --net nsc-network --restart unless-stopped --name main-postgres $newDbImage > /dev/null
[ ${?} -ne 0 ] && exit 1
sleep 5
echo "New database container started"
echo "Dropping organization list schema"
docker exec main-postgres psql -U nsc -c "DROP SCHEMA organizationlist CASCADE;" maindatabase > /dev/null 2>&1
if [ ${?} -ne 0 ]; then
  echo "Error in schema dropping"
  exit 1
fi
echo "Organization list schema dropped"

echo "Modifying configuration to allow md5 hash password"
docker exec main-postgres sed -i 's/host all all all scram-sha-256/host all all all md5/g' /var/lib/postgresql/data/pgdata/pg_hba.conf > /dev/null
[ ${?} -ne 0 ] && exit 1

echo ""
echo "Migrating database from dump"
echo "Copying the dumpfile in container"
docker cp maindatabase-all.sql main-postgres:/tmp > /dev/null
[ ${?} -ne 0 ] && exit 1
echo "Copying done"
echo "Restore contents from dumpfile, possible errors will be in error-main-db.log"
docker exec main-postgres psql -U nsc -f /tmp/maindatabase-all.sql maindatabase > /dev/null 2> error-main-db.log
if [ ${?} -ne 0 ]; then
  echo "Error in migrating the db from dumpfile. Read error-main-db.log"
  exit 1
fi
echo "Database content restored"
echo "Restarting database container"
docker restart main-postgres > /dev/null
[ ${?} -ne 0 ] && exit 1

echo ""
echo "Script done"

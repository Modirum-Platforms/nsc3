# Filebeat log collection

## Project description

This folder contains files needed for setting up docker log collection to our Elastic stack at logs.nsiontec.com .
Filebeat is set up with docker-compose.yml . Configuration for Filebeat is in filebeat.docker.yml .

You need to fill in password for Elasticsearch user for both docker-compose.yml and filebeat.docker.yml . Password is available in eyeshare password keep.
You need to fill in host name in docker-compose.yml, meaning the host that Filebeat will be running on and collecting logs from.

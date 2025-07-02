# NSC3 Installation guidance
## Project description:
NSC3 backend installation guides and scripts for single node server configuration

    Release Tag of latest release: release-4.3

## Project structure:
- README.md: General guidance for this repository. NSC3 installation, upgrade and maintenance instructions.
- nsc3-install.sh: Script for NSC3 installation
- nsc3-upgrade.sh: Script for NSC3 upgrade
- nsc3-docker-compose-ext-reg.tmpl: Docker Compose template for NSC3
- valor-installation-guide.md: Valor installation guidance 
- valor-install.sh: Script for Valor installation
- valor-upgrade.sh: Script for upgradeValor 
- valor-docker-compose-ext-reg.tmpl: Docker Compose template for Valor
- nsc3-conf-tool.sh: Shell Script for NSC3 and Valor runtime configuration. Designed for Development pipe usage where configuration is pre-set outside of targeted server.
- generateTeamBridgeRSAKeyPairs.sh: Team-Bridge TCP/IP mode key generation script
- team-bridge.md: Team-Bridge installation guidance

## Prerequisites for NSC3 installation:
- [x] Minimum HW configuration: 8 CPU cores, 16GB RAM, 500GB Free Disk. As reference 1h video clip is consuming around 2GB disk space.
      Recommended 16 CPU cores, 32GB RAM to managed more than 50 simultaneous video sources.
- [x] Linux operating system (Latest Ubuntu LTS as recommended OS)
- [x] The computer or virtual machine is allocated for NSC3 use only.
- [x] Internet access is available
- [x] Following TCP/IP4 ports are open from network to server:
- 443(HTTPS)
- 1935(RTMPS), 1936(RTMP)
- NSC3 application specific ports (25204, 25205, 25206)
- Livelink specific ports 40000-40007
- Team-Bridge specific port (Team-Bridge server): 64660
- [x] SSL certifications for the service domain. Human readable (PEM) format. A private key file named as privkey.pem. A full chained certification file named as fullchain.pem
- [x] Server domain name is registered to DNS services. 
- [x] Linux account with sudo privileges for operating system.
- [x] Following 3rd party apps are needed: git, wget and curl. Most of them are by default included as part of a linux basic setup. However please ensure beforehand availability on your local linux setup. 


## NSC3 backend installation guidance for single node:
### Default file system locations:

- NSC3 Installation folder: ```$HOME/nsc3```, However this location is configurable. Instruction are referring for ```$HOME/nsc3``` folder. The subfolder "nsc3" will be created automatically while installation process.
- Docker content folder: ```/var/lib/docker```
- Relational Database (Postgresql) content folder: ```/var/lib/docker/volumes/main-postgres-volume```
- Object Storage (min.io) content folder: ```/var/lib/docker/volumes/minio-volume```
- NSC3 logs files folder: ```$HOME/nsc3/logs```. Container logs ```sudo docker logs <container name>```
- NSC3 maptiles files folder: ```$HOME/nsc3/mapdata``` Note only one maptile file is supported!
- SSL cert files folder: ```$HOME/nsc3/nsc-gateway-cert```
- Environment variables for system maintenance: ```$HOME/nsc3/nsc-host.env```
- Maintenance log: ```$HOME/nsc3/logs/nsc-maintenance/nsc-maintenance-log.txt```

### Instructions for NSC3 add-on features:

#### Team bridge:
https://github.com/NSION/nsc3/blob/main/team-bridge.md

#### Valor AI module:
https://github.com/NSION/nsc3/blob/main/valor-installation-guide.md

#### NSC3 tooling:
##### NSC3 monitoring
https://github.com/NSION/nsc3/blob/main/nsc3-monitoring/README.md

### NSC3 installation:
#### Install Docker:
Please follow the latest installation instructions by Docker community https://docs.docker.com/engine/install/ 
As an example, installation for Ubuntu with access to the internet:

##### Update the apt package index and install packages to allow apt to use a repository over HTTPS:
```
sudo apt-get update
```
```bash
sudo apt-get install \
ca-certificates \
curl \
gnupg \
lsb-release \
dnsutils
```

##### Add Docker’s official GPG key:
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```    
##### Use the following command to set up the stable repository
```bash
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
##### Install Docker Engine
```
sudo apt-get update
```
```
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

#### Install git:

- Please follow the latest installation instructions by Git community https://git-scm.com/download/linux

As example Ubuntu:
```
sudo apt install git
```
#### Setup installation folder:

- Copy the SSL cert files privkey.pem and fullchain.pem to your home folder. As this example $HOME 
- Clone git project from Modirum Platforms NSC3 repository

#### Gather installation scripts from Modirum Platforms github:
With access to the internet:

    cd $HOME
    git clone https://github.com/Modirum-Platforms/nsc3.git

If you don't have access to the internet on the machine that NSC3 will be installed:
- Download a ZIP of the Github repository via this link https://github.com/Modirum-Platforms/nsc3/archive/refs/heads/main.zip
- Move the ZIP to the NSC3 machine's $HOME folder
- Run the following commands:

```
    cd $HOME
    mkdir $HOME/nsc3
    unzip nsc3-main.zip -d $HOME/nsc3
```
    
#### Grant execute rights for the installation script:

    cd $HOME/nsc3
    chmod u+x nsc3-install.sh
    
#### Gaining access to the docker images:

Via Docker registry:

    cd $HOME/nsc3
    sudo docker login registrynsion.azurecr.io
    
    <Registry crentials will be delivered separately>

Via delivered tar file:
- Move the delivered tar file to the NSC3 machine's $HOME folder
- Load the images:

```
    cd $HOME
    tar -xvf export_release_<YOUR_RELEASE_NUMBER_HERE>.tar.xz
    cd $HOME/export
    ls -1 *.tar | xargs --no-run-if-empty -L 1 docker load -i
```
        
#### Install Docker Compose:

Please follow the latest installation instructions by Docker community https://docs.docker.com/compose/install/.
As an example, installation for Ubuntu with access to the internet:

Remove old docker-compose:

    sudo apt-get remove docker-compose
    
Install docker-compose:

	VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')

    DESTINATION=/usr/local/bin/docker-compose
    sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DESTINATION
    sudo chmod 755 $DESTINATION


#### Install NSC3
##### Silent installation mode: 

    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    NSC3 installer usage:

    sudo ./nsc3-install.sh --help 	  	'help text'
    sudo ./nsc3-install.sh --silent     'installation with command line parameters'
    sudo ./nsc3-install.sh 		  		'interactive installation mode'

    CLI parameters usage:
    sudo ./nsc3-install.sh --silent <Installation path> <SSL cert files location> <host name> <MAP region> <NSC3 release tag> <VALOR enabled true/false>

    CLI parameters example:
    sudo ./nsc3-install.sh --silent /home/ubuntu/nsc3 /home/ubuntu foo.nsion.io NA release-3.15 false

    Regional identifiers of MAP selection:
    EU=Europe, NA=North America, AUS=Australia, GCC=GCC states, false=skip maptiles downloading
    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


##### Interactive installation mode: installation dialog with example values  
```
cd $HOME/nsc3
sudo ./nsc3-install.sh  
```    
    ++++++++++++++++++++++++++++++++++++++++
                                        
    NSC3 docker-compose installer:        
    This script prepares NSC3 config      
                                          
    ++++++++++++++++++++++++++++++++++++++++
    NSC3 installation folder, e.g /home/ubuntu/nsc3: /home/ubuntu/nsc3      
    NSC3 public hostname, e.g foo.nsion.io: foo.nsion.io   
    Location of SSL cert files, e.g /home/ubuntu: /home/ubuntu
    NSC3 Release tag, e.g release-3.15: release-3.11
    Map files options : 
    1. North America map
    2. Europa map
    3. Australia map
    4. GCC states map
    5. Skip maptile download
    Select your option as number: 
    1   
    ++++++++++++++++++++++++++++++++++++++++
    NSC3 backend is installed!
    Login to your NSC3 web app by URL address
    https://foo.nsion.io
    ++++++++++++++++++++++++++++++++++++++++
    
### Post installation steps

- [x] Verify installation
- [x] Insert NSC3 license
- [x] Configure NSC3 organisation

#### Verify installation
Check docker containers, Totally number of running containers is 16 without optional features

    sudo docker ps
    sudo docker stats

Check Web services, Expected result if ok, "HTTP/2 200"

    cd $HOME/nsc3
    source nsc-host.env
    curl -I --http2 -s https://$PUBLICIP
    
Check SSL Certification status, Expected result when ok, "SSL certificate verify ok"
```
curl --cert-status -v https://$PUBLICIP 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'
```    
#### Insert NSC3 license

Login to the NSC3 web app as admin
- Initial admin login. org: admin login user and password: admin. System is proposing to change password right after first successful login session.
- Download an instance key via NSC3 admin/license UI. Licenses Tab / Server license / Set new NSC3 license / Download Instance key
- Send the instance key file via Modirum Platforms Jira Service desk support portal.
- Modirum Platforms will prepare and return a corresponding license key file back. No need to left UI open while waiting
- Insert license key via NSC3 admin/license UI. Licenses Tab / Server license / Set new NSC3 license / Insert license key (download from local computer via Web app)

#### Configure NSC organisation

NSC3 Admin documentation: https://www.nsiontec.com/user-guide-webapp-admin/ 

### Upgrade NSC3

Download the latest scripts from github:

With internet access:

    cd $HOME/nsc3
    chmod u-x *.sh
    git pull -f

Without internet access:
- Download a ZIP of the Github repository via this link https://github.com/Modirum-Platforms/nsc3/archive/refs/heads/main.zip
- Move the ZIP to the NSC3 machine's $HOME folder
- Run the following commands:

```
    cd $HOME
    mkdir $HOME/nsc3
    unzip -o nsc3-main.zip -d $HOME/nsc3
```

If images were loaded from the delivered tar file, you will be delivered a new tar file with updated images:
- Move the delivered tar file to the NSC3 machine's $HOME folder
- Load the images:

```
    cd $HOME
    tar -xvf export_release_<YOUR_RELEASE_NUMBER_HERE>.tar.xz
    cd $HOME/export
    ls -1 *.tar | xargs --no-run-if-empty -L 1 docker load -i
```

Grant execute rights for the upgrade script:

    chmod u+x nsc3-upgrade.sh
    
Start upgrade process:

    sudo ./nsc3-upgrade.sh
    
Note that release tag format is 
    
    release-<release number>, e.g: release-3.15  
    
### NSC3 Maintenance

#### Managing NSC3 containers:

Stop NSC3 services:

    cd $HOME/nsc3
    sudo docker compose down

Start NSC3 services:

    cd $HOME/nsc3
    sudo docker compose up -d  

Restart NSC3 container:

    cd $HOME/nsc3
    sudo docker compose restart [NSC3 container]

#### Monitoring NSC3 runtime environment:

Monitor container logs via docker logs:

    sudo docker logs <container name>
    
Check disk storage usage level:

    df -hT | grep /$ | awk '{ print $6}'
    
Check computer free RAM memory:

    echo $(free -g | grep Mem: | awk '{ print $7}') "GB"
    
Container status:

    sudo docker stats

#### Update SSL certification

Copy new cert file to $HOME/nsc3/nsc-gateway-cert.

If the existing cert will be updated then only cert file need to be replaced.

Naming rule: 
- privatekey: privkey.pem
- SSL cert: fullchain.pem

E.g if you have changed SSL cert files then nsc-gateway-service and nsc-stream-in-service  require restarting in order to take into use a new cert file.

```
sudo docker compose restart nsc-gateway nsc-stream-in-service
```

#### Relocating the Docker root directory

If the file space in the Docker root directory is not adequate, you must relocate the directory.

1. Stop NSC3 services:
```
cd $HOME/nsc3
sudo docker compose down
```
2. Stop Docker services:
```
sudo systemctl stop docker
sudo systemctl stop docker.socket
sudo systemctl stop containerd
```
3. Create the necessary directory structure into which to move Docker root by running the following command. This directory structure must reside on a file system with at least 50 GB free disk space. Significantly more disk space might be required depending on your daily ingestion volumes and data retention policy.
```
sudo mkdir -p /<new_dir_structure>
```
4. Move Docker root to the new directory structure:
```
sudo mv /var/lib/docker /<new_dir_structure>
```
5. Edit the file /etc/docker/daemon.json. If the file does not exist, create the file by running the following command:
```
sudo vim /etc/docker/daemon.json
```
Add the following information to this file:

	{
  	"data-root": "/<new_dir_structure>/docker"
	}

6. After the /etc/docker/daemon.json file is saved and closed, restart the Docker services:
```
sudo systemctl start docker
```	
After you run the command, all Docker services through dependency management will restart.

7. Validate the new Docker root location:
```
docker info -f '{{ .DockerRootDir}}'
```
8. Start NSC3 services:
```
cd $HOME/nsc3
sudo docker compose up -d
```
    
### NSC3 system troubleshooting

#### No access to NSC3 services:

Try to restart NSC3 services:

    cd $HOME/nsc3
    sudo docker compose up -d 
    
Check https status: 
Expected result if ok, "HTTP/2 200"

    cd $HOME/nsc3
    source nsc-host.env
    curl -I --http2 -s https://$PUBLICIP
    
If still no access please then check ...
- Network status
- Disk space usage level
- Docker status

#### NSC3 Web service is not working properly:

##### Check that SSL cert is valid: Expected result if ok, "SSL certificate verify ok"

    cd $HOME/nsc3
    source nsc-host.env

```
curl --cert-status -v https://$PUBLICIP 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'
```
##### Check that the HTTPS port is listening:

    ss -lntu | grep ':443'
    
##### Validate cert file and private key files:

######  Cert files location:

	$HOME/nsc3/nsc-gateway-cert
	

###### Check that privkey.pem first line looks as below 

	-----BEGIN PRIVATE KEY-----

```
cat privkey.pem
```
	
	
###### Check that fullchain.pem first line looks as below

	-----BEGIN CERTIFICATE-----

```
cat fullchain.pem
```
	
###### Check that private key and cert files are paired together: Expected result -> both md5 checksum values are equal
	
privkey check sum: 

```	
openssl rsa -noout -modulus -in privkey.pem | openssl md5
```

cert check sum: 

```
openssl x509 -noout -modulus -in fullchain.pem | openssl md5
```

###### SSL Cert file is chained with dns_operator + service certs: Expected result -> number is more than 1

```
cat fullchain.pem | grep "BEGIN" | wc -l
```
###### Restart nsc-gateway services

E.g if you have changed SSL cert files then nsc-gateway-service requires restarting in order to take into use a new cert file.

```
sudo docker compose restart nsc-gateway
```

##### Check TCP IP route from external network to NSC3 https port:

This requires extra tool called nmap:
As example Ubuntu installation

    sudo apt install nmap
    
Test that route to 443 port is open:

    nmap <hostname> | grep 443

## NSC3 Container description:
![NSC3-containers](https://github.com/NSION/nsc3/blob/team-bridge-dev/NSC3-Valor-containers.png)

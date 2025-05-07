# Valor Installation guidance
## Project description:
Valor installation guidance and scripts for single node server configuration.
Detailed installation guidance for Ubuntu 20.04 LTS and 22.02 LTS

    Release Tag: release-3.15

## Project structure:

- valor-installation-guide.md -> Valor installation instructions
- valor-install.sh -> Script for Valor installation
- valor-upgrade.sh -> Script for Valor upgrade
- valor-docker-compose-ext-reg.tmpl -> Docker Compose template for Valor

## Prerequisites for Valor installation:
- [x] Minimum HW configuration: 8 CPU cores with GPU, 32 GB RAM, 500GB Free Disk. As reference 1h video clip is consuming around 2GB disk space.
- [x] Linux operating system, Ubuntu 20.04/22.02 LTS as reference. Following instructions regarding NVIDIA drivers installation are compatible only with Ubuntu 20.04/22.04 LTS.
- [x] The computer or virtual machine is allocated for NSC3 use only.
- [x] Internet access is available
- [x] NSC3 backend is installed and Docker is attached to NSION container registry
- [x] Valor specific NSC3 license is required 

NSC3 technical description: https://www.nsiontec.com/technical-specifications/

## NSC3 backend installation guidance for single node via public NSION repository:
### Default file system locations:

- NSC3-Valor Installation folder $HOME/nsc3, However this location is configurable. Instruction are referring for $HOME/nsc3 folder. 
- Docker content folder is /var/lib/docker
- Valor RDB content folder is /var/lib/docker/volumes/analytics-postgres-volume
- NSC3 logs files folder is $HOME/nsc3/logs

## Install GPU drivers to host VM

19.10.2023 Note: It is recommeded to install Ubuntu 20.04 based image for Cloud VM due to limitations with NVIDIA latest drivers.
01.07.2024 Note: In case of Azure VM Please add then NVIDIA extension. https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/hpccompute-gpu-linux?source=recommendations. 

Ubuntu 20.04/22.04 LTS as reference:

To install the NVIDIA Cuda drivers for Ubuntu 20.04/22.04 LTS

1. Update your package cache and get the package updates for your instance.
```
sudo apt-get update -y
```    
2. Install Nvidia Cuda toolkit
```
sudo apt -y install nvidia-cuda-toolkit
```
3. Check your CUDA version:
```
nvcc --version
```    
Expected output:

	nvcc: NVIDIA (R) Cuda compiler driver
	Copyright (c) 2005-2019 NVIDIA Corporation
	Built on Sun_Jul_28_19:07:16_PDT_2019
	Cuda compilation tools, release 10.1, V10.1.243


4. Setup Nvida CUDA repository. Execute the following commands to enable CUDA repository.

Ubuntu 20.04 LTS
```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
```
Ubuntu 22.04 LTS

If Nvidia cuda has already installed via previous Nvidia repository then please remove the outdated singing key

```
sudo apt-key del 7fa2af80
```

```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /"
```

5. Install Nvidia Cuda via apt repository:
```
sudo apt update
sudo apt install cuda
```

6. Set your path to point to CUDA binaries:
```
echo 'export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}' >> ~/.bashrc
```
Reboot server:
```
sudo reboot
```

### Install Nvidia container toolkit:
Please follow the latest installation instructions by [Nvidia community](https://github.com/NVIDIA/nvidia-container-toolkit).

### As example Ubuntu:


Install the repository for your distribution by following the instructions [here](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).

```
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```
```
sudo apt-get update
```
```
sudo apt-get install -y nvidia-container-toolkit
```

### Docker Engine setup

#### Systemd drop-in file
```
sudo mkdir -p /etc/systemd/system/docker.service.d
```
```bash
sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --host=fd:// --add-runtime=nvidia=/usr/bin/nvidia-container-runtime
EOF
```
```
sudo systemctl daemon-reload
```
```
sudo systemctl restart docker
```

#### Daemon configuration file
```bash
sudo tee /etc/docker/daemon.json <<EOF
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF
```
```
sudo pkill -SIGHUP dockerd
```

### Verify NVIDIA driver installation:

```
/usr/bin/nvidia-container-cli info
```

Expected output (as example):

    NVRM version:   510.47.03
    CUDA version:   11.6

    Device Index:   0
    Device Minor:   0
    Model:          Tesla T4
    Brand:          Unknown
    GPU UUID:       GPU-d4eb615d-8f1e-4731-6b80-73bc2c391073
    Bus Location:   00000000:00:1e.0
    Architecture:   7.5


## Valor installation:    
### Download latest version of Valor installation scripts:

    cd $HOME/nsc3
    chmod u-x *.sh
    git pull
    chmod u+x *.sh
    

### Install Valor
#### Silent installation mode: 

    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Valor installer usage:

    sudo ./valor-install.sh --help 	  	'help text'
    sudo ./valor-install.sh --silent     'installation with command line parameters'
    sudo ./valor-install.sh 		  		'interactive installation mode'

    CLI parameters usage:
    sudo ./valor-install.sh --silent <NSC3 release tag>

    CLI parameters example:
    sudo ./valor-install.sh --silent release-3.15
    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#### Interactive installation mode: installation dialog with example values  

    cd $HOME/nsc3
    sudo ./valor-install.sh  
    

    ++++++++++++++++++++++++++++++++++++++++

      Valor docker-compose installer:       
      This script prepares Valor config     

    ++++++++++++++++++++++++++++++++++++++++
    Valor Release tag, e.g release-3.15: 
    latest  
    ++++++++++++++++++++++++++++++++++++++++
    Valor backend is installed!
    Login to your NSC3 web app by URL address
    https://foo.nsion.io
    ++++++++++++++++++++++++++++++++++++++++
    
#### Initialize the Valor database

```
sudo docker restart nsc-scheduler-service
```

Valor installation is now completed!

### Post installation steps

#### Verify installation
Check docker containers. NSC3 + Valor container both are up and running

    sudo docker ps
    sudo docker stats

Check Web services, Expected result if ok, "HTTP/2 200"

    cd $HOME/nsc3
    source nsc-host.env
    curl -I --http2 -s https://$PUBLICIP
    
Check SSL Certification status, Expected result when ok, "SSL certificate verify ok"

    curl --cert-status -v https://$PUBLICIP 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'
    

### Upgrade NSC3

Downlaod the latest scripts from github:

    cd $HOME/nsc3
    chmod u-x *.sh
    git pull -f
    
Grant execute rights for the upgrade script:

    chmod u+x valor-upgrade.sh
    
Start upgrade process:

    ./valor-upgrade.sh
    
Note that release tag format is 
    
    release-<release number>, e.g: release-3.15
    
### Valor maintenance

Stop Valor services:

    cd $HOME/nsc3
    sudo docker compose -f docker-compose-valor.yml  down

Start NSC3 services:

    cd $HOME/nsc3
    sudo docker compose -f docker-compose-valor.yml up -d  

Monitor container logs via docker logs:

    sudo docker logs <container name>
    
    
Check disk storage usage level:

    df -hT | grep /$ | awk '{ print $6}'
    
Check computer free RAM memory:

    echo $(free -g | grep Mem: | awk '{ print $7}') "GB"
    
Container status:

    sudo docker stats
    
### Valor troubleshooting

#### Valor services does not working properly:

Try to restart Valor services:

    cd $HOME/nsc3
    sudo docker compose -f docker-compose-valor.yml up -d 
    
Check https status: 
Expected result if ok, "HTTP/2 200"

    cd $HOME/nsc3
    source nsc-host.env
    curl -I --http2 -s https://$PUBLICIP
    
If still no access please then check ...
- Network status
- Disk space usage level
- Docker status

#### Check that Valor services are allocated correctly to the Docker runtime GPU resources 

	nvidia-smi 
	
Expected results:

    Wed Nov 16 11:20:41 2022       
    +-----------------------------------------------------------------------------+
    | NVIDIA-SMI 515.65.01    Driver Version: 515.65.01    CUDA Version: 11.7     |
    |-------------------------------+----------------------+----------------------+
    | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
    | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
    |                               |                      |               MIG M. |
    |===============================+======================+======================|
    |   0  Tesla M60           Off  | 00000000:00:1E.0 Off |           8589934590 |
    | N/A   36C    P0    39W / 150W |    634MiB /  7680MiB |      0%      Default |
    |                               |                      |                  N/A |
    +-------------------------------+----------------------+----------------------+

    +-----------------------------------------------------------------------------+
    | Processes:                                                                  |
    |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
    |        ID   ID                                                   Usage      |
    |=============================================================================|
    |    0   N/A  N/A      1071      G   /usr/lib/xorg/Xorg                  3MiB |
    |    0   N/A  N/A   2288852      C   ...l/bin/redis-server *:6379      627MiB |
    +-----------------------------------------------------------------------------+
	
Identify that processes PID is pointing to the redis-server process

	ps -ef | grep redis-server
	
Example printout:

	root      194341  194316  0 Feb24 ?        00:59:39 /usr/local/bin/redis-server *:6379
	
### Valor add-ons

#### Face comparison
Release 3.15 as example

1. Loading image

```
sudo docker pull registrynsion.azurecr.io/nsc-recipe-face-comparison-service:release-3.15
```
Note the tag that image gets when loaded

2. Make a directory for face samples
    - Here for example purposes inside /home/exampleuser
    - `cd /home/exampleuser`
    - `mkdir -p demodata/faces`
    - Put face samples here as jpg-files. Note that filenames will be used as detection names

3. Running container
    - Use the tag that image got when loaded; here as an example :release-3.15 . Use actual path in volume mount parameter (-v)

```
sudo docker run -d -v /home/exampleuser/demodata/faces:/data/wanted_faces --net nsc-network --restart unless-stopped --name nsc-recipe-face-comparison-service registry.menturagroup.com/nsc3/docker-images/nsc-recipe-face-comparison-service:release-3.15
```

#### Object detection

1. Loading images

```
sudo docker pull registrynsion.azurecr.io/nsc-recipe-object-detection-service:release-3.15
```

```
sudo docker pull registrynsion.azurecr.io/nsc-recipe-object-detection-service-onnx:release-3.15
```		

Note the tags that images get when loaded.

2. Running containers
Use the tag that images got when loaded; here as an example :release-3.15

```
sudo docker run -d --net nsc-network -e "NVIDIA_VISIBLE_DEVICES=all" -e "NVIDIA_DRIVER_CAPABILITIES=all" --runtime=nvidia --restart unless-stopped --name nsc-recipe-object-detection-service-onnx registry.menturagroup.com/nsc3/docker-images/nsc-recipe-object-detection-service-onnx:release-3.15
```

```
sudo docker run -d --net nsc-network --restart unless-stopped --name nsc-recipe-object-detection-service registry.menturagroup.com/nsc3/docker-images/nsc-recipe-object-detection-service:release-3.15
```


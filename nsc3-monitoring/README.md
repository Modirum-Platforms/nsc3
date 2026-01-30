# NSC3 OPS-tools
## Project description
This repository contains OPS specific tools for NSC3 admin purposes, like system monitoring and maintenence

## Project structure
- nsc3-ops-tools-minio-status.sh: Object storage status check by nsc3-ops-tools-minio-status.sh
- nsc3-ops-tools-node-status.sh: System level status check by nsc3-ops-tools-node-status.sh
- nsc-perf-monitoring.sh: Performance testing tools -> printout to csv format
- nsc-device-status.sh: Device status list
- nsc3-license-expiration.sh: NSC3 server license expiration
- nsc3-org-license-expirations.sh: License expiration for every organization

## Object storage status check by nsc3-ops-tools-minio-status.sh
Object storage status check tool for min.io specific object storage setup

### Prerequisites
#### Run as root:

	$ sudo su
    
#### Configure to script the enviroment specific parameters

	MINIOPATHDIR="/var/lib/docker/volumes/minio-volume/_data"
	HOSTNAME="example.com"
	OUTPUTLOCATION="/home/ubuntu/nsc3/logs"
    
#### Set execute permissions for the file

	$ chmod u+x nsc3-ops-tools-minio-status.sh

### Run the script

	$ ./nsc3-ops-tools-minio-status.sh

### Reported output:
- output file is located on folder: $OUTPUTLOCATION
- file name: minio-files-nsc3-${HOSTNAME}-${DATE}.csv
### Results as example:

	'DATE','HOSTNAME','ORGNAME','TOTAL SIZE','TOTAL COUNTS','OLDEST TIMESTAMP','BUCKETID'
	'20220109','example.com','vansomerten','272K','20220109','ie3z0vjt5ju3m0iog0h8f1ovnopsv9jlqpk'


### Add the script to crontab
Cronjob syntax:

```text
* * * * * command to be executed
- - - - -
| | | | |
| | | | ----- Day of week (0 - 7) (Sunday=0 or 7)
| | | ------- Month (1 - 12)
| | --------- Day of month (1 - 31)
| ----------- Hour (0 - 23)
------------- Minute (0 - 59)
```
As an example set cronjob run the script daily basis at 7:00 AM.
```text
crontab -e
```
```
0 7 * * * bash /home/ubuntu/nsc3-ops-tools-minio-status.sh
```
Save changes on editor. Eg vim editor ```<esc>``` -button  and ```:wq!```

## System level status check by nsc3-ops-tools-node-status.sh
System level status tool for daily maintenance purposes. 
Output in csv format

### Prerequisites
#### Following 3rd party tools are required: curl and sysstat

	$ sudo apt-get install sysstat
	$ sudo apt-get install curl
    
#### Run as root: 
	
    $ sudo su
    
#### Configure to script the enviroment specific parameters

	MINIOPATHDIR="/var/lib/docker/volumes/minio-volume/_data"
	DOCKERPATHDIR="/var/lib/docker"
	HOSTNAME="example.com"
	NSC3LOGS="/home/ubuntu/logs"
	OUTPUTLOCATION="/home/ubuntu/logs"

#### Set execute permissions for the file

	$ chmod u+x nsc3-ops-tools-node-status.sh

### Run the script

	$ ./nsc3-ops-tools-node-status.sh

### Reported output:
- output file is located on folder: $OUTPUTLOCATION
- file name: system-status-nsc3-${HOSTNAME}-${DATE}.csv
### Results as example:

	'DATE','HOSTNAME','CPUUSAGEFREE','MEMUSAGEFREE','DISKUSAGELEVEL','STORAGESIZE','OBJECTSTORAGESIZE','CONTAINERSIZE','NSCLOGS','CERTEXP','HTTPSTATUS'
    '20220109','example.com','91.47%','2GB;14%','1.5T','165G','9.1GB','124M','2022-Sep-4','200'
    
### Add the script to crontab
Cronjob syntax:

```text
* * * * * command to be executed
- - - - -
| | | | |
| | | | ----- Day of week (0 - 7) (Sunday=0 or 7)
| | | ------- Month (1 - 12)
| | --------- Day of month (1 - 31)
| ----------- Hour (0 - 23)
------------- Minute (0 - 59)
```
As an example set cronjob run the script daily basis at 7:00 AM.
```text
crontab -e
```
```
0 7 * * * bash /home/ubuntu/nsc3-ops-tools-node-status.sh
```
Save changes on editor. Eg vim editor ```<esc>``` -button  and ```:wq!```

## Performance testing tools -> printout to csv format
Toolset for performance measuring purposes

### Prerequisites
#### edit script header with env specific parameters

	$ cd $HOME/nsc3
	$ nano nsc-perf-monitoring.sh
    
    ---- example
    OUTPUTLOCATION="/home/ubuntu/nsc3/logs"
	HOSTNAME="example.com"
    ---- example
    
#### Run script: 
	
	$ cd $HOME/nsc3
	$ ./nsc-perf-monitoring.sh
  
#### CSV file location: $HOME/nsc3/logs/nsc3-perftest-${HOSTNAME}-${DATE}.txt
#### Results as example:
```text
'DATE','TIME','NAME','CPU %','MEM usage','MEM limit','NET Inbound','NET Outbound','BLOCK Inbound','BLOCK Outbound','PIDS'
'20230226','11:37:29','nsc-recipe-face-comparison-service','0.14%','747.2MiB ',' 29.87GiB','89MB ',' 2.02MB','40.3MB ',' 94.2kB','10'
'20230226','11:37:29','nsc-recipe-object-detection-service','0.13%','98.01MiB ',' 29.87GiB','54.3GB ',' 29.6GB','42.6MB ',' 160kB','10'
'20230226','11:37:29','nsc-recipe-object-detection-service-onnx','0.16%','1.063GiB ',' 29.87GiB','29.5GB ',' 50.4GB','274MB ',' 0B','12'
'20230226','11:37:29','nsc-valor-tasker-service','0.10%','189.5MiB ',' 29.87GiB','40.4GB ',' 6.04GB','15.4MB ',' 4.1kB','72'
'20230226','11:37:29','nsc-valor-bus','0.28%','62.19MiB ',' 29.87GiB','3.71GB ',' 4.04GB','84.9MB ',' 1.06GB','33'
'20230226','11:37:29','valor-postgres','0.00%','34.76MiB ',' 29.87GiB','1.65GB ',' 2.62GB','17.1MB ',' 119MB','10'
'20230226','11:37:29','nsc-webrtc-proxy','2.22%','89.71MiB ',' 29.87GiB','2.45GB ',' 228MB','272MB ',' 115kB','39'
'20230226','11:37:29','nsc-network-stream-service','0.06%','144.4MiB ',' 4GiB','5.8GB ',' 42GB','354MB ',' 4.1kB','46'
'20230226','11:37:29','nsc-aar-worker','0.10%','599.8MiB ',' 29.87GiB','8.36GB ',' 8.89GB','8.2GB ',' 13.5GB','48'
'20230226','11:37:29','nsc-gateway','0.31%','73.34MiB ',' 29.87GiB','210GB ',' 207GB','10.2MB ',' 11.2MB','2'
'20230226','11:37:29','map-service','0.01%','72.98MiB ',' 29.87GiB','1.84MB ',' 19.8MB','106MB ',' 12.3kB','16'
'20230226','11:37:29','rtmp-server','0.01%','5.168MiB ',' 29.87GiB','654kB ',' 37.4kB','2.7MB ',' 8.19kB','6'
'20230226','11:37:29','web-nginx','0.00%','6.215MiB ',' 29.87GiB','6.29MB ',' 613MB','25.2MB ',' 12.3kB','5'
'20230226','11:37:29','nsc-stream-in-service','0.48%','713.2MiB ',' 29.87GiB','163GB ',' 316GB','42.6MB ',' 4.1kB','2171'
'20230226','11:37:29','nsc-playback-service','0.04%','250.8MiB ',' 29.87GiB','8.77GB ',' 4.83GB','38.3MB ',' 4.1kB','68'
'20230226','11:37:29','nsc-live-service','0.04%','184.1MiB ',' 29.87GiB','28.4GB ',' 28.9GB','18.9MB ',' 4.1kB','89'
'20230226','11:37:29','nsc-auth-service','0.03%','175.6MiB ',' 29.87GiB','19.4MB ',' 8.03MB','14.8MB ',' 4.1kB','39'
'20230226','11:37:29','nsc-comms-service','2.75%','340.9MiB ',' 29.87GiB','27.5GB ',' 17.6GB','57.7MB ',' 12.9MB','117'
'20230226','11:37:29','nsc-notify-service','0.05%','135.6MiB ',' 29.87GiB','1.19GB ',' 328MB','4.51MB ',' 4.1kB','47'
'20230226','11:37:29','nsc-scheduler-service','0.15%','222.2MiB ',' 29.87GiB','570GB ',' 2.07GB','1.92GB ',' 32MB','73'
'20230226','11:37:29','nsc-minio','4.52%','11.36GiB ',' 29.87GiB','165GB ',' 595GB','14.3TB ',' 279GB','113'
'20230226','11:37:29','user-postgres','0.08%','34.8MiB ',' 29.87GiB','286MB ',' 553MB','13.8MB ',' 1.24GB','17'
'20230226','11:37:29','main-postgres','0.25%','347.6MiB ',' 29.87GiB','6.04GB ',' 19.6GB','667MB ',' 32.3GB','75'
'20230226','11:37:29','bus-redis','0.14%','10.03MiB ',' 29.87GiB','159GB ',' 72.2GB','23.7MB ',' 13.7GB','5'
'20230226','11:37:29','system','13.82 %','6 GB','29 GB'
```
### Add the script to crontab
Cronjob syntax:

```text
* * * * * command to be executed
- - - - -
| | | | |
| | | | ----- Day of week (0 - 7) (Sunday=0 or 7)
| | | ------- Month (1 - 12)
| | --------- Day of month (1 - 31)
| ----------- Hour (0 - 23)
------------- Minute (0 - 59)
``` scrip
As an example set cronjob run the script daily basis at 1:00 AM.
```text
crontab -e
```
```text
0 1 * * * bash /home/ubuntu/nsc-perf-monitoring.sh
```
## nsc-device-status.sh: Device status list 

Designed for NSC maintance purposes for an admin user group.
Typically admin persons do not have access for content itself via NSC3 Web app.
However for troubleshooting purposes it is important to get access for information about status of devices and activities.

### Prerequisites
This script do not require any parameters. It is based on linux CLI script. The script do not contain any sudo privileges inside of script. If needed please use sudo when run the script. 

#### Set execute permission for script

```text
chmod u+x nsc-device-status.sh
```

### Usage
Run script

```text
sudo ./nsc-device-status.sh
```

### Expected result
```text
'OrgName','OrgID','DeviceName','DeviceID','Connected','LastBroadCast'
'ABC','G7AG3VNpYMQipqluNsN9tcnudeMkw-GK6Kuy','<no-name>','be7f7c424ffec21b','false','2023-02-23 16:25'
'ABC','G7AG3VNpYMQipqluNsN9tcnudeMkw-GK6Kuy','PasinPuhelin','2ea1f7e71a3b1d14','<no-connection-status>','2023-02-23 16:25'
'ABC','G7AG3VNpYMQipqluNsN9tcnudeMkw-GK6Kuy','SierraXray','5aedf4cb0b7b38a3','<no-connection-status>','2023-02-23 16:25'
'ABC','G7AG3VNpYMQipqluNsN9tcnudeMkw-GK6Kuy','Tommi S22','5103f2a5115fcd43','false','2023-02-23 16:25'

```

## nsc3-license-expiration.sh: NSC3 server license expiration

Designed for monitoring NSC3 server license expiration. Prints days until license expiry.

### Prerequisites
This script do not require any parameters. It is based on linux CLI script. The script do not contain any sudo privileges inside of script. If needed please use sudo when run the script. 

#### Set execute permission for script

```text
chmod u+x nsc3-license-expiration.sh
```

### Usage
Run script

```text
sudo ./nsc3-license-expiration.sh
```

### Expected result
```text
2188
```

## nsc3-org-license-expirations.sh: License expiration for every organization

Designed for monitoring NSC3 organization's license expiration. Prints days until license expiry for every organization in the NSC3 instance. Output is in csv format

### Prerequisites
This script do not require any parameters. It is based on linux CLI script. The script do not contain any sudo privileges inside of script. If needed please use sudo when run the script. 

#### Set execute permission for script

```text
chmod u+x nsc3-org-license-expirations.sh
```

### Usage
Run script

```text
sudo ./nsc3-org-license-expirations.sh
```

### Expected result
```text
'OrgName','DaysToExpiry'
'OPS','363'
'Modirum','1814'
'Test','2'
```

# NSC3 Team-Bridge Service

Release tag: `release-3.15`

## Team-Bridge Service description:

NSC3 Team-Bridge Service is designed to broadcast live-stream between independent NSC3 servers. Team-Bridge enables communication pipe with specified NSC3 organisations. Pipes can be one-directional or bi-directional. Communication protocol can be TCP or UDP. TCP pipe is encrypted.

In order to avoid overlapping with device indentifications the original device identifications at source organisation is renamed at destination organisation. Team-Bridge is designed to syncronize live-stream data from devices, exclusing users identified data and storaged data content. 

### One-Directional pipe:

One-Directional pipe contains two elements, client and server. Dataflow point of view the client node is defining source organisation and the server node is defining the source/destination organisation. 

Pre-requisites for installation:
- 2 x NSC3 servers installed
- admin credentials for NSC3
- IP address for both servers
- Organisation ID for source and destination NSC3 organisations -> Org ID is visible via NSC3 Admin panel
- Team-Bridge specific port 64660 open for Team-Bridge server

### Bi-Directional pipe:

Bi-Directional pipe combines both elements client and server that need to installed at both end. Dataflow point of view it is similar as in case of One-Directional link but along two pipes outbound and inbound directions. 

In order to get this concept working accordingly, Bi-Directional pipe requires two organizations that need to be created on both servers. Inside of NSC3 server those two independent organisations can be link together by JointOps tasks. Note that Joint Operations functionality in NSC3 requires dedicated license.

Pre-requisites for installation:
- 2 x NSC3 servers installed
- admin credentials for NSC3
- IP address for both servers
- 2 x NSC3 organisations defined at both server
- Organisation ID for source and destination NSC3 organisations for both directions -> Org ID is visible via NSC3 Admin panel
- Team-Bridge specific port 64660 is open for both servers

## Setting up Team-Bridge One-Directional link:

### Reference dataflow with example values.

![One-Directional-link](https://github.com/NSION/nsc3/blob/team-bridge-dev/One-directional-TB-link.png)

### Team-Bridge One-Directional link - Client:

Login to Client node:

``` bash
cd $HOME/nsc3
sudo chmod u-x *.sh
git pull
sudo chmod u-x *.sh
sudo ./team-bridge-install.sh
```

Installation with reference example values:

```properties
++++++++++++++++++++++++++++++++++++++++
                                        
  NSC3 Team-Bridge installer:           
  This script prepares NSC3 config      
                                        
++++++++++++++++++++++++++++++++++++++++
NSC3 installation folder, e.g /home/ubuntu/nsc3: /home/ubuntu/nsc3
TCP or UDP Protocol ?: UDP
Role (client, server or both) ?: client
Local Team-Bridge node IP address: 192.168.10.12
Other end Team-Bridge server IP address: 192.168.10.13
Local source organisation ID: L5JXk6d18KtyeuZfhKtLuerJeJtEnEYRGTfX
```

### Team-Bridge One-Directional link - Server:

Login to Server node:

``` bash
cd $HOME/nsc3
sudo chmod u-x *.sh
git pull
sudo chmod u-x *.sh
sudo ./team-bridge-install.sh
```

Installation with reference example values:

```properties
++++++++++++++++++++++++++++++++++++++++
                                        
  NSC3 Team-Bridge installer:           
  This script prepares NSC3 config      
                                        
++++++++++++++++++++++++++++++++++++++++
NSC3 installation folder, e.g /home/ubuntu/nsc3: /home/ubuntu/nsc3
TCP or UDP Protocol ?: UDP
Role (client, server or both) ?: server
Local Team-Bridge node IP address: 192.168.10.13
Other end source organisation ID: L5JXk6d18KtyeuZfhKtLuerJeJtEnEYRGTfX
Local target organisation ID: kqkYDd2Ofv04eFBg-G7xmPIO9IjGMcx_VcEJ
```

## Setting up Team-Bridge Bi-Directional link:

### Reference dataflow with example values.

![Bi-Directional-link](https://github.com/NSION/nsc3/blob/team-bridge-dev/Bi-directional-TB-link.png)

### Team-Bridge Bi-Directional link - Server1:

Login to Server1:

``` bash
cd $HOME/nsc3
sudo chmod u-x *.sh
git pull
sudo chmod u-x *.sh
sudo ./team-bridge-install.sh
```

Installation with reference example values:

```properties
++++++++++++++++++++++++++++++++++++++++
                                        
  NSC3 Team-Bridge installer:           
  This script prepares NSC3 config      
                                        
++++++++++++++++++++++++++++++++++++++++
NSC3 installation folder, e.g /home/ubuntu/nsc3: /home/ubuntu/nsc3
TCP or UDP Protocol ?: UDP
Role (client, server or both) ?: both
Client - other end Team-Bridge server IP address: 192.168.10.13
Client - Local source organisation ID: L5JXk6d18KtyeuZfhKtLuerJeJtEnEYRGTfX
Server - Local Team-Bridge server IP address: 192.168.10.12
Server - other end source organisation ID: bMHZxI3Ke5QEaNqx7qFtuQUHTTNszYgNDEcK
Server - Local target organisation ID: 57NK1bbudRW_b1fgzJztNzVLcbSvR2zHkqBU
```

### Team-Bridge Bi-Directional link - Server2:

Login to Server2:

``` bash
cd $HOME/nsc3
sudo chmod u-x *.sh
git pull
sudo chmod u-x *.sh
sudo ./team-bridge-install.sh
```

Installation with reference example values:
 
```properties
++++++++++++++++++++++++++++++++++++++++
                                        
  NSC3 Team-Bridge installer:           
  This script prepares NSC3 config      
                                        
++++++++++++++++++++++++++++++++++++++++
NSC3 installation folder, e.g /home/ubuntu/nsc3: /home/ubuntu/nsc3
TCP or UDP Protocol ?: UDP
Role (client, server or both) ?: both
Client - other end Team-Bridge server IP address: 192.168.10.12
Client - Local source organisation ID: bMHZxI3Ke5QEaNqx7qFtuQUHTTNszYgNDEcK
Server - Local Team-Bridge server IP address: 192.168.10.13
Server - other end source organisation ID: L5JXk6d18KtyeuZfhKtLuerJeJtEnEYRGTfX
Server - Local target organisation ID: kqkYDd2Ofv04eFBg-G7xmPIO9IjGMcx_VcEJ
```
## TCP key-pairs:

TCP key-pairing is mandatory part of TCP protocol based dataflow pipes to enable encrypted data pipes.
Installation process will take case of TCP key-pair creation.
It is mandatory manual step to do in order to ensure that server side and client side is paired accordingly.
Copy the keypair file bundle directory only once from the server where the bundle is created in the first place to other end server. Installation process will remind that separately. Installation process won't overwrite existing key-pairs if files are existing at specified location.

After first TCP mode installation the key-pair bundle is located to folder:

``` bash
$HOME/nsc3/bridgekeys
```

Copy them to corresponding folder on other end server.
e.g with scp command

``` bash
scp -r $HOME/nsc3/bridgekeys <username>@<server2>:./nsc3/.
```

Key-pairs can be generated separately by command
``` bash
generateTeamBridgeRSAKeyPairs.sh
```

## Troubleshooting UDP

To test if the server is running and can be connected to, linux command line utility `netcat` can be
used to write something into it.

``` bash
sudo netcat localhost 64660 -u
```

Type something into the terminal, press enter to send and observe server container logs from another
terminal with `docker logs -f nsc-team-bridge-service`. A protobuf exception should get logged as the
plain text message is unexpected format.

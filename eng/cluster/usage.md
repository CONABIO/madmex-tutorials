#This documentation shows the use of the madmex system in a cluster version

A docker installation in your system is crucial: https://www.docker.com/

In this version of madmex we use sun grid engine an "open-source grid computing cluster software system for distributed resource management and job distribution". Responsible for scheduling, dispatching and managing jobs.

We will consider four nodes:



- Master node that will have the sun grid engine master service in a docker container.
- Two processing nodes that will have a container of docker in charge of execution of processes and the client of the service master of sun grid engine.
- Database node.


Specifications for nodes:

##Master node: *
* 2-4 cores
* Minimum 4 gb de RAM
* A volume or partition with an ext4 file system format with a minimum capacity of 500 Gb - 1Tb.


##Processing nodes: *
* Minimum 8 cores
* Minimum 20-32 Gb RAM
* A partition or volume with capacity of at least 500gb - 1tb
* A volume or partition with an ext4 file system format with a minimum capacity of 100GB .


## Database node: *
* Minimum 1 core
* Minimum 8-16 gb de RAM
* A volume with a capacity of at least 20 gb

*NOTES:*

- Between the processing nodes and the master node we will mount a shared folder using the mentioned volume or partition with capacity of 500gb - 1tb and a directory tree will be made to store the images, as well as other uses.

- In every processing node we will mount a folder "temporal_madmex" in the volume or partition mentioned capacity of 100 gb in which we will store process results.

*These capacity requirements in the partitions or volumes vary for the use case.

##Database

###Configuring postgresSQL server

Run the following command after cloning this repository into the "eng/madmex_database_command" folder on the node for the database:

```
$docker run --name postgres-server-madmex -v $(pwd):/results -p 32852:22 -p 32851:5432 -dt madmex/postgres-server
```

###Creating madmex database

-Requirements:

	*IP address of the container in which the postgres server is raised. To know the IP we execute:

```
$docker inspect postgres-server-madmex|grep IPA

```

The IPAddress is the one we are looking for.

-Example: 

	* We assume that the IP address of the container is 172.17.0.2.

Run the following command:

```
$docker exec -u=postgres -it postgres-server-madmex /bin/bash /results/madmex_database_install.sh 172.17.0.2 5432
```

## Shared folder by all nodes via nfs:

The following assumes an nfs server on a ubuntu system version 14.04 and a folder with name /share_folder.
To install the nfs server on master node, run:

```
$sudo apt-get install nfs-kernel-server
```

On the processing nodes run:

```
$sudo apt-get install nfs-common
```

In the master node we configure the file "/etc/exports" with the following inputs:

	/share_folder ip_processing_node1(rw, sync, no_subtree_check, no_root_squash)
	/share_folder ip_processing_node2(rw, sync, no_subtree_check, no_root_squash)

We execute:

```
$sudo exportfs -ar
```

In the processing nodes we create the folder named /share_folder. 

Add the following line in the file /etc/fstab:

	ip_master_node:/share_folder /share_folder nfs default 0 0

 And then run the line:

```
$sudo mount -a
```
##Sun grid engine master service configuration

On the master node run the following command:

```
$docker run --name master-sge-container -h $(hostname -f) -v /carpeta_compartida:/LUSTRE/MADMEX -p 6444:6444 \ 
-p 2224:22 -p 8083:80 -p 6445:6445 -dt madmex/sge_dependencies /bin/bash

```

Enter the docker container that we just started with the previous command by executing the following line:
```
$docker exec -it master-sge-container /bin/bash

```

Inside the docker execute the following commands, in these commands we assume that the hostname of the master node is "nodomaestro":

```
$root@nodomaestro:/# service apache2 start

$root@nodomaestro:/# service ssh restart

$root@nodomaestro:/#apt-get install -y gridengine-client gridengine-exec gridengine-master

```

The last command will take us to a series of configurations for the sun grid engine master service. Select the defaults and in the screen where asking for "SGE master hostname" write "nodomaestro".

Restart sun grid engine master service:

```
$root@nodomaestro:/# /etc/init.d/gridengine-master restart

```

When executing the following command there should be no errors:

```
$root@nodomaestro:/# qhost

```

Configure the nodomaestro as submit host:

```
$root@nodomaestro:/# qconf -as nodomaestro
```

Create the group @allhost:

```
$root@nodomaestro:/# qconf -ahgrp @allhosts
```
Do not modify anything in this file, type ESC and then: x!

Create the queue miqueue.q:

```
$root@nodomaestro:/# qconf -aq miqueue.q

```
Do not modify anything in this file, type ESC and then: x!

Add the @allhosts group to the queue:

```
$root@nodomaestro:/# qconf -aattr queue hostlist @allhosts miqueue.q

```

Configure the number of cores to be used by processing nodes, for example 2:

```
$root@nodomaestro:/# qconf -aattr queue slots "2" miqueue.q
```

Exit the docker to complete the sun grid engine master service configuration:

```
$root@nodomaestro:/# exit

```

Now we can view in a browser the page: nodomaestro: 8083 / qstat which is a web service for "queue monitoring of sun grid engine"



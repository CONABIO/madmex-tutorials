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



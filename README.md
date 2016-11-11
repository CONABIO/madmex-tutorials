# madmex-tutorial

MAD-MEX (Monitoring Activity Data for the Mexican REDD+ program) is a system to provide standardized annual wall-to-wall land cover information by automatic image classification for the Mexican territory in a cost-beneficial manner.  It is one aim of the system to automatically produce a national land cover dataset in a standardized, transparent and transferable way to ensure operative activity data monitoring.


Repository to contain information and tutorials about the requirements to install and use the MAD-Mex system. The folder "es" contains the documentation in spanish about how to install the system in two different ways:

1) cluster
2) standalone

The first one is the deployment over a cluster of computers. It uses Sun Grid Engine, a job scheduler designed to optimize the use of computational resources or distributed processes in heterogeneous environments in order to use the resources in the most efficient way. In this type of architectures, SGE accepts, schedules and dispaches remote jobs, these jobs can be sequential, parallel or interactive.

The system can also be installed in standalone mode. This version uses a single machine in offline mode. This means the system does not need to be connected to a network.

In the database MAD-Mex commands directory there is shell scropt that will install and configure the database used by the system. This step plays a main role in order to for the sytem to work correctly. The whole functionality relies on a correct configuration of the database, without it it will not be possible to run the different commands to ingest, classify and detect changes.

We suggest that before installing and running any command, to get through the documentation in order to understand what does the system does and does not.

The MAD-Mex team.

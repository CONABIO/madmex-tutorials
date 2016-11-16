##Base de datos

###Levantamiento del servidor de postgres

Ejecutar el siguiente comando después de clonar este repositorio dentro de la carpeta "es/comandos_base_de_datos_madmex" de manera local:

```
$docker run --name postgres-server-madmex -v $(pwd):/results -p 32852:22 -p 32851:5432 -dt madmex/postgres-server
```

###Creación de la base de datos madmex

-Requerimientos:

	*Dirección IP del host en el que está levantado el servidor de postgres
	*shells de creación de base de datos, ir a la carpeta comandos_base_de_datos_madmex de este repositorio
	*shell madmex_database_install.sh que debe tener permisos de ejecución, ir a comandos.md de este repositorio

-Ejemplo: 

	*Dirección IP del host: 192.168.99.100

```
$docker exec -u=postgres -it postgres-server-madmex /bin/bash /results/madmex_database_install.sh 192.168.99.100 32851
```

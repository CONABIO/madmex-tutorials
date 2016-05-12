#Documentación Técnica del Sistema MAD-Mex

##Arquitectura del Sistema

El sistema está diseñado para poder ser instalado de dos formas:

* cluster: Los componentes se instalan en un conjunto de computadoras que forman un cluster. Uno de los nodos se encarga de distribuir trabajos a los nodos esclavo. Está es la forma más eficiente de uso cuando se cuentan con los recursos necesarios.

* standalone: El sistema en su totalidad se instala en un solo mainframe, este será encargado de hacer todo el procesamiento. Es poco recomendable cuando existen restricciones de tiempo para la obtención de los productos.

A continuación se muestra un diagrama que representa la arquitectura del sistema en modo de cluster:


![Diagrama de componentes de MAD-Mex](../images/component_diagram.png)

##Requerimientos del Sistema en Modo Cluster

Para el correcto funcionamiento del sistema, un conjunto de requerimientos mínimos es necesario. A continuación se ofrece una breve descripción.

###Hardware Nodo Maestro
- mínimo: 2-4 vCPUs
- mínimo: 4GB RAM
- 50GB Memory
- ssh: 22/tcp

###Hardware Nodo Esclavo
- mínimo: 16 vCPUs
- mínimo: 64GB RAM
- memoria: 50GB
- ssh: 22/tcp


###Sofware

####Docker

El sistema MAD-Mex hace uso de contenedores Docker para virtualizar ambientes y hacerlos disponibles en las distintas plataformas sin las dificultades usuales. Algunos de los procesos dentro de MAD-Mex solo pueden ser ejecutados en sistemas operativos específicos. Con el fin de no requerir que los usuarios cuenten con dichas distribuciones, esos procesos corren dentro de los contenedores Docker. Esta guia no prende enseñar al usuario el uso y desarrollo de dichos contenedores, para una guia de como instalar y usar Docker, se pueden consultar las siguientes ligas:

- [Instalación](https://docs.docker.com/engine/installation/)
- [Uso](https://docs.docker.com/mac/)

Al instalar Docker via Docker Toolbox, se instalará automáticamente una máquina virtual VirtualBox, en ella correran los contenedores.

####Geospatial Data Abstraction Library (GDAL)

La librería GDAL es necesaria para el uso y manipulación de imagenes geoespaciales en distintos formatos. La instalación de GDAL es un prerequisito para varios sistemas de información geográfica. Para el caso específico de MAD-Mex es necesario instalar, además, los bindings para hacer uso de GDAL desde al ambiente Python. A continuación las ligas necesarias:

- [Instalación](https://trac.osgeo.org/gdal/wiki/DownloadingGdalBinaries)
- [Instalación de bindings de Python](https://pypi.python.org/pypi/GDAL/)

####PostgreSQL

PostgreSQL es el motor de base de datos que el sistema MAD-Mex usa para guardar referencia de los archivos y productos que han sido ingestados en el sistema. Adicionalmente se usa una extensión de PostgreSQL llamada PosGIS para poder hacer consultas espaciales sobre la información. Para instalar estas dependencias:

- [Instalación PostgreSQL](http://www.postgresql.org/download/)
- [Instalación PosGIS](http://postgis.net/install/)

Para poder visualizar la información de la base de datos de una manera sencilla, se recomienda la instalación de un cliente para la base de datos. DbVisualizer es la opción recomendada:

- [Instalación DbVisualizer](https://www.dbvis.com/download/)

####QGIS

El sistema MAD-Mex produce imagenes multi banda de alta resolución. Estás imágenes no pueden ser visualizadas por métodos tradicionales. Para hacer uso de las mismas, se recomienda la instalación del sistema de información geográfica QGIS. Al igual que con los requisitos anteriores, el aprendizaje sobre el uso del sistema queda como ejercicio para el lector:

- [Instalación QGIS](http://www.qgis.org/en/site/forusers/download.html)









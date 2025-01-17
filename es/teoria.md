#Teoría del Sistema MAD-Mex

##Cobertura de Suelo

Existen [conceptos importantes](http://www.biodiversidad.gob.mx/pais/cobertura_suelo/glosario.html) como el de cobertura de suelo, el cual hace referencia a la morfologia de la superficie y describe el material físico de la Tierra considerando también la actividad humana. La definición relaciona estrechamente las clases de cobertura con sus características físicas. Las clases son discernibles con relativa facilidad mediante mediciones de sensores remotos, los cuales registran la respuesta espectral de los diferentes tipos de superficies. Algunos ejemplos de clases de cobertura de suelo son; bosque, cuerpos de agua y suelos desnudos, los cuales además son comúnmente subdivididos, e.g. en bosque de coníferas y latifoliadas o perennifolio y caducifolio. 

##Clasificación de Cobertura de Suelo

El Sistema de clasificación de cobertura de suelo ([LCCS](http://www.fao.org/docrep/003/x0596e/x0596e00.HTM)) fue desarrollado por la Organización para la Alimentación y la Agricultura (FAO) de las Naciones Unidas. Es un esfuerzo de descripción de clases de cobertura de suelo de un modo estandarizado que se divide en dos fases: dicotómica y jerárquica-modular. El sistema facilita la interpretación de la leyenda y armonización de cartografía.
La clasificación es una representación abstracta de la situación real en campo utilizando
criterios de diagnóstico bien definidos llamados clasificadores. Se definen según Sokal (1974), como "el arreglo u ordenamiento de objetos en grupos o conjuntos sobre la base de sus relaciones". Una clasificación describe el esquema sistemático con los nombres de las clases y los criterios utilizados para distinguirlos, y la relación entre clases. Por lo que la clasificación requiere la definición de limites de clase, los cuales deben ser claros, precisos, en lo posible cuantitativos, y basados en criterios objetivos.

##Detección de Cambios en Clasificación de Cobertura de Suelo

La detección de cambios consiste en identificar diferencias en el estado de una característica o fenómeno por observaciones que se hacen en diferentes épocas. La detección de cambios en el sistema MADMex está basada en la comparación bitemporal de imágenes, tanto para los periodos de referencia en el procesamiento Landsat como para el procesamiento anual de RapidEye. La detección de cambios bitemporal se realiza mediante el algoritmo iMAD (Multivariate Alteration Detection transformation) y un postprocesamiento basado en el algoritmo MAF (Maximum Autocorrelation Factor transformation).

## Flujo de trabajo del proceso de clasificación (LANDSAT)

![Flujo de trabajo MAD-Mex](../images/work_flow.png)


##Transformada MAD

La transformación (MAD, Multivariate Alteration Detection) esta basada en un análisis multivariante que establece la correlación canónica de los cambios entre las bandas. Este esquema transforma dos series de observaciones multivariantes en una diferencia entre dos combinaciones lineales de las varibales originales, estas diferencias cuantifican el cambio máximo en todas las variables simultáneamente. 
La transformación MAD es invariante a escala lineal y puede ser usada de forma iterativa. En primera instancia, se puede utilizar para detectar valores atípicos o el ruido y en una segunda iteración, se puede utilizar para realizar la detección de cambio real después de la acción apropiada en los valores atípicos o de ruido.
Debido a su capacidad para detectar cambios en los canales de manera simultánea, la transformación y el post-procesamiento MAD/MAF es aún más útil cuando se aplica a un mayor número de bandas en las que se aprecien los cambios.

##Transformada MAF

A fin de mejorar la coherencia espacial de los componentes de cambio, se aplica la transformada MAF (Maximum Autocorrelation Factor) a los componentes MAD. Suponiendo que el ruido de la imagen se calcula como la diferencia entre las intensidades de los píxeles vecinos, la transformada MAF es equivalente a una transformación de fracción de ruido mínimo (MNF), lo que genera componentes de imágenes con una relación señal a ruido máxima. También la transformación MAF es invariante a escala lineal.  

## Algortimo fmask

El algoritmo fmask relaciona las nubes con sus sombras basado en mediciones de similitud. Este algoritmo itera desde una altura mínima posible hasta una altura máxima y calcula la similitud entre la nube y la sombra de la nube, esto lo hace para nubes a diferentes alturas. En el algoritmo original fmask, la prueba de altura de las nubes continúa si la similitud continua incrementando o no disminuye por debajo del 98% de la similitud máxima medida; de lo contrario, la búsqueda de altura de nubes se detiene y la sombra de nube se asocia a la máxima similitud. Sin embargo, a veces la iteración puede parar antes de lo que debería, como por ejemplo que la similitud no alcance su valor máximo; este puede deberse a que existan máximos locales que son 2% más grandes que la similitud medida para la altura de las nubes vecinas. En el algoritmo fMask mejorado, la relación entre la sombra de nube y la nube, no se detendrá a menos que el valor de similitud se reduzca al 95% del valor máximo de similitud.
























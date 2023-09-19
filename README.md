# Unidad de Conteo de Coincidencias

La unidad de conteo de coincidencias (UCC) nace como solución a la necesidad instrumental del Laboratorio de Óptica Cuántica de la Universidad de Antioquia de tener un sistema que les permitiera estudiar sistemas fotónicos de baja intensidad (fotones individuales). A su vez, la UCC representa una aplicación directa del sistema de adquisición de datos general que se desarrolló con base en la integración de las tecnologías que combinan FPGA y microprocesadores en la [tesis de pregrado][manuscript] de uno de los estudiantes ([Daniel Estrada][author]) del Grupo de investigación (GICM). 

En este repositorio podrá encontrar la información más relevante del sistema, asi como los códigos fuentes para reproducirlo. 

>**CONTRIBUCIONES Y REPORTE DE PROBLEMAS**
>
>Las contribuciones a este proyecto son siempre bienvenidas, pero, para tratar de preservar la integridad del repositorio y evitar fallos, por favor seguir las pautas para publicar aportaciones, las cuales se indican en el apartado ["CONTRIBUTING"][contributors]. Si encuentra algún problema dentro del proyecto puede reportarlo abriendo un "issue" de acuerdo con los lineamientos del mismo apartado.

#### Tabla de contenidos
1. [¿Qué se entiende por conteo de coincidencias?](#coincidencia)
2. [¿Por qué utilizar esta versión?](#porqué?)

### <a name="coincidencia"></a> ¿Qué se entiende por conteo de coincidencias?
En palabras simples, cuando se habla de un módulo o sistema de conteo de coincidencias se hace referencia a un sistema que recibe un conjunto de señales eléctricas provenientes, usualmente, de algún tipo de detector de eventos y realiza un conteo de la detección simultanea de un par o más de estas señales. Lo cual resulta crucial en procesos de experimentación en física. 

La simultaneidad mencionada es un término que se debe usar con cuidado, ya que no hay que pasar por alto ciertos detalles inherentes a las limitaciones tanto electrónicas como físicas de los dispositivos a usar (resolución temporal de los detectores y de la electrónica de adquisición). En el siguiente esquema se ilustra una situación en donde la primera coincidencia registrada (D12), la del evento E1, si corresponde con una detección simultanea por parte de ambos detectores, y por el contrario, no es el caso para los eventos E2
y E3. Todo esto como consecuencia de los tiempos de relajación intrínseco del semiconductor del cual este fabricado el detector y de los intervalos de tiempo que se usen como ventana de tiempo de análisis (TWC).

<p align="center">
  <image src="img/coincidencias_concepto.jpg" alt="Descripción de la imagen" width="500x" justify="center"/>
</p>

Más detalles pueden ser consultados en el capítulo 3 de la [tesis][manuscript] mencionada. 

### <a name="porqué?"></a> ¿Por qué utilizar esta versión?

Como se mencionó al comienzo, el desarrollo del proyecto está enmarcado en una necesidad del grupo de Óptica Cuántica. Ellos ya contaban con un sistema de conteo funcional basado en FPGA que fue diseñado e implementado mediante una tarjeta [Nexys 4 DDR][nexys4] (ver [`old``](old)), una versión que integra varios periféricos con una FPGA de la familia Xilinx, la cual, trabaja a 100 MHz para hacer los conteos de coincidencias en un número controlable de ventajas de análisis de tamaño también configurable. 

Aunque dicha versión es funcional, el diseño se queda corto en eficiencia. Allí la toma de datos y la extracción de la información son **procesos que se realizan de forma secuencial**, y por tanto, que relentiza las demás tareas. Suponga que un usuario pretende analizar cinco ventanas de conteo de 10 ns, idealmente esto sería un proceso que tomaría un poco más de 50 ns y al final se podría tener las cuentas de las coincidencias para cada ventana, sin embargo, en este diseño se invierten poco más de 10 ms, ya que luego de desencadenar cada ventana de conteo se debe ejecutar el proceso de extracción de las cuentas a través del protocolo serial, **retrasando la ventana siguiente significativamente**.

<p align="center">
  <image src="img/old-system-delay.png" alt="Descripción de la imagen" width="500x" justify="center"/>
</p>

En contra parte, el nuevo diseño para el sistema (ver [`new`](new)) se basa en la tarjeta [Arty-Z7][arty] (u otra equivalente, la tarjeta [PYNQ][pynq]). Dispositivos que, además de integrar periféricos con una FPGA de la familia Xilinx, incluyen un procesador AMD. Está característica diferencial hace de esta nueva generación de tarjetas una gran alternativa, ya que permiten incluso instalar pequeños sistemas operativos dedicados, que soportan programación en Python para implementar sistemas más fáciles de controlar.

El nuevo diseño aprovecha sus características para implementar de forma más sencilla la interacción con el usuario, además de integrar las memorias FIFOs de la tarjeta para optimizar la trasferencia de las cuentas medidas entre ventanas, mitigando de esta forma el principal problema de su predecesor, los tiempos muertos entre ventanas. La característica más llamativa a nivel de usuario es la posibilidad de personalizar el proceso a través de entornos de programación en python, tal como lo es un Jupyter notebook. 

De nuevo, los detalles completos pueden consultarse en la mencionada [tesis][manuscript]. También puede ver la presentación de este proyecto que se hizo durante el [X Simposio de Ciencias Exactas y Naturales][simposio] (min 3:30:00 - 3:56:00) de la Universidad de Antioquia.


[![License: CC0-1.0](https://img.shields.io/badge/License-CC0_1.0-lightgrey.svg)](http://creativecommons.org/publicdomain/zero/1.0/)

[manuscript]: https://udeaeduco-my.sharepoint.com/:b:/g/personal/daniel_estrada1_udea_edu_co/EdM_h6KY1mpCmvMl5yqfjiEBALvJMZS2eBhwlgy3Vx6PTw?e=sJqXjP 
[author]: https://github.com/DanielEstrada971102
[contributors]: CONTRIBUTING.mb
[nexys4]: https://digilent.com/reference/programmable-logic/nexys-4-ddr/reference-manual
[arty]: https://digilent.com/reference/programmable-logic/arty-z7/start
[pynq]: http://www.pynq.io/
[simposio]: https://www.facebook.com/plugins/video.php?height=314&href=https%3A%2F%2Fwww.facebook.com%2Ffcenudea%2Fvideos%2F394431428642955%2F&show_text=false&width=560&t=12720


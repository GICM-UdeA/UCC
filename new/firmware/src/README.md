# Módulos de la UCC
El siguiente diagrama representa la interconexión entre los diferentes componentes del sistema. Se pueden resaltar los tres bloques más grandes que corresponden a: El bloque que instancia y habilita el uso del microprocesador en el sistema (PS_and_AXI_interconect), el módulo diseñado por los investigadores del MLAB en el ICTP ([ComBlock][comblock]) que intermedia y facilita la comunicación entre el el procesador (PS) y la FPGA (PL), y, el bloque que encapsula la unidad de conteto de coincidencias diseñado (UCC). Esta forma de establecer la comunicación representa una metodología para la implementación de sistemas de adquisición de forma sencilla y constiuye uno de los principales resultados ([Comblock PYNQ API][pynqApi]) de la tesis mencionada en el [apartado principal][readme] de este repositorio. 

<p align="center">
  <image src="../../img/systemUCC_v4.png" alt="Descripción de la imagen" width="500x" justify="center"/>
</p>

En lo que sigue, se describe de forma general los principales módulos que integran la UCC, donde la filosofía modular sigue manteniendose. 

#### Tabla de contenidos
1. [Adquisición y generación de señales](#señales)
2. [counter.vhd - Conteo de señales](#conteo)
3. [UCC_controler.vhd - módulo de control interno](#UCC)
4. [time_window.vhd - módulo de control de ventanas de análisis](#tw)
5. [counts_sender.vhd - módulo de envió del número de cuentas](#c_sender)
5. [Diagrama de bloques de la UCC](#bd_UCC)

### <a name="señales"></a> Adquisición y generación de señales
Dada la finalidad del sistema, el primer paso consiste en definir cómo identificar las coincidencias de las señales. En este caso particular, será de interes examinar las coincidencias de 3 señales provenientes de 3 detectores. Se requiere distinguir entre: coincidencias dobles (entre pares de señales, e.g., coincidencias de la señal 1 y la 2), y coincidencias triples (las tres señales a la vez). Con una inspección rápida a ["¿Qué se entiende por conteo de coincidencias?"][readme.1], usted podrá notar que la determinación de coincidencias entre un par o más señales puede ser estudiada a partir del análisis de la señal resultante al aplicar la operación logica AND entre las mismas. De esta forma, en el transito de la señales que provienen directamente de los detectores, el primer módulo que deben atravesar corresponde a un conjunto de compuertas logicas que producen las señales a analizar (ver figura).

<p align="center">
  <image src="../../img/signals_ands.png" alt="Descripción de la imagen" width="500x" justify="center"/>
</p>

### <a name="conteo"></a> counter.vhd - Conteo de señales
este módulo es contador personalizado que tiene 4 pines, 3 de entrada y 1 de salida (ver figura). Internamente se hace un registro de los flancos de subida que aparezcanla señal de entrada `signal_in` (solo si la
bandera `enb` está en alto), las cuentas registradas se sacan como un vector de 32 bits por la señal `number_counts`(número máximo de flancos que pueden contarse es $2^{32}$). La última entrada, corresponde a una bandera de reinicio de los contadores. Dado que se requiere contar tanto las detecciones individuales, como las dobles y triples. En el diseño final hay varias instacias de este módulo, encapsuladas en en bloque `counters`.

<p align="center">
  <image src="../../img/counter_mod.png" alt="Descripción de la imagen" width="500x" justify="center"/>
</p>

### <a name="UCC"></a> UCC_controler.vhd - módulo de control interno
De lo discutido en el apartado [¿por qué utilizar esta versión?][readme.2], es claro que algo fundamental en el sistema es cómo se controlan las ventanas de analsis de las señales y cómo se gestiona la trasmisión de los resultado. Intentando lograr el sistema más óptimo posible, la gestión de lo mencionado se delega a esté módulo interno. Desde el punto de vista del usuario, basta con configurar los parametros de análisis y controlar y monitorear las señales `Do_UCC_controler` y `Done_UCC_controler` respectivamente. 

La forma de operar de este módulo de control consiste en desencadenar cada ventana de análisis con rápidez (a tráves del módulo `time_window.vhd`) para evitar los tiempos muertos entre ventanas consecutivas, y aprovehcar el tiempo de conteo de cada ventana para almacenar la cuentas del análisis inmediatamente anterior en la memoria FIFO de la tarjeta (a través del módulo `counts_sender.vhd`). De está forma, no se invierte tiempo de procesamiento en el envío en tiempo real de la cuentas al usuario, sino que más bien se deján a su disposición para consultar hasta el final del proceso. Lograr un análisis ininterrumpido entre ventanas implicó agragar una condición de posprosamiento a los resultados obtenidos del sistema, ya que al optmizar el número de ciclos de reloj de procesamiento, se evita el reinicio de los contadores entre ventas, por lo tanto, se deja al usuario la responsabilidad de restar las cuentas de ventanas consecutivas si desea extraer la informaciónde  cada ventana individualmente.

### <a name="tw"></a> time_window.vhd - módulo de control de ventanas de análisis
El módulo `time_window` trabaja con 8 señales: las típicas `CLK` y `rst`; las dos banderas `Do` y `Done`
que marcan el inicio y el final del proceso (inicio y final de la ventana de tiempo grande); las dos señales `large_tw_counter_max` y `short_tw_counter_max` que se pasan desde el Comblock para establecer el intervalo grande y pequeño de tiempo respectivamente; y por último las dos señales más importantes, `large_tw_activate` y `send_data`. La primera de estas, es una señal que permanece en estado alto hasta que se verifique el cumplimiento del intervalo grande de tiempo, es decir, esta señal es la que habilita a los contadores para analizar la información que ingresa desde los detectores, y `send_data` es un pulso que se activa cuando el intervalo temporal determinado por la ventana pequeña se cumpla, este activa el proceso de envío de cuentas.

<p align="center">
  <image src="../../img/tw_mod_2.png" alt="Descripción de la imagen" width="500x" justify="center"/>
</p>

### <a name="c_sender"></a> counts_sender.vhd - módulo de envió del número de cuentas

Como se insinúo antes, uno de los puntos importantes que hace este sistema más óptimo es el uso de una Memoria FIFO para no invertir tiempo de procesamiento en sacar la información con un protocolo serial. Este módulo se encarga de gestionar el proceso de escritura de las cuentas en la memoria FIFO de forma secuencial. Se toma la información a almacenar desde un registro de entrada de 256 bits, los cuales, provienen directamente del módulo `packer.vhd` (es simplemente un concatenador de las cuentas que vienen de cada contador de coincidencias). Finalmente, el módulo para hacer la escritura en la memoria FIFO sitúa la información a almacenar en `data_out`, que es una conexión directa a la entrada `fifo_data_in` del Comblock, y habiendose asegurado de tener la escritura habilitada en este último (señal `fifo_we_i` en alto), genera un pulso en `fifo_clk_o`que se pasa a la entrada `fifo_clk_i` del Comblock.

<p align="center">
  <image src="../../img/counts_sender.jpg" alt="Descripción de la imagen" width="500x" justify="center"/>
</p>

> **Nota:**
> El módulo `packer.vhd` produce un paquete de 8 bytes que incluye, las cuentas de los pulsos de los 3 detectores, las 3 cuentas que corresponden a las coincidencias dobles entre detectores, y una cuenta más que corresponde a la coincidencia triple. El byte restante corresponde al carácter "@", este se incluye para facilitar la distinción entre las cuentas de diferentes ventanas a la hora de hacer el análisis. 

### <a name="bd_UCC"></a> Diagrama de bloques de la UCC
Combinando los módulos descritos, se crea el bloque que se mostró al inicio, el bloque UCC. La interconexión de los módulos queda de la siguiente forma: 

<p align="center">
  <image src="../../img/ucc_mod_v4.png" alt="Descripción de la imagen" width="800x" justify="center"/>
</p>

[comblock]: https://gitlab.com/rodrigomelo9/core-comblock
[pynqApi]: https://github.com/DanielEstrada971102/Comblock-PYNQ-API
[readme.1]: ../../README.md#coincidencia
[readme.2]: ../../README.md#porqué?
[readme]: ../../README.md
# UCC - versión Nexys 4 DDR
El sistema base del cual se comenzó a trabajar fue un diseño implementado por el profesor Johny Jaramillo, investigador asociado al grupo GICM. Su versión necesitaba ser actualizada para incluir el conteo de coincidencias triples y optimizar algunos procesos. El resultado de lo último, es el sistema que se presenta a continuación. 
## Guía para el usuario
La siguiente imagen indica los conectores e interruptores usados de la tarjeta. 
<p align="center">
  <image src="../img/old-card.png" alt="Descripción de la imagen" width="800x" justify="center"/>
</p>

1. El conector USB es de tipo Micro B 2.0, por acá se alimenta la energía de la tarjeta y se da la comunicación serial. 

2. La tarjeta no se energizará si no se coloca el interruptor en estado "ON".

3. La tarjeta solo trabajará si se le carga el programa adecuado. Este se quema automáticamente si este se encuentra dentro de la micro SD.

4. Aunque la tarjeta este encendida, el programa no responderá a las instrucciones enviadas a no ser de que el interruptor de enable este habilitado. Sabrá que lo está cuando vea encendido el LED indicador. 

5. LED indicador, se ilumina si el interruptor enable está habilitado. 

6. Si por alguna razón la tarjeta se traba y no responde a los comandos, puede regresarla a su estado inicial habilitando y luego volviendo a apagar el interruptor de Reset. 

7. Jumpers que configuran la forma de programar la tarjeta. Asegúrese de que estén en la posición "SD" y "USB/SD" respectivamente.

8. Conectores BNC: Los canales del A al C será por donde ingrese la señal de los fotodetectores, por lo tanto, está tarjeta solo soporta 3 detectores a la vez. El conector `COM4` se usa como salida de monitoreo, si conecta un osciloscopio allí podrá corroborar que cuando se active una ventana de análisis se emitirá por el mismo un pulso con la duración de la ventana.


Luego de conectar la tarjeta por medio de un cable micro USB B a la computadora e indentificar el puerto `COM` asignado por el sistema, siga los siguientes pasos para utilizar la UCC:

<p align="center">
  <image src="../img/old-interfaz.png" alt="Descripción de la imagen" width="800x" justify="center"/>
</p>

1. Una vez abra la interfaz gráfica "[UCC_interfaz.exe][exe]", la cual ya debe tener en su computador[^1], seleccione el puerto que corresponda. 

2. Oprima el botón de ejecución (➡️) para que la interfaz comience a trabajar. Si no ocurre ningún error de conexión con la tarjeta se marcara un ✔️ en el status.

3. Escoja la escala y el tiempo que quiere que tenga la ventana de análisis, luego oprima el botón "Config_Tiempo" y espere a que el indicador LED este en verde, al mismo tiempo, recibe un mensaje de confirmación en el panel de Lectura.

4. Configure cuantas ventanas de análisis desea ejecutar, y cuando este listo, oprima "INICIAR" para correr el análisis. Mientras la ventana de análisis esta activa el indicador LED dejara de alumbrar, y lo volverá a hacer hasta que la ventana haya terminado. 

   Al finalizar el análisis, las cuentas de la ventana se podrán visualizar en los paneles de la derecha. Respectivamente, podrá encontrar las cuentas de los contadores individuales y las cuentas de las coincidencias dobles y triples.

5. Si le interesa correr más de una ventana de análisis, es posible que quiera guardar el registro de las cuentas de cada ventana. Para ello, antes de oprimir "INICIAR", puede escoger un ruta a un archivo `.txt` en donde se escribirá el resultado y *time stamp* de cada ventana. Las cuentas se guardarán solo si proporciona una ruta valida y si el botón de guardar se habilita.  

6. Este botón debe dejarse oprimido en caso de que quiera guardar los resultados del análisis. 

7. En caso de que la interfaz se trabe o deje de responder por alguna razón puede tratar de reiniciarla oprimiendo el botón "FORCE STOP". Si este último también se encuentre bloqueado recurra al botón 🔴 de la parte superior, o simplemente cierre de forma forzada la interfaz. 

## Guía para el desarrollador
La siguiente es una representación esquemática del diseño del sistema. 

<p align="center">
  <image src="../img/old-system-design.jpeg" alt="Descripción de la imagen" width="800x" justify="center"/>
</p>

De la imagen destaca el diseño modular, en particular, las dos de mayor importancias son `Super_uart` (ver [código][super-uart]) y `CPU` (ver [código][cpu]). El primero define la interacción entre el usuario y el sistema a través de protocolo serial, y el segundo gestiona el sistema de acuerdo con los comandos recibidos por el primero.

El protocolo de comunicación serial implementado consiste en la recepción y transmisión de comandos de 14 bytes estructurados de la forma:
``` python
COMMAND + " "[El carácter espacio] + NUMBER + "#"
```
donde, `COMMAND` es un conjunto de 4 caracteres que indican la acción a realizar o la respuesta del sistema. Y `NUMBER` son 9 caracteres que indican la variable numérica que se le pasa o que entrega el sistema en caso de que corresponda. A continuación se listas los posibles comandos que se usan para interactuar con la tarjeta:

### Comandos de para probar el sistema

#### **`WTt1 000000000#`**

este comando desencadena una ventana de tiempo que por defecto se configura en 1 s. Puede verificar que efectivamente esto sucede conectando un osciloscopio a la salida `COM4`. Si el comando es recibido correctamente, el sistema responderá enviando el mensaje "`WTok#999999999`".

#### **`WTt2 [TIEMPO en ms]#`**

A diferencia del anterior comando, este nos permite configurar el tiempo de la ventana de análisis. Por lo tanto, es útil para comprobar que el sistema entiende bien los números que se está enviando. Si el comando es recibido correctamente, el sistema responderá enviando el mensaje "`WTok#999999999`", y al igual que antes, puede corroborar el tiempo de la ventana configurada usando la salida del `COM4`.

#### **`CON1 000000000#`**

Este permite corroborar que los contadores internos funcionan adecuadamente. Cuando el sistema recibe esta instrucción, ejecuta una ventana de análisis de 1 s activando los contadores, luego, retorna el número de pulsos que contó en el contador número 1. Puede conectar a `COM1` una señal conocida para contrastar con el resultado que arroje el sistema. Si el comando es recibido correctamente, el sistema responderá enviando el mensaje "`C1ok#[NUMERO DE CUENTAS]`" luego de terminar la ventana de análisis.

### Comandos de para configurar y ejecutar análisis

#### **`TIE[ESCALA] [TIEMPO en la escala indicada]#`**

Este comando configura el tamaño de la ventana de análisis. "`ESCALA`" puede ser: "`s`" para segundos, "`m`" para milisegundos, "`u`" para microsegundos, y "`n`" para nanosegundos. El tiempo de la ventana se pasa como valor numérico teniendo en cuenta la escala. Considere que existe un limite inferior de 10 ns para la ventana, entonces, cuando use la escala de tiempo "`n`" el valor numérico pasado corresponde al número de ciclos de 10 ns que tendrá la ventana.

Si el comando es recibido correctamente, el sistema responderá enviando el mensaje "`T[escala]OK#[NUMERO recibido]`" luego de terminar la ventana de análisis.

*ejemplo:* si envía `TIEm 000001000#`, estará configurando una ventana de tiempo de 1000 ms, o lo que es igual, 1 s. El sistema responderá con `TmOK 000001000#`.

#### **`RUN1 000000000#`**

Este comando activa la ventana de análisis que se haya configurado. Si el comando es recibido correctamente, el sistema, luego de que se ejecute la ventana, responderá enviando el mensaje "`R1OK#9999999999`".

#### **`GET1 000000000#`**

Este es el comando que se utilizaría para obtener los resultados de la ventana de análisis ejecutada, es decir, el número de cuentas de cada señal y sus coincidencias. El sistema enviará recursivamente las cuentas de la forma `D1__#[NUMERO DE CUENTAS]`, `D2__#[NUMERO DE CUENTAS]`, ..., `D12_#[NUMERO DE CUENTAS]`, ..., `D123#[NUMERO DE CUENTAS]`. 


Los comandos que se describieron pueden enviarse y recibirse por cualquier programa que actúe como una terminal serial, como por ejemplo, [Hyper Serial Port][hsp]. Sin embargo, por facilidad, también hay una interfaz auxiliar en este proyecto que puede usar con el mismo fin. [prueba-comandos.exe][exe] se diseño para conectarse a la tarjeta e ir enviando el comando deseado y visualizando cual es la respuesta. A continuación se adjunta una captura de pantalla de esta interfaz. 

<p align="center">
  <image src="../img/old-command-tester.png" alt="Descripción de la imagen" width="800x" justify="center"/>
</p>

### Modificaciones al sistema

En caso de ser necesario cambiar algo en el firmware del sistema, usted requerirá de una forma de sintetizar e implementar los códigos VHDL del proyecto luego de haberlos modificado. Para ello se recomienda usar el software [Vivado][vivado], plataforma típica de los sistemas implementados en tarjetas FPGA de Xilinx. Allí bastará con que suba los código y genere el *bitstream File*, el cual será el archivo a remplazar en la memoria SD de la tarjeta y es el binario que contendrá el programa a cargarle ([UCC.bit][bitstream]). 

En este repositorio también se deja el archivo fuente de la interfaz gráfica desarrollada (ver [Todas_Coincidecias_3_detectores.vi][interfaz]). Como puede notar es una interfaz de LabView, en caso de requerir modificarla asegúrese de usar una version de LabView superior a la 2010. Al finalizar los cambios genere el ejecutable y remplace el que se encuentra en la carpeta [exe][exe].

[^1]: Tenga en cuanta que para que la interfaz funcione debe instalar el RunTime de LabView, la versión debe coincidir con la versión de LabView con la cual se genero el ejecutable. Para la versión actual del sistema, la interfaz fue hecha con la versión de 2010 de 32-bits de LabView.



[super-uart]: ./firmware/Super_uart_derecho.vhd
[cpu]: ./firmware/CPU_COINC2.vhd
[vivado]: https://www.xilinx.com/support/download.html
[bitstream]: ./firmware/UCC.bit
[interfaz_src]: ./software/src/Todas_Coincidencias_3_detectores.vi
[exe]: ./software/exe/
[hsp]: https://download.cnet.com/hyper-serial-port/3000-18511_4-75984552.html


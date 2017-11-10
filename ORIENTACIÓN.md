# VIMASM

## Proyecto de Programación de Máquinas I.

## Ciencia de la Computación. Curso 2017-2018.

<img src="Vimlogo.svg.png" alt="Vim logo" style="width: 200px;"/>

## Introducción

Con la idea de preparar un soporte para lo que más adelante será el curso de Sistemas Operativos el colectivo de la asignatura a decidido orientar un proyecto sin dicho recurso (SO).

El objetivo es la implementación de un editor de texto que incluya un subconjunto de las funcionalidades de [Vim](http://wikipedia.matcom.uh.cu/wikipedia_en_all_02_2014/A/html/V/i/m/_/Vim_(text_editor).html), pero completamente desarrollado en NASM y sin la utilización de un sistema operativo. Para esto se le brinda un API para la interacción con las partes más primitivas de la computadora, en estos momentos completamente desprovista de drivers ni nada por el estilo.

Para el desarollo del proyecto resulta casi imprescindible la utilización de Linux como sistema operativo. Aquellos aventureros que insistan en la utilización de Windows deben conocer que el colectivo de la asignatura no brindará soporte para esta plataforma.

## Sobre Vim

Vim es un editor de texto en la terminal, aunque cuenta también con una aplicación gráfica. Una de sus principales características es el concepto de modos, a diferencia de los editores de texto tradicionales como Microsoft Word o Notepad, donde siempre el usuario se encuentra en modo de inserción, en Vim existen múltiples modos. Además, es un editor altamente customizable, contando con un gran ecosistema de _plugins_. Para el desarrollo de este proyecto, resulta necesario contar con una comprensión básica de Vim, sus modos y funcionalidades. Con este propósito, se adjunta documentación que facilite esta tarea.

## Dependencias

Antes de empezar a desarrollar es necesario que tenga instalado todos los programas. Para esto, debe tener acceso a un repositorio de Linux, ya sea conectado a la red o desde un disco duro. Desde el directorio donde se encuentra el proyecto, abra una terminal y ejecute:

```
$ sudo make install_dependencies
```

## Requerimientos

Los requerimientos básicos (los que garantizan una calificación de 3) del proyecto son los siguientes:

* Comenzar
    - Que el editor de texto arranque.
* Mensaje de bienvenida
    - Su proyecto debe mostrar al inicio los nombre de los integrantes y algo semejante a: "Proyecto de PMI 2017-2018. Presione cualquier tecla para continuar..."
* Alternar entre modos
    - Su proyecto debe ser capaz de alternar entre modo normal de Vim, el modo inserción y el modo visual.
* Insertar texto
    - Ser capaces de entrar en modo inserción y poder insertar y eliminar texto.
* Copiar texto en modo visual
    - Su proyecto debe permitir entrar en modo visual y seleccionar y copiar texto de tres formas posibles: simple, en líneas y en bloque.
* Pegar texto en modo normal
    - El texto que haya sido copiado en modo visual, debe poderse pegar en modo normal.
* Volver a la pantalla de inicio
    - Su proyecto debe permitir regresar a la pantalla inicio y volver a entrar para editar un documento nuevo, descartando todos los cambios hechos.

Una **correcta** implementación del anterior grupo de funcionalidades le otorgará 3 puntos. Para alcanzar una nota superior es necesario implementar algunas de las siguientes características opcionales.

Es importante notar que para lograr estos objetivos, las combinaciones de teclas tienen que ser las mismas utilizadas por Vim.

## Funcionalidades optativas

Por su nivel de complejidad no todas tienen el mismo "peso".

Cada funcionalidad otorga una cantidad de puntos determinada, en función de su complejidad. A continuación describimos cada una:

- Operaciones en modo normal
    - (0.75ptos) Comando punto (_Dot command_):
        - Permite repetir el último cambio. Una de las instrucciones más poderosas y versátiles de Vim. Es necesario implementar al menos una versión de este operador que repita lo que sucedió entre entrar en modo inserción y salir.
    - (0.25ptos) Deshacer una acción.
    - (0.25ptos) Deshacer infinito.
    - Operadores + Repeticiones + Movimiento (0.75ptos)
        - Es necesario implementar al menos los operadores de copiar, borrar y reemplazar con cualquier cantidad de repeticiones y al menos tres tipos de movimientos diferentes.
    - (0.25ptos) Ir al inicio del fichero, al final del fichero y a una línea específica del fichero.
    - (0.25ptos) Entrar en modo sobreescribir.
- Operaciones en modo inserción
    - (0.25ptos) Borrar utilizando operadores de movimiento.
    - (0.25ptos) Pegar desde registro.
- Operaciones en modo visual
    - (0.25ptos) Mover el rango de selección con operadores de movimiento.
    - (0.5ptos) Inserción en modo bloque.
- Operaciones en modo línea de comandos
    - (0.5ptos) Reemplazar texto.
    - (0.25ptos) Especificar preferencias (comando `set`). Su proyecto debe ser capaz al menos de especificar la búsqueda con resaltado, el tamaño de los tabs e ignorar las mayúsculas y minúsculas. Es importante también implementar sus contrapartes, o sea, ser capaces de revertir estas configuraciones. Resulta necesario haber implementado la funcionalidad de búsqueda para implementar esta funcionalidad.
    - (0.25ptos) Otras operaciones como `delete`, `yank`, `put`, `copy`, `move`, `join` y `normal`. Es necesario implementar al menos tres de ellas.
- Misceláneas
    - (0.25ptos) Buscar texto y ser capaz de moverse hacia la próxima ocurrencia con `/pattern` y `n`.
    - (0.25ptos) Autocompletamiento.
    - (0.25ptos) Cursor de bloque intermitente (blinking cursor).
 
Como puede verse, es posible lograr más de 5 puntos, calificación que se tendrá en cuenta para la evaluación final de la asignatura. Cada una de las funcionalidades implementadas debe integrarse con las implementadas anteriormente. Esto significa, por ejemplo, que si se implementa el comando punto y deshacer, su proyecto tiene que ser capaz de deshacer lo que se haga con el comando punto.

Es muy probable que para realizar (como es debido) algunos de estos requerimientos se necesite de un poco de investigación al respecto.

Si a usted se le ocurre otra funcionalidad que resulte interesante y útil, díscútala con el colectivo de la asignatura para decidir si es de interés y cuántos puntos se otorgan por la misma. 

## Estructura del proyecto

Para la correcta implementación de la tarea se le brinda una plantilla que contiene el código necesario para comenzar a cargar un programa muy básico en una máquina virtual, además de las respectivas funciones para leer del teclado, pintar en la pantalla y consultar el tiempo.

    vimasm/
    ├── src/
    │   ├── multiboot.asm
    │   ├── boot.asm
    │   ├── main.asm
    │   ├── game.asm
    │   ├── keyboard.asm
    │   ├── keyboard.mac
    │   ├── video.asm
    │   ├── video.mac
    │   └── timing.asm
    ├── Makefile
    ├── README.md
    ├── ORIENTACIÓN.md
    ├── linker.ld
    ├── menu.lst
    └── stage2_eltorito

Vale destacar que, aunque estaremos usando una máquina virtual para el desarrollo, este esqueleto contiene todo lo necesario para que al finalizar su proyecto, usted pueda guardar su juego en una memoria y ejecutarlo en su PC real.

## Código base
En la carpeta `src` se encuentra el código que se brinda como base para comenzar el proyecto.

* `game.asm`

    Se encuentra el ciclo principal del juego, como ejemplo se ve el código de un programa que cuando se presiona la tecla `arriba` la pantalla se pone de color rojo y cuando se presiona "abajo" de color verde.

* `kerboard.asm`

    Se encuentra un procedimiento llamado `scan` que retorna en `al` el byte de la última tecla que se presionó y 0 si es la misma.

* `keyboard.mac`

    Valores útiles para el trabajo con el teclado.

* `video.asm`

    En este fichero está implementado solo el procedimiento `clear` que recibe una palabra que representa el color con el que pintar toda la pantalla. Es tarea de usted implementar el resto de las funciones que sean necesarias para el trabajo con la pantalla.

    Para manipular la pantalla se utilizará el framebuffer. Básicamente lo que se debe hacer es escribir una dirección de memoria (`0xB8000`) declarada en la macro `FBUFFER`. A partir de esta dirección de memoria es posible utilizar `COLS*ROWS` palabras (2 bytes). En cada "casilla" es posible especificar el caracter (1 byte), el foreground (1 nibble) y el background (1 nibble). Ej. Para representar una `a` de color rojo y fondo azul se utilizaría

        mov ax, 'a' | FG.RED | BG.BLUE

    Para escribir en el pixel `i`, `j` (fila i, columna j) es necesario modificar el valor de la posición `2*(i*COLS + j)`.

    Se recomienda utilizar lo más que se pueda instrucciones de cadena para disminuir la longitud del código y aumentar su expresividad.

* `video.mac`

    Macros útiles para el trabajo con el framebuffer. Tamaño de la pantalla y colores para background y foreground.

* `timing.asm`

    Funciones para el trabajo con el tiempo.

Los demás archivos son utilizados en el proceso de arranque (*boot*).

* `multiboot.asm`

    Declara la sección `multiboot`.

* `boot.asm`

    Prepara la pila y salta para la etiqueta `main`.

* `main.asm`

    Desaparece el cursor de la pantalla y salta para la etiqueta `game`.

## Otros

Existen otros archivos de utilidad en el proyecto no relacionados con el código fuente.

* `linker.ld`

    Características a tener en cuenta en el proceso de enlace (*linker*).

* `menu.lst`

    Configuración de `grub`.

* `stage2_eltorito`

    Binario de `GRUB` para incluirlo dentro de la imagen de disco que se construye.

* `README.md`

    Utilizar este archivo para describir las características propias de su proyecto. Ser lo más claro posible, incluir imágenes y ejemplos.

    Este tipo de archivos es característico en todo tipo de proyectos, y utiliza formato [Markdown](http://wikipedia.matcom.uh.cu/wikipedia_en_all_02_2014/A/html/M/a/r/k/Markdown.html). Normalmente se usa para explicar el software en caso de que otra persona quiera utilizar este código.

* `ORIENTACIÓN.md`

    Este archivo ;-).

* `.gitignore`

    Archivos que no se tendrán en cuenta en su repositorio de `git`.

* `Vimlogo.svg.png`

    El logo de Vim.

## Compilación

El proceso de compilación y ejecución del código está completamente a cargo de `make`. En principio no es necesario cambiar el código del `Makefile`, solo si se quisiera añadir alguna modificación, como añadir más directorios a su proyecto.

Para compilar el proyecto solo es necesario ejecutar `make` en el directorio del proyecto.

```
$ make
```

Cualquier archivo que se añada en el directorio `src` automáticamente pasará a formar parte del código fuente de su proyecto, por tanto se ensamblará y enlazará apropiadamente para crear el programa `vimasm.elf` sin hacer ninguna modificación en el `Makefile`.

## QEMU

QEMU es donde va a correr su programa de manera virtualizada.

Para correr y probar su programa ejecutar `make qemu` en una terminal sobre el directorio de su proyecto.

```
$ make qemu
```

De manera opcional también se puede preparar un iso y realizar el proceso de arranque utilizando qemu directamente con el iso.

```
$ make qemu-iso
```

## Especificaciones

* Los equipos no deben ser de más de dos personas y se recomienda que no sean menos que esta cantidad.
* No hay ninguna razón para utilizar `C` a no ser que la funcionalidad que se quiera implementar sea lo suficientemente compleja. En cualquier caso consultar con el colectivo de la asignatura su propuesta.
* La fecha de entrega es el viernes de la semana 16.

## Recomendaciones

* No invertir mucho tiempo en tareas que parezcan muy complicadas. Proceder en orden ascendente. Plantearse tareas pequeñas que puedan luego ir escalando.
* Comentar el código abundantemente, cuanto más, mejor.
* Organizar convenientemente el código en distintos archivos dentro de la carpeta `src`, de acuerdo con la lógica que desarrollen.

## Git

Sistema de control de versiones.

Es altamente recomendada la utilización de esta herramienta dada las ventajas que brinda.

Este proyecto se encuentra en el repositorio [http://gitlab.matcom.uh.cu/pm1/vimasm.git](http://gitlab.matcom.uh.cu/pm1/vimasm.git). Se recomienda hacer un _fork_ del mismo para trabajar sobre él.

## Ayuda
Todo ha sido preparado para que se pueda concentrar en la implementación del proyecto únicamente. De cualquier forma el colectivo de la asignatura está preparado para recibir preguntas de cualquier tipo con respecto al código y las herramientas que se brindan.

### Documentación adjunta
Junto con el proyecto se distribuyen varios documentos que pueden resultar de utilidad. Entre ellos se encuentran varios libros que resultan de gran utilidad para comprender Vim y todas su funcionalidades. Además, se incluyen tres documentos creados por el desarrollador del proyecto [Tetrasm](https://github.com/programble/tetrasm), en el cual se inspira este proyecto. Otro de los documentos que se incluyen en la tabla con los códigos de escaneo para reconocer las teclas que se presionan. Uno de los recursos más importantes para comprender Vim, es la propia documentación, intente ejecutar `vimtutor` en una terminal.

### CMOS/RTC
`CMOS` (Complementary-symmetry Metal-Oxide Semiconductor) es una zona de memoria estática, dividida en varios registros, destinada a almacenear la información del `SETUP` del `BIOS` (Basic Input Output System). El CMOS se encuentra dentro de un chip que posee una batería independiente, por lo que retiene la información mientras la computadora está apagada. Este chip también posee otro circuito llamado `RTC` (Real Time Clock), que cuenta la fecha y la hora, y almacena su valor en varios registros del CMOS.

La comunicación con el CMOS se realiza através de los puertos 0x70 y 0x71. El puerto de direccionamiento (0x70) se utiliza para informar a qué registro del CMOS se quiere acceder, mientras que el puerto de datos (0x71) se utiliza para escribir o leer en el registro seleccionado con 0x70. Los registros del CMOS asociados al RTC son:

Register | Contents
---------|----------
 0x00    |  Seconds
 0x02    |  Minutes
 0x04    |  Hours
 0x06    |  Weekday
 0x07    |  Day of Month
 0x08    |  Month
 0x09    |  Year
 0x32    |  Century (maybe)
 0x0A    |  Status Register A
 0x0B    |  Status Register B

El registro 0x0A notifica en su 5to bit menos significativo (0x80) cuándo está sucediendo la actualización de los registros del RTC (RTC Update In Progress) y por tanto están en un estado inconsistente. Por lo tanto, antes de hacer una consulta a los registros debería
esperar a que dicho bit esté activo.

Ej:
```nasm
wait_in_progress:
    mov al, 0XA0
    in 0x70, al
    test al, 0x80 ; and lógico que sólo modifica los flags (no modifica los operandos)
    jnz wait_in_progress
```

Cada registro tiene un byte de tamaño, por lo que el año no cabe en un solo registro. El siglo es almacenado en el Century Register (0x32) y el resto se almacena en el Tear Register (0x09). Por lo tanto si se quiere obtener el año completo debería calcularse (RealYear = 100 * Century + Year).

Ej: 
Las siguientes instrucciones guardan en `al` los segundos de la hora actual:
```nasm
mov al, 0x00
out 0x70, al ; seleccionando el registro 0x00 del CMOS
in al, 0x71  ; leyendo su valor
```
links:
*   [http://wiki.osdev.org/CMOS](http://wiki.osdev.org/CMOS)


### Timing
Si se quisiera esperar (en un programa) un tiempo determinado, se pudiera ejecutar un ciclo hasta que la diferencia en la hora sea dicho tiempo. Pero la fecha proporcionada por los registros del CMOS tiene una resolución en segundos, lo cual es inútil por si solo cuando queremos esperar milisegundos. Para resolver este problema puede ser utilizada instrucción `rdtsc` (Read Time Stamp Counter), que almacena en `edx:eax` la cantidad de ciclos del reloj que han ocurrido desde que se ha encendido la computadora. A continuación se explica cómo se puede hacer para una cantidad de milisegundos `ms`:

1. Calcular previamente la cantidad de ciclos que han transcurrido durante un segundo (`tps`) utilizando rtdsc y la hora del CMOS (teniendo en cuenta el wait in progress)
2. A partir del momento en que se desee esperar, contar, dentro de un ciclo, la cantidad de ciclos del reloj transcurridos (`tc`)
3. Romper el ciclo cuando se cumpla la condición `1000 * tc / tps >= ms`


### Keyboard
El teclado es otro dispositivo que se comunica através del bus IO. Este dispositivo es extremadamete complejo y sólo nos centraremos en saber cuál tecla fue presionada. Para esto podemos consultar el puerto IO 0x60.

Ej:
```nasm
in al, 0x60 ; almacena en al el código de la tecla presionada
```

links:
*   [http://wiki.osdev.org/PS/2_Keyboard](http://wiki.osdev.org/PS/2_Keyboard)


### Memory Mapped IO - Frame Buffer
Existen otros dispositivos (`Memory Mapped Devices`) que, a difirencia de utilizar el bus IO, utilizan la `RAM` para su comunicación. La tarjeta gráfica se comunica utilizando una zona de memoria denominada `Frame Buffer`, cuyo tamaño varía dependiendo del modo en que se configure. En el proyecto se utilizará la tarjeta gráfica en modo texto, el cual asume que la pantalla es una matriz de texto con 25 filas y 80 columnas. La codificación de la matriz se realiza utilizando 2 bytes por celda y ubicando en la memoria cada fila una a continuación de otra. El framebuffer está ubicado a partir de la dirección 0xB8000 y tiene una extensión de 25 * 80 * 2 bytes, por lo tanto la celda ubicada en la fila r y la columna c se encuentra en la dirección de memoria 0xB8000 + (80 * r + c) * 2. Cada celda se codifica en una palabra (word), el byte menos significativo es exactamente el caracter (chr) que se mostrará en la celda y el más significativo representa el color de la celda. El byte del color almacena en el nibble menos significativo el color del caracter (fg), y en el nible más significativo el color de fondo (bg). Por lo tanto, la palabra (word) correspondiente a una celda puede ser representada de la forma ((bg << 12) | (fg << 8) | chr). Además, el bit más significativo de cada color (fb o bg), al estar activado, indica
que el color se mostrará en su forma más clara.

Color   | value
--------|------
BLACK   | 0x0
BLUE    | 0x1
GREEN   | 0x2
CYAN    | 0x3
RED     | 0x4
MAGENTA | 0x5
YELLOW  | 0x6
GRAY    | 0x7

```c
LIGHT_BLUE = BLUE | 0b1000
```

links:
*   [https://en.wikipedia.org/wiki/VGA-compatible_text_mode](https://en.wikipedia.org/wiki/VGA-compatible_text_mode)

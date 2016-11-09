# SNAKASM
[http://gitlab.matcom.uh.cu/pm1/snakasm.git](http://gitlab.matcom.uh.cu/pm1/snakasm.git)

Proyecto de Programación de Máquinas I.

Ciencia de la Computación. Curso 2016-17.

![](/home/frnd/Pictures/nibbles.png)

[https://wiki.gnome.org/Apps/Nibbles/](https://wiki.gnome.org/Apps/Nibbles/)

## Introducción
El objetivo del proyecto este año sera implementar un juego tipo "Snake" implementado completamente en NASM y sin la utilización de un sistema operativo. Con este objetivo se les brinda esta API para la interacción con las partes de la computadora que van a necesitar (teclado, pantalla, etc).

## Dependencias
Para empezar a desarrollar necesitaran algunos programas y bibliotecas:

```
$ sudo make install_dependencies
```

Debe de estar conectado y con acceso a un repositorio. Luego de esto, no debe haber ningún problema con empezar de inmediato con el resto de su proyecto.

## Requerimientos
Los requerimientos básicos (los que garantizan una calificación de 3) del proyecto son los siguientes:

* Comenzar.

    Que el juego arranque.

* Visualizar Mapa.

    Este deben tener paredes y espacios en blanco de forma tal que la serpiente pueda moverse y chocar.

* Movimiento con teclas.

    4 movimientos básicos, arriba, abajo, derecha e izquierda.

* Comer y crecer.

    Eventualmente hacer aparecer "fruta" en una posición válida (alcanzable) del mapa y cuando la cabeza de la serpiente pase por encima de este, hacer que la longitud de la serpiente aumente.

* Chocar y perder.

    Si la cabeza de la serpiente se se encuentra en un obstáculo (zona no vacía que no sea una fruta) el juego debe detenerse e indicar que se ha perdido.

* Puntuación.

    Llevar la cuenta de los puntos del jugador y hacérselo saber en algún momento.

El cumplimiento de todos estos requerimientos garantizan una nota básica, como se dijo antes. Para alcanzar una nota superior es necesario realizar algunos de estos requerimientos opcionales (es posible lograr más de 5 puntos, calificación que se tendrá en cuenta para la evaluación final de la asignatura).

### Requerimientos opcionales
Por su nivel de complejidad no todos tienen el mismo "peso":

* Alta puntuación (+0.5)

    Durante el período del juego llevar la cuenta de cuáles han sido las puntuaciones más altas.

* Niveles fijos (+0.5) - Aleatorios jugables (+1)

    Tener la opción de jugar distintos niveles en vez de uno fijo. También es posible que estos niveles se generen de manera aleatoria, pero siempre garantizando que sean jugables, que no haya una zona inaccesible en el mapa.

* Dificultad (velocidades, ...) (+0.5)

    Tener distintos niveles de dificultad, que afecten la sensación del juego. Una posible idea sería la velocidad de la serpiente.

* Title screen con ascii art (+0.5)

    Tener una pantalla de presentación generada con ascci art. (Googlear)

* Tiempo (modificar la puntuación, ...) (+0.5)

    El tiempo transcurrido debe afectar el modo de juego. Por ejemplo ir disminuyendo la puntuación cada 10 segundos si no se tomado ninguna fruta.

* Serpientes adicionales (IA ó 2nd player) (+1) (ambos +1.5)

    Tener la posibilidad de jugar con varias serpientes, lo mismo controladas de manera automática que por otro jugador. La implementación de alguno de estos requerimientos aporta 1 punto adicional ó (no el ó de lógica, en todo caso el xor ;-)) 1.5 si se realizan ambos.

* Sonido/Música (+0.5)

    Añadir sonido ó música al juego.

* Cualquier otro (+?) (consultar con el profesor)

Es muy probable que para realizar (como es devido) algunos de estos requerimientos se necesite de un poco de investigación al respecto. Ej 1. Para poner sonido es necesario leer sobre los "puertos" y como pedir e insertar valores. Ej 2. Las serpientes controladas automáticamente normalmente se quiere que no tengan un movimiento completamente caótico (solución que es perfectamente válida para conseguir los puntos de este requerimiento). Ej 3. Funciones que generen números "ramdom".

## Estructura del proyecto
Para la correcta implementación de la tarea se le brinda una plantilla que contiene el código necesario para comenzar a cargar un programa muy básico en una máquina virtual, además de las respectivas funciones para leer del teclado, pintar en la pantalla y consultar el tiempo.

    snakasm/
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

### Código base
En la carpeta `src` se encuentra el código que se brinda como base para comenzar el proyecto.

* `game.asm`

    Se encuentra el ciclo principal del juego, como ejemplo se ve el código de un programa que cuando se presiona la tecla "arriva" la pantalla se pone de color rojo y cuando se presiona "abajo" de color verde.

* `kerboard.asm`

    Se encuentra un procedimiento llamado `scan` que retorna en `al` el byte de la última tecla que se presionó y zero si es la misma.

* `keyboard.mac`

    Valores útiles para el trabajo con el teclado.

* `video.asm`

    En este fichero está implementado solo el procedimiento `clear` que recibe una palabra que representa el color con el que pintar toda la pantalla. Es tarea de usted implementar el resto de las funciones que sean necesarias para el trabajo con la pantalla.

    Para manipular la pantalla se utilizará el framebuffer. Básicamente lo que se debe hacer es escribir una dirección de memoria (`0xB8000`) declarada en la macro `FBUFFER`. A partir de esta dirección de memoria es posible utilizar `COLS*ROWS` palabras (2 bytes). En cada "casilla" es posible especificar el caracter (1 byte), el foreground (1 nibble) y el backgroud (1 nibble). Ej. Para representar una a de color rojo y fondo azul se utilizaría

        mov ax, 'a' | FG.RED | BG.BLUE

    Para escribir en el pixel `i`, `j` (fila i, columna j) es necesario modificar el valor de la posición `2*(i*COLS + j)`.

    Se recomienda utilizar lo más que se pueda instrucciones de cadena para disminuir la cantidad y aumentar la expresividad del código.

* `video.mac`

    Macros útiles para el trabajo con el framebuffer. Tamaño de la pantalla y colores para backgroud y foreground.

* `timing.asm`

    Funciones útiles para el trabajo con el tiempo.

    TODO: Hablar más al respecto.

Los demás archivos son utilizados en el proceso de `boot`.

* `multiboot.asm`

    Declara la sección `multiboot`.

* `boot.asm`

    Prepara la pila y salta para la etiqueta `main`.

* `main.asm`

    Desaparece el cursor de la pantalla y salta para la etiqueta `game`.

### Otros
Existen otros archivos de utilidad en el proyecto no relacionados con el código fuente.

* `linker.ld`

    Características a tener en cuenta en el proceso de `link`.

* `menu.lst`

    Configuración de `grub`.

* `stage2_eltorito`

    Binario de `grub` para incluirlo dentro del `iso`.

* `README.md`

    Utilizar este archivo para describir las características propias de su proyecto. Ser lo más claro posible, incluir imágenes y ejemplos.

    Este tipo de archivos es característico en todo tipo de proyectos. Normalmente se usa para explicar el software en caso de que otra persona quiera utilizar este código. Para más información buscar "markdown".

* `ORIENTACIÓN.md`

    Este archivo ;-).

* `.gitignore`

    Archivos que no se tendrán en cuenta en su repositorio de `git`.

### Compilación
El proceso de compilación y ejecución del código está completamente a cargo de `make`. En principio no es necesario cambiar el código del `Makefile`, solo si se quisiera añadir alguna modificación, como compilar ficheros escritos en `C` o añadir más directorios a su proyecto.

Para compilar el proyecto solo ejecutar `make` en el directorio del proyecto.

```
$ make
```

Cualquier archivo que se añada en el directorio `src` automáticamente pasará a formar parte del código fuente de su proyecto, por tanto se compilará y linquerá apropiadamente para crear el programa `snakasm.elf` sin hacer ninguna modificación en el `Makefile`.

### QEMU
QEMU es donde va a correr su programa de manera virtualizada.

Para correr y probar su programa ejecutar `make qemu` en una terminal sobre el directorio de su proyecto.

```
$ make qemu
```

De manera opcional también se puede preparar un iso y realizar el proceso de `boot` utilizando qemu directamente con el iso.

```
$ make qemu-iso
```

## Especificaciones
* Los equipos no deben ser de más de dos personas y se recomienda que no sean menos que esta cantidad.
* No hay ninguna razón para utilizar `C` a no ser que la funcionalidad que se quiera implementar sea lo suficientemente compleja. En cualquier caso consultar con el colectivo de la asignatura su propuesta.
* TODO: Fecha de entrega

## Recomendaciones
* No invertir mucho tiempo en tareas que parezcan muy complicadas. Proceder en orden ascendente. Plantearse tareas pequeñas que puedan luego ir escalando.
* Comentar el código abundantemente, cuanto más, mejor.
* Organizar convenientemente el código en distintos archivos dentro de la carpeta `src`, de acuerdo con la lógica que desarrollen.

### Git
Sistema de control de versiones.

Es altamente recomendada la utilización de esta herramienta dada las ventajas que brinda.

## Ayuda
Todo a sido preparado para que se pueda concentrar en la implementación del proyecto únicamente. De cualquier forma el colectivo de la asignatura está preparado para recibir preguntas de cualquier tipo con respecto al código y las tecnologías que se brindan.

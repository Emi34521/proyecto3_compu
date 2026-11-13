# Proyecto 3: exploración del sistema solar

Readme generado con Chatgpt


[![Pequeña demostración](https://img.youtube.com/vi/59jF99mF7fo/0.jpg)](https://youtu.be/59jF99mF7fo)
Proyecto académico de gráficas por computadora desarrollado en **Zig 0.16** con **raylib-zig**. Implementa un ray tracer por software para explorar un sistema solar con planetas texturizados, iluminación, materiales reflectantes y transparentes, un fondo espacial y un mapa para seleccionar destinos de viaje rápido.

El sistema contiene el Sol y ocho planetas: Mercurio, Venus, Tierra, Marte, Júpiter, Saturno, Urano y Neptuno. Saturno cuenta con un anillo texturizado. Las distancias y los tamaños se adaptaron para facilitar la exploración; no representan una escala astronómica real.

## Requisitos

- **Zig 0.16.0**, compatible con las API de `std.Io` utilizadas por el proyecto.
- **Una versión de raylib-zig compatible con Zig 0.16**. Se debe conservar la dependencia fijada en `build.zig.zon`, que integra raylib y sus bindings para Zig:
  - Repositorio: [raylib-zig](https://github.com/raylib-zig/raylib-zig).
  - Commit configurado: `bd161c82d4cc42d9ea7986d0c6a86daaae79e430`.
  - Evitar sustituirla por una versión destinada a otra versión de Zig sin adaptar el código.
- Conexión a Internet durante la primera compilación para descargar las dependencias.
- Las texturas de `src/Texturas/` y los modelos de `src/modelos/`, respetando sus nombres y rutas.
- Blender para convertir el modelo externo de la nave a formato OBJ, si es necesario.

### Modelo y textura de la nave

Para utilizar la nave se necesita descargar **el modelo y su textura** del recurso [Low Poly Space Ship en Sketchfab](https://sketchfab.com/3d-models/low-poly-space-ship-587941c9c11742c6b82dfb99e7b210b9).

1. Descargar los recursos desde la página original y revisar sus condiciones de uso y atribución.
2. Si el modelo está en formato Blender, abrirlo y exportarlo como Wavefront OBJ, conservando las coordenadas UV.
3. Guardar el modelo como `src/modelos/Nave_lowpoly.obj`.
4. Guardar su textura como `src/Texturas/nave_lowpoly.png`. Respetar las mayúsculas y minúsculas, especialmente en sistemas que las distinguen.
5. En `src/main.zig`, cambiar la ruta `src/modelos/cubo.obj` de la llamada a `Modelo.Modelo.init` por `src/modelos/Nave_lowpoly.obj`.

**Estado actual:** el código carga `cubo.obj` como modelo de prueba y utiliza la textura de la nave. Descargar el OBJ por sí solo no cambia el modelo que se renderiza: también es necesario actualizar esa ruta.

El modelo externo de la nave no es de autoría propia. Su uso no acredita el bono de modelado propio ni sustituye la entrega de un archivo `.blend` creado por el estudiante. El `.gitignore` excluye los recursos de la nave; deben prepararse localmente si no están presentes en la copia del proyecto.

## Compilación y ejecución

Ejecutar los comandos desde la raíz del proyecto para que se encuentren los modelos y las texturas:

```sh
zig version
zig build run -Doptimize=ReleaseFast
```

Para compilar sin abrir la aplicación:

```sh
zig build -Doptimize=ReleaseFast
```

También se puede ejecutar en modo de depuración con `zig build run`. Para la demostración se recomienda `ReleaseFast`, ya que el trazado de rayos se calcula por software y su rendimiento depende del equipo y de la escena.

## Controles

- **Mouse o flechas:** orientar la cámara.
- **W / S:** avanzar y retroceder.
- **A / D:** desplazarse lateralmente.
- **Espacio / Ctrl izquierdo:** subir y bajar.
- **Shift izquierdo:** duplicar la velocidad de movimiento.
- **R, mientras se mantiene presionada:** animar la rotación de los planetas.
- **T, mientras se mantiene presionada:** animar su traslación orbital.
- **Tab:** alternar entre la exploración 3D y el mapa; no se puede cambiar de modo durante un viaje rápido.
- **Clic izquierdo sobre un planeta en el mapa:** seleccionar el destino y regresar a la vista 3D.
- **F:** iniciar el viaje rápido al destino seleccionado.
- **Esc:** cerrar la aplicación.

El viaje rápido desplaza la cámara durante aproximadamente cinco segundos, con una trayectoria elevada en forma de parábola y orientación hacia el destino. El modelo que acompaña a la cámara se actualiza con su posición y orientación.

## Criterios de evaluación

Esta sección relaciona la rúbrica con el código actual. Los puntos indicados son los de la tarea; la calificación depende de la demostración y de la revisión del docente.

### Planetas o lunas con texturas diferentes — hasta 50 puntos

Se incluyen ocho planetas con una textura propia para cada uno: `mercurio.png`, `venus.png`, `tierra.png`, `marte_textura.png`, `jupiter.png`, `saturno.png`, `urano.png` y `neptuno.png`. Esto supera los cinco cuerpos necesarios para alcanzar el máximo de este criterio. No se incluyen lunas.

Si falta una textura planetaria, el programa utiliza un color de respaldo; para evaluar este criterio deben estar disponibles las texturas.

### Shader único por planeta o luna — 5 puntos adicionales por cuerpo

El proyecto utiliza un algoritmo de sombreado compartido en el ray tracer, con propiedades de material diferentes. La Tierra tiene reflexión; Urano tiene transparencia, refracción y reflexión; Neptuno también incorpora reflexión. Además, se puede animar la rotación y traslación de los planetas.

Estas características se pueden mostrar como efectos especiales de los materiales, pero no hay shaders independientes por planeta. Corresponde al docente determinar si los efectos cumplen el criterio de shader único.

### Estrellas que iluminan los planetas — 10 puntos

El Sol dispone de una luz puntual ubicada en el origen. El ray tracer calcula iluminación difusa, brillo especular y sombras mediante rayos de oclusión. También hay una luz direccional tenue de relleno. El material del Sol tiene brillo propio.

### Back-face culling — 10 puntos

**Pendiente en la implementación actual.** La intersección de triángulos utiliza Möller–Trumbore y acepta ambos signos del determinante. Invertir una normal para orientarla hacia el rayo no descarta las caras posteriores.

### LOD — 10 puntos

**Pendiente en la implementación actual.** Se utiliza una esfera envolvente para descartar rayos que no alcanzan un modelo, pero no se cambia la complejidad de la geometría o del sombreado según la distancia. Esa optimización no equivale a LOD.

### Rendimiento general y cerca de los objetos — 10 + 10 puntos

El render se divide en bloques con tareas concurrentes, las mallas usan una esfera envolvente y los rayos de reflexión y refracción tienen una profundidad limitada. La ventana solicita una tasa de 60 FPS; esto no garantiza que el render alcance esa velocidad.

**Por verificar durante la demostración:** fluidez durante la exploración y al acercarse a los planetas y al modelo. No se incluyen mediciones de rendimiento que acrediten estos puntos.

### Viaje rápido y efecto animado — 10 + 10 puntos

Se implementa la selección de un destino desde el mapa y el inicio del viaje con **F**. El desplazamiento se anima mediante interpolación suave y una trayectoria parabólica, acompañada por un cambio de orientación de la cámara.

### Nave que sigue a la cámara — 30 puntos

Se implementa el seguimiento del modelo mediante `actualizar_nave`, que ajusta su posición y sus ejes a los de la cámara. **Para demostrar una nave debe configurarse el OBJ externo indicado arriba**, ya que actualmente se carga un cubo de prueba.

- **Modelado propio, 10 puntos adicionales:** no acreditado. Se utiliza un recurso externo y no se incluye un `.blend` propio como prueba.
- **Geometría con caras que no sean solo triángulos, 20 puntos adicionales:** el cargador OBJ acepta caras de hasta 32 vértices y las triangula en abanico. `cubo.obj` contiene caras cuadriláteras y permite mostrar ese procesamiento. La triangulación en abanico no garantiza un resultado correcto para polígonos cóncavos arbitrarios.

### Skybox con estrellas — 10 puntos

Se carga `src/Texturas/Skybox_space.png` como fondo espacial. Cuando un rayo no intersecta la escena, se obtiene el color del fondo a partir de su dirección, mostrando el entorno alrededor de la cámara.

### Evitar atravesar los elementos del sistema — 10 puntos

La función `colisiones` comprueba distancias y corrige la posición de la cámara para mantener un margen respecto del Sol, los planetas y la esfera envolvente de los modelos. Se trata de una comprobación por fotograma: no incluye una colisión precisa de la malla de la nave ni del anillo de Saturno. Conviene demostrar su comportamiento al aproximarse a los cuerpos.

### Movimiento 3D de la cámara — 10 puntos

La cámara permite avanzar, retroceder, moverse lateralmente, subir, bajar y cambiar la orientación con mouse o flechas. La inclinación vertical se limita para evitar orientaciones degeneradas.

## Organización del código

- `src/main.zig`: escena, cuerpos celestes, render, iluminación, mapa, animaciones, viaje rápido y colisiones.
- `src/camera.zig`: posición y orientación de la cámara.
- `src/raytracer.zig`: definiciones de luces, materiales e intersecciones.
- `src/Object.zig`: lectura de archivos OBJ y triangulación de caras.
- `src/formas/`: intersecciones con esferas, triángulos, planos, anillos y modelos.
- `src/textura.zig`: carga y muestreo de texturas.
- `src/framebuffer.zig`: manejo del framebuffer y dibujo.
- `src/Texturas/` y `src/modelos/`: recursos visuales.
- `build.zig` y `build.zig.zon`: compilación y dependencias.

## Video de demostración y explicación

**Enlace al video:** _Agregar aquí el enlace al video antes de entregar._

Guion sugerido:

1. Mostrar el Sol y al menos cinco planetas con sus texturas diferentes.
2. Explicar la iluminación solar, las sombras y los materiales con reflexión o refracción.
3. Demostrar el movimiento 3D, la rotación y la traslación de los planetas.
4. Abrir el mapa, seleccionar un planeta y mostrar el viaje rápido animado.
5. Mostrar la nave siguiendo a la cámara y explicar la carga de caras cuadriláteras desde OBJ.
6. Acercarse a los cuerpos para demostrar las colisiones y evaluar la fluidez.
7. Explicar las optimizaciones y señalar los criterios pendientes: back-face culling, LOD y cualquier otro que no se haya completado al entregar.

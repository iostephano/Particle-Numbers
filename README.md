# ParticleNumbers — Números formados por partículas con Metal

ParticleNumbers es una app de iOS que dibuja 2000 partículas de colores flotando
sobre un fondo negro. Al tocar un botón, elige un número al azar entre 0 y 99 y
las partículas se reagrupan para formar ese número, lo sostienen unos segundos y
vuelven a dispersarse. Existe como proyecto de portafolio para mostrar cómo
combino render por GPU (Metal) con una interfaz UIKit hecha por código, y cómo
convierto texto en posiciones destino para una animación de partículas.

<img width="1387" height="712" alt="ParticleNumbers" src="https://github.com/user-attachments/assets/fea9d018-d191-4ef8-ac2f-4baf5d3208f3" />

---

## Tecnologías usadas

- Swift 6 (con verificación estricta de concurrencia activada)
- UIKit, construido por código (sin Storyboards)
- MetalKit / Metal para el render de las partículas en GPU
- Core Graphics para rasterizar el número y sacar sus píxeles
- `simd` para la interpolación de posiciones
- Swift Testing para las pruebas
- Integración continua con GitHub Actions (compila y corre los tests en cada push/PR)
- Cero dependencias externas

---

## Cómo está organizado el proyecto

```
ParticleNumbers/
├── AppDelegate.swift / SceneDelegate.swift   # Arranque; SceneDelegate crea el ViewController
├── Controllers/
│   └── ViewController.swift                  # Pantalla única: la vista Metal + el botón
├── Views/
│   └── ParticleMetalView.swift               # MTKView: buffer de partículas, loop de dibujo,
│                                             #   máquina de estados de la animación
├── Particles/
│   ├── TextParticleMask.swift                # Texto -> nube de puntos normalizados (Core Graphics)
│   └── ParticleTargetFitter.swift            # Ajusta esos puntos a la cantidad de partículas
└── Shaders/
    └── ParticleShader.metal                  # vertex + fragment shader (puntos de color)
```

La lógica que se puede probar sin GPU está aislada en `Particles/`:
`TextParticleMask` y `ParticleTargetFitter` son funciones puras (o casi) que
`ParticleMetalView` orquesta.

---

## Cómo funciona / flujo principal

1. `ParticleMetalView` crea 2000 partículas en posiciones y colores aleatorios y
   las sube a un `MTLBuffer` compartido.
2. El `MTKView` dibuja a 60 fps: en estado `idle` solo renderiza; en los demás
   estados interpola posiciones y vuelve a subir el buffer.
3. Al tocar **Generar número**, `ViewController` elige `Int.random(in: 0...99)` y
   llama a `animateParticles(to:)`.
4. `TextParticleMask` rasteriza el número (blanco sobre negro), lo relee en escala
   de grises y devuelve un punto normalizado (`-1...1`, Y hacia arriba) por cada
   píxel encendido.
5. `ParticleTargetFitter` ajusta esa nube a exactamente 2000 puntos: si sobran,
   muestrea de forma uniforme; si faltan, rellena con posiciones aleatorias.
6. La máquina de estados recorre `forming` (60 frames) → `holding` (180 frames) →
   `dispersing` (60 frames) → `idle`, interpolando cada partícula entre su
   posición inicial y su destino con `simd_mix`.

---

## Funcionalidades / qué demuestra

- Render de 2000 partículas por GPU con un pipeline Metal mínimo (puntos).
- Conversión de texto a geometría con Core Graphics (rasterizar y leer píxeles).
- Ajuste de una nube de puntos de tamaño arbitrario a un número fijo de agentes.
- Animación por fases con interpolación lineal, dirigida por un contador de frames.
- Tamaño de partícula configurable (`pointSize`), pasado al vertex shader por buffer.
- Interfaz por código, pensada para fondo negro.

---

## Pruebas

`ParticleNumbersTests` (Swift Testing) cubre la lógica de `Particles/`:

- **`ParticleTargetFitter`**: `count` 0 → vacío; coincidencia exacta → sin cambios;
  entrada vacía → todo relleno; menos puntos que partículas → se conservan los
  originales y se rellena el resto; más puntos que partículas → muestreo uniforme
  ascendente que abarca todo el rango; el total nunca excede lo pedido.
- **`TextParticleMask`**: string vacío → sin puntos; un dígito produce puntos, todos
  dentro de `-1...1`; un glifo más denso (`8`) genera más puntos que uno simple
  (`1`); un dígito alto abarca casi todo el rango vertical; dos dígitos son más
  anchos que uno.

Correr los tests:

```bash
xcodebuild test \
  -project ParticleNumbers.xcodeproj \
  -scheme ParticleNumbers \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Cómo correr el proyecto

1. Clona el repo:
   ```bash
   git clone https://github.com/iostephano/Particle-Numbers.git
   ```
2. Abre `ParticleNumbers.xcodeproj` con **Xcode 26** (ver `.xcode-version`).
3. El objetivo mínimo es **iOS 26**. Elige un simulador de iPhone o un dispositivo
   con Metal y ejecuta (Cmd-R).
4. Toca **Generar número** para lanzar la animación.

---

## Cosas pendientes o limitadas (a propósito)

- **La animación se calcula en CPU.** Cada frame se interpolan las 2000 partículas
  en Swift y se vuelve a subir el buffer; el shader solo dibuja. Un compute shader
  movería ese trabajo a la GPU, pero para 2000 partículas la versión CPU va sobrada
  y es más fácil de leer.
- **Cantidad de partículas fija en 2000.** No se ajusta al tamaño de pantalla ni a
  la complejidad del número.
- **La máscara de texto usa la fuente del sistema a 200 pt.** Números muy anchos
  (99) quedan con menos densidad de partículas por trazo que los angostos (11).
- **Sin gestos ni personalización en la interfaz**: un solo botón. El foco está en
  el pipeline partículas + texto, no en la UI.
- El botón dispara un número aleatorio; no hay forma de pedir un número concreto.

---

## Autor

Stephano Portella

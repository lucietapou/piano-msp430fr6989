# Piano Digital — MSP430FR6989

Piano digital de 3 octavas implementado sobre la placa de desarrollo **MSP430FR6989 LaunchPad** de Texas Instruments. El proyecto combina código C con módulos en ensamblador MSP430 para lograr una síntesis de audio por hardware, lectura de teclado matricial con antirebote por interrupción y visualización en el LCD de segmentos integrado.

---

## Características

- **20 teclas** distribuidas en 3 octavas (Do4 a Si6), incluyendo sostenidos
- Generación de audio mediante **Timer A0 en modo toggle** sobre P1.0
- LCD de 6 dígitos de 14 segmentos con visualización de la nota activa
- Teclado matricial 4×4 con antirebote gestionado por interrupción (Timer A2)
- Arquitectura de **superbucle con modos de bajo consumo** (LPM3 en reposo)
- Reloj ACLK desde cristal externo LFXT a 32.768 kHz; SMCLK a 1 MHz para audio

---

## Hardware

| Componente | Descripción |
|---|---|
| MCU | MSP430FR6989 (FRAM, 16 bits) |
| Placa | MSP430FR6989 LaunchPad (MSP‑EXP430FR6989) |
| Audio | Altavoz o auricular en P1.0 (TA0.1) |
| Teclado | Matriz 4×4 — filas en P3.2, P4.7, P2.4, P2.5 / columnas en P2.0, P9.3, P4.3, P9.2 |
| LCD | LCD de segmentos integrado en la LaunchPad |
| LEDs | LED1 en P1.0 (rojo), LED2 en P9.7 (verde) |

---

## Estructura del proyecto

```
├── main.c               # Punto de entrada, superbucle y lógica de aplicación
├── snd.asm / snd.h      # Módulo de síntesis de audio (Timer A0)
├── teclado.asm / .h     # Teclado matricial con antirebote por IRQ
├── lcd.asm / .h         # Driver del LCD de 14 segmentos
├── st.asm / .h          # Sistema de tiempo (System Timer sobre Timer A2)
├── cs.asm / .h          # Configuración del sistema de reloj (LFXT)
├── pt.asm / .h          # Abstracción de puertos GPIO
├── msp430ports.asm / .h # Tabla de direcciones base de puertos
├── adc.asm / .h         # Driver ADC12 (canal A0)
└── frecuencia.asm / .h  # Detector de frecuencia por zero-crossing
```

---

## Mapa de teclas

El teclado matricial 4×4 se mapea a notas musicales de la siguiente forma:

```
┌─────┬─────┬─────┬─────┐
│ BEL │ Do# │ Re# │  +  │    ← Fila 0  (sostenidos / control)
├─────┼─────┼─────┼─────┤
│ Do  │ Re  │ Mi  │  -  │    ← Fila 1  (notas naturales oct. 4)
├─────┼─────┼─────┼─────┤
│ CR  │ Fa# │ Sol#│ La# │    ← Fila 2  (sostenidos)
├─────┼─────┼─────┼─────┤
│ Fa  │ Sol │ La  │ Si  │    ← Fila 3  (notas naturales)
└─────┴─────┴─────┴─────┘
 Col0  Col1  Col2  Col3
```

Las mayúsculas corresponden a sostenidos (Do#, Re#, Fa#, Sol#, La#). Las minúsculas son notas naturales. La octava se selecciona con `+` (subir) y `-` (bajar), rango de octava 4 a 6.

---

## Cómo funciona

### Síntesis de audio (`snd.asm`)

Se usan tablas precalculadas con el **semiperiodo** de cada nota para las octavas 4, 5 y 6:

```
TabOct4: SMCLK/262, SMCLK/277, ...   (Do4 a Si4)
TabOct5: SMCLK/523, SMCLK/554, ...   (Do5 a Si5)
TabOct6: SMCLK/1047, ...             (Do6 a Si6)
```

`sndNota` carga el semiperiodo en `TA0CCR1` en modo comparación con `OUTMOD_4` (toggle). La ISR `TA0_1_ISR` suma el semiperiodo a `TA0CCR1` en cada disparo, generando una onda cuadrada continua a la frecuencia de la nota.

### Teclado matricial (`teclado.asm`)

1. Las cuatro filas tienen **interrupción por flanco de bajada** habilitada.
2. Al detectar una pulsación, `kbTeclaISR` deshabilita las IRQs de fila y programa `TA2CCR1` para disparar ~10 ms después (antirebote).
3. `kbReboteISR` ejecuta `kbBarrido`, que activa cada columna una a una y lee las filas para identificar la tecla. El resultado se almacena en un **buffer circular** de 16 posiciones.
4. Al soltar la tecla, se invierte la polaridad de IRQ para detectar el flanco de subida y repetir el proceso.

### Sistema de tiempo (`st.asm`)

`Timer A2` en modo continuo con `ACLK` (32.768 kHz). `TA2CCR0` genera una IRQ periódica que incrementa un contador de 32 bits (`SystemTimer`). `stTime()` devuelve el tiempo actual en ticks, con resolución de ~30 µs y desbordamiento a los ~36 horas.

---

## Compilación

El proyecto está configurado para **Code Composer Studio (CCS)** con el compilador TI MSP430 `cl430`.

1. Importar el proyecto en CCS: *File → Import → CCS Projects*.
2. Seleccionar el dispositivo `MSP430FR6989`.
3. Compilar con *Project → Build All* (Ctrl+B).
4. Cargar con *Run → Debug* (F11).

Flags relevantes del compilador:
```
-vmspx --code_model=small --data_model=small
--use_hw_mpy=F5 --define=__MSP430FR6989__
```

---

## Dependencias

- [Code Composer Studio](https://www.ti.com/tool/CCSTUDIO) v12 o superior
- Compilador `ti-cgt-msp430` v21.6 o superior
- MSP430 DriverLib (incluido en CCS)

---

## Arquitectura de módulos

```
main.c
  ├── cs    →  Inicia LFXT (reloj base del sistema)
  ├── st    →  Sistema de tiempo global (Timer A2 CCR0)
  ├── lcd   →  Visualización en LCD de segmentos
  ├── pt    →  Abstracción de GPIO (configura LEDs)
  ├── teclado → Lectura de teclas (Timer A2 CCR1, IRQs de puerto)
  └── snd   →  Síntesis de audio (Timer A0 CCR1)
```

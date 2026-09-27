# MacroDelay - Addon para WoW 3.3.5a

*[English version](README.md)*

**MacroDelay** es un addon Lua/XML para World of Warcraft: Wrath of the Lich King (3.3.5a - Client Build 12340).

Fusiona dos addons pequeños y conocidos en uno solo: adiós al límite de 255 caracteres en las macros, y un comando `/in <segundos> <comando>` para retrasar cualquier comando de chat, emote o línea de una macro.

> **Estado actual:** `1.0.0`. Consulta [`CHANGELOG.md`](CHANGELOG.md) para el detalle de cada versión.

---

## 🛠️ Características principales

- **Macros sin el límite de 255 caracteres:** escribe una macro tan larga como necesites en la propia ventana de macros del juego (`Escape > Macros`, o `/macro`). A partir de 255 caracteres, MacroDelay guarda el texto completo y sustituye la macro por un proxy interno que la ejecuta; el resto (icono, nombre, arrastrar a las barras de acción) funciona exactamente igual. El límite de caracteres (1024 o 2048) es una opción configurable.
- **Comandos retrasados (`/in`, `/md`):** `/in <segundos> <comando>` (o `/md`, es lo mismo) ejecuta un comando de barra tras un retraso, para encadenar avisos, emotes o acciones cosméticas dentro de una misma macro.
- **Icono de minimapa:** arrastrable alrededor del borde, con posición guardada. Clic izquierdo abre el panel de opciones; clic derecho activa/desactiva el addon.
- **Botón en la barra de wcdpanel:** MacroDelay publica un data object LibDataBroker estándar, igual que Questie, GatherMate o RecipeRadar, así que `wcdpanel` lo detecta solo si está instalado. Sin dependencia en ningún sentido.
- **Panel de opciones:** activar/desactivar el addon y elegir el límite de caracteres de macro, desde la ventana estándar de Opciones de interfaz.
- **Ayuda dentro del juego:** una pestaña de Ayuda propia dentro del panel de opciones, con la sintaxis, ejemplos y las limitaciones de GCD/combate explicadas más abajo.

---

## 📂 Instalación

1. Clona o descarga este repositorio dentro del directorio de addons de tu cliente, en una carpeta llamada `MacroDelay`:
   `World of Warcraft 3.3.5a/Interface/AddOns/MacroDelay/`
2. Asegúrate de tener activada la opción **"Cargar accesorios antiguos"** (Load out of date addons) en la pantalla de selección de personajes.

---

## 🚀 Ejemplos de uso

**Avisos en banda:**
```
/cast Himno de esperanza
/s ¡Lanzando Himno de esperanza! + Maná para todos.
/in 4 /s Quedan 4 segundos de Himno.
/in 8 /s Himno de esperanza finalizado.
```

**Encadenar acciones cosméticas o habilidades sin GCD:**
```
/use Abalorio de poder
/in 1 /cast Furia sangrienta
/in 2 /y ¡Por la Horda!
```

---

## ⚠️ Limitaciones importantes

La API de Blizzard impide que las macros se salten el Global Cooldown (GCD) o disparen habilidades protegidas de forma automática en combate; es una limitación de diseño, pensada para evitar rotaciones scripteadas. `/in` siempre funciona para chat, emotes y macros de rol; en combate, solo es fiable para acciones no protegidas (texto, objetos cosméticos, alguna habilidad sin GCD activo). Fuera de combate no hay ninguna restricción de este tipo.

---

## 📁 Estructura del repositorio

```
MacroDelay.toc, MacroDelay.lua   # Punto de entrada del addon
Core/                            # Límite de macro, planificador de /in, panel de opciones, ayuda
UI/                              # Icono de minimapa, data object LibDataBroker
Libs/                            # LibStub, CallbackHandler-1.0, LibDataBroker-1.1 (de terceros)
```

El addon y este README se publican en GitHub; el `CHANGELOG.md` se mantiene en local.

---

## 📜 Licencia y créditos

Addon desarrollado desde cero para servidores de la comunidad basados en **AzerothCore**, inspirado en dos addons clásicos de WoW: *ncBiggerMacros* (nightcracker), por la ampliación del límite de caracteres, y *SlashIn* (Morsker), por el comando `/in`. No se ha reutilizado código de ninguno de los dos; MacroDelay reimplementa las mismas ideas como un addon único y autocontenido.

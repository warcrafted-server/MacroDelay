# MacroDelay - Addon para WoW 3.3.5a

*[English version](README.md)*

**MacroDelay** es un addon en Lua para World of Warcraft: Wrath of the Lich King (3.3.5a - Client Build 12340).

Hace dos cosas: se acaba el límite de 255 caracteres de las macros, y tienes un comando `/in <segundos> <comando>` para retrasar comandos de chat, emotes y otros comandos no protegidos.

> **Versión actual:** `1.2.0`.

---

## 🛠️ Características principales

- **Macros sin el límite de 255 caracteres:** escribe una macro tan larga como necesites en la ventana de macros del propio juego (`Escape > Macros`, o `/macro`). A partir de 255 caracteres, MacroDelay guarda el texto completo y cambia la macro por un botón interno que lo ejecuta; el icono, el nombre y arrastrarla a las barras de acción funcionan igual que siempre. Sirve tanto para macros generales como de personaje, y el límite (1024 o 2048) se elige en las opciones.
- **Comandos retrasados (`/in`, `/md`):** `/in <segundos> <comando>` (o `/md`, es lo mismo) ejecuta un comando de barra pasado un tiempo, para encadenar avisos o emotes dentro de una misma macro.
- **Icono de minimapa:** se arrastra alrededor del borde y recuerda su posición. Clic izquierdo abre las opciones; clic derecho activa o desactiva el addon. Se puede ocultar desde las opciones.
- **Botón en la barra de wcdpanel:** MacroDelay publica un objeto LibDataBroker estándar, como Questie, GatherMate o RecipeRadar, así que `wcdpanel` lo muestra solo en su barra. MacroDelay no incluye la librería: usa la que carga la barra, así que no depende de ella ni al revés. Mientras MacroDelay está en la barra de wcdpanel, wcdpanel oculta el icono del minimapa (así es como deja libre el minimapa); para recuperarlo, quita MacroDelay de la barra de wcdpanel.
- **Panel de opciones:** activar o desactivar el addon, elegir el límite de caracteres y mostrar u ocultar el icono del minimapa, desde la ventana estándar de Opciones de interfaz.
- **Ayuda dentro del juego:** una pestaña de Ayuda en el panel de opciones con la sintaxis, ejemplos y limitaciones.

---

## 📂 Instalación

1. Descarga este repositorio en el directorio de addons de tu cliente, en una carpeta que se llame exactamente `MacroDelay`:
   `World of Warcraft 3.3.5a/Interface/AddOns/MacroDelay/`
2. Activa **"Cargar accesorios antiguos"** (Load out of date addons) en la pantalla de selección de personajes.

> **Al actualizar:** cierra el cliente de WoW del todo y vuelve a abrirlo, porque ha cambiado la lista de archivos del addon y `/reload` no lo recoge. Las macros largas guardadas con versiones anteriores se convierten solas la primera vez que entras.

---

## 🚀 Ejemplos de uso

**Avisos en banda:**
```
/cast Himno de esperanza
/s ¡Lanzando Himno de esperanza! Maná para todos.
/in 4 /s Quedan 4 segundos de Himno.
/in 8 /s Himno de esperanza terminado.
```

**Secuencia de rol:**
```
/e alza un estandarte.
/in 2 /y ¡Por la Horda!
/in 4 /e carga hacia delante.
```

**Comandos de GM (solo staff):** un "." seguido de letras en cualquier parte del texto de una macro lo intercepta el servidor en cuanto se pulsa, antes de que `/in` llegue a procesarlo. Pásalo envuelto en `RunGMCommand`, que añade el "." solo cuando se ejecuta de verdad:
```
/in 4 /run RunGMCommand('gh teleport')
```

---

## ⚠️ Limitaciones

Lo que ejecuta `/in` lo lanza el código del addon, no una pulsación tuya, así que Blizzard bloquea todo lo protegido: lanzar hechizos (`/cast`), usar objetos (`/use`), cambiar de objetivo, etc. Pasa dentro y fuera de combate. Si lo intentas, MacroDelay te avisa en el chat en vez de fallar sin decir nada. Usa `/in` para chat, emotes, scripts `/run` y otros comandos no protegidos; las acciones protegidas solo funcionan en las líneas sin `/in`, que se ejecutan en el momento de pulsar la macro.

Las macros largas no se pueden guardar en combate, y si haces `/reload` en combate vuelven a funcionar en cuanto termina.

---

## 📁 Estructura del repositorio

```
MacroDelay.toc, MacroDelay.lua   # Punto de entrada, datos guardados y eventos
Core/                            # Límite de caracteres, /in, panel de opciones, ayuda
UI/                              # Icono de minimapa, objeto LibDataBroker
```

---

## 📜 Licencia y créditos

**MacroDelay** © 2026 WarCrafted. Se publica bajo la **WarCrafted Non-Commercial License** ([WNCL-1.0](LICENSE), `LicenseRef-WNCL-1.0`).

### Puedes
- Usarlo gratis, en cualquier servidor, para uso personal y otros usos no comerciales
- Estudiarlo, modificarlo y hacer tus propias versiones
- Compartirlo, o compartir tus versiones modificadas, gratis

### Debes
- Mantener el archivo [LICENSE](LICENSE) y los avisos de copyright y de autoría
- En cualquier versión modificada que publiques, acreditar a WarCrafted como autor original, enlazar este repositorio (https://github.com/warcrafted-server/MacroDelay) y dejar claro qué has cambiado

### No puedes
- Venderlo, cobrar por acceder a él o por copias, ni sacar dinero de él de ninguna otra forma (anuncios, servicios de pago...) sin permiso escrito de WarCrafted
- Quitar los créditos ni presentar una versión modificada como obra original tuya

La WNCL-1.0 es una licencia propia no comercial, no una licencia de código abierto aprobada por la OSI. La versión 1.1.0 se publicó con GPL v3 y mantiene esa licencia.

### Inspiración
El código de MacroDelay es propio de WarCrafted, escrito desde cero. Las ideas vienen de dos addons clásicos: **SlashIn**, de Morsker (el comando `/in`), y **ncBiggerMacros**, de nightcracker (macros de más de 255 caracteres mediante un botón seguro).

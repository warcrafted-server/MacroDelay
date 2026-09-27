# MacroDelay (WoW 3.3.5)

**MacroDelay** es un addon ligero y potente para **World of Warcraft: Wrath of the Lich King (3.3.5a)** diseñado para llevar la automatización de tus macros al siguiente nivel. Esta herramienta fusiona la libertad de **escribir sin límite de caracteres** con la capacidad de **programar la ejecución de comandos con retrasos temporales precisos**.

Optimiza tu interfaz, gestiona tus rotaciones fuera de combate, automatiza avisos informativos para tu banda o crea secuencias de rol complejas de forma eficiente.

## ✨ Características principales

*   **Macros sin límites:** Olvídate de la restricción nativa de 255 caracteres. Escribe scripts y secuencias tan largas como necesites en una ventana de edición ampliada.
*   **Secuenciación temporal (`/in`):** Introduce retrasos en segundos para tus comandos de barra (`/slash`). Permite encadenar acciones, textos o habilidades con una sintaxis simple: `/in <segundos> <comando>`.
*   **Integración nativa:** Se integra perfectamente con el sistema de macros por defecto de WoW, garantizando una configuración limpia y sin configuraciones complejas.
*   **Rendimiento optimizado:** Desarrollado con un código de bajo consumo que no afecta a tus fotogramas por segundo (FPS) ni a la memoria RAM del juego, ideal para entornos de banda (raids).

## 🚀 Ejemplos de uso

### Automatización de avisos en Raid
```warcraft
/cast Himno de esperanza
/s ¡Lanzando Himno de esperanza! + Mana para todos.
/in 4 /s Quedan 4 segundos de Himno.
/in 8 /s Himno de esperanza finalizado.
```

### Encadenar comandos cosméticos o habilidades sin GCD
```warcraft
/use Abalorio de poder
/in 1 /cast Furia sangrienta
/in 2 /y ¡Por la Horda!
```

## 🛠️ Instalación

1. Descarga el repositorio como un archivo `.zip`.
2. Descomprime el archivo en tu carpeta de WoW: `Interface\AddOns\`.
3. Asegúrate de que la carpeta se llame exactamente `MacroDelay`.
4. Inicia el juego y activa la opción **"Cargar accesorios antiguos"** en la pantalla de selección de personajes si es necesario.

## ⚠️ Notas importantes (Restricciones del juego)
Debido a las limitaciones de la API de Blizzard orientadas a combatir el juego automatizado, el comando `/in` **no puede saltarse el Global Cooldown (GCD) ni ejecutar habilidades protegidas de forma automática en combate**. Está diseñado principalmente para mensajes de texto, emotes, macros de rol, uso de objetos cosméticos o habilidades específicas fuera de combate.

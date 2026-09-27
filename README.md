# MacroDelay - WoW 3.3.5a Addon

*[Versión en castellano](README.es.md)*

**MacroDelay** is a Lua addon for World of Warcraft: Wrath of the Lich King (3.3.5a - Client Build 12340).

It does two things: no more 255-character limit on macros, and a `/in <seconds> <command>` slash command to delay chat commands, emotes and other unprotected commands.

> **Current version:** `1.2.0`.

---

## 🛠️ Main Features

- **Macros without the 255-character limit:** write as long a macro as you need in the game's own macro window (`Escape > Macros`, or `/macro`). Past 255 characters, MacroDelay stores the full text and swaps the macro for an internal proxy button that runs it; icon, name and dragging it onto your action bars work exactly as before. Works for both general and character macros, and the limit (1024 or 2048) is a setting.
- **Delayed commands (`/in`, `/md`):** `/in <seconds> <command>` (or `/md`, same thing) runs a slash command after a delay, so you can chain announcements or emotes inside one macro.
- **Minimap icon:** draggable around the edge, with saved position. Left-click opens the options panel; right-click turns the addon on/off. It can be hidden from the options panel.
- **Button on the wcdpanel bar:** MacroDelay publishes a standard LibDataBroker data object, like Questie, GatherMate or RecipeRadar, so `wcdpanel` shows it on its bar on its own. MacroDelay doesn't ship the library: it uses the one the bar loads, so there's no dependency either way. While MacroDelay is on the wcdpanel bar, wcdpanel hides the minimap icon (that's how it frees up the minimap); to get the icon back, take MacroDelay off the wcdpanel bar.
- **Options panel:** turn the addon on/off, pick the macro character limit and show/hide the minimap icon, from the standard Interface Options window.
- **In-game help:** a Help tab under the options panel with the syntax, examples and limitations.

---

## 📂 Installation

1. Download this repository into your client's addons directory, in a folder named exactly `MacroDelay`:
   `World of Warcraft 3.3.5a/Interface/AddOns/MacroDelay/`
2. Make sure **"Load out of date addons"** is enabled on the character selection screen.
3. Disable **ncBiggerMacros** and **SlashIn** if you have them: they replace the same parts of the macro window and the `/in` command.

> **When updating:** fully close and reopen the WoW client, since the list of addon files changed and `/reload` doesn't pick that up. Long macros saved with earlier versions are converted automatically the first time you log in.

---

## 🚀 Usage examples

**Raid announcements:**
```
/cast Hymn of Hope
/s Hymn of Hope going out! Mana for everyone.
/in 4 /s 4 seconds left on the Hymn.
/in 8 /s Hymn of Hope done.
```

**Roleplay sequence:**
```
/e raises a banner.
/in 2 /y For the Horde!
/in 4 /e charges forward.
```

**GM commands (staff only):** a `.` followed by letters anywhere in a macro's text gets intercepted by the server the instant the macro is clicked, before `/in` ever runs. Wrap the GM command in `RunGMCommand`, which adds the `.` only when it actually runs:
```
/in 4 /run RunGMCommand('gh teleport')
```

---

## ⚠️ Limitations

What `/in` runs is fired by the addon's own code, not by a key press, so Blizzard blocks anything protected: casting spells (`/cast`), using items (`/use`), targeting, and so on. That applies in and out of combat. If you try, MacroDelay tells you in chat instead of failing silently. Use `/in` for chat, emotes, `/run` scripts and other unprotected commands; protected actions only work on lines without `/in`, which run the moment you press the macro.

Long macros can't be saved in combat, and if you `/reload` in combat they start working again as soon as combat ends.

---

## 📁 Repository Structure

```
MacroDelay.toc, MacroDelay.lua   # Addon entry point, saved data and events
Core/                            # Macro character limit, /in, options panel, help
UI/                              # Minimap button, LibDataBroker data object
```

---

## 📜 License & Credits

**MacroDelay** © 2026 WarCrafted. Released under the **WarCrafted Non-Commercial License** ([WNCL-1.0](LICENSE), `LicenseRef-WNCL-1.0`).

### You can
- Use it for free, on any server, for personal and other non-commercial purposes
- Study it, modify it and build your own versions
- Share it or your modified versions, for free

### You must
- Keep the [LICENSE](LICENSE) file and the copyright and author notices
- In any modified version you publish, credit WarCrafted as the original author, link to this repository (https://github.com/warcrafted-server/MacroDelay) and make clear what you changed

### You can't
- Sell it, charge for access or copies, or make money from it in any other way (ads, paid services...) without written permission from WarCrafted
- Remove the credits or present a modified version as your own original work

WNCL-1.0 is a custom non-commercial license, not an OSI-approved open source license. Version 1.1.0 was published under the GPL v3 and keeps that license.

### Inspiration
MacroDelay's code is WarCrafted's own, written from scratch. The ideas come from two classic addons: **SlashIn** by Morsker (the `/in` command) and **ncBiggerMacros** by nightcracker (macros over 255 characters through a secure button).

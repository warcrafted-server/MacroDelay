# MacroDelay - WoW 3.3.5a Addon

*[Versión en castellano](README.es.md)*

**MacroDelay** is a Lua/XML addon for World of Warcraft: Wrath of the Lich King (3.3.5a - Client Build 12340).

It merges two small, well-known addons into one: no more 255-character limit on macros, and a `/in <seconds> <command>` slash command to delay any chat command, emote, or macro line.

> **Current status:** `1.0.0`. See [`CHANGELOG.md`](CHANGELOG.md) for the full version history.

---

## 🛠️ Main Features

- **Macros without the 255-character limit:** write as long a macro as you need in the game's own macro window (`Escape > Macros`, or `/macro`). Past 255 characters, MacroDelay stores the full text and swaps the macro for an internal proxy that runs it; everything else about the macro (icon, name, drag onto action bars) works exactly as before. The character limit (1024 or 2048) is a setting.
- **Delayed commands (`/in`, `/md`):** `/in <seconds> <command>` (or `/md`, same thing) runs a slash command after a delay, so you can chain announcements, emotes, or cosmetic actions inside one macro.
- **Minimap icon:** draggable around the edge, with saved position. Left-click opens the options panel; right-click toggles the addon on/off.
- **Button on the wcdpanel bar:** MacroDelay publishes a standard LibDataBroker data object, the same way Questie, GatherMate or RecipeRadar do, so `wcdpanel` picks it up on its own if it's installed. No dependency either way.
- **Options panel:** enable/disable the addon and pick the macro character limit, from the standard Interface Options window.
- **In-game help:** a dedicated Help tab under the options panel with syntax, examples, and the GCD/combat limitations explained below.

---

## 📂 Installation

1. Clone or download this repository into your client's addons directory, in a folder named `MacroDelay`:
   `World of Warcraft 3.3.5a/Interface/AddOns/MacroDelay/`
2. Make sure the **"Load out of date addons"** option is enabled on the character selection screen.

---

## 🚀 Usage examples

**Raid announcements:**
```
/cast Hymn of Hope
/s Hymn of Hope going out! Mana for everyone.
/in 4 /s 4 seconds left on the Hymn.
/in 8 /s Hymn of Hope done.
```

**Chaining cosmetic actions or off-GCD abilities:**
```
/use Trinket of Power
/in 1 /cast Bloodrage
/in 2 /y For the Horde!
```

**GM commands (staff only):** a `.` followed by letters anywhere in a macro's text gets intercepted by the server the instant the macro is clicked, before `/in` ever runs. To dodge that, wrap the GM command in `RunGMCommand`, which adds the `.` only when it actually runs:
```
/in 4 /run RunGMCommand('gh teleport')
```

---

## ⚠️ Important limitations

Blizzard's API blocks macros from skipping the Global Cooldown (GCD) or firing protected abilities automatically in combat, by design (it's meant to stop scripted rotations). `/in` always works for chat, emotes, and roleplay macros; in combat, it's only reliable for actions that aren't protected (text, cosmetic items, a few off-GCD abilities). Outside combat there are no such restrictions.

---

## 📁 Repository Structure

```
MacroDelay.toc, MacroDelay.lua   # Addon entry point
Core/                            # Macro character limit, /in scheduler, options panel, help
UI/                              # Minimap button, LibDataBroker data object
Libs/                            # LibStub, CallbackHandler-1.0, LibDataBroker-1.1 (third-party)
```

The addon itself and this README are published on GitHub; `CHANGELOG.md` is kept locally.

---

## 📜 License & Credits

Built from scratch for community servers running **AzerothCore**, inspired by two long-standing WoW addons: *ncBiggerMacros* (nightcracker) for the macro character limit, and *SlashIn* (Morsker) for the `/in` command. No code from either was reused; MacroDelay reimplements the same ideas as a single, self-contained addon.

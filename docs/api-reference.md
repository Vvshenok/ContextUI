# API Reference

Every public method is visible in the main module. Chainable methods return the same context.

## Methods {#methods}

| Method | Returns | Purpose |
| --- | --- | --- |
| ContextUI.GetTheme(name, overrides?) | Theme | Copy a named preset and apply optional overrides. |
| ContextUI.new(target?, config?) | Context | Create a client context. Does not bind or allocate a surface. |
| SetTitle(text) / SetDescription(text) | Context | Create or update the named heading/description. |
| AddText(text, config?) | Context | Append a text row. |
| AddImage(image, config?) / SetIcon(image) | Context | Append an image or create/update Icon. |
| AddStat(label, value, config?) / SetStat(id, value) | Context | Add or update a string/number stat. |
| AddProgress(label, value, config?) / SetProgress(id, value) | Context | Add or update a clamped 0–1 progress fraction. |
| AddDivider(config?) / AddSection(text, config?) | Context | Append a rule or section heading. |
| AddKeybind(text, key, config?) | Context | Append a hint; does not register an action. |
| AddButton(text, callback, config?) | Context | Append a single action. |
| AddButtonGroup(buttons, config?) | Context | Append ButtonSpec records with Text, Callback, Disabled?, KeyCode?. |
| AddCustom(gui, config?) | Context | Mount an existing GuiObject. |
| SetText(id, text) / SetImage(id, image) | Context | Update an existing text field or Image component. |
| SetButtonEnabled(id, enabled) | Context | Enable or disable a Button or ButtonGroup. |
| Remove(id) / Clear() | Context | Remove one component or every component. |
| SetExpandable(enabled, label?) | Context | Add/remove the built-in More/Less action. |
| Expand() / Collapse() / ToggleExpanded() | Context | Reveal/hide ExpandedOnly rows without reconstructing them. |
| IsExpanded() | boolean | Read expansion state. |
| SetInteractive(boolean?) / IsInteractive() | Context / boolean | Override or read automatic interaction behavior. |
| SetTheme(nameOrOverrides, overrides?) | Context | Reset to a named preset, or merge a table into the current theme; optionally apply additional overrides. |
| SetTarget(target?) | Context | Move the binding to a new target, or switch to manual. |
| Bind() / Unbind() | Context | Connect/disconnect target input. Unbind also hides. |
| Show(position?) / Hide() | Context | Open at a screen-space anchor or close. |
| Pin() / Unpin() | Context | Keep open at the current position or release the pin. |
| GetState() | State | Read current interaction state. |
| GetSurface() | CanvasGroup? | Read the lazy surface, or nil before first show/after destroy. |
| Use(extension) | Context | Install a named extension and own its cleanup. |
| Destroy() | () | Release inputs, UI, owned tasks, signals, tweens, and extensions. Idempotent. |

## Signals and constants {#signals-and-constants}

| Option | Behavior |
| --- | --- |
| context.StateChanged | `Signal<State>`: Connect, Once, Disconnect through the returned connection. |
| context.ExpandedChanged | `Signal<boolean>`: true after expansion, false after collapse. |
| ContextUI.Themes | Frozen preset tables keyed by ThemeName. |
| ContextUI.Version | 1.0.0 |
| ContextUI.Credits | Interactive Studios |

## Public types {#public-types}

The main module exports Context, Config, Theme, ThemeName, ThemeOverrides, Component, ButtonConfig, StatConfig, AnimationConfig, Target, State, and Extension. The Types child also exports ThemeOverrides, ComponentConfig, CustomConfig, ButtonSpec, Signal, Connection, and resolved internal configuration types.

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)
local contexts: {ContextUI.Context} = {}
local options: ContextUI.Config = { MaxWidth = 280 }
```

## Errors and ownership {#errors-and-ownership}

Methods that change a destroyed context raise an error, except idempotent Destroy(), Hide(), and Unbind(). GetState() remains Destroyed. Keep IDs unique. Do not share a single custom GuiObject between contexts. Developer-created tasks spawned outside library callbacks remain the developer’s responsibility.

# Interaction

Passive contexts follow the pointer. Adding visible buttons, a button group, or interactive custom GUI makes the panel dock when the player approaches it. Leaving the target also docks an interactive panel immediately.

## Getting from the target to the panel

The context keeps its current rendered position when it docks. A short close delay and a bounded safe corridor let the pointer cross the gap. Once inside the panel, it stays open until the pointer leaves. The corridor expires; it cannot hold a forgotten panel open forever.

[Positioning](positioning.md) explains the related options.

## Input methods

| Input | Behavior |
| --- | --- |
| Mouse | Hover a target; move onto the surface to use its controls. |
| Touch | Tap a GUI or world target to open a docked panel. Tapping outside an unpinned surface starts its close delay. |
| Gamepad GUI selection | Selecting a bound GUI target opens a docked panel and selects its first available built-in action. |
| Keyboard | A button's `KeyCode` activates it while that context is focused. Text entry and processed game input suppress shortcuts. |

Built-in buttons use Roblox's `Activated` event. `AddKeybind()` only displays a hint; use `AddButton(..., { KeyCode = ... })` to register an action. World gamepad interaction can call `Show()` from your existing selection or proximity system.

The most recently opened context receives keyboard actions. Clicking a pinned surface or selecting one of its controls gives that context focus. Escape or ButtonB dismisses the focused context when Roblox has not already processed the input.

## Pinning and dismissal

`Pin()` keeps a context open at its current position while other contexts appear. `Unpin()` releases that hold. `Hide()` can always dismiss it. Pins do not automatically arrange themselves or support dragging; see [Pinning](pinning.md).

## Application callbacks

Buttons receive their context as the callback argument. They can yield, and their tracked tasks are canceled on destruction. Reported callback errors do not prevent cleanup.

ContextUI only presents client-side controls. Use your existing server validation for equipment, purchases, currency, and permissions.

# Positioning, following, and docking

A context starts near its screen-space anchor, using `Offset`. It flips to the other side near an edge and clamps to the usable viewport. `MaxWidth` limits width; it does not force every panel to be that wide. Height overflow scrolls.

## Follow the mouse

Bound contexts start in `Following`. Movement is smoothed using the elapsed frame time. Interactive contexts become `Docked` as the pointer approaches or leaves the target, keeping the surface within reach.

```lua
local context = ContextUI.new(button, {
    Offset = Vector2.new(14, 16),
    MaxWidth = 280,
    MaxHeight = 400,
    EdgePadding = 8,
    CloseDelay = 0.18,
    TransitionGrace = 0.6,
    DockThreshold = 3,
})
```

`SafePadding` widens the transition corridor; `TransitionGrace` limits its duration. Avoid long delays that leave unrelated panels on screen.

## Explicit positioning

`Show(Vector2)` accepts a screen-space anchor, then applies the offset, flipping, and clamping. Omit the target for a manually controlled context. With `Offset = Vector2.zero`, an anchor with enough space becomes the panel's top-left corner.

When anchoring to a GUI object's `AbsolutePosition`, convert it to screen coordinates:

```lua
local GuiService = game:GetService("GuiService")
local inset = GuiService:GetGuiInset()
local anchor = button.AbsolutePosition + inset + button.AbsoluteSize
context:Show(anchor):Pin()
```

The library performs this conversion internally for input hit testing and gamepad selection.

## Resizing and viewport changes

Live values, themes, and expanded rows can change the measured size. The panel animates to its new size and remains constrained by the viewport, including while docked or pinned. See [Animations](animations.md) for reduced-motion options and [configuration](advanced-configuration.md) for all defaults.

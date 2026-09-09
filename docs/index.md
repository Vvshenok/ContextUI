# ContextUI

**Context and hover panels for Roblox, by Vvshenok / Interactive Studios.**

A short hint should stay small. An item inspector should have room for values and actions. ContextUI handles both with the same API, including the transition from following the pointer to a panel you can interact with.

[Download the module](https://github.com/Vvshenok/ContextUI/releases/latest/download/ContextUI.rbxm){ .md-button .md-button--primary }
[Get started](getting-started.md){ .md-button }

## Start with what you need

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)

local context = ContextUI.new(script.Parent, { Theme = "Midnight" })
    :SetTitle("Asterblade")
    :AddStat("Damage", 75)
    :AddProgress("Durability", 0.86)
    :AddButton("Inspect", function(view)
        view:SetDescription("A balanced blade with a little history.")
    end)
    :Bind()
```

Run this from a LocalScript under a GUI target. [Installation](installation.md) is one module download.

## What it handles

- **Compact panels:** size follows the content, with wrapping and scrolling at your limits.
- **Reachable actions:** mouse following, approach detection, docking, and a bounded transition corridor.
- **Reusable rows:** titles, text, images, stats, progress, dividers, sections, key hints, buttons, groups, and custom GUI.
- **Live updates and expansion:** update values or reveal details without rebuilding their instances.
- **GUI and world targets:** GuiObject, BasePart, Model, Attachment, or manual positioning.
- **Pinning:** keep an inspector open while opening another context.
- **Nine themes:** switch presets or customize their colors, fonts, spacing, borders, and controls.
- **Owned cleanup:** release bindings, surfaces, tweens, signals, and extension resources with `Destroy()`.

## Explore the library

[Contexts](contexts.md) explains creation and ownership. [Components](components.md) covers the available rows. Read [interaction](interaction.md) for input behavior and [positioning](positioning.md) for following and docking. The [theme guide](themes.md) shows every preset and override token.

The [API reference](api-reference.md) lists signatures. [Examples](examples.md) covers common integrations, including attribute-driven values and custom content.

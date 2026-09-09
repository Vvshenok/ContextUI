# ContextUI

[![docs](https://img.shields.io/github/actions/workflow/status/Vvshenok/ContextUI/docs.yml?branch=main&label=docs&style=plastic)](https://github.com/Vvshenok/ContextUI/actions/workflows/docs.yml)
[![Version](https://img.shields.io/badge/version-v1-blue?style=plastic)](https://github.com/Vvshenok/ContextUI/releases/latest)
[![License](https://img.shields.io/github/license/Vvshenok/ContextUI?style=plastic)](LICENSE)
[![Roblox Luau](https://img.shields.io/badge/Roblox-Luau-red?style=plastic)](https://create.roblox.com/docs/luau)

ContextUI is a context and hover UI library for Roblox by **Vvshenok / Interactive Studios**. Start with a compact hint, then add live values, progress, expandable details, or actions to the same panel.

Contexts follow the pointer. Interactive panels dock as you approach them so their buttons stay within reach. You can attach them to GUI or world objects, pin them for comparison, and switch between nine built-in themes.

## Installation

Download **[ContextUI.rbxm](https://github.com/Vvshenok/ContextUI/releases/latest/download/ContextUI.rbxm)** from the latest release. In Studio, right-click **ReplicatedStorage → Insert from File** and select it. Keep the module and its children together, then require it from a LocalScript.

## Basic usage

Place this LocalScript under your GUI button:

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)

local context = ContextUI.new(script.Parent, { Theme = "Midnight" })
    :SetTitle("Asterblade")
    :AddStat("Damage", 75)
    :AddButton("Inspect", function(view)
        view:SetDescription("A balanced blade with a little history.")
    end)
    :Bind()
```

Update rows with methods such as `SetStat()` and `SetProgress()`. Call `Destroy()` when you remove the feature; destroying the target also cleans up its context.

**Themes:** Default, Dark, Light, Glass, Midnight, Minimal, Terminal, Neon, and Soft. Use `context:SetTheme("Light")` to switch, or pass overrides to match your interface.

[Documentation](https://vvshenok.github.io/ContextUI/) · [Getting started](https://vvshenok.github.io/ContextUI/getting-started/) · [Themes](https://vvshenok.github.io/ContextUI/themes/) · [API reference](https://vvshenok.github.io/ContextUI/api-reference/) · [Examples](https://vvshenok.github.io/ContextUI/examples/)

Released under the [MIT License](LICENSE).

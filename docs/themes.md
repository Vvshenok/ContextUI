# Themes

Nine presets change the panel's palette, typography, spacing, shape, and controls. Switch them by name or require an individual preset ModuleScript. Custom GUI keeps its own styling.

<div class="theme-grid">
<div class="theme-sample" style="background:#17191f;color:#f4f5f8;border-radius:6px;"><strong>Default</strong><span style="color:#aeb4c1">Equipment &nbsp; · &nbsp; 75 damage</span><div class="theme-meter" style="background:#81a8ff"></div><span class="theme-action" style="background:#2b303c;color:#f4f5f8">Inspect</span></div>
<div class="theme-sample" style="background:#191919;color:#F2F0EB;border-radius:5px;"><strong>Dark</strong><span style="color:#ACA9A2">Equipment &nbsp; · &nbsp; 75 damage</span><div class="theme-meter" style="background:#E7BE78"></div><span class="theme-action" style="background:#30302F;color:#F4E8CD">Inspect</span></div>
<div class="theme-sample" style="background:#FFFFFF;color:#172338;border-radius:9px;"><strong>Light</strong><span style="color:#536174">Equipment &nbsp; · &nbsp; 75 damage</span><div class="theme-meter" style="background:#2563EB"></div><span class="theme-action" style="background:#2563EB;color:#FFFFFF">Inspect</span></div>
<div class="theme-sample" style="background:#233448;color:#F3F9FF;border-radius:12px;"><strong>Glass</strong><span style="color:#C5D9E8">Equipment &nbsp; · &nbsp; 75 damage</span><div class="theme-meter" style="background:#8EDCF5"></div><span class="theme-action" style="background:#3C586F;color:#FFFFFF">Inspect</span></div>
<div class="theme-sample" style="background:#15192D;color:#EEEFFF;border-radius:8px;"><strong>Midnight</strong><span style="color:#ABB0D0">Equipment &nbsp; · &nbsp; 75 damage</span><div class="theme-meter" style="background:#B2A1F5"></div><span class="theme-action" style="background:#343051;color:#F3ECFF">Inspect</span></div>
<div class="theme-sample" style="background:#F5F5F3;color:#24282C;border-radius:2px;"><strong>Minimal</strong><span style="color:#666B6F">Equipment &nbsp; · &nbsp; 75 damage</span><div class="theme-meter" style="background:#333B42"></div><span class="theme-action" style="background:#E5E7E7;color:#24282C">Inspect</span></div>
<div class="theme-sample" style="background:#101914;color:#CBF0D6;border-radius:0px;font-family:monospace;"><strong>Terminal</strong><span style="color:#8FAB98">Equipment &nbsp; · &nbsp; 75 damage</span><div class="theme-meter" style="background:#7CDA9C"></div><span class="theme-action" style="background:#1F3528;color:#BCEAC9">Inspect</span></div>
<div class="theme-sample" style="background:#1B1429;color:#F5EDFF;border-radius:7px;"><strong>Neon</strong><span style="color:#BBB0D1">Equipment &nbsp; · &nbsp; 75 damage</span><div class="theme-meter" style="background:#69E4DB"></div><span class="theme-action" style="background:#432752;color:#F9DFFF">Inspect</span></div>
<div class="theme-sample" style="background:#F5EEE6;color:#493A37;border-radius:14px;"><strong>Soft</strong><span style="color:#7F6861">Equipment &nbsp; · &nbsp; 75 damage</span><div class="theme-meter" style="background:#AD6655"></div><span class="theme-action" style="background:#E9CEBF;color:#51372F">Inspect</span></div>
</div>

These swatches summarize the palettes. Roblox renders the actual fonts, spacing, and transparency.

## Choose a preset

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)

local context = ContextUI.new(script.Parent, { Theme = "Midnight" })
    :SetTitle("Asterblade")
    :AddStat("Damage", 75)
    :AddProgress("Durability", 0.86)
    :Bind()

context:SetTheme("Light")
```

| Preset | Character |
| --- | --- |
| Default | Compact, neutral slate with BuilderSans and a restrained blue accent. |
| Dark | Opaque charcoal with warm text and amber progress. |
| Light | White panels, dark text, and solid blue actions. |
| Glass | Translucent blue-gray panels, cool text, and rounded controls. |
| Midnight | Navy panels with lavender accents and more breathing room. |
| Minimal | Tight spacing, almost square corners, thin progress, and no visible border. |
| Terminal | Monospaced text, square corners, and muted green controls. |
| Neon | Deep plum with cyan progress and a visible violet border. |
| Soft | Warm cream, peach controls, and generous rounded corners. |

Glass uses transparency. It does not add a blur effect or change Lighting. Check its contrast against your game's backgrounds. Compact presets use smaller controls; increase text and button sizes for touch-heavy interfaces.

## Presets plus overrides

Use `GetTheme(name, overrides?)` to obtain an independent, mutable theme table. Pass it to a constructor, or pass overrides alongside a name when switching:

```lua
local theme = ContextUI.GetTheme("Midnight", {
    Accent = Color3.fromRGB(125, 218, 192),
    TextSize = 14,
    ButtonHeight = 34,
})

local context = ContextUI.new(button, { Theme = theme })
context:SetTheme("Soft", { CornerRadius = 10, ButtonCornerRadius = 5 })
```

`SetTheme("Name")` resets all theme fields to that preset. `SetTheme({ ... })` merges only the supplied fields into the context's current theme. Both restyle the existing rows and remeasure the panel without replacing the component instances.

```lua
context:SetTheme({ Padding = 12, Gap = 7 })
context:SetTheme("Default")
```

## Theme modules and shared presets

`ContextUI.Themes` exposes the frozen built-in tables:

```lua
local context = ContextUI.new(button, { Theme = ContextUI.Themes.Terminal })
```

Each preset also exists as a ModuleScript under the library:

```lua
local Midnight = require(game.ReplicatedStorage.ContextUI.Themes.Midnight)
local context = ContextUI.new(button, { Theme = Midnight })
```

Shared presets cannot be edited. Use `GetTheme()` for a reusable custom table. Every context copies its resolved theme, so later changes to your table do not silently change an existing panel.

## Color and font tokens {#color-and-type-tokens}

| Field | Used for |
| --- | --- |
| Background / BackgroundTransparency | Panel fill; transparency ranges from 0 to 1. |
| Text / SecondaryText | Primary text and descriptions/stat labels. |
| SectionText | Section headings. |
| Accent | Progress fill. |
| Button / ButtonHover | Resting and hovered action backgrounds. |
| ButtonText | Enabled action text, independent of panel text. |
| ProgressTrack | Unfilled part of a progress bar. |
| Stroke / StrokeTransparency / StrokeThickness | Border color, transparency, and pixel thickness. |
| Font / TitleFont | Enum.Font values for body and title/section text. |
| TextSize / TitleSize | Positive pixel sizes. Default uses 13 and 14. |

## Geometry tokens {#geometry-tokens}

| Field | Default | Used for |
| --- | --- | --- |
| Padding | 8 | Outer content padding. |
| Gap | 5 | Space between rows and wrapped actions. |
| CornerRadius | 6 | Panel corner radius. |
| ButtonCornerRadius | 3 | Action corner radius. |
| ButtonPadding | 9 | Horizontal action padding. |
| ButtonHeight | 26 | Minimum action height; wrapped captions can grow. |
| ProgressHeight | 4 | Progress track thickness. |
| IconSize | 32 | Preferred square image size. |
| StatGap | 22 | Preferred gap between a stat label and its value. |

Theme numeric values must be finite and nonnegative. Text, button, progress, and icon sizes must be positive. Unknown fields, unknown preset names, wrong types, and out-of-range transparency produce descriptive errors.

## Existing override tables {#override-only-what-you-need}

Existing partial tables still work. When you override `Text`, `SecondaryText`, `Button`, or `CornerRadius` without its more specific new token, the library also updates `ButtonText`, `SectionText`, `ProgressTrack`, or half-radius `ButtonCornerRadius`, respectively. Supply both fields to style them separately.

## Responsive limits {#responsive-limits}

`MaxWidth`, `MinWidth`, and `MaxHeight` are context configuration, separate from the theme. The viewport constrains the final panel; overflowing content scrolls. See [configuration](advanced-configuration.md) and [positioning](positioning.md).

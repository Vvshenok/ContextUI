# Components

Compose the information and controls that fit your interaction.

## Available components {#available-components}

| Option | Behavior |
| --- | --- |
| SetTitle(text) | One primary title; ID Title. |
| SetDescription(text) | One secondary description; ID Description. |
| AddText(text, config?) | A wrapping text row. |
| AddImage(asset, config?) / SetIcon(asset) | An image at Theme.IconSize. SetIcon uses ID Icon. |
| AddStat(label, value, config?) | A label and right-aligned value. |
| AddProgress(label, fraction, config?) | A label with a 0–1 progress fill. |
| AddDivider(config?) | A subtle horizontal rule. |
| AddSection(text, config?) | A section heading within the same context. |
| AddKeybind(text, key, config?) | A display-only key hint. |
| AddButton / AddButtonGroup | Actions, optional keyboard shortcuts, and disabled states. |
| AddCustom(gui, config?) | Mount your existing GuiObject and keep its connections. |

## Component options {#component-options}

| Option | Behavior |
| --- | --- |
| Id: string? | A stable key for setters and Remove(). |
| ExpandedOnly: boolean? | Keep the row hidden until Expand(). |
| StatConfig.Color: Color3? | Override the value color for a stat. |
| CustomConfig.Size: Vector2? | Declared pixel size for custom content. Use it for scale-sized or unparented GUI. |
| CustomConfig.Interactive: boolean? | Override detection for this custom component. |

## A mixed context {#a-mixed-context}

```lua
context:SetTitle("AK-47")
    :SetDescription("A reliable rifle.")
    :AddStat("Damage", 35)
    :AddProgress("Durability", 0.8)
    :AddDivider()
    :AddKeybind("Inspect", Enum.KeyCode.E)
```

## Custom GUI ownership {#custom-gui-ownership}

AddCustom mounts the original GuiObject instead of cloning it, so existing callbacks continue to work. Remove() and Destroy() restore its parent, size, position, and anchor. If the original parent was destroyed, the object is left unparented. Keep one owner per custom GuiObject.

```lua
context:AddCustom(myPanel, { Id = "Preview", Size = Vector2.new(180, 60) })
```

!!! note

    Custom GUI is responsible for its own styling and internal layout. GuiButtons and TextBoxes present when added are detected as interactive. Use CustomConfig.Interactive for dynamic or unconventional controls.

## Sizing and text {#sizing-and-text}

Rows are measured using TextService with Enum.Font fonts, wrapping at the configured maximum. RichText is intentionally disabled in built-in text rows so measurement matches what is rendered. Use custom GUI when you need rich text, custom fonts, or a specialized layout.

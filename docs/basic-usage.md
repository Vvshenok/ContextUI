# Basic Usage

Start small, keep a reference, and add only the content your player needs.

## A compact hint {#a-compact-hint}

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)
local context = ContextUI.new(button):SetTitle("Open Shop"):Bind()
```

## Add more detail {#add-more-detail}

Title and Description are single named components. Calling their setters again updates those components in place.

```lua
context:SetTitle("General Store")
context:SetDescription("Tools, supplies, and equipment")
```

## Give updatable components an ID {#give-updatable-components-an-id}

Stats and progress bars default to their label as an ID. Other Add methods generate IDs unless you provide one. IDs must be unique within a context. Title, Description, Icon, and __Expansion are reserved by the matching convenience methods.

```lua
context:AddText("In stock", { Id = "Availability" })
context:SetText("Availability", "Sold out")
context:Remove("Availability")
```

## Show and hide manually {#show-and-hide-manually}

Omit the target for a manual context. Show(position) uses a screen-space anchor, applies the configured offset, and clamps the panel to the viewport. Manual contexts start docked. Pin() makes the lifetime explicit, including when the pointer leaves the surface.

```lua
local inspect = ContextUI.new()
    :SetTitle("Player statistics")
    :AddStat("Wins", 12)

inspect:Show(Vector2.new(240, 160)):Pin()
inspect:Hide()
inspect:Destroy()
```

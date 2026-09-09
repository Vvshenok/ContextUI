# Examples

Seven integration examples. Supply the target and application callbacks shown in each example; all use the same ContextUI module.

## Simple tooltip {#simple-tooltip}

A title-only context stays close to the measured text size.

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)

return function(button: GuiObject): ContextUI.Context
	return ContextUI.new(button):SetTitle("Open Shop"):Bind()
end
```

## Inventory item {#inventory-item}

Combine a title, stats, and an equip request callback.

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)

return function(slot: GuiObject, requestEquip: () -> ()): ContextUI.Context
	return ContextUI.new(slot)
		:SetTitle("Legendary Sword")
		:SetDescription("A well-balanced blade.")
		:AddStat("Damage", 75)
		:AddStat("Speed", 1.4)
		:AddButton("Equip", function(context) requestEquip(); context:Hide() end)
		:Bind()
end
```

## Weapon stats {#weapon-stats}

Reflect existing attributes without a polling loop.

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)

return function(slot: GuiObject, weapon: Instance): ContextUI.Context
	local context = ContextUI.new(slot):SetTitle(weapon.Name):AddStat("Ammo", ""):AddProgress("Durability", 1)
	context:Use({
		Name = "WeaponAttributes",
		Install = function(view)
			local function refresh()
				local ammo, capacity = weapon:GetAttribute("Ammo"), weapon:GetAttribute("Capacity")
				local durability = weapon:GetAttribute("Durability")
				view:SetStat("Ammo", tostring(ammo or 0) .. "/" .. tostring(capacity or 0))
				view:SetProgress("Durability", if typeof(durability) == "number" then durability else 1)
			end
			local connections = {
				weapon:GetAttributeChangedSignal("Ammo"):Connect(refresh),
				weapon:GetAttributeChangedSignal("Capacity"):Connect(refresh),
				weapon:GetAttributeChangedSignal("Durability"):Connect(refresh),
				weapon.Destroying:Connect(function() view:Destroy() end),
			}
			refresh()
			return function() for _, connection in connections do connection:Disconnect() end end
		end,
	})
	return context:Bind()
end
```

## Interactive buttons {#interactive-buttons}

Group actions, add a shortcut, and pin or close the surface.

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)

return function(slot: GuiObject, inspect: () -> (), compare: () -> ()): ContextUI.Context
	return ContextUI.new(slot)
		:SetTitle("Item actions")
		:AddButtonGroup({
			{ Text = "Inspect", Callback = function() inspect() end, KeyCode = Enum.KeyCode.E },
			{ Text = "Compare", Callback = function() compare() end },
		})
		:AddButton("Pin", function(context) context:Pin() end)
		:AddButton("Close", function(context) context:Hide() end)
		:Bind()
end
```

## Expandable panel {#expandable-panel}

Mark extra rows ExpandedOnly and add the More control.

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)

return function(slot: GuiObject): ContextUI.Context
	return ContextUI.new(slot)
		:SetTitle("Sword")
		:AddStat("Damage", 75)
		:AddText("Forged for long journeys.", { ExpandedOnly = true })
		:AddStat("Speed", 1.4, { ExpandedOnly = true })
		:AddProgress("Durability", 0.9, { ExpandedOnly = true })
		:AddSection("Effects", { ExpandedOnly = true })
		:AddText("+10% movement speed", { ExpandedOnly = true })
		:SetExpandable(true)
		:Bind()
end
```

## World object {#world-object}

Bind a queryable part, model, or an attachment on a part.

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)

return function(target: BasePart | Model | Attachment, openShop: () -> ()): ContextUI.Context
	return ContextUI.new(target)
		:SetTitle("Shop")
		:SetDescription("Browse the latest supplies.")
		:AddButton("Open", function(context) openShop(); context:Hide() end, { KeyCode = Enum.KeyCode.E })
		:Bind()
end
```

## Custom component {#custom-component}

Mount an existing GUI and preserve its event connections.

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)

return function(slot: GuiObject, customGui: GuiObject): ContextUI.Context
	return ContextUI.new(slot)
		:SetTitle("Your interface")
		:AddCustom(customGui, { Id = "DeveloperContent", Size = Vector2.new(180, 60) })
		:Bind()
end
```

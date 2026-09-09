--!strict
--[[
MIT License | Copyright (c) 2026 Interactive Studios
Credits: Interactive Studios | ContextUI example: Weapon stats
Documentation: https://vvshenok.github.io/ContextUI/examples/
Usage: require(path.WeaponStats)(slot, weapon); update the weapon's Ammo and Capacity attributes.
]]

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local ContextUI = require(game.ReplicatedStorage.ContextUI)

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
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

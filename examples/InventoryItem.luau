--!strict
--[[
MIT License | Copyright (c) 2026 Interactive Studios
Credits: Interactive Studios | ContextUI example: Inventory item
Documentation: https://vvshenok.github.io/ContextUI/examples/
Usage: require(path.InventoryItem)(slot, function() print("Equip requested") end)
]]

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local ContextUI = require(game.ReplicatedStorage.ContextUI)

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
return function(slot: GuiObject, requestEquip: () -> ()): ContextUI.Context
	return ContextUI.new(slot)
		:SetTitle("Legendary Sword")
		:SetDescription("A well-balanced blade.")
		:AddStat("Damage", 75)
		:AddStat("Speed", 1.4)
		:AddButton("Equip", function(context) requestEquip(); context:Hide() end)
		:Bind()
end

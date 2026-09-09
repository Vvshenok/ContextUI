--!strict
--[[
MIT License | Copyright (c) 2026 Interactive Studios
Credits: Interactive Studios | ContextUI example: Expandable panel
Documentation: https://vvshenok.github.io/ContextUI/examples/
Usage: require(path.ExpandablePanel)(slot)
]]

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local ContextUI = require(game.ReplicatedStorage.ContextUI)

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
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

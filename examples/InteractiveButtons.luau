--!strict
--[[
MIT License | Copyright (c) 2026 Interactive Studios
Credits: Interactive Studios | ContextUI example: Interactive buttons
Documentation: https://vvshenok.github.io/ContextUI/examples/
Usage: require(path.InteractiveButtons)(slot, inspect, compare)
]]

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local ContextUI = require(game.ReplicatedStorage.ContextUI)

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
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
